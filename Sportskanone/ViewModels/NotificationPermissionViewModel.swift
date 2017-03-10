//
//  NotificationPermissionViewModel.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 28.03.17.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import ReactiveSwift
import Result

final class NotificationPermissionViewModel<Store: StoreType> {
  
  // Outputs
  let title = Property(value: "Notification.Permission.Title".localized)
  let text = Property(value: "Notification.Permission.Text".localized)
  let continueButtonTitle = Property(value: "Notification.Permission.Button.Continue.Title".localized.uppercased())
  let logoName = "Notification"
  
  // Actions
  lazy var notificationRegistrationAction: Action<Void, Void, AnyError> = { [unowned self] in
    return Action { _ in
      return self.store.requestNotificationAuthorization().map { _ in }
    }
  }()
  
  fileprivate let store: Store
  
  init(store: Store) {
    self.store = store
  }
  
}
