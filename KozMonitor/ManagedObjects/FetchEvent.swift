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

extension FetchEvent : MyManagedObjectProtocol {
  
  // MARK: - MyManagedObjectProtocol
  
  static var sortDescriptors: [NSSortDescriptor]? {
    return [ NSSortDescriptor(key: "date", ascending: true) ]
  }
  
  // MARK: - Fetch
  
  static func fetch(date: Date) -> FetchEvent? {
    let predicate = NSPredicate(format: "date == %@", date as NSDate)
    return self.fetchOne(predicate: predicate)
  }
  
  // MARK: - Create / Update
  
  static func createOrUpdate(date: Date, processingTime: Double, collection: FetchEventCollection? = nil) -> FetchEvent {
    let object = self.fetch(date: date) ?? self.create()
    object.date = date as NSDate
    object.processingTime = processingTime
    if let collection = collection {
      object.collection = collection
    }
    return object
  }
  
  // MARK: - Fetched Results Controller
  
  static func newFetchedResultsController2(collection: FetchEventCollection) -> NSFetchedResultsController<FetchEvent>? {
    let predicate = NSPredicate(format: "collection = %@", collection)
    return self.newFetchedResultsController(predicate: predicate)
  }
}
