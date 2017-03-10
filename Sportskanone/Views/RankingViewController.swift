//
//  RankingViewController.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 28.03.17.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

final class RankingViewController<Store: StoreType>: UITableViewController {

  fileprivate let viewModel: RankingViewModel<Store>
  fileprivate let cellIdentifitier = "cell"
  
  private let (lifetime, token) = Lifetime.make()

  // MARK: - Object Life Cycle

  init(viewModel: RankingViewModel<Store>) {
    self.viewModel = viewModel
    super.init(style: .grouped)

    title = viewModel.navigationBarTitle.value

    tabBarItem.image = UIImage(named: viewModel.tabBarItemImageName)
    tabBarItem.reactive.title <~ viewModel.tabBarItemTitle
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 60
    tableView.register(RankingTableViewCell.self, forCellReuseIdentifier: cellIdentifitier)

    refreshControl = UIRefreshControl()

    viewModel.fetchSummariesAction.errors
      .take(during: lifetime)
      .observe(on: UIScheduler())
      .observeValues { [weak self] error in
        self?.presentError(error: error.error, title: "Error.Default.Title".localized)
      }

    // TODO: Refactor this ugly solution
    NotificationCenter.default.reactive.notifications(forName: Notification.Name.UIApplicationDidBecomeActive)
      .take(during: lifetime)
      .observeValues { [weak self] _ in
        self?.viewModel.fetchSummariesAction.apply().start()
      }
    
    viewModel.fetchSummariesAction.values
      .take(during: lifetime)
      .observe(on: UIScheduler())
      .observeValues { [weak self] _ in
        self?.title = self?.viewModel.navigationBarTitle.value
        self?.tableView.reloadData()
      }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    setupBindings()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // TODO: Refactor this ugly solution
    viewModel.fetchSummariesAction.apply().start()
  }

  // MARK: - Reactive Bindings

  func setupBindings() {
    refreshControl?.reactive.refresh = CocoaAction(viewModel.fetchSummariesAction)
  }
  
  // MARK: - TableViewDataSource

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.activitySummaries.value.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifitier, for: indexPath) as! RankingTableViewCell
    cell.viewModel = viewModel.cellViewModel(atIndexPath: indexPath)
    
    return cell
  }

  // MARK: - TableViewDataDelegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }

}
