//
//  CoordinatorViewModel.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 25/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import ReactiveSwift
import Result

struct CoordinatorViewModel<Store: StoreType> {

  enum Screen {

    case ranking(RankingViewModel<Store>)
    case signUp(SignUpViewModel<Store>)
    case healthAccess(HealthAccessViewModel<Store>)
    case healthDataSync(HealthDataSyncViewModel<Store>)
    case notificationPermission(NotificationPermissionViewModel<Store>)
    
  }

  // Outputs
  let currentScreen: Property<Screen>

  fileprivate let store: Store

  init(store: Store) {
    self.store = store

    let screen = SignalProducer
                  .combineLatest(store.isUserAuthenticated.producer,
                    store.isHealthAccessDetermined.producer,
                    store.isHealthDataSynced.producer,
                    store.isNotificationAuthorizationDetermined.producer
                  )
                  .map { isUserAuthenticated, isHealthAccessAuthorized, isHealthDataSynced, isNotificationAuthorizationDetermined -> Screen in
                    if !isUserAuthenticated { return .signUp(SignUpViewModel(store: store)) }
                    if !isHealthAccessAuthorized { return .healthAccess(HealthAccessViewModel(store: store)) }
                    if !isHealthDataSynced { return .healthDataSync(HealthDataSyncViewModel(store: store)) }
                    if !isNotificationAuthorizationDetermined { return .notificationPermission(NotificationPermissionViewModel(store: store)) }
                    
                    return .ranking(RankingViewModel(store: store))
                  }
    
    currentScreen = Property(initial: .ranking(RankingViewModel(store: store)), then: screen)
  }

}
