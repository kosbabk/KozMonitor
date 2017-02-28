//
//  TimeInterval+Util.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/20/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation

enum TimeIntervalType {
  case nanosecond, millisecond, second, minute, hour, day, week, year
  
  var value: TimeInterval {
    switch self {
    case .nanosecond:
      return 1 / 1000000
    case .millisecond:
      return 1 / 1000
    case .second:
      return 1
    case .minute:
      return 60
    case .hour:
      return 60*60
    case .day:
      return 60*60*24
    case .week:
      return 60*60*24*7
    case .year:
      return 60*60*24*7*52
    }
  }
  
  var string: String {
    switch self {
    case .nanosecond:
      return "ns"
    case .millisecond:
      return "ms"
    case .second:
      return "s"
    case .minute:
      return "m"
    case .hour:
      return "h"
    case .day:
      return "d"
    case .week:
      return "w"
    case .year:
      return "y"
    }
  }
  
  static let all: [TimeIntervalType] = [ .year, .week, .day, .hour, .minute, .second, .millisecond ]
}

extension TimeInterval {
  
  var timeString: String {
    var elements: [String] = []
    var remaining = self
    for intervalType in TimeIntervalType.all {
      let value = Int(remaining / intervalType.value)
      if value > 0 {
        elements.append("\(value)\(intervalType.string)")
      }
      remaining -= TimeInterval(value) * intervalType.value
    }
    return elements.joined(separator: " ")
  }
  
  func get(_ intervalType: TimeIntervalType) -> Int {
    return Int(self / intervalType.value)
  }
}
