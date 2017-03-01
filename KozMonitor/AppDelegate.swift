//
//  AppDelegate.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    // Wunderground Key ID: 0137f0460db72c7d
    // Project Name: KozMonitor
    // Company Website: kozinga.net
    // For more details visit https://www.wunderground.com/weather/api/d/docs?MR=1
    Global.shared.requestPath = "https://api.wunderground.com/api/0137f0460db72c7d/conditions/q/CA/San_Francisco.json"
    MyDataManager.shared.saveMainContext()
    
    // Set minimum background fetch interval
    if Global.shared.backgroundFetchInterval < UIApplicationBackgroundFetchIntervalMinimum {
      Global.shared.backgroundFetchInterval = UIApplicationBackgroundFetchIntervalMinimum
      MyDataManager.shared.saveMainContext()
    }
    UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    
    // Request necessary permissions
    MyNotificationManger.shared.refreshPermission {
      MyLocationManager.shared.refreshPermission {
        print("\(self.className) : Completed refreshing permission status")
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
    
    // Publish the application event
    _ = ApplicationEvent.createOrUpdate(date: Date(), eventType: .appDidEnterBackground, fetchInterval: Global.shared.backgroundFetchInterval, requestPath: Global.shared.requestPath)
    MyDataManager.shared.saveMainContext()
    
    // Start location services if not already
    MyLocationManager.shared.startLocationServices()
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
  
  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    // Publish the application event
    let eventType: ApplicationEventType = .backgroundFetchTriggered
    _ = ApplicationEvent.createOrUpdate(date: Date(), eventType: eventType, fetchInterval: Global.shared.backgroundFetchInterval, requestPath: Global.shared.requestPath)
    MyDataManager.shared.saveMainContext()
    
    // Publish a local notification if enabled
    MyNotificationManger.shared.publishNotification(title: eventType.description, body: eventType.body)
    
    MyServiceManager.shared.handleBackgroundFetch {
      completionHandler(.newData)
    }
  }
}
