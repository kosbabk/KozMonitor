//
//  UIKit+Util.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/20/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

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

