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
  
  static func createOrUpdate(startDate: Date) -> FetchEventCollection {
    let object = self.fetch(startDate: startDate) ?? self.create()
    object.startDate = startDate as NSDate
    return object
  }
}
