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
  
  private var applicationEvent: ApplicationEvent? = nil
  
  func configure(applicationEvent: ApplicationEvent) {
    self.applicationEvent = applicationEvent
    
    self.titleLabel.text = applicationEvent.eventType.description
    self.leftDetailLabel.text = "Expected Interval: \(applicationEvent.fetchInterval.timeString)"
    self.rightDetailLabel.text =  applicationEvent.date?.formatted_MdYYhms ?? "🕑?"
  }
}

class ApplicationEventsViewController : MyTableViewController, ItemsReloadable, NSFetchedResultsControllerDelegate {
  
  // MARK: - Class Accessors
  
  static func newViewController() -> ApplicationEventsViewController {
    return self.newViewController(fromStoryboard: .main)
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Application Events"
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icSettingsMenu"), target: self, action: #selector(self.openSettingsMenu))
    
    self.buildFetchedResultsController()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.reloadItems()
  }
  
  // MARK: - Actions
  
  @objc func openSettingsMenu() {
    var viewController = SettingsViewController.newViewController()
    viewController.presentControllerIn(self, forMode: .leftMenu, inNavigationController: false, isDragDismissable: true)
  }
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  var fetchedResultsController: NSFetchedResultsController<ApplicationEvent>? = nil
  
  func buildFetchedResultsController() {
    self.fetchedResultsController = ApplicationEvent.newFetchedResultsController(eventTypes: [ .appDidBecomeActive, .backgroundFetchEventStarted, .backgroundFetchEventCompleted ])
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
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return nil
  }
  
  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    
    // Can only calculate the interval if there is a next event to calculate from
    if section + 1 < self.applicationEvents.count, let currentDate = self.applicationEvents[section].date, let nextDate = self.applicationEvents[section + 1].date {
      let timeInterval = nextDate.timeIntervalSince(currentDate)
      return  "Interval: \(timeInterval.timeString)"
    }
    return nil
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 22
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ApplicationEventCell.name, for: indexPath) as! ApplicationEventCell
    let applicationEvent = self.applicationEvents[indexPath.section]
    cell.configure(applicationEvent: applicationEvent)
    return cell
  }
}

//extension CollectionListViewController : EmptyStateDelegate {
//  
//  var emptyStateTitle: String {
//    return "None"
//  }
//  
//  var emptyStateMessage: String {
//    return "In the Settings app make sure Background App Refresh is enabled for this app. Once enabled, this app will perform background fetches and update the content of the applications. Check back periodically to check the status of the background fetches."
//  }
//  
//  var emptyStateImage: UIImage? {
//    return nil
//  }
//  
//  var emptyStateButtonTitle: String? {
//    return "Open Settings"
//  }
//  
//  func emptyStateButtonSelected() {
//    if let settingsUrl = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) {
//      UIApplication.shared.open(settingsUrl, completionHandler: nil)
//    }
//  }
//}
