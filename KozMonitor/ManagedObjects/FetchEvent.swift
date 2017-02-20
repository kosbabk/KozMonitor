//
//  FetchEvent.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension FetchEvent {
  
  var date: Date? {
    get {
      return self.dateNSDate as? Date
    }
    set {
      self.dateNSDate = newValue as NSDate?
    }
  }
  
  var bytesProcessed: Int {
    get {
      return Int(self.bytesProcessedValue)
    }
    set {
      self.bytesProcessedValue = Int64(newValue)
    }
  }

}
