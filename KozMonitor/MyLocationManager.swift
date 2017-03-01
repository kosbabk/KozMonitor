//
//  MyLocationManager.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/25/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import MapKit

class MyLocationManager : NSObject, PermissionProtocol {
  
  // MARK: - Singleton
  
  static let shared: MyLocationManager = MyLocationManager()
  
  private override init() {
    super.init()
    
    self.manager.desiredAccuracy = kCLLocationAccuracyBest
    self.manager.distanceFilter = kCLDistanceFilterNone
    self.manager.delegate = self
    self.manager.allowsBackgroundLocationUpdates = true
  }
  
  // MARK: - Properties
  
  let manager: CLLocationManager = CLLocationManager()
  
  var locationAuthorized: Bool {
    return CLLocationManager.authorizationStatus() == .authorizedAlways
  }
  
  var backgroundTask = UIBackgroundTaskInvalid
  
  var locations: [MKPointAnnotation] = []
  
  // MARK: - Permissions
  
  func refreshPermission(completion: @escaping () -> Void) {
    self.checkPermission(authorized: {
      
      self.startLocationServices()
      DispatchQueue.main.async {
        completion()
      }
      
    }, notDetermined: {
      
      // Request permission
      self.manager.requestAlwaysAuthorization()
      DispatchQueue.main.async {
        completion()
      }
      
    }) {
      // Denied or restricted
      
      // Disable notifications within the app
      Global.shared.notificationsEnabled = false
      MyDataManager.shared.saveMainContext()
      
      DispatchQueue.main.async {
        completion()
      }
    }
  }
  
  func checkPermission(authorized: @escaping () -> Void, notDetermined: @escaping () -> Void, denied: (() -> Void)?) {
    switch CLLocationManager.authorizationStatus() {
    case .authorizedAlways:
      DispatchQueue.main.async {
        authorized()
      }
      break
    case .notDetermined:
      DispatchQueue.main.async {
        notDetermined()
      }
      break
    case .restricted, .denied, .authorizedWhenInUse:
      DispatchQueue.main.async {
        denied?()
      }
      break
    }
  }
  
  func promptAlertIfDenied(_ presentingViewController: UIViewController, completion: (() -> Void)?) {
    self.checkPermission(authorized: {
      // Do nothing
    }, notDetermined: {
      // Do nothing
    }) { 
      let alertController = UIAlertController(title: "Background Location Access Disabled", message: "In order to get background notifications, please open this app's settings and set location access to 'Always'.", preferredStyle: .alert)
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
      presentingViewController.present(alertController, animated: true, completion: completion)
    }
  }
  
  // MARK: - Location Updates
  
  func startLocationServices() {
    self.manager.startUpdatingLocation()
  }
  
  func stopLocationServices() {
    self.manager.stopUpdatingLocation()
  }
}

extension MyLocationManager : CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
    if status == .authorizedAlways {
      self.startLocationServices()
    } else {
      self.manager.requestAlwaysAuthorization()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    self.backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
      UIApplication.shared.endBackgroundTask(self.backgroundTask)
      self.backgroundTask = UIBackgroundTaskInvalid
    })
    
    guard let mostRecentLocation = locations.last else {
      return
    }
    
    // Add another annotation to the map.
    let annotation = MKPointAnnotation()
    annotation.coordinate = mostRecentLocation.coordinate
    
    // Also add to our map so we can remove old values later
    self.locations.append(annotation)
    
    // Remove values if the array is too big
    while locations.count > 100 {
      if let annotationToRemove = self.locations.first {
      }
      self.locations.remove(at: 0)
      
      // Also remove from the map
      // mapView.removeAnnotation(annotationToRemove)
    }
    
    if UIApplication.shared.applicationState == .active {
      print("\(self.className) : App is active. New location is %@", mostRecentLocation)
      //mapView.showAnnotations(self.locations, animated: true)
    } else {
      print("\(self.className) : App is backgrounded. New location is %@", mostRecentLocation)
    }
    
    // Check for background fetch if eclipsed interval
    var shouldBackgroundFetch = false
    if let lastBackgroundFetchDate = Global.shared.lastBackgroundFetchDate as? Date, abs(Date().timeIntervalSince(lastBackgroundFetchDate)) > Global.shared.backgroundFetchInterval {
      shouldBackgroundFetch = true
    } else if Global.shared.lastBackgroundFetchDate == nil {
      shouldBackgroundFetch = true
    }
    
    if shouldBackgroundFetch {
      
      // Publish the application event
      let eventType: ApplicationEventType = UIApplication.shared.applicationState == .active ? .activeLocationFetchTriggered : .backgroundLocationFetchTriggered
      _ = ApplicationEvent.createOrUpdate(date: Date(), eventType: eventType, fetchInterval: Global.shared.backgroundFetchInterval, requestPath: Global.shared.requestPath)
      MyDataManager.shared.saveMainContext()
      
      // Publish a local notification if enabled
      MyNotificationManger.shared.publishNotification(title: eventType.description, body: eventType.body)
      
      MyServiceManager.shared.handleBackgroundFetch {
      }
    }
  }
}
