//
//  SportskanoneStore.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 24/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import Parse
import HealthKit
import ReactiveCocoa
import ReactiveSwift
import Result
import UserNotifications

struct SportskanoneStore: StoreType {

  typealias ActivitySummary = PFActivitySummary
  
  let isUserAuthenticated: Property<Bool>
  let isHealthAccessDetermined: Property<Bool>
  let isHealthDataSynced: Property<Bool>
  let isNotificationAuthorizationDetermined: Property<Bool>
  let currentUser: Property<ActivitySummary.User?>
  
  fileprivate let healthStore: HKHealthStore
  fileprivate let user: MutableProperty<ActivitySummary.User?>
  fileprivate let healthAccessDetermined: MutableProperty<Bool>
  fileprivate let healthDataSynced: MutableProperty<Bool>
  fileprivate let notificationAuthorizationDetermined = MutableProperty(false)
  fileprivate let healthSampleTypes: [HKSampleType] = [HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!]
  fileprivate let notificationAuthorizationOptions: UNAuthorizationOptions = [.badge, .sound, .alert]
  
  init(healthStore: HKHealthStore) {
    self.healthStore = healthStore
    
    // TODO: Refactor
    healthAccessDetermined = MutableProperty(healthSampleTypes
      .map { healthStore.authorizationStatus(for: $0) }
      .map { $0 != .notDetermined }
      .reduce(true) { $0 && $1 }
    )

    // TODO: Refactor user defaults solution
    let userDefaults = UserDefaults.standard
    healthDataSynced = MutableProperty(userDefaults.bool(forKey: "isHealthDataSynced"))
    
    healthDataSynced
      .signal
      .observeValues { userDefaults.set($0, forKey: "isHealthDataSynced"); userDefaults.synchronize() }
    
    notificationAuthorizationDetermined <~ UNUserNotificationCenter.current().reactive.getNotificationSettings()
      .map { $0.authorizationStatus != .notDetermined }
    
    user = MutableProperty(PFUser.current())
    currentUser = Property(capturing: user)
    
    isUserAuthenticated = user.map { $0?.isAuthenticated ?? false }
    isHealthAccessDetermined = Property(capturing: healthAccessDetermined)
    isNotificationAuthorizationDetermined = Property(capturing: notificationAuthorizationDetermined)
    isHealthDataSynced = Property(capturing: healthDataSynced)
    
    // TODO: Refactor
    observeHealthActivity().start()
  }

  // MARK: - Notifications
  
  func requestNotificationAuthorization() -> SignalProducer<Bool, AnyError> {
    return UNUserNotificationCenter.current().reactive.requestAuthorization(options: notificationAuthorizationOptions)
            .on(completed: {
              self.notificationAuthorizationDetermined <~ UNUserNotificationCenter.current().reactive.getNotificationSettings()
                .map { $0.authorizationStatus != .notDetermined }
            })
  }
  
  func registerForRemoteNotifications(withDeviceToken token: Data) -> SignalProducer<Bool, AnyError> {
    guard let installation = PFInstallation.current() else {
      fatalError("Installation must not be nil")
    }
    installation.setDeviceTokenFrom(token)
    installation.addUniqueObject("sportskanoneOfTheDay", forKey: "channels")
    
    return installation.reactive.saveEventually()
  }
  
  // MARK: - Health
  
  func requestHealthAccessAuthorization() -> SignalProducer<Void, AnyError> {
    return healthStore.reactive.requestAuthorization(toShare: nil, read: Set(healthSampleTypes))
            .on(completed: {
              self.healthAccessDetermined.value = self.healthSampleTypes
                .map { self.healthStore.authorizationStatus(for: $0) }
                .map { $0 != .notDetermined }
                .reduce(true) { $0 && $1 }
            })
  }
  
  func syncHealthData() -> SignalProducer<Void, AnyError> {
    // TODO: Refactor error generation
    guard let user = currentUser.value else {
      return SignalProducer<Void, AnyError>(error: AnyError(SportskanoneError.userAuthorizationError))
    }
    return self.syncDailyActiveCalorieStatistics(for: user, endDate: Date())
            .map { _ in }
            .on(completed: {
              self.healthDataSynced.value = true
            })
  }
  
  func syncDailyActiveCalorieStatistics(fromDate startDate: Date? = nil, to endDate: Date) -> SignalProducer<Bool, AnyError> {
    guard let user = currentUser.value else {
      return SignalProducer<Bool, AnyError>(error: AnyError(SportskanoneError.userAuthorizationError))
    }
    return syncDailyActiveCalorieStatistics(for: user, startDate: startDate, endDate: endDate)
  }
  
