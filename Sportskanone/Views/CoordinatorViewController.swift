//
//  CoordinatorViewController.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 25/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

final class CoordinatorViewController<Store: StoreType>: UIViewController {

  fileprivate let mainTabBarController = UITabBarController()
  fileprivate let onboardingNavigationController = UINavigationController()
  
  private let (lifetime, token) = Lifetime.make()
  
  private let viewModel: CoordinatorViewModel<Store>
  
  // MARK: - Object Life Cycle
  
  init(viewModel: CoordinatorViewModel<Store>) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    onboardingNavigationController.setNavigationBarHidden(true, animated: false)
    
    viewModel.currentScreen.producer
      .take(during: lifetime)
      .observe(on: UIScheduler())
      .startWithValues { [weak self] screen in
        self?.show(screen: screen)
      }
  }

}

fileprivate extension CoordinatorViewController {

  // TODO: Refactor this ugly implementation
  func show(screen: CoordinatorViewModel<Store>.Screen) {
    var isOnboarding = false
    
    switch screen {
    case .signUp(let viewModel):
      onboardingNavigationController.pushViewController(SignUpViewController(viewModel: viewModel), animated: true)
      isOnboarding = true
    case .healthAccess(let viewModel):
      onboardingNavigationController.pushViewController(HealthAccessViewController(viewModel: viewModel), animated: true)
      isOnboarding = true
    case .healthDataSync(let viewModel):
      onboardingNavigationController.pushViewController(HealthDataSyncViewController(viewModel: viewModel), animated: true)
      isOnboarding = true
    case .notificationPermission(let viewModel):
      onboardingNavigationController.pushViewController(NotificationPermissionViewController(viewModel: viewModel), animated: true)
      isOnboarding = true
    case .ranking(let viewModel):
      mainTabBarController.viewControllers = [UINavigationController(rootViewController: RankingViewController(viewModel: viewModel))]
    }
    
    if isOnboarding {
      mainTabBarController.willMove(toParentViewController: nil)
      mainTabBarController.view.removeFromSuperview()
      mainTabBarController.removeFromParentViewController()
      
      if !childViewControllers.contains(onboardingNavigationController) {
        addChildViewController(onboardingNavigationController)
        onboardingNavigationController.view.frame = view.bounds
        view.addSubview(onboardingNavigationController.view)
        onboardingNavigationController.didMove(toParentViewController: self)
      }
    } else {
      onboardingNavigationController.willMove(toParentViewController: nil)
      onboardingNavigationController.view.removeFromSuperview()
      onboardingNavigationController.removeFromParentViewController()
      
      if !childViewControllers.contains(mainTabBarController) {
        addChildViewController(mainTabBarController)
        mainTabBarController.view.frame = view.bounds
        view.addSubview(mainTabBarController.view)
        mainTabBarController.didMove(toParentViewController: self)
      }
    }
  }
  
}
