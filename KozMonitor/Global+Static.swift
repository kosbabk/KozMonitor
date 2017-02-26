//
//  Global+Static.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/19/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import CoreData

extension Global : MyManagedObjectProtocol {
  
  // MARK: - MyManagedObjectProtocol
  
  static var sortDescriptors: [NSSortDescriptor]? {
    return []
  }
  
  // MARK: - Singleton
  
  static var shared: Global {
    return self.fetchOne() ?? self.create()
  }
}
