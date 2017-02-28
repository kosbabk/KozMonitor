//
//  MyNotificationManger.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/25/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class MyNotificationManger : NSObject, PermissionProtocol {
  
  // MARK: - Singleton
  
  static let shared: MyNotificationManger = MyNotificationManger()
  
  private override init() { super.init() }
  
  // MARK: - Properties
  
  var notificationsAuthorized: Bool? = nil
  
  // MARK: - Permission
  
  func refreshPermission(completion: @escaping () -> Void) {
    self.checkPermission(authorized: {
      
      self.notificationsAuthorized = true
      DispatchQueue.main.async {
        completion()
      }
      
    }, notDetermined: {
      
      // Request authorization from the user
      UNUserNotificationCenter.current().requestAuthorization(options: [ .alert, .badge, .sound, .carPlay ]) { (authorized, error) in
        if authorized {
          print("\(self.className) : User authorized notifications")
          self.notificationsAuthorized = true
          Global.shared.notificationsEnabled = true
          MyDataManager.shared.saveMainContext()
          
        } else {
          print("\(self.className) : User did not authorize notifications")
          self.notificationsAuthorized = false
          Global.shared.notificationsEnabled = false
          MyDataManager.shared.saveMainContext()
        }
        DispatchQueue.main.async {
          completion()
        }
      }
      
    }) {
      // Denied
      
      // Disable notifications within the app
      self.notificationsAuthorized = false
      Global.shared.notificationsEnabled = false
      MyDataManager.shared.saveMainContext()
      
      DispatchQueue.main.async {
        completion()
      }
    }
  }
  
  func checkPermission(authorized: @escaping () -> Void, notDetermined: @escaping () -> Void, denied: (() -> Void)?) {
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
      switch settings.authorizationStatus {
      case .authorized:
        DispatchQueue.main.async {
          authorized()
        }
        break
      case .notDetermined:
        DispatchQueue.main.async {
          notDetermined()
        }
        break
      case.denied:
        DispatchQueue.main.async {
          denied?()
        }
        break
      }
    }
  }
  
  func promptAlertIfDenied(_ presentingViewController: UIViewController, completion: (() -> Void)?) {
    self.checkPermission(authorized: {
      // Do nothing
    }, notDetermined: {
      // Do nothing
    }) {
      let alertController = UIAlertController(title: "Background Fetch Access Disabled", message: "In order to get background notifications, please open this app's settings and enable background fetch.", preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        completion?()
      }))
      alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (_) in
        if let url = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url, options: [:]) { (_) in
            DispatchQueue.main.async {
              completion?()
            }
          }
        }
      }))
      presentingViewController.present(alertController, animated: true, completion: nil)
    }

  }
  
  // MARK: - Publishing
  
  func publishNotification(title: String, body: String, timeInterval: TimeInterval = 1, repeats: Bool = false, completion: (() -> Void)? = nil) {
    
    if Global.shared.notificationsEnabled {
      let content = UNMutableNotificationContent()
      content.title = title
      content.body = body
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
      let notificationIdentifier: String = "\(self.className).publishNotification.\(title).\(Date().serverDateString)"
      let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
      UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
        completion?()
      })
      
    } else {
      completion?()
    }
  }
}
