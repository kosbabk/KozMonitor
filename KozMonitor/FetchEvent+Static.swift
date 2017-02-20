//
//  FetchEvent+Static.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/19/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import CoreData

extension FetchEvent : MyManagedObjectProtocol {
  
  // MARK: - MyManagedObjectProtocol
  
  static var sortDescriptors: [NSSortDescriptor]? {
    return [ NSSortDescriptor(key: "dateNSDate", ascending: true) ]
  }
  
  // MARK: - Fetch
  
  static func fetch(date: Date) -> FetchEvent? {
    let predicate = NSPredicate(format: "dateNSDate == %@", date as NSDate)
    return self.fetchOne(predicate: predicate)
  }
  
  // MARK: - Create / Update
  
  static func createOrUpdate(date: Date, processingTime: Double, bytesProcessed: Int, session: FetchSession? = nil) -> FetchEvent {
    let object = self.fetch(date: date) ?? self.create()
    object.date = date
    object.processingTime = processingTime
    object.bytesProcessed = bytesProcessed
    if let session = session {
      object.session = session
    }
    return object
  }
  
  // MARK: - Fetched Results Controller
  
  static func newFetchedResultsController2(session: FetchSession) -> NSFetchedResultsController<FetchEvent>? {
    let predicate = NSPredicate(format: "session = %@", session)
    return self.newFetchedResultsController(predicate: predicate)
  }
}
