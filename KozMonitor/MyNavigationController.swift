//
//  MyNavigationController.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

class MyNavigationController : UINavigationController, MyViewControllerIdentifierProtocol, PresentableController {
  
  // MARK: - PresentableController
  
  var presentedMode: PresentationMode = .navStack
  var transitioningDelegateReference: UIViewControllerTransitioningDelegate? = nil
}
