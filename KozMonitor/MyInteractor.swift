//
//  MyInteractor.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/20/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

class MyInteractor : UIPercentDrivenInteractiveTransition {
  
  // MARK: - Properties / Init
  
  var interactiveController: UIViewController? = nil
  var hasStarted: Bool = false
  var shouldFinish: Bool = false
  var percentThreshold: CGFloat = 0.3
  
  init(interactiveController: UIViewController) {
    super.init()
    
    // Configure the view controller for interaction
    interactiveController.view.isUserInteractionEnabled = true
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleGesture(_:)))
    interactiveController.view.addGestureRecognizer(panGestureRecognizer)
    self.interactiveController = interactiveController
  }
  
  func handleGesture(_ sender: UIPanGestureRecognizer) {}
}
