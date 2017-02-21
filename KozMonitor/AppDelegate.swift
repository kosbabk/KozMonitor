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
    application.setMinimumBackgroundFetchInterval(TimeInterval(Global.shared.backgroundFetchInterval))
    
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
    
    // Update minimum background fetch interval
    application.setMinimumBackgroundFetchInterval(TimeInterval(Global.shared.backgroundFetchInterval))
    
    // Publish the application event
    _ = ApplicationEvent.createOrUpdate(date: Date(), eventType: .appDidEnterBackground, fetchInterval: Global.shared.backgroundFetchInterval, requestPath: Global.shared.requestPath)
    MyDataManager.shared.saveMainContext()
    
    // Begin a background task here if there is a process that requires extra time to execute
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Publish event
    _ = ApplicationEvent.createOrUpdate(date: Date(), eventType: .appDidBecomeActive, fetchInterval: Global.shared.backgroundFetchInterval, requestPath: Global.shared.requestPath)
    MyDataManager.shared.saveMainContext()
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // Publish the application event
    _ = ApplicationEvent.createOrUpdate(date: Date(), eventType: .appWillTerminate, fetchInterval: Global.shared.backgroundFetchInterval, requestPath: Global.shared.requestPath)
    MyDataManager.shared.saveMainContext()
  }

  // MARK: - Background App Refresh
  
  private let backgroundSessionConfigurationIdentifier: String = "Kozinga.KozMonitor.BackgroundSessionConfiguration"
  var backgroundSession: URLSession? = nil
  
  private func createBackgroundSessionInstance() -> URLSession {
    let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: self.backgroundSessionConfigurationIdentifier)
    backgroundConfiguration.isDiscretionary = true
    return URLSession(configuration: backgroundConfiguration, delegate: self, delegateQueue: .main)
  }
  
  var performFetchCompletionHandler: ((_ backgroundFetchResult: UIBackgroundFetchResult) -> Void)? = nil

  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    // Publish the application event
    _ = ApplicationEvent.createOrUpdate(date: Date(), eventType: .backgroundFetchEventStarted, fetchInterval: Global.shared.backgroundFetchInterval, requestPath: Global.shared.requestPath)
    MyDataManager.shared.saveMainContext()
    
    if let requestPath = Global.shared.requestPath, let requestUrl = URL(string: requestPath) {
      
      // Store the fetch completion handler
      self.performFetchCompletionHandler = completionHandler
      
      // Build the data request
      let session = self.backgroundSession ?? self.createBackgroundSessionInstance()
      self.backgroundSession = session
      let downloadTask = session.downloadTask(with: requestUrl)
      downloadTask.resume()
      
      // Establish a timeout just in case
      DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
        if let _ = self.performFetchCompletionHandler {
          self.urlSessionDidFinishEvents(forBackgroundURLSession: session)
        }
      })
    }
  }
}

extension AppDelegate : URLSessionDownloadDelegate {
  
  func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    print("\(self.className) : didBecomeInvalidWithError \(error)")
    self.urlSessionDidFinishEvents(forBackgroundURLSession: session)
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if let error = error {
      print("\(self.className) : didCompleteWithError \(error)")
    }
    self.urlSessionDidFinishEvents(forBackgroundURLSession: session)
  }
  
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    
    // Publish a local notification if enabled
    if Global.shared.notificationsEnabled {
      let content = UNMutableNotificationContent()
      content.title = ApplicationEventType.backgroundFetchEventCompleted.description
      content.body = "Currently expecting an interval of \(Global.shared.backgroundFetchInterval.timeString)"
      //content.sound = UNNotificationSound.default()
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
      let request = UNNotificationRequest(identifier: "KozMonitor.BackgroundFetchEvent", content: content, trigger: trigger)
      UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // Publish the application event
    _ = ApplicationEvent.createOrUpdate(date: Date(), eventType: .backgroundFetchEventCompleted, fetchInterval: Global.shared.backgroundFetchInterval, requestPath: Global.shared.requestPath)
    MyDataManager.shared.saveMainContext()
    
    // Execute background task completion handler
    self.performFetchCompletionHandler?(.newData)
    self.performFetchCompletionHandler = nil
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    print("\(self.className) : Did finish downloading")
  }
}