  // MARK: - User
  
  func signUpUser(withName name: String) -> SignalProducer<Void, AnyError> {
    let user = PFUser()
    user.username = name
    user.password = name
    
    return user.reactive.signUp()
            .map { _ in }
            .on(completed: {
              self.user.value = user
            })
  }
  
  // MARK: - Activity Summaries
  
  func requestActivitySummaries(forUser user: ActivitySummary.User? = nil, from startDate: Date? = nil, to endDate: Date, sortDescriptor: NSSortDescriptor? = nil) -> SignalProducer<[PFActivitySummary], AnyError> {
    let activityQuery = PFActivitySummary.query() as! PFQuery<PFActivitySummary>
    activityQuery.limit = PFQuery.maxLimit()
    activityQuery.includeKey("user")
    
    if let sortDescriptor = sortDescriptor {
      activityQuery.order(by: sortDescriptor)
    }
    
    if let startDate = startDate {
      activityQuery.whereKey("date", greaterThanOrEqualTo: startDate.beginningOfDay())
    }
    activityQuery.whereKey("date", lessThanOrEqualTo: endDate.beginningOfDay())
    
    if let user = user {
      activityQuery.whereKey("user", matchesQuery: user.usernameQuery)
    }
    
    return activityQuery.reactive.find()
  }
  
}

// MARK: - Private

private extension SportskanoneStore {

  func syncDailyActiveCalorieStatistics(for user: PFUser, startDate: Date? = nil, endDate: Date) -> SignalProducer<Bool, AnyError> {
    return healthStore.reactive.fetchDailyActiveCalorieSumStatistics(from: startDate, to: endDate)
            .flatMap(.merge) { statistics -> SignalProducer<Bool, AnyError> in
              return self.fetchRemoteActivitySummary(for: statistics.startDate, user: user)
                .flatMap(.latest) { remoteSummary -> SignalProducer<Bool, AnyError> in
                  let kiloCalories = Int(statistics.sumQuantity()!.doubleValue(for: HKUnit.kilocalorie()))

                  if let remoteSummary = remoteSummary { // Update activity summary
                    remoteSummary.activeEnergyBurned = kiloCalories
                    return remoteSummary.reactive.save()
                  } else { // Create new activity summary
                    let activitySummary = PFActivitySummary(date: statistics.startDate, activeEnergyBurned: kiloCalories)
                    return activitySummary.reactive.save()
                  }
                }
            }
            .reduce(true) { $0 && $1 }
  }
  
  func observeHealthActivity() -> SignalProducer<Bool, AnyError> {
    return isHealthAccessDetermined.producer
            .filter { $0 }
            .flatMap(.merge) { _ -> SignalProducer<PFUser, NoError> in
              return self.user.producer.skipNil()
            }
            .flatMap(.merge) { user -> SignalProducer<Bool, AnyError> in
              return self.observeHealthActivity(forTypes: self.healthSampleTypes, user: user)
            }
  }
  
  func observeHealthActivity(forTypes types: [HKSampleType], user: PFUser) -> SignalProducer<Bool, AnyError> {
    return SignalProducer<HKSampleType, NoError>(types)
            .flatMap(.merge) { sampleType -> SignalProducer<Bool, AnyError> in
              return self.healthStore.reactive.enableBackgroundDelivery(for: sampleType, frequency: .immediate)
                .filter { $0 }
                .on(value: { _ in
                  let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { _, completionHandler, _ in
                    switch sampleType {
                    case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!:
                      let now = Date()
                      self.syncDailyActiveCalorieStatistics(for: user, startDate: now.dayBefore(), endDate: now)
                        .start { _ in
                          completionHandler()
                        }
                    default:
                      completionHandler()
                    }
                  }
                  self.healthStore.execute(query)
                })
            }
  }

  // MARK: - Queries
  
  func fetchRemoteActivitySummary(for date: Date, user: PFUser) -> SignalProducer<PFActivitySummary?, AnyError> {
    let activityQuery = PFActivitySummary.query() as! PFQuery<PFActivitySummary>
    activityQuery.limit = 1
    activityQuery.includeKey("user")
    activityQuery.whereKey("user", matchesQuery: user.usernameQuery)
    activityQuery.whereKey("date", greaterThanOrEqualTo: date.beginningOfDay())
    activityQuery.whereKey("date", lessThan: date.beginningOfDay().dayAfter())
    
    return activityQuery.reactive.find().map { $0.first }
  }
  
}
