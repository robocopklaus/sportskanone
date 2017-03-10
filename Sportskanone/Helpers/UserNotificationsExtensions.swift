//
//  UserNotificationsExtensions.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 22/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import UserNotifications
import ReactiveSwift
import Result

extension Reactive where Base: UNUserNotificationCenter {

  // MARK: - Managing Settings and Authorization

  func requestAuthorization(options: UNAuthorizationOptions = []) -> SignalProducer<Bool, AnyError> {
    return SignalProducer { [base = self.base] observer, _ in
      base.requestAuthorization(options: options) { granted, error in
        guard let error = error else {
          observer.send(value: granted)
          observer.sendCompleted()
          return
        }
        observer.send(error: AnyError(error))
      }
    }
  }

  func getNotificationSettings() -> SignalProducer<UNNotificationSettings, NoError> {
    return SignalProducer { [base = self.base] observer, _ in
      base.getNotificationSettings(completionHandler: { settings in
        observer.send(value: settings)
        observer.sendCompleted()
      })
    }
  }
  
  // MARK: - Managing Notification Requests

  func add(_ request: UNNotificationRequest) -> SignalProducer<Void, AnyError> {
    return SignalProducer { [base = self.base] observer, _ in
      base.add(request) { error in
        guard let error = error else {
          observer.sendCompleted()
          return
        }
        observer.send(error: AnyError(error))                
      }
    }
  }

}
