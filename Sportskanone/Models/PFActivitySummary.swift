//
//  PFActivitySummary.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 23/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import Parse
import ReactiveCocoa
import ReactiveSwift
import Result

final class PFActivitySummary: PFObject {

  @NSManaged var user: PFUser
  @NSManaged var date: Date
  @NSManaged var activeEnergyBurned: Int

}

extension PFActivitySummary: ActivitySummaryType {
  
  var username: String {
    return user.username ?? "Unknown"
  }
  
}

extension PFActivitySummary: PFSubclassing {

  static func parseClassName() -> String {
    return "ActivitySummary"
  }
  
}

extension PFActivitySummary {
  
  convenience init(date: Date, activeEnergyBurned: Int) {
    self.init()
    self.date = date
    self.activeEnergyBurned = activeEnergyBurned
  }
  
}

extension Reactive where Base: PFQuery<PFActivitySummary> {
  
  func find() -> SignalProducer<[PFActivitySummary], AnyError> {
    return SignalProducer { [base = self.base] sink, _ in
      base.findObjectsInBackground(block: { summaries, error in
        guard let error = error else {
          guard let activiySummaries = summaries else {
            sink.send(value: [])
            sink.sendCompleted()
            return
          }
          sink.send(value: activiySummaries)
          sink.sendCompleted()
          return
        }
        sink.send(error: AnyError(error))
      })
    }
  }
  
}
