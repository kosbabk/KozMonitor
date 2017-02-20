//
//  PresentableController.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

enum PresentationMode {
  case modal, leftMenu, overCurrentContext, navStack
}

protocol PresentableController {
  var presentedMode: PresentationMode { get set }
  var transitioningDelegateReference: UIViewControllerTransitioningDelegate? { get set }
}

extension PresentableController where Self : UIViewController {
  
  mutating func presentControllerIn(_ presentingController: UIViewController, forMode mode: PresentationMode, inNavigationController: Bool = true, isDragDismissable: Bool = false, completion: (() -> Void)? = nil) {
    
    // Configure this presented controller
    self.presentedMode = mode
    self.hidesBottomBarWhenPushed = true
    self.navigationItem.backBarButtonItem = UIBarButtonItem(text: "", target: nil, action: nil)
    let presentedController: UIViewController = mode != .navStack && inNavigationController ? MyNavigationController(rootViewController: self) : self
    var presentedPresentableController: PresentableController? = presentedController as? PresentableController
    
    // Present this presented controller
    switch mode {
      
    case .modal:
      if UIDevice.isPhone {
        presentedController.modalTransitionStyle = .coverVertical
        presentedController.modalPresentationStyle = .overFullScreen
        presentedController.modalPresentationCapturesStatusBarAppearance = true
      } else {
        presentedController.modalPresentationStyle = .formSheet
      }
      presentingController.present(presentedController, animated: true, completion: completion)
      break
      
    case .leftMenu:
      let presentationManager = isDragDismissable ? LeftMenuPresentationManager(dismissInteractor: DragLeftDismissInteractor(interactiveController: presentedController)) : LeftMenuPresentationManager()
      presentedController.modalPresentationStyle = .custom
      presentedController.modalPresentationCapturesStatusBarAppearance = true
      presentedController.transitioningDelegate = presentationManager
      presentedPresentableController?.transitioningDelegateReference = presentationManager
      presentingController.present(presentedController, animated: true, completion: completion)
      
    case .overCurrentContext:
      presentedController.modalPresentationStyle = .overCurrentContext
      presentedController.modalTransitionStyle = .crossDissolve
      presentingController.present(presentedController, animated: true, completion: completion)
      break
      
    case .navStack:
      presentingController.navigationController?.pushViewController(presentedController, animated: true)
      completion?()
      break
    }
  }
  
  func dismissController(completion: (() -> Void)? = nil){
    switch self.presentedMode {
      
    case .navStack:
      if let navigationController = self.navigationController, navigationController.viewControllers.first != self {
        _ = navigationController.popViewController(animated: true)
        completion?()
      } else {
        self.presentingViewController?.dismiss(animated: true, completion: completion)
      }
      
    default:
      self.presentingViewController?.dismiss(animated: true, completion: completion)
      break
    }
  }
}
