//
//  SignUpViewController.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 25/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

final class SignUpViewController<Store: StoreType>: UIViewController, UITextFieldDelegate {
  
  private let verticalStackView = UIStackView()
  private let logoImageView = UIImageView()
  private let horizontalStackView = UIStackView()
  private let greetingLabel = HeadlineLabel()
  private let textLabel = TextLabel()
  private let usernameTextField = TextField()
  private let submitButton = BorderButton(type: .system)
  
  private let (lifetime, token) = Lifetime.make()
  
  private let viewModel: SignUpViewModel<Store>
  
  // MARK: - Object Life Cycle
  
  init(viewModel: SignUpViewModel<Store>) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View Life Cycle
  
  override func loadView() {
    let view = UIView()
    view.backgroundColor = .white
    view.addSubview(verticalStackView)
    
    verticalStackView.addArrangedSubview(logoImageView)
    verticalStackView.addArrangedSubview(UIView())
    verticalStackView.addArrangedSubview(UIView())
    verticalStackView.addArrangedSubview(horizontalStackView)
    horizontalStackView.addArrangedSubview(greetingLabel); horizontalStackView.addArrangedSubview(usernameTextField)
    verticalStackView.addArrangedSubview(textLabel)
    verticalStackView.addArrangedSubview(UIView())
    verticalStackView.addArrangedSubview(UIView())
    verticalStackView.addArrangedSubview(UIView())
    verticalStackView.addArrangedSubview(submitButton)
    
    self.view = view
    
    setupConstraints()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // TODO: RACtify
    usernameTextField.delegate = self
    
    verticalStackView.axis = .vertical
    verticalStackView.alignment = .center
    verticalStackView.spacing = 10
    
    logoImageView.contentMode = .scaleAspectFit
    logoImageView.image = UIImage(named: viewModel.logoName)
    
    horizontalStackView.axis = .horizontal
    horizontalStackView.alignment = .center
    horizontalStackView.spacing = 4
    
    textLabel.lineBreakMode = .byWordWrapping
    textLabel.numberOfLines = 0

    logoImageView.image = UIImage(named: viewModel.logoName)
    
    viewModel.signUpAction.errors
      .take(during: lifetime)
      .observe(on: UIScheduler())
      .observeValues { [weak self] error in
        self?.presentError(error: error.error, title: "Error.Default.Title".localized)
      }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setupBindings()
  }
  
  // MARK: - Styling
  
  func setupConstraints() {
    verticalStackView.translatesAutoresizingMaskIntoConstraints = false
    verticalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
    logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor).isActive = true
    logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
    
    usernameTextField.widthAnchor.constraint(equalToConstant: 160).isActive = true
    
    textLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
  }
  
  // MARK: - Reactive Bindings
  
  func setupBindings() {
    greetingLabel.reactive.text <~ viewModel.greeting
    
    viewModel.username <~ usernameTextField.reactive.continuousTextValues.skipNil()
    usernameTextField.reactive.text <~ viewModel.validatedUsername
    usernameTextField.placeholder = viewModel.usernamePlaceholder.value
    
    submitButton.reactive.pressed = CocoaAction(viewModel.signUpAction)
    submitButton.reactive.title(for: .normal) <~ viewModel.signUpButtonTitle
    submitButton.reactive.isEnabled <~ viewModel.signUpAction.isEnabled
    
    textLabel.reactive.text <~ viewModel.text
  }
  
  // MARK: - UITextFieldDelegate

  // TODO: RACtify
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}
