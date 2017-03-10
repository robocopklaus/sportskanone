//
//  FoundationExtensions.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 22/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import Foundation

extension Date {

  static func today() -> Date {
    return self.init().beginningOfDay()
  }
  
  func dayBefore() -> Date {
    return Calendar.autoupdatingCurrent.date(byAdding: .day, value: -1, to: self)!.beginningOfDay()
  }

  func dayAfter() -> Date {
    return Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: self)!.beginningOfDay()
  }
  
  func beginningOfDay() -> Date {
    let calendar = Calendar.autoupdatingCurrent
    return calendar.date(from: calendar.dateComponents([.year, .month, .day], from: self))!
  }

  func toString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    
    return dateFormatter.string(from: self)
  }
  
}
