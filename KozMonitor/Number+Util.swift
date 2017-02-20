//
//  Number+Util.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/19/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
//
//  Number+Util.swift
//  SwingLync
//
//  Created by Kelvin Kosbab on 2/27/16.
//  Copyright © 2016 Kozinga. All rights reserved.
//

import Foundation
import UIKit

extension Int {
  
  var string: String {
    return "\(self)"
  }
}

extension Double {
  
  var string: String {
    return "\(self)"
  }
  
  var noDecimals: Int {
    return Int(self)
  }
  
  var oneDecimal: Double {
    return (10*self).rounded()/10
  }
  
  var twoDecimals: Double {
    return (100*self).rounded()/100
  }
  
  var threeDecimals: Double {
    return (1000*self).rounded()/1000
  }
  
  var fourDecimals: Double {
    return (10000*self).rounded()/10000
  }
}

extension Float {
  
  var string: String {
    return "\(self)"
  }
  
  var noDecimals: Int {
    return Int(self)
  }
  
  var oneDecimal: Float {
    return (10*self).rounded()/10
  }
  
  var twoDecimals: Float {
    return (100*self).rounded()/100
  }
  
  var threeDecimals: Float {
    return (1000*self).rounded()/1000
  }
  
  var fourDecimals: Float {
    return (10000*self).rounded()/10000
  }
}

extension CGFloat {
  
  var string: String {
    return "\(self)"
  }
  
  var noDecimals: Int {
    return Int(self)
  }
  
  var oneDecimal: CGFloat {
    return (10*self).rounded()/10
  }
  
  var twoDecimals: CGFloat {
    return (100*self).rounded()/100
  }
  
  var threeDecimals: CGFloat {
    return (1000*self).rounded()/1000
  }
  
  var fourDecimals: CGFloat {
    return (10000*self).rounded()/10000
  }
}
