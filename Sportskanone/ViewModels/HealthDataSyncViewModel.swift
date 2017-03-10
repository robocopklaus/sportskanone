//
//  HealthDataSyncViewModel.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 28.03.17.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import ReactiveSwift
import Result

final class HealthDataSyncViewModel<Store: StoreType> {

  // Outputs
  let title = Property(value: "Health.DataSync.Title".localized)
  let text = Property(value: "Health.DataSync.Text".localized)
  let logoName = "Sync"
  
  // Actions
  lazy var healthDataSyncAction: Action<Void, Void, AnyError> = { [unowned self] in
    return Action { _ in
      return self.store.syncHealthData()
    }
  }()

  fileprivate let store: Store

  init(store: Store) {
    self.store = store
  }

}
