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
  
  static func createOrUpdate(startDate: Date, selectedFetchInterval: Int, requestPath: String) -> FetchEventCollection {
    let object = self.fetch(startDate: startDate) ?? self.create()
    object.startDate = startDate as NSDate
    object.selectedFetchInterval = selectedFetchInterval
    object.requestPath = requestPath
    return object
  }
}
