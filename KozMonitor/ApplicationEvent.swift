//
//  ApplicationEvent.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/20/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import CoreData

extension ApplicationEvent {
  
  var eventType: ApplicationEventType {
    get {
      return ApplicationEventType(rawValue: Int(self.eventTypeValue))!
    }
    set {
      self.eventTypeValue = Int16(newValue.rawValue)
    }
  }
  
  var date: Date? {
    get {
      return self.dateNSDate as? Date
    }
    set {
      self.dateNSDate = newValue as NSDate?
    }
  }
  
  var fetchInterval: TimeInterval {
    get {
      return TimeInterval(self.fetchIntervalValue)
    }
    set {
      self.fetchIntervalValue = Int64(newValue)
    }
  }
}
