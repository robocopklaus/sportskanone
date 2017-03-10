//
//  Localizator.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 05/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import Foundation

final class Localizator {

  static let shared = Localizator()

  lazy var localizableDictionary: NSDictionary = {
    guard let path = Bundle.main.path(forResource: "Localizable", ofType: "plist") else {
      fatalError("Localizable file not found")
    }
    return NSDictionary(contentsOfFile: path)!
  }()

  func localize(string: String) -> String {
    guard let localizedString = (localizableDictionary.value(forKey: string) as? NSDictionary)?.value(forKey: "value") as? String else {
      assertionFailure("Missing translation for: \(string)")
      return ""
    }
    return localizedString
  }

}

extension String {

  var localized: String {
    return Localizator.shared.localize(string: self)
  }

}
