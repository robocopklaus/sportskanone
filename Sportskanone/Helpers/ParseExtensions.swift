//
//  ParseExtensions.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 23/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import Parse
import ReactiveSwift
import Result

extension PFQuery {
  
  static func maxLimit() -> Int {
    return 1000
  }
  
}

extension Reactive where Base: PFObject {
  
  // MARK: - Saving Objects
  
  func save() -> SignalProducer<Bool, AnyError> {
    return SignalProducer { [base = self.base] observer, _ in
      base.saveInBackground { success, error in
        guard let error = error else {
          observer.send(value: success)
          observer.sendCompleted()
          return
        }
        observer.send(error: AnyError(error))
      }
    }
  }
  
  func saveEventually() -> SignalProducer<Bool, AnyError> {
    return SignalProducer { [base = self.base] observer, _ in
      base.saveEventually { success, error in
        guard let error = error else {
          observer.send(value: success)
          observer.sendCompleted()
          return
        }
        observer.send(error: AnyError(error))
      }
    }
  }
    
}

extension Reactive where Base: PFUser {
  
  // MARK: - Creating a New User
  
  func signUp() -> SignalProducer<Bool, AnyError> {
    return SignalProducer { [base = self.base] observer, _ in
      base.signUpInBackground { success, error in
        guard let error = error else {
          observer.send(value: success)
          observer.sendCompleted()
          return
        }
        observer.send(error: AnyError(error))
      }
    }
  }
  
}
