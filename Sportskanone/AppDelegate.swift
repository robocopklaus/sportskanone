//
//  AppDelegate.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 22/02/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import UIKit
import HealthKit
import ReactiveSwift
import ReactiveCocoa
import Result
import Parse
import HockeySDK

@UIApplicationMain
final class AppDelegate: UIResponder {

  var window: UIWindow?
    
  fileprivate let healthStore = HKHealthStore()
  fileprivate lazy var store: SportskanoneStore = { [unowned self] in
    return SportskanoneStore(healthStore: self.healthStore)
  }()

}

// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    // Parse
    Parse.initialize(with: ParseClientConfiguration {
      $0.applicationId = Secrets.Parse.applicationID
      $0.clientKey = Secrets.Parse.clientKey
      $0.server = Secrets.Parse.serverURL
    })
    PFActivitySummary.registerSubclass()
    
    // Hockey
    let hockeyManager = BITHockeyManager.shared()
    hockeyManager.configure(withIdentifier: Secrets.Hockey.applicationID)
    hockeyManager.updateManager.isShowingDirectInstallOption = true
    hockeyManager.crashManager.crashManagerStatus = .autoSend
    hockeyManager.start()
    
    // Model
    let coordinatorViewModel = CoordinatorViewModel(store: store)
    
    // View
    let window = UIWindow(frame: UIScreen.main.bounds)
    
    window.rootViewController = CoordinatorViewController(viewModel: coordinatorViewModel)
    window.makeKeyAndVisible()

    self.window = window
    
    // Styling
    applyTheme(window: window)

    // Notifications
    application.registerForRemoteNotifications()
    
    return true
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    store.registerForRemoteNotifications(withDeviceToken: deviceToken).start()
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    PFPush.handle(userInfo)
  }

}

private extension AppDelegate {
  
  func applyTheme(window: UIWindow) {
    let tintColor: UIColor = .skGreen
    
    window.tintColor = tintColor
    
    BorderButton.appearance().titleFont = .skTextButton
    BorderButton.appearance().shadowColor = .skGray
    BorderButton.appearance().shadowOffset = CGSize(width: 0, height: 0)
    BorderButton.appearance().shadowRadius = 6
    BorderButton.appearance().shadowOpacity = 0.8
    
    TextLabel.appearance().fontColor = .skGray
    TextLabel.appearance().textFont = .skText
    
    HeadlineLabel.appearance().textAlignment = .center
    HeadlineLabel.appearance().fontColor = .skBlack
    HeadlineLabel.appearance().textFont = .skHeadline
    
    BorderButton.appearance().backgroundColor = tintColor
    BorderButton.appearance().tintColor = .white
    BorderButton.appearance().contentEdgeInsets = UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20)
  }
  
}
