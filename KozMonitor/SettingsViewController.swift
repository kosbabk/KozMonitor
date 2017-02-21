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
  @IBOutlet weak var fetchIntervalLabel: UILabel!
  @IBOutlet weak var fetchIntervalPickerView: UIPickerView!
  @IBOutlet weak var versionLabel: UILabel!
  @IBOutlet weak var buildLabel: UILabel!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.fetchIntervalPickerView.delegate = self
    self.fetchIntervalPickerView.dataSource = self
    
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
    
    self.updateSelectedFetchIntervalPicker()
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
    self.fetchIntervalLabel.text = Global.shared.backgroundFetchInterval.timeString
    
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
    
    // Update the visible rows of the table
    self.tableView.reloadData()
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
  let settingsSection: Int = 1
  let infoSection: Int = 2
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }
  
  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == self.settingsSection, let path = Global.shared.requestPath {
      return "Request Path: \(path)"
    }
    return nil
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case self.dismissSection:
      return 1
    case self.settingsSection:
      return 1
    case self.infoSection:
      return 2
    default:
      return 0
    }
  }
}

extension SettingsViewController : UIPickerViewDelegate, UIPickerViewDataSource {
  
  private var fetchIntervals: [TimeInterval] {
    var intervals: [TimeInterval] = []
    for minuteValue in 4...30 {
      intervals.append(TimeInterval(minuteValue * 60))
    }
    return intervals
  }
  
  func updateSelectedFetchIntervalPicker() {
    if let index = self.fetchIntervals.index(of: Global.shared.backgroundFetchInterval) {
      self.fetchIntervalPickerView.selectRow(index, inComponent: 0, animated: true)
      self.fetchIntervalPickerView.reloadComponent(0)
    }
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.fetchIntervals.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return self.fetchIntervals[row].timeString
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let interval = self.fetchIntervals[row]
    Global.shared.backgroundFetchInterval = interval
    MyDataManager.shared.saveMainContext()
    UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    self.reloadContent()
  }
}
