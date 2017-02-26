//
//  PermissionProtocol.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/25/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

protocol PermissionProtocol {
  func refreshPermission(completion: @escaping () -> Void)
  func checkPermission(authorized: @escaping () -> Void, notDetermined: @escaping () -> Void, denied: (() -> Void)?)
  func promptAlertIfDenied(_ presentingViewController: UIViewController, completion: (() -> Void)?)
}
