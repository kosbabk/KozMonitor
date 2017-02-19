//
//  MyViewController.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

class MyViewController : UIViewController, MyViewControllerIdentifierProtocol, PresentableController {
  
  // MARK: - PresentableController
  
  var presentedMode: PresentationMode = .navStack
  var transitioningDelegateReference: UIViewControllerTransitioningDelegate? = nil
}
