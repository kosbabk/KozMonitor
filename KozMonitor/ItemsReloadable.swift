//
//  ItemsReloadable.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/19/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

protocol ItemsReloadable {}
extension ItemsReloadable where Self : UIViewController {
  
  func reloadEmptyState() {
    var emptyStateDelegate = self as? EmptyStateDelegate
    emptyStateDelegate?.updateEmptyState()
  }
  
  func reloadEditableElements() {
//    if let itemsEditable = self as? ItemsEditable {
//      itemsEditable.updateNavigationAndTabBar()
//    }
  }
}

extension ItemsReloadable where Self : UICollectionViewController {
  
  func reloadItems() {
    self.collectionView?.reloadData()
    self.reloadEmptyState()
    self.reloadEditableElements()
  }
}

extension ItemsReloadable where Self : UITableViewController {
  
  func reloadItems() {
    self.tableView.reloadData()
    self.reloadEmptyState()
    self.reloadEditableElements()
  }
}
