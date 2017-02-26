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
    
    self.title = "Background Events"
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icSettingsMenu"), target: self, action: #selector(self.openSettingsMenu))
    
    self.buildFetchController()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.reloadContent()
  }
  
  // MARK: - Actions
  
  @objc func openSettingsMenu() {
    var viewController = SettingsViewController.newViewController()
    viewController.presentControllerIn(self, forMode: .leftMenu, inNavigationController: false, isDragDismissable: true)
  }
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  var fetchedResultsController: NSFetchedResultsController<Global>? = nil
  var eventFetchedResultsController: NSFetchedResultsController<ApplicationEvent>? = nil
  
  func buildFetchController() {
    
    self.fetchedResultsController = Global.newFetchedResultsController()
    self.fetchedResultsController?.delegate = self
    
    self.eventFetchedResultsController = ApplicationEvent.newFetchedResultsController(eventTypes: [ .backgroundFetchGetStarted, .backgroundFetchGetCompleted, .backgroundFetchTriggered ])
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
