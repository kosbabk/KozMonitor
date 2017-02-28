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
  
  private override init() { super.init() }
  
  // MARK: - Properties
  
  lazy var manager: CLLocationManager = {
    let manager = CLLocationManager()
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.delegate = self
    return manager
  }()
  
  var locationAuthorized: Bool {
    return CLLocationManager.authorizationStatus() == .authorizedAlways
  }
  
  var locations: [MKPointAnnotation] = []
  
  // MARK: - Permissions
  
  func refreshPermission(completion: @escaping () -> Void) {
    self.checkPermission(authorized: {
      
      self.manager.startUpdatingLocation()
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
}

extension MyLocationManager : CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
    if status == .authorizedAlways || status == .authorizedWhenInUse {
      manager.startUpdatingLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
      _ = ApplicationEvent.createOrUpdate(date: Date(), eventType: .backgroundLocationFetchTriggered, fetchInterval: Global.shared.backgroundFetchInterval, requestPath: Global.shared.requestPath)
      MyDataManager.shared.saveMainContext()
      
      
      MyServiceManager.shared.handleBackgroundFetch {
      }
    }
  }
}
