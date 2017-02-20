//
//  FetchEventCollection.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension FetchEventCollection : MyManagedObjectProtocol {
  
  // MARK: - Properties
  
  var selectedFetchInterval: Int {
    set {
      self.selectedFetchIntervalValue = Int32(newValue)
    }
    get {
      return Int(self.selectedFetchIntervalValue)
    }
  }
  
  var events: [FetchEvent] {
    if let array = self.eventsSet?.sortedArray(using: FetchEvent.sortDescriptors ?? []) as? [FetchEvent] {
      return array
    }
    return []
  }
  
  var averageFetchInterval: Double? {
    var currentTimeInterval: Double = 0
    var totalCalculations: Int = 0
    let events = self.events
    
    guard events.count > 1 else {
      // Not enough data to calculate average interval
      return nil
    }
    
    // Calculate the average fetch interval
    for index in 1..<events.count {
      let previousFetchEvent = events[index - 1]
      let currentFetchEvent = events[index]
      if let currentDate = currentFetchEvent.date, let previousDate = previousFetchEvent.date {
        currentTimeInterval += (currentDate as Date).timeIntervalSince(previousDate as Date)
        totalCalculations += 1
      }
    }
    let averageSecondsPerFetch = currentTimeInterval / Double(totalCalculations)
    return averageSecondsPerFetch / 60
  }
  
  // MARK: - MyManagedObjectProtocol
  
  static var sortDescriptors: [NSSortDescriptor]? {
    return [ NSSortDescriptor(key: "startDate", ascending: true) ]
  }

  // MARK: - Fetch
  
  static func fetch(startDate: Date) -> FetchEventCollection? {
    let predicate = NSPredicate(format: "startDate == %@", startDate as NSDate)
    return self.fetchOne(predicate: predicate)
  }
  
  // MARK: - Create / Update
  
  static func createOrUpdate(startDate: Date, selectedFetchInterval: Int, requestPath: String?) -> FetchEventCollection {
    let object = self.fetch(startDate: startDate) ?? self.create()
    object.startDate = startDate as NSDate
    object.selectedFetchInterval = selectedFetchInterval
    object.requestPath = requestPath
    return object
  }
}
