//
//  UIView+Util.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  
  func addToContainer(_ containerView: UIView, atIndex index: Int? = nil) {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.frame = containerView.frame
    
    if let index = index {
      containerView.insertSubview(self, at: index)
    } else {
      containerView.addSubview(self)
    }
    
    let top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 0)
    let bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0)
    let leading = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1, constant: 0)
    let trailing = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1, constant: 0)
    containerView.addConstraints([ top, bottom, leading, trailing ])
    containerView.layoutIfNeeded()
  }
}
