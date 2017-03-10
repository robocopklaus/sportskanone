//
//  ActivitySummaryType.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 29.03.17.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import Foundation

protocol ActivitySummaryType {

  associatedtype User: UserType
  typealias Calories = Int

  var date: Date { get }
  var updatedAt: Date? { get }
  var activeEnergyBurned: Calories { get }
  var user: User { get }

}
