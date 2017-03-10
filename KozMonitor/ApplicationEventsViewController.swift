//
//  ApplicationEventsViewController.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import UserNotifications

class ApplicationEventCell : UITableViewCell {
  @IBOutlet weak private var titleLabel: UILabel!
  @IBOutlet weak private var leftDetailLabel: UILabel!
  @IBOutlet weak private var rightDetailLabel: UILabel!
  @IBOutlet weak private var timeToNextEventLabel: UILabel!
  
  private var applicationEvent: ApplicationEvent? = nil
  private var nextApplicationEvent: ApplicationEvent? = nil
  
  func configure(applicationEvent: ApplicationEvent, nextApplicationEvent: ApplicationEvent?) {
    self.applicationEvent = applicationEvent
    self.nextApplicationEvent = nextApplicationEvent
    
    self.titleLabel.text = applicationEvent.eventType.description
    self.leftDetailLabel.text = applicationEvent.date?.formatted_MdYYhms ?? "🕑?"
    self.rightDetailLabel.text = applicationEvent.eventType.body
    
    // Duration to next event
    if let currentDate = applicationEvent.date, let nextDate = nextApplicationEvent?.date {
      let timeInterval = nextDate.timeIntervalSince(currentDate)
      self.timeToNextEventLabel.text = timeInterval.timeString
    } else {
      self.timeToNextEventLabel.text = "NA"
    }
  }
}

class ApplicationEventsViewController : MyTableViewController, NSFetchedResultsControllerDelegate, ItemsReloadable, EmptyStateDelegate {
  
  // MARK: - Class Accessors
  
  static func newViewController() -> ApplicationEventsViewController {
    return self.newViewController(fromStoryboard: .main)
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.buildFetchedResultsController()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.reloadItems()
  }
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  var fetchedResultsController: NSFetchedResultsController<ApplicationEvent>? = nil
  
  func buildFetchedResultsController() {
    self.fetchedResultsController = ApplicationEvent.newFetchedResultsController(eventTypes: ApplicationEvent.listenableEvents)
    self.fetchedResultsController?.delegate = self
    
    do {
      try self.fetchedResultsController?.performFetch()
    } catch {
      print("\(self.className) : Fetch error \(error.localizedDescription)")
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    
    self.reloadItems()
  }
  
  // MARK: - UITableView Helpers
  
  var applicationEvents: [ApplicationEvent] {
    return self.fetchedResultsController?.fetchedObjects ?? []
  }
  
  // MARK: - UITableView
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.applicationEvents.count
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ApplicationEventCell.name, for: indexPath) as! ApplicationEventCell
    let applicationEvent = self.applicationEvents[indexPath.section]
    let nextEvent: ApplicationEvent? = indexPath.section + 1 < self.applicationEvents.count ? self.applicationEvents[indexPath.section + 1] : nil
    cell.configure(applicationEvent: applicationEvent, nextApplicationEvent: nextEvent)
    return cell
  }
  
  // MARK: - EmptyStateDelegate
  
  var emptyStateView: EmptyStateView? = nil
  
  var emptyStateTitle: String {
    return "No Events"
  }
  
  var emptyStateMessage: String {
    return "No background or location events have occurred."
  }
  
  var emptyStateImage: UIImage? {
    return nil
  }
  
  var emptyStateButtonTitle: String? { return nil }
  
  func emptyStateButtonSelected() {}
}
