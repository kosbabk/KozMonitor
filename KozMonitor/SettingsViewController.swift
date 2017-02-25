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
import UserNotifications

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
    
    // Request notifications
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
      
      if settings.authorizationStatus != .authorized {
        
        // Update the notification settings flag
        Global.shared.notificationsEnabled = false
        MyDataManager.shared.saveMainContext()
        self.reloadContent()
        
        // If the notification settings have not been determined yet display authorization prompt
        if settings.authorizationStatus.isNotDetermined {
          
          UNUserNotificationCenter.current().requestAuthorization(options: [ .alert, .badge, .sound, .carPlay ]) { (authorized, error) in
            if authorized {
              print("\(self.className) : User authorized notifications")
              Global.shared.notificationsEnabled = true
              MyDataManager.shared.saveMainContext()
              self.reloadContent()
              
            } else {
              print("\(self.className) : User did not authorize notifications")
              Global.shared.notificationsEnabled = false
              MyDataManager.shared.saveMainContext()
              self.reloadContent()
            }
          }
        }
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Check for updates to notification settings
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
      
      if !settings.authorizationStatus.isAuthorized {
        Global.shared.notificationsEnabled = false
        MyDataManager.shared.saveMainContext()
        self.reloadContent()
      }
    }

    self.reloadContent()
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
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
      
      if settings.authorizationStatus.isAuthorized {
        
        // Update the setting
        Global.shared.notificationsEnabled = sender.isOn
        MyDataManager.shared.saveMainContext()
        
      } else {
        
        // Notifications are not enabled
        Global.shared.notificationsEnabled = false
        MyDataManager.shared.saveMainContext()
        self.reloadContent(animated: true)
        
        // Alert to tell user to adjust their settings
        self.showNotificationsDisabledAlert()
      }
    }
  }
  
  @IBAction func getEnabledSwitchValueChanged(_ sender: UISwitch) {
    Global.shared.backgroundFetchGetEnabled = sender.isOn
    MyDataManager.shared.saveMainContext()
  }
  
  func showNotificationsDisabledAlert() {
    let settingsAlertController = UIAlertController(title: "Notifications", message: "Notifications have not been authorized. Please go to settings and authorize this app for notifications", preferredStyle: .alert)
    settingsAlertController.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { (_) in
      
      if let settingsUrl = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) {
        UIApplication.shared.open(settingsUrl, completionHandler: nil)
      }
      
    }))
    settingsAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(settingsAlertController, animated: true, completion: nil)
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
