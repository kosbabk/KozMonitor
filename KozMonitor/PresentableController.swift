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
  
  mutating func presentControllerIn(_ parentController: UIViewController, forMode mode: PresentationMode, inNavigationController: Bool = true, completion: (() -> Void)? = nil) {
    self.presentedMode = mode
    self.configureBackButtonItem(parentController: parentController)
    
    switch mode {
      
    case .modal:
      let viewController = inNavigationController ? MyNavigationController(rootViewController: self) : self
      if UIDevice.isPhone {
        viewController.modalTransitionStyle = .coverVertical
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalPresentationCapturesStatusBarAppearance = true
      } else {
        viewController.modalPresentationStyle = .formSheet
      }
      parentController.present(viewController, animated: true, completion: completion)
      break
      
    case .leftMenu:
      let viewController = inNavigationController ? MyNavigationController(rootViewController: self) : self
      viewController.modalPresentationStyle = .custom
      viewController.modalPresentationCapturesStatusBarAppearance = true
      let manager = LeftMenuPresentationManager()
      if viewController is PresentableController {
        var presentableController = viewController as! PresentableController
        presentableController.transitioningDelegateReference = manager
      }
      viewController.transitioningDelegate = manager
      parentController.present(viewController, animated: true, completion: completion)
      
    case .overCurrentContext:
      let viewController = inNavigationController ? MyNavigationController(rootViewController: self) : self
      viewController.modalPresentationStyle = .overCurrentContext
      viewController.modalTransitionStyle = .crossDissolve
      parentController.present(viewController, animated: true, completion: completion)
      break
      
    case .navStack:
      self.hidesBottomBarWhenPushed = true
      parentController.navigationController?.pushViewController(self, animated: true)
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
  
  private func configureBackButtonItem(parentController: UIViewController) {
    self.navigationItem.backBarButtonItem = UIBarButtonItem(text: "", target: nil, action: nil)
    parentController.navigationItem.backBarButtonItem = UIBarButtonItem(text: "", target: nil, action: nil)
  }
}
