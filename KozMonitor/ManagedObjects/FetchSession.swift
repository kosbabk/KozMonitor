//
//  FetchSession.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension FetchSession {
  
  var startDate: Date? {
    get {
      return self.startDateNSDate as? Date
    }
    set {
      self.startDateNSDate = newValue as NSDate?
    }
  }
  
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
}
