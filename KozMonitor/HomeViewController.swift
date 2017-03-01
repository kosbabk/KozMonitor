//
//  HomeViewController.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/26/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HomeViewController : MyViewController, NSFetchedResultsControllerDelegate {
  
  // MARK: - Class Accessors
  
  static func newViewController() -> HomeViewController {
    return self.newViewController(fromStoryboard: .main)
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var lastBackgroundFetchLabel: UILabel!
  @IBOutlet weak var lastBackgroundRequestLabel: UILabel!
  @IBOutlet weak var totalEventsLabel: UILabel!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Events"
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icSettingsMenu"), target: self, action: #selector(self.openSettingsMenu))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Scroll Bottom", style: .plain, target: self, action: #selector(self.scrollToLast))
    
    self.buildFetchController()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.reloadContent()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.scrollToLast()
  }
  
  // MARK: - Actions
  
  @objc func openSettingsMenu() {
    var viewController = SettingsViewController.newViewController()
    viewController.presentControllerIn(self, forMode: .leftMenu, inNavigationController: true, isDragDismissable: true)
  }
  
  @objc func scrollToLast() {
    for childViewController in self.childViewControllers {
      if let tableViewController = childViewController as? UITableViewController {
        tableViewController.scrollToLastItem()
      }
    }
  }
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  var fetchedResultsController: NSFetchedResultsController<Global>? = nil
  var eventFetchedResultsController: NSFetchedResultsController<ApplicationEvent>? = nil
  
  func buildFetchController() {
    
    self.fetchedResultsController = Global.newFetchedResultsController()
    self.fetchedResultsController?.delegate = self
    
    self.eventFetchedResultsController = ApplicationEvent.newFetchedResultsController(eventTypes: ApplicationEvent.listenableEvents)
    self.eventFetchedResultsController?.delegate = self
    
    do {
      try self.fetchedResultsController?.performFetch()
      try self.eventFetchedResultsController?.performFetch()
    } catch {
      let fetchError = error as NSError
      print("\(fetchError), \(fetchError.userInfo)")
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    
    self.reloadContent()
    
    self.scrollToLast()
  }
  
  // MARK: - Content
  
  var applicationEvents: [ApplicationEvent] {
    return self.eventFetchedResultsController?.fetchedObjects ?? []
  }
  
  func reloadContent() {
    
    if let backgroundFetchDate = Global.shared.lastBackgroundFetchDate as? Date {
      self.lastBackgroundFetchLabel.text = backgroundFetchDate.formatted_MdYYhms
    } else {
      self.lastBackgroundFetchLabel.text = "NA"
    }
    
    if let lastRequestDate = Global.shared.lastRequestDate as? Date {
      self.lastBackgroundRequestLabel.text = lastRequestDate.formatted_MdYYhms
    } else {
      self.lastBackgroundRequestLabel.text = "NA"
    }
    
    self.totalEventsLabel.text = "\(self.applicationEvents.count)"
  }
}
