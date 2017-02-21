//
//  Global.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension Global {
  
  var backgroundFetchInterval: TimeInterval {
    get {
      return TimeInterval(self.backgroundFetchIntervalValue)
    }
    set {
      self.backgroundFetchIntervalValue = Int32(newValue)
    }
  }
}
