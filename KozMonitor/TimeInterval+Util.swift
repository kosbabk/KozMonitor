//
//  TimeInterval+Util.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/20/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation

extension TimeInterval {
  
  var timeString: String {
    return self > 120 ? "\((self / 60).oneDecimal)m" : "\(Double(self).oneDecimal)s"
  }
}
