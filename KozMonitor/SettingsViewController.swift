//
//  SettingsViewController.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/19/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SettingsViewController : MyTableViewController, NSFetchedResultsControllerDelegate {
  
  // MARK: - Class Accessors
  
  static func newViewController() -> SettingsViewController {
    return self.newViewController(fromStoryboard: .main)
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var dismissButton: UIButton!
  
  @IBOutlet weak var notificationSwitch: UISwitch!
  
  @IBOutlet weak var getEnabledSwitch: UISwitch!
  
  @IBOutlet weak var versionLabel: UILabel!
  @IBOutlet weak var buildLabel: UILabel!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Notification permissions
    MyNotificationManger.shared.promptAlertIfDenied(self, completion: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.reloadContent()
    MyNotificationManger.shared.refreshPermission {
      self.reloadContent()
    }
  }
  
  // MARK: - Actions
  
  @IBAction func dismissButtonSelected() {
    self.dismissController()
  }
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  var fetchedResultsController: NSFetchedResultsController<Global>? = nil
  
  func buildFetchController() {
    
    self.fetchedResultsController = Global.newFetchedResultsController()
    self.fetchedResultsController?.delegate = self
    
    do {
      try self.fetchedResultsController?.performFetch()
    } catch {
      let fetchError = error as NSError
      print("\(fetchError), \(fetchError.userInfo)")
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    
    self.reloadContent(animated: true)
  }
  
  // MARK: - Content
  
  func reloadContent(animated: Bool = false) {
    self.notificationSwitch.setOn(Global.shared.notificationsEnabled, animated: animated)
    self.getEnabledSwitch.setOn(Global.shared.backgroundFetchGetEnabled, animated: animated)
    
    // Set the version label
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      self.versionLabel.text = version
    } else {
      self.versionLabel.text = "🤷🏼‍♂️"
    }
    
    // Set build label
    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
      self.buildLabel.text = build
    } else {
      self.buildLabel.text = "🤷🏼‍♂️"
    }
  }
  
  // MARK: - Notifications Switch
  
  @IBAction func notificationSwitchValueChanged(_ sender: UISwitch) {
    MyNotificationManger.shared.checkPermission(authorized: {
      // Update the setting
      Global.shared.notificationsEnabled = sender.isOn
      MyDataManager.shared.saveMainContext()
      
    }, notDetermined: {
      MyNotificationManger.shared.promptAlertIfDenied(self, completion: nil)
      
    }) {
      // Denied
      MyNotificationManger.shared.promptAlertIfDenied(self, completion: nil)
    }
    
  }
  
  @IBAction func getEnabledSwitchValueChanged(_ sender: UISwitch) {
    Global.shared.backgroundFetchGetEnabled = sender.isOn
    MyDataManager.shared.saveMainContext()
  }
  
  // MARK: - UITableView
  
  let dismissSection: Int = 0
  let notificationsSection: Int = 1
  let networkGetSection: Int = 2
  let infoSection: Int = 3
  
  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == self.networkGetSection, let path = Global.shared.requestPath {
      return "Request Path: \(path)"
    }
    return nil
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case self.dismissSection:
      return 1
    case self.notificationsSection:
      return 1
    case self.networkGetSection:
      return 1
    case self.infoSection:
      return 2
    default:
      return 0
    }
  }
}
