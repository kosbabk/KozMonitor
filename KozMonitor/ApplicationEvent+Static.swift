//
//  ApplicationEvent+Static.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/20/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import CoreData

enum ApplicationEventType: Int {
  case na, appDidBecomeActive, appDidEnterBackground, appWillTerminate, backgroundFetchEventStarted, backgroundFetchEventCompleted
  
  var description: String {
    switch self {
    case .na:
      return "NA"
    case .appDidBecomeActive:
      return "App Did Become Active"
    case .appDidEnterBackground:
      return "App Did Enter Background"
    case .appWillTerminate:
      return "App Will Terminate"
    case .backgroundFetchEventStarted:
      return "Background Fetch Event Started"
    case .backgroundFetchEventCompleted:
      return "Background Fetch Event Completed"
    }
  }
}

extension ApplicationEvent : MyManagedObjectProtocol {
  
  static var sortDescriptors: [NSSortDescriptor]? {
    return [ NSSortDescriptor(key: "dateNSDate", ascending: true) ]
  }
  
  // MARK: - Fetch
  
  static func fetch(date: Date) -> ApplicationEvent? {
    let predicate = NSPredicate(format: "dateNSDate == %@", date as NSDate)
    return self.fetchOne(predicate: predicate)
  }
  
  static func fetchMany(eventType: ApplicationEventType) -> [ApplicationEvent] {
    let predicate = NSPredicate(format: "eventTypeValue == %d", eventType.rawValue)
    return self.fetchMany(predicate: predicate)
  }
  
  // MARK: - Create / Update
  
  static func createOrUpdate(date: Date, eventType: ApplicationEventType, fetchInterval: TimeInterval, requestPath: String?) -> ApplicationEvent {
    let object = self.fetch(date: date) ?? self.create()
    object.date = date
    object.eventType = eventType
    object.fetchInterval = fetchInterval
    object.requestPath = requestPath
    return object
  }
  
  // MARK: - Fetched Results Controllers
  
  static func newFetchedResultsController(eventType: ApplicationEventType) -> NSFetchedResultsController<ApplicationEvent> {
    let predicate = NSPredicate(format: "eventTypeValue == %d", eventType.rawValue)
    return self.newFetchedResultsController(predicate: predicate)
  }
  
  static func newFetchedResultsController(eventTypes: [ApplicationEventType]) -> NSFetchedResultsController<ApplicationEvent> {
    var rawEventTypes: [Int16] = []
    for eventType in eventTypes {
      rawEventTypes.append(Int16(eventType.rawValue))
    }
    let predicate = NSPredicate(format: "eventTypeValue IN %@", rawEventTypes)
    return self.newFetchedResultsController(predicate: predicate)
  }
}