//
//  LeftMenuPresentationManager.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

class LeftMenuPresentationManager : NSObject, UIViewControllerTransitioningDelegate, MyPresenationManager {
  
  // MARK: - MyPresenationManager
  
  var presentationInteractor: MyInteractor? = nil
  var dismissInteractor: MyInteractor? = nil
  
  required override init() {
    super.init()
  }
  
  required init(presentationInteractor: MyInteractor, dismissInteractor: MyInteractor) {
    self.presentationInteractor = presentationInteractor
    self.dismissInteractor = dismissInteractor
    super.init()
  }
  
  required init(presentationInteractor: MyInteractor) {
    self.presentationInteractor = presentationInteractor
    super.init()
  }
  
  required init(dismissInteractor: MyInteractor) {
    self.dismissInteractor = dismissInteractor
    super.init()
  }
  
  // MARK: - UIViewControllerTransitioningDelegate
  
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    return LeftMenuPresentationController(presentedViewController: presented, presenting: source)
  }
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return LeftMenuAnimator()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return LeftMenuAnimator()
  }
  
  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    if let presentationInteractor = self.presentationInteractor {
      return presentationInteractor.hasStarted ? presentationInteractor : nil
    }
    return nil
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    if let dismissInteractor = self.dismissInteractor {
      return dismissInteractor.hasStarted ? dismissInteractor : nil
    }
    return nil
  }
  
  // MARK: - Animator
  
  class LeftMenuAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      
      guard let toViewController = transitionContext.viewController(forKey: .to), let fromViewController = transitionContext.viewController(forKey: .from) else {
        return
      }
      
      let isUnwinding = toViewController.presentedViewController == fromViewController
      let isPresenting = !isUnwinding
      
      // let presentingViewController = isPresenting ? fromViewController : toViewController
      let presentedViewController = isPresenting ? toViewController : fromViewController
      let containerView = transitionContext.containerView
      
      let presentedWidth = max(min(containerView.frame.size.width - 40, 360), 280)
      if isPresenting {
        
        // Currently presenting
        
        presentedViewController.view.frame.origin.x -= presentedWidth
        containerView.addSubview(presentedViewController.view)
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
          presentedViewController.view.frame.origin.x += presentedWidth
        }, completion: { (_) in
          transitionContext.completeTransition(true)
        })
        
      } else {
        
        // Currently not presenting
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
          presentedViewController.view.frame.origin.x -= presentedWidth
          
        }, completion: { (_) in
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
      }
    }
  }
  
  // MARK: - Presentation Controller
  
  class LeftMenuPresentationController : UIPresentationController {
    
    // MARK: - Properties
    
    private var blurView: UIView? = nil
    
    // MARK: - Blur View
    
    private func createBlurView() -> UIView {
      let blurView = UIView()
      blurView.backgroundColor = .black
      blurView.frame = self.presentingViewController.view.bounds
      blurView.isUserInteractionEnabled = true
      blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissController)))
      return blurView
    }
    
    // MARK: - UIPresentationController
    
    override func presentationTransitionWillBegin() {
      
      guard let containerView = self.containerView else {
        return
      }
      
      // Setup blur view
      let blurView = self.blurView ?? self.createBlurView()
      self.blurView = blurView
      blurView.addToContainer(containerView, atIndex: 0)
      blurView.alpha = 0
      
      // Begin animation
      self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
        blurView.alpha = 0.75
      }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
      self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
        self.blurView?.alpha = 0
      }, completion: nil)
    }
    
    override func containerViewWillLayoutSubviews() {
      super.containerViewWillLayoutSubviews()
      
      self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    override var shouldPresentInFullscreen: Bool {
      return false
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
      if let size = self.containerView?.frame.size {
        let width = max(min(size.width - 40, 360), 320)
        return CGRect(x: 0, y: 0, width: width, height: size.height)
      }
      return CGRect(x: 0, y: 0, width: 275, height: UIScreen.main.bounds.height)
    }
    
    // MARK: - Actions
    
    func dismissController() {
      self.presentedViewController.dismiss(animated: true, completion: nil)
    }
  }
}
