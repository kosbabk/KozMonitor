//
//  DragRightDismissInteractor.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/20/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

class DragRightDismissInteractor : MyInteractor {
  
  // MARK: - Gestures
  
  override func handleGesture(_ sender: UIPanGestureRecognizer) {
    super.handleGesture(sender)
    
    guard let view = self.interactiveController?.view else {
      return
    }
    
    // Convert position to pull progress (percentage)
    let translation = sender.translation(in: view)
    let horizontalMovement = translation.x / view.bounds.width
    let leftMovement = fmaxf(Float(horizontalMovement), 0.0)
    let leftMovementPercent = fminf(leftMovement, 1.0)
    let progress = CGFloat(leftMovementPercent)
    
    switch sender.state {
    case .began:
      self.hasStarted = true
      self.interactiveController?.dismiss(animated: true, completion: nil)
      
    case .changed:
      self.shouldFinish = progress > self.percentThreshold
      self.update(progress)
    case .cancelled:
      self.hasStarted = false
      self.cancel()
    case .ended:
      self.hasStarted = false
      self.shouldFinish ? self.finish() : self.cancel()
    default:
      break
    }
  }
}
