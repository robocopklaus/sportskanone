//
//  HealthAccessViewModel.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 27/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import ReactiveSwift
import Result

final class HealthAccessViewModel<Store: StoreType> {
  
  // Outputs
  let title = Property(value: "Health.Access.Title".localized)
  let text = Property(value: "Health.Access.Text".localized)
  let continueButtonTitle = Property(value: "Health.Access.Button.Continue.Title".localized.uppercased())
  let logoName = "Muscle"
  
  // Actions
  lazy var healthAuthorizationAction: Action<Void, Void, AnyError> = { [unowned self] in
    return Action { _ in
      return self.store.requestHealthAccessAuthorization()
    }
  }()
  
  fileprivate let store: Store
  
  init(store: Store) {
    self.store = store
  }
  
}
