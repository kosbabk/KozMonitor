//
//  AppDelegate.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    // Set minimum background fetch interval
    self.setBackgroundFetchInterval(application: application)
    
    // Request notifications
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
      
      if !settings.authorizationStatus.isAuthorized {
        
        // Disable notifications within the app
        Global.shared.notificationsEnabled = false
        MyDataManager.shared.saveMainContext()
        
        // If the notification settings have not been determined yet display authorization prompt
        if settings.authorizationStatus.isNotDetermined {
          
          UNUserNotificationCenter.current().requestAuthorization(options: [ .alert, .badge, .sound, .carPlay ]) { (authorized, error) in
            if authorized {
              print("\(self.className) : User authorized notifications")
              Global.shared.notificationsEnabled = true
              MyDataManager.shared.saveMainContext()
              
            } else {
              print("\(self.className) : User did not authorize notifications")
              Global.shared.notificationsEnabled = false
              MyDataManager.shared.saveMainContext()
            }
          }
        }
      }
    }
    
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    Global.shared.activeSession = nil
    MyDataManager.shared.saveMainContext()
    
    // Set minimum background fetch interval
    self.setBackgroundFetchInterval(application: application)
    
    // Begin a background task here if there is a process that requires extra time to execute
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    Global.shared.activeSession = nil
    MyDataManager.shared.saveMainContext()
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

  // MARK: - Background App Refresh
  
  private func setBackgroundFetchInterval(application: UIApplication) {
    application.setMinimumBackgroundFetchInterval(TimeInterval(Global.shared.backgroundFetchInterval))
  }

  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    let activeSession = Global.shared.activeSession ?? FetchSession.createOrUpdate(startDate: Date(), selectedFetchInterval: Global.shared.backgroundFetchInterval, requestPath: Global.shared.requestPath)
    Global.shared.activeSession = activeSession
    MyDataManager.shared.saveMainContext()
    
    let configuration = URLSessionConfiguration.default
    let session = URLSession(configuration: configuration)
    let startTime = Date()
    
    if let requestPath = Global.shared.requestPath, let requestUrl = URL(string: requestPath) {
      let dataTask = session.dataTask(with: requestUrl, completionHandler: { (data, urlResponse, error) in
        
        // Save the fetch event
        let processingTime = Date().timeIntervalSince(startTime)
        let bytesProcessed = data?.count ?? 0
        _ = FetchEvent.createOrUpdate(date: Date(), processingTime: processingTime, bytesProcessed: bytesProcessed, session: activeSession)
        MyDataManager.shared.saveMainContext()
        
        if Global.shared.notificationsEnabled {
          
          // Create local notification
          let content = UNMutableNotificationContent()
          content.title = "Background Event Triggered"
          if let averageMinutes = activeSession.averageFetchInterval {
            let averageString = averageMinutes < 2 ? "\((averageMinutes * 60).twoDecimals)s" : "\(averageMinutes.twoDecimals)m"
            content.body = "Current average fetch interval: \(averageString) (\(activeSession.selectedFetchInterval)m expected)"
          } else {
            content.body = "Currently expecting an interval of \(activeSession.selectedFetchInterval)m"
          }
          //content.sound = UNNotificationSound.default()
          let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
          let request = UNNotificationRequest(identifier: "KozMonitor.BackgroundFetchEvent", content: content, trigger: trigger)
          UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        
        // Execute background task completion handler
        completionHandler(.newData)
      })
      dataTask.resume()
    }
  }
}

extension UIApplicationState {
  
  var isActive: Bool {
    return self == .active
  }
  
  var isInactive: Bool {
    return self == .inactive
  }
  
  var isBackground: Bool {
    return self == .background
  }
}

extension UIBackgroundFetchResult {
  
  var isNewData: Bool {
    return self == .newData
  }
  
  var isFailed: Bool {
    return self == .failed
  }
  
  var isNoData: Bool {
    return self == .noData
  }
}

extension UNAuthorizationStatus {
  
  var isAuthorized: Bool {
    return self == .authorized
  }
  
  var isDenied: Bool {
    return self == .denied
  }
  
  var isNotDetermined: Bool {
    return self == .notDetermined
  }
}
