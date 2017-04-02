//
//  RankingViewModel.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 28.03.17.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import ReactiveSwift
import ReactiveCocoa
import Result
import UIKit

final class RankingViewModel<Store: StoreType> {

  // Outputs
  let tabBarItemImageName = "Podium"
  let tabBarItemTitle = Property(value: Bundle.main.infoDictionary![String(kCFBundleNameKey)] as! String)
  let activitySummaries: Property<[(Store.ActivitySummary, Int)]>
  let navigationBarTitle: Property<String>
  let currentUsername: Property<String>
  
  // Actions
  let fetchSummariesAction: Action<Void, [(Store.ActivitySummary, Int)], AnyError>

  fileprivate let store: Store
  fileprivate let currentDate = MutableProperty(Date())

  init(store: Store) {
    self.store = store

    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .none
    dateFormatter.dateStyle = .full
    
    navigationBarTitle = Property(capturing: currentDate.map { dateFormatter.string(from:$0) })

    fetchSummariesAction = Action { _ in
      return store.syncDailyActiveCalorieStatistics(fromDate: Date.today(), to: Date())
              .then(store.requestActivitySummaries(forUser: nil, from: Date.today(), to: Date(), sortDescriptor: NSSortDescriptor(key: "activeEnergyBurned", ascending: false))
                      .values()
                      .flatMap(.merge) { summary -> SignalProducer<(Store.ActivitySummary, Int), AnyError> in
                        return store.requestActivitySummaries(forUser: summary.user, from: nil, to: Date(), sortDescriptor: NSSortDescriptor(key: "date", ascending: false))
                          .values()
                          .take(first: 14)
                          .collect()
                          .map { summaries in
                            return (summary, Int(summaries.reduce(0) { $0 + $1.activeEnergyBurned } / summaries.count))
                          }
                      }
                      .collect()
                      .map { $0.sorted(by: { firstTuple, secondTuple in
                        return firstTuple.0.activeEnergyBurned > secondTuple.0.activeEnergyBurned
                      })}
              )
    }

    activitySummaries = Property(initial: [], then: fetchSummariesAction.values)
    currentUsername = Property(capturing: store.currentUser.map { $0?.name ?? "" })
    
    currentDate <~ fetchSummariesAction
                    .completed
                    .map { Date() }
  }

  func cellViewModel(atIndexPath indexPath: IndexPath) -> RankingCellViewModel {
    let (summary, averageCalories) = activitySummaries.value[indexPath.row]
    
    var image: UIImage?
    
    switch indexPath.row {
    case 0:
      image = UIImage(named: "FirstPlace")
    case 1:
      image = UIImage(named: "SecondPlace")
    case 2:
      image = UIImage(named: "ThirdPlace")
    default:
      if indexPath.row + 1 != activitySummaries.value.count {
        image = UIImage.image(forRank: indexPath.row + 1)
      } else {
        image = UIImage(named: "Turtle")
      }
    }
    
    let timeFormatter = DateFormatter()
    timeFormatter.timeStyle = .short
    timeFormatter.dateStyle = .none
    
    var updatedAtString = "-"
    if let updatedAt = summary.updatedAt {
      updatedAtString = timeFormatter.string(from:updatedAt)
    }
    
    return RankingCellViewModel(isCurrentUser: currentUsername.value == summary.user.name,
                                rankImage: image,
                                username: summary.user.name,
                                updatedAtText: "\("Ranking.LastUpdate.Text".localized) \(updatedAtString)",
                                activeCalories: summary.activeEnergyBurned,
                                averageCaloriesText: "\("Ranking.AverageCalories.Text".localized) \(averageCalories) kCal")
  }
  
}

struct RankingCellViewModel {

  let isCurrentUser: Bool
  let rankImage: UIImage?
  let username: String
  let updatedAtText: String
  let activeCalories: Int
  let averageCaloriesText: String

}
