//
//  FetchSession+Static.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/19/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import CoreData

extension FetchSession : MyManagedObjectProtocol {
  
  // MARK: - MyManagedObjectProtocol
  
  static var sortDescriptors: [NSSortDescriptor]? {
    return [ NSSortDescriptor(key: "startDateNSDate", ascending: true) ]
  }
  
  // MARK: - Fetch
  
  static func fetch(startDate: Date) -> FetchSession? {
    let predicate = NSPredicate(format: "startDateNSDate == %@", startDate as NSDate)
    return self.fetchOne(predicate: predicate)
  }
  
  // MARK: - Create / Update
  
  static func createOrUpdate(startDate: Date, selectedFetchInterval: Int, requestPath: String?) -> FetchSession {
    let object = self.fetch(startDate: startDate) ?? self.create()
    object.startDate = startDate
    object.selectedFetchInterval = selectedFetchInterval
    object.requestPath = requestPath
    return object
  }
}
