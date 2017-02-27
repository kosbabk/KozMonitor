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
//    let day: TimeInterval = 60*60*24
//    let hour: TimeInterval = 60*60
//    let minute: TimeInterval = 60
//    let days = Int(self / day)
//    let hours = Int(self.truncatingRemainder(dividingBy: day) / hour)
//    let minutes = Int(self.truncatingRemainder(dividingBy: day).truncatingRemainder(dividingBy: hour) / minute)
//    let seconds = Int(self.truncatingRemainder(dividingBy: day).truncatingRemainder(dividingBy: hour).truncatingRemainder(dividingBy: minute))
//    
//    var timeStrings: [String] = []
//    if days > 1 { timeStrings.append("\(days)d") }
//    if hours > 1 { timeStrings.append("\(hours)h") }
//    if minutes > 1 { timeStrings.append("\(minutes)m") }
//    if seconds > 1 { timeStrings.append("\(seconds)s") }
//    return timeStrings.joined(separator: " ")
      
    // OLD
    if self > 120 {
      return "\((self / 60).oneDecimal)m"
    } else {
      return "\(Double(self).oneDecimal)s"
    }
  }
}
