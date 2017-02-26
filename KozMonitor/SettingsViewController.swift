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
  @IBOutlet weak var expectedFetchIntervalLabel: UILabel!
  @IBOutlet weak var expectedFetchIntervalPickerView: UIPickerView!
  
  @IBOutlet weak var notificationSwitch: UISwitch!
  
  @IBOutlet weak var getEnabledSwitch: UISwitch!
  
  @IBOutlet weak var versionLabel: UILabel!
  @IBOutlet weak var buildLabel: UILabel!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.expectedFetchIntervalPickerView.delegate = self
    self.expectedFetchIntervalPickerView.dataSource = self
    
    // Notification permissions
    MyNotificationManger.shared.promptAlertIfDenied(self, completion: nil)
    
    self.buildFetchController()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.reloadContent()
    MyNotificationManger.shared.refreshPermission {
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
    
    self.expectedFetchIntervalLabel.text = Global.shared.backgroundFetchInterval.timeString
    self.reloadIntervalPicker(animated: animated)
    
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
  
  let dismissAndFetchIntervalSection: Int = 0
  let notificationsSection: Int = 1
  let networkGetSection: Int = 2
  let infoSection: Int = 3
  
  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == self.networkGetSection, let path = Global.shared.requestPath {
      return "Request Path: \(path)"
    }
    return nil
  }
}

extension SettingsViewController : UIPickerViewDelegate, UIPickerViewDataSource {
  
  func reloadIntervalPicker(animated: Bool = false) {
    if let index = self.timeIntervals.index(of: Global.shared.backgroundFetchInterval) {
      self.expectedFetchIntervalPickerView.selectRow(index, inComponent: 0, animated: animated)
      self.expectedFetchIntervalPickerView.reloadComponent(0)
    }
  }
  
  private var timeIntervals: [TimeInterval] {
    var intervals: [TimeInterval] = []
    for minute in 0...30 {
      intervals.append(TimeInterval(minute * 60))
    }
    return intervals
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.timeIntervals.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    let timeInterval = self.timeIntervals[row]
    return timeInterval.timeString
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let timeInterval = self.timeIntervals[row]
    Global.shared.backgroundFetchInterval = timeInterval
    MyDataManager.shared.saveMainContext()
  }
}
