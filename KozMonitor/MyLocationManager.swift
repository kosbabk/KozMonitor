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

class MyLocationManager : NSObject, PermissionProtocol {
  
  // MARK: - Singleton
  
  static let shared: MyLocationManager = MyLocationManager()
  
  private override init() { super.init() }
  
  // MARK: - Properties
  
  let manager: CLLocationManager = CLLocationManager()
  
  var locationAuthorized: Bool {
    return CLLocationManager.authorizationStatus() == .authorizedAlways
  }
  
  // MARK: - Permissions
  
  func refreshPermission(completion: @escaping () -> Void) {
    self.checkPermission(authorized: {
      
      completion()
      
    }, notDetermined: {
      
      // Request permission
      self.manager.requestAlwaysAuthorization()
      
    }) {
      // Denied or restricted
      
      // Disable notifications within the app
      Global.shared.notificationsEnabled = false
      MyDataManager.shared.saveMainContext()
      
      completion()
    }
  }
  
  func checkPermission(authorized: @escaping () -> Void, notDetermined: @escaping () -> Void, denied: (() -> Void)?) {
    switch CLLocationManager.authorizationStatus() {
    case .authorizedAlways:
      authorized()
      break
    case .notDetermined:
      notDetermined()
      break
    case .restricted, .denied, .authorizedWhenInUse:
      denied?()
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
            completion?()
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
}
