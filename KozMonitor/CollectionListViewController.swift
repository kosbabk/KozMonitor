//
//  CollectionListViewController.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import UserNotifications

class CollectionListElementCell : UITableViewCell {
  @IBOutlet weak private var titleLabel: UILabel!
  @IBOutlet weak private var numberFetchEventsLabel: UILabel!
  @IBOutlet weak private var averageFetchTimeLabel: UILabel!
  @IBOutlet weak private var expectedIntervalLabel: UILabel!
  private var collection: FetchSession? = nil
  
  func configure(collection: FetchSession) {
    self.collection = collection
    
    self.titleLabel.text = collection.startDate?.dateTimeFormat ?? "NA"
    self.numberFetchEventsLabel.text = "\(collection.events.count) \(collection.events.count == 1 ? "Event" : "Events")"
    self.expectedIntervalLabel.text = "Expected: \(collection.selectedFetchInterval)m"
    
    if let averageMinutes = collection.averageFetchInterval {
      let averageString = averageMinutes < 2 ? "\((averageMinutes * 60).twoDecimals)s" : "\(averageMinutes.twoDecimals)m"
      self.averageFetchTimeLabel.text = "Average: \(averageString)"
    } else {
      self.averageFetchTimeLabel.text = "Average: NA"
    }
  }
}

class CollectionListViewController : MyTableViewController, ItemsReloadable, NSFetchedResultsControllerDelegate {
  
  // MARK: - Class Accessors
  
  static func newViewController() -> CollectionListViewController {
    return self.newViewController(fromStoryboard: .main)
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Sessions"
    
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
    viewController.presentControllerIn(self, forMode: .leftMenu, inNavigationController: false)
  }
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  var fetchedResultsController: NSFetchedResultsController<FetchSession>? = nil
  
  func buildFetchedResultsController() {
    self.fetchedResultsController = FetchSession.newFetchedResultsController()
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
  
  var collections: [FetchSession] {
    return self.fetchedResultsController?.fetchedObjects ?? []
  }
  
  // MARK: - UITableView
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.collections.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CollectionListElementCell.name, for: indexPath) as! CollectionListElementCell
    let collection = self.collections[indexPath.row]
    cell.configure(collection: collection)
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
