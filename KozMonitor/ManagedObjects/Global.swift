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

extension Global : MyManagedObjectProtocol {
  
  // MARK: - MyManagedObjectProtocol
  
  static var sortDescriptors: [NSSortDescriptor]? {
    return nil
  }

  // MARK: - Singleton
  
  static var shared: Global {
    return self.fetchOne() ?? self.create()
  }
  
  // MARK: - Properties
  
  var backgroundFetchInterval: Int {
    set {
      self.backgroundFetchIntervalValue = Int32(newValue)
    }
    get {
      return Int(self.backgroundFetchIntervalValue)
    }
  }
}
