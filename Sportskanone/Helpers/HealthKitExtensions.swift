//
//  HealthKitExtensions.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 27/02/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import HealthKit
import ReactiveSwift
import Result

extension Reactive where Base: HKHealthStore {
  
  func fetchDailyActiveCalorieSumStatistics(from startDate: Date? = nil, to endDate: Date) -> SignalProducer<HKStatistics, AnyError> {
    let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    let calendar = Calendar.autoupdatingCurrent
    
    var intervalComponents = DateComponents()
    intervalComponents.day = 1
    
    var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: Date())
    
    // Set the anchor date to Monday at 0:00 a.m.
    let offset = (7 + anchorComponents.weekday! - 2) % 7
    anchorComponents.day = anchorComponents.day! - offset
    anchorComponents.hour = 0
    
    let anchorDate = calendar.date(from: anchorComponents)!
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])
    
    return self.fetchStatisticsCollection(for: type, predicate: predicate, options: [.cumulativeSum, .separateBySource], anchorDate: anchorDate, intervalComponents: intervalComponents)
      .map { $1 }
      .skipNil()
      .flatMap(.latest) { collection -> SignalProducer<HKStatistics, AnyError> in
        return SignalProducer(collection.statistics())
      }
  }

}

// MARK: RAC Wrapper

extension Reactive where Base: HKHealthStore {

  // MARK: - Accessing HealthKit

  func authorizationStatus(for type: HKObjectType) -> SignalProducer<HKAuthorizationStatus, NoError> {
    return SignalProducer { [base = self.base] observer, _ in
      observer.send(value: base.authorizationStatus(for: type))
      observer.sendCompleted()
    }
  }
  
  func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?) -> SignalProducer<Void, AnyError> {
    return SignalProducer { [base = self.base] observer, _ in
      base.requestAuthorization(toShare: typesToShare, read: typesToRead) { _, error in
        guard let error = error else {
          observer.sendCompleted()
          return
        }
        observer.send(error: AnyError(error))
      }
    }
  }

  // MARK: - Querying HealthKit Data

  func fetchSamples(for type: HKSampleType, predicate: NSPredicate? = nil, limit: Int = Int(HKObjectQueryNoLimit), sortDescriptors: [NSSortDescriptor]? = nil) -> SignalProducer<(HKSampleQuery, [HKSample]?), AnyError> {
    return SignalProducer { [base = self.base] observer, _ in
      base.execute(HKSampleQuery(sampleType: type, predicate: predicate, limit: limit, sortDescriptors: sortDescriptors) { query, samples, error in
        guard let error = error else {
          observer.send(value: (query, samples))
          observer.sendCompleted()
          return
        }
        observer.send(error: AnyError(error))
      })
    }
  }

  func fetchQuantitySamples(for type: HKQuantityType, predicate: NSPredicate? = nil, limit: Int = Int(HKObjectQueryNoLimit), sortDescriptors: [NSSortDescriptor]? = nil) -> SignalProducer<(HKSampleQuery, [HKQuantitySample]?), AnyError> {
    return SignalProducer { [base = self.base] observer, _ in
      base.execute(HKSampleQuery(sampleType: type, predicate: predicate, limit: limit, sortDescriptors: sortDescriptors) { query, samples, error in
        guard let error = error else {
          observer.send(value: (query, samples as? [HKQuantitySample]))
          observer.sendCompleted()
          return
        }
        observer.send(error: AnyError(error))
      })
    }
  }

  func fetchActivitySummaries(with predicate: NSPredicate? = nil) -> SignalProducer<(HKActivitySummaryQuery, [HKActivitySummary]?), AnyError> {
    return SignalProducer { [base = self.base] observer, _ in
      base.execute(HKActivitySummaryQuery(predicate: predicate) { query, summaries, error in
        guard let error = error else {
          observer.send(value: (query, summaries))
          observer.sendCompleted()
          return
        }
        observer.send(error: AnyError(error))
      })
    }
  }

  func fetchStatistics(for type: HKQuantityType, predicate: NSPredicate? = nil, options: HKStatisticsOptions) -> SignalProducer<(HKStatisticsQuery, HKStatistics?), AnyError> {
    return SignalProducer { [base = self.base] observer, _ in
      base.execute(HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: options) { query, statistics, error in
        guard let error = error else {
          observer.send(value: (query, statistics))
          observer.sendCompleted()
          return
        }
        observer.send(error: AnyError(error))
      })
    }
  }

  func fetchStatisticsCollection(for type: HKQuantityType, predicate: NSPredicate? = nil, options: HKStatisticsOptions, anchorDate: Date, intervalComponents: DateComponents) -> SignalProducer<(HKStatisticsCollectionQuery, HKStatisticsCollection?), AnyError> {
    return SignalProducer { [base = self.base] observer, _ in
      let query = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: predicate, options: options, anchorDate: anchorDate, intervalComponents: intervalComponents)
      query.initialResultsHandler = { query, collection, error in
        guard let error = error else {
          observer.send(value: (query, collection))
          observer.sendCompleted()
          return
        }
        observer.send(error: AnyError(error))
      }

      base.execute(query)
    }
  }

  // MARK: - Managing Background Delivery

  func enableBackgroundDelivery(for type: HKObjectType, frequency: HKUpdateFrequency) -> SignalProducer<Bool, AnyError> {
    return SignalProducer { [base = self.base] observer, _ in
      base.enableBackgroundDelivery(for: type, frequency: frequency) { success, error in
        guard let error = error else {
          observer.send(value: success)
          observer.sendCompleted()
          return
        }
        observer.send(error: AnyError(error))
      }
    }
  }

  func disableBackgroundDelivery(for type: HKObjectType) -> SignalProducer<Bool, AnyError> {
    return SignalProducer { [base = self.base] observer, _ in
      base.disableBackgroundDelivery(for: type, withCompletion: { success, error in
        guard let error = error else {
          observer.send(value: success)
          observer.sendCompleted()
          return
        }
        observer.send(error: AnyError(error))
      })
    }
  }

}
