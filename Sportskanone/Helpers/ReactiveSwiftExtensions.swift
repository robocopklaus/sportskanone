//
//  ReactiveSwiftExtensions.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 01.04.17.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import ReactiveSwift

extension SignalProducer where Value: Sequence {
  
  typealias T = Value.Iterator.Element
  
  func values() -> SignalProducer<T, Error> {
    return self.flatMap(.latest) { (values) -> SignalProducer<T, Error> in
      return SignalProducer<T, Error>(values)
    }
  }

}
