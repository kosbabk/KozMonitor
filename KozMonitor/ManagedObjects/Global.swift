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
  
  var backgroundFetchInterval: Int {
    set {
      self.backgroundFetchIntervalValue = Int32(newValue)
    }
    get {
      return Int(self.backgroundFetchIntervalValue)
    }
  }
  
  var backgroundFetchIntervalSeconds: Int {
    set {
      self.backgroundFetchInterval = Int(newValue / 60)
    }
    get {
      return self.backgroundFetchInterval * 60
    }
  }
}
