//
//  DragDownDismissInteractor.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/20/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

class DragDownDismissInteractor : MyInteractor {
  
  // MARK: - Gestures
  
  override func handleGesture(_ sender: UIPanGestureRecognizer) {
    super.handleGesture(sender)
    
    guard let view = self.interactiveController?.view else {
      return
    }
    
    // Convert position to pull progress (percentage)
    let translation = sender.translation(in: view)
    let verticalMovement = translation.y / view.bounds.height
    let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
    let downwardMovementPercent = fminf(downwardMovement, 1.0)
    let progress = CGFloat(downwardMovementPercent)
    
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
