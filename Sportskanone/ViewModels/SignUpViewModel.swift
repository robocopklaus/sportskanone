//
//  SignUpViewModel.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 25/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import ReactiveSwift
import ReactiveCocoa
import Result

final class SignUpViewModel<Store: StoreType> {
  
  // Inputs
  let username = MutableProperty<String>("")
  
  // Outputs
  let greeting = Property(value: "SignUp.IntroLabel.Text".localized)
  let usernamePlaceholder = Property(value: "SignUp.Username.Placeholder".localized)
  let text = Property(value: "SignUp.Intro.Text".localized)
  let signUpButtonTitle = Property(value: "SignUp.Button.Submit.Title".localized.uppercased())
  let logoName = "Logo"
  let validatedUsername: Property<String>
  let isUsernameValid: Property<Bool>
  
  // Actions
  lazy var signUpAction: Action<Void, Void, AnyError> = {
    return Action(enabledIf: self.isUsernameValid, { [unowned self] _ in
      return self.store.signUpUser(withName: self.validatedUsername.value)
    })
  }()
  
  fileprivate let store: Store
  
  init(store: Store) {
    self.store = store
    
    let validation = username.signal
                      .map { $0.trimmingCharacters(in: CharacterSet.letters.inverted) }
                      .map { $0.characters.count < 9 ? $0 : $0.substring(to: $0.index($0.startIndex, offsetBy: 9)) }
    
    validatedUsername = Property(initial: "", then:validation)
    isUsernameValid = Property(initial: false, then: validatedUsername.signal.map { $0.characters.count > 2 })
  }
  
}
