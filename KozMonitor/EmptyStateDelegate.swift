//
//  EmptyStateDelegate.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/19/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

protocol EmptyStateDelegate {
  var emptyStateTitle: String { get }
  var emptyStateMessage: String { get }
  var emptyStateImage: UIImage? { get }
  var emptyStateButtonTitle: String? { get }
  func updateEmptyState()
  func emptyStateButtonSelected()
}

extension EmptyStateDelegate where Self : UIViewController {
  
  func updateEmptyState() {
    
    if let collectionViewController = self as? UICollectionViewController, let collectionView = collectionViewController.collectionView {
      
      var areItemsInCollectionView: Bool = false
      for section in 0..<collectionViewController.numberOfSections(in: collectionView) {
        let numberOfItemsInSection = collectionViewController.collectionView(collectionView, numberOfItemsInSection: section)
        if numberOfItemsInSection > 0 {
          areItemsInCollectionView = true
          break
        }
      }
      if areItemsInCollectionView {
        self.hideEmptyState()
      } else {
        self.showEmptyState()
      }
      
    } else if let tableViewController = self as? UITableViewController, let tableView = tableViewController.tableView {
      
      var areItemsInTableView: Bool = false
      for section in 0..<tableView.numberOfSections {
        let numberOfItemsInSection = tableView.numberOfRows(inSection: section)
        if numberOfItemsInSection > 0 {
          areItemsInTableView = true
          break
        }
      }
      if areItemsInTableView {
        self.hideEmptyState()
      } else {
        self.showEmptyState()
      }
      
    } else {
      self.hideEmptyState()
    }
  }
  
  func showEmptyState() {
    
    // Hide empty state if necessary
    self.hideEmptyState()
    
    // Configure the empty view
    let emptyStateView = EmptyStateView.newView(title: self.emptyStateTitle, message: self.emptyStateMessage, image: self.emptyStateImage, buttonTitle: self.emptyStateButtonTitle, didSelectButton: self.emptyStateButtonSelected)
    if let collectionViewController = self as? UICollectionViewController, let collectionView = collectionViewController.collectionView {
      emptyStateView.backgroundColor = collectionView.backgroundColor
      emptyStateView.addToContainer(self.view)
    } else if let tableViewController = self as? UITableViewController, let tableView = tableViewController.tableView {
      emptyStateView.backgroundColor = tableView.backgroundColor
      if let navigationController = self.navigationController {
        let convertedTableViewFrame = tableViewController.tableView.convert(tableViewController.tableView.frame, to: navigationController.view)
        let tableViewYOffset = convertedTableViewFrame.minY
        emptyStateView.addToContainer(navigationController.view, topMargin: tableViewYOffset)
      } else {
        emptyStateView.addToContainer(tableViewController.view, topMargin: 50)
      }
    } else {
      emptyStateView.backgroundColor = self.view.backgroundColor
      emptyStateView.addToContainer(self.view)
    }
  }
  
  func hideEmptyState() {
    
    // Find the empty state view and remove it
    var emptyStateViews: [EmptyStateView] = []
    
    // Special case for table view
    if let _ = self as? UITableViewController, let navigationController = self.navigationController {
      for view in navigationController.view.subviews {
        if let view = view as? EmptyStateView {
          emptyStateViews.append(view)
          break
        }
      }
      
    } else {
      
      
      for view in self.view.subviews {
        if let view = view as? EmptyStateView {
          emptyStateViews.append(view)
          break
        }
      }
    }
    
    for view in emptyStateViews {
      view.removeFromSuperview()
    }
  }
}
