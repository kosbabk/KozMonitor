//
//  UIBarButtonItem+Util.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/18/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {
  
  convenience init(image: UIImage, target: Any?, action: Selector?) {
    self.init(image: image, style: .plain, target: target, action: action)
    self.setFont()
  }
  
  convenience init(text title: String, target: Any?, action: Selector?) {
    self.init(title: title, style: .plain, target: target, action: action)
    self.setFont()
  }
  
  convenience init(systemItem barButtonSystemItem: UIBarButtonSystemItem, target: Any?, action: Selector?) {
    self.init(barButtonSystemItem: barButtonSystemItem, target: target, action: action)
    self.setFont()
  }
  
  private func setFont() {
    self.setTitleTextAttributes([ NSFontAttributeName : UIFont.systemFont(ofSize: 15) ], for: .normal)
  }
}
