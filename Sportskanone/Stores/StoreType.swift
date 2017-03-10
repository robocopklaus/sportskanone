//
//  StoreType.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 26/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import ReactiveSwift
import Result

// TODO: Error type
enum SportskanoneError: Error {

  case unknownError
  case userAuthorizationError

}

protocol StoreType {

  associatedtype ActivitySummary: ActivitySummaryType
  //associatedtype User: UserType

  // MARK: - Notifications

  var isNotificationAuthorizationDetermined: Property<Bool> { get }

  func requestNotificationAuthorization() -> SignalProducer<Bool, AnyError>
  func registerForRemoteNotifications(withDeviceToken token: Data) -> SignalProducer<Bool, AnyError>

  // MARK: - Health

  var isHealthAccessDetermined: Property<Bool> { get }
  var isHealthDataSynced: Property<Bool> { get }

  func requestHealthAccessAuthorization() -> SignalProducer<Void, AnyError>
  func syncHealthData() -> SignalProducer<Void, AnyError>
  func syncDailyActiveCalorieStatistics(fromDate startDate: Date?, to endDate: Date) -> SignalProducer<Bool, AnyError>

  // MARK: - User

  var isUserAuthenticated: Property<Bool> { get }
  var currentUser: Property<ActivitySummary.User?> { get }

  func signUpUser(withName name: String) -> SignalProducer<Void, AnyError>

  // MARK: - Activity Summaries

  func requestActivitySummaries(forUser user: ActivitySummary.User?, from startDate: Date?, to endDate: Date, sortDescriptor: NSSortDescriptor?) -> SignalProducer<[ActivitySummary], AnyError>

}
