//
//  HealthAccessViewController.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 27/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

final class HealthAccessViewController<Store: StoreType>: UIViewController {
  
  private let verticalStackView = UIStackView()
  private let logoImageView = UIImageView()
  private let titleLabel = HeadlineLabel()
  private let textLabel = TextLabel()
  private let continueButton = BorderButton(type: .system)

  private let (lifetime, token) = Lifetime.make()
  
  private let viewModel: HealthAccessViewModel<Store>
  
  // MARK: - Object Life Cycle
  
  init(viewModel: HealthAccessViewModel<Store>) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View Life Cycle
  
  override func loadView() {
    let view = UIView()
    view.addSubview(verticalStackView)
    
    verticalStackView.addArrangedSubview(logoImageView)
    verticalStackView.addArrangedSubview(UIView())
    verticalStackView.addArrangedSubview(UIView())
    verticalStackView.addArrangedSubview(titleLabel)
    verticalStackView.addArrangedSubview(textLabel)
    verticalStackView.addArrangedSubview(UIView())
    verticalStackView.addArrangedSubview(UIView())
    verticalStackView.addArrangedSubview(UIView())
    verticalStackView.addArrangedSubview(continueButton)
    
    self.view = view
    
    setupConstraints()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    verticalStackView.axis = .vertical
    verticalStackView.alignment = .center
    verticalStackView.spacing = 10
    
    logoImageView.contentMode = .scaleAspectFit
    logoImageView.image = UIImage(named: viewModel.logoName)
    
    titleLabel.numberOfLines = 0
    titleLabel.lineBreakMode = .byWordWrapping
    
    textLabel.lineBreakMode = .byWordWrapping
    textLabel.numberOfLines = 0
    
    viewModel.healthAuthorizationAction.errors
      .take(during: lifetime)
      .observe(on: UIScheduler())
      .observeValues { [weak self] error in
        self?.presentError(error: error, title: "Error.Default.Title".localized)
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
    
    titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
    
    textLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
  }
  
  // MARK: - Reactive Bindings
  
  func setupBindings() {
    titleLabel.reactive.text <~ viewModel.title
    textLabel.reactive.text <~ viewModel.text
    
    continueButton.reactive.pressed = CocoaAction(viewModel.healthAuthorizationAction)
    continueButton.reactive.title(for: .normal) <~ viewModel.continueButtonTitle
  }
  
}
