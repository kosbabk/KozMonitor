//
//  Global+Static.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/19/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation

extension Global : MyManagedObjectProtocol {
  
  // MARK: - MyManagedObjectProtocol
  
  static var sortDescriptors: [NSSortDescriptor]? {
    return nil
  }
  
  // MARK: - Singleton
  
  static var shared: Global {
    return self.fetchOne() ?? self.create()
  }
}
