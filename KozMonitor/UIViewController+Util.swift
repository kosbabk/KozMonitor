//
//  UIViewController+Util.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  
  // MARK: - Accessing Controllers from Storyboard
  
  static func newStoryboardController(fromStoryboardWithName storyboard: String, withIdentifier identifier: String) -> UIViewController {
    let storyboard = UIStoryboard(name: storyboard, bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: identifier)
  }
  
  // MARK: - Adding child view controller helpers
  
  func addChildViewController(_ childViewController: UIViewController, containerView: UIView) {
    self.addChildViewController(childViewController)
    childViewController.view.addToContainer(containerView)
    childViewController.didMove(toParentViewController: self)
  }
  
  // MARK: - Hiding Tab Bar
  
  func showTabBar(completion: (() -> Void)? = nil) {
    if let tabBarController = self.tabBarController {
      let tabBarFrame = tabBarController.tabBar.frame
      let heightOffset = tabBarFrame.size.height
      UIView.animate(withDuration: 0.3, animations: {
        let tabBarNewY = tabBarFrame.origin.y - heightOffset
        tabBarController.tabBar.frame = CGRect(x: tabBarFrame.origin.x, y: tabBarNewY, width: tabBarFrame.size.width, height: tabBarFrame.size.height)
      }, completion: { (_) in
        tabBarController.tabBar.isUserInteractionEnabled = true
        completion?()
      })
    }
  }
  
  func hideTabBar(completion: (() -> Void)? = nil) {
    if let tabBarController = self.tabBarController {
      tabBarController.tabBar.isUserInteractionEnabled = false
      let tabBarFrame = tabBarController.tabBar.frame
      let heightOffset = tabBarFrame.size.height
      UIView.animate(withDuration: 0.3, animations: {
        let tabBarNewY = tabBarFrame.origin.y + heightOffset
        tabBarController.tabBar.frame = CGRect(x: tabBarFrame.origin.x, y: tabBarNewY, width: tabBarFrame.size.width, height: tabBarFrame.size.height)
      }, completion: { (_) in
        completion?()
      })
    }
  }
}

extension UITableViewController {
  
  func scrollToLastItem(animated: Bool = true) {
    let lastIndexPath = self.lastIndexPath
    self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
  }
  
  var lastIndexPath: IndexPath {
    let lastSectionIndex = max(0, self.tableView.numberOfSections - 1)
    let lastRowIndex = max(0, self.tableView.numberOfRows(inSection: lastSectionIndex) - 1)
    return IndexPath(row: lastRowIndex, section: lastSectionIndex)
  }
}
