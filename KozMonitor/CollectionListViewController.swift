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

class CollectionListViewController : MyTableViewController, NSFetchedResultsControllerDelegate {
  
  // MARK: - Class Accessors
  
  static func newViewController() -> CollectionListViewController {
    return self.newViewController(fromStoryboard: .main)
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icSettingsMenu"), target: self, action: #selector(self.openSettingsMenu))
  }
  
  // MARK: - Actions
  
  @objc func openSettingsMenu() {
    var viewController = SettingsViewController.newViewController()
    viewController.presentControllerIn(self, forMode: .leftMenu, inNavigationController: false)
  }
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  var fetchedResultsController: NSFetchedResultsController<FetchEventCollection>? = nil
  
  func buildFetchedResultsController() {
    self.fetchedResultsController = FetchEventCollection.newFetchedResultsController()
    self.fetchedResultsController?.delegate = self
    
    do {
      try self.fetchedResultsController?.performFetch()
    } catch {
      print("\(self.className) : Fetch error \(error.localizedDescription)")
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    
    self.tableView.reloadData()
  }
  
  // MARK: - UITableView Helpers
  
  var collections: [FetchEventCollection] {
    return self.fetchedResultsController?.fetchedObjects ?? []
  }
  
  // MARK: - UITableView
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.collections.count
  }
}
