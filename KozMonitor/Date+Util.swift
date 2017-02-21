//
//  Date+Util.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/19/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation

extension Date {
  
  // MARK: - Helpers
  
  var year: Int {
    return Calendar.current.component(.year, from: self)
  }
  
  var month: Int {
    return Calendar.current.component(.month, from: self)
  }
  
  var day: Int {
    return Calendar.current.component(.day, from: self)
  }
  
  var hour: Int {
    return Calendar.current.component(.hour, from: self)
  }
  
  var minute: Int {
    return Calendar.current.component(.minute, from: self)
  }
  
  var second: Int {
    return Calendar.current.component(.second, from: self)
  }
  
  var uniqueId: Int {
    return Int(self.timeIntervalSince1970)
  }
  
  var nsDate: NSDate {
    return NSDate(timeIntervalSince1970: self.timeIntervalSince1970)
  }
  
  var isToday: Bool {
    return NSCalendar.current.isDateInToday(self)
  }
  
  // MARK: - Comparison
  
  func compareIsGreater(thanDate date: Date) -> Bool {
    return self.compare(date) == .orderedDescending
  }
  
  func compareIsLess(thanDate date: Date) -> Bool {
    return self.compare(date) == .orderedAscending
  }
  
  func compareIsEqual(toDate date: Date) -> Bool {
    return self.compare(date) == .orderedSame
  }
  
  // MARK: - Adding Intervals
  
  func add(years value: Int) -> Date? {
    return Calendar.current.date(byAdding: .year, value: value, to: self)
  }
  
  func add(months value: Int) -> Date? {
    return Calendar.current.date(byAdding: .month, value: value, to: self)
  }
  
  func add(weeks value: Int) -> Date? {
    return Calendar.current.date(byAdding: .weekOfYear, value: value, to: self)
  }
  
  func add(days value: Int) -> Date? {
    return Calendar.current.date(byAdding: .day, value: value, to: self)
  }
  
  func add(hours value: Int) -> Date? {
    return Calendar.current.date(byAdding: .hour, value: value, to: self)
  }
  
  func add(minutes value: Int) -> Date? {
    return Calendar.current.date(byAdding: .minute, value: value, to: self)
  }
  
  func add(seconds value: Int) -> Date? {
    return Calendar.current.date(byAdding: .second, value: value, to: self)
  }
  
  func add(nanoseconds value: Int) -> Date? {
    return Calendar.current.date(byAdding: .nanosecond, value: value, to: self)
  }
  
  func add(timeInterval: Double) -> Date {
    return self.addingTimeInterval(timeInterval)
  }
  
  // MARK: - Duration
  
  func years(fromDate date: Date) -> Int {
    return Calendar.current.dateComponents([ .year ], from: date, to: self).year!
  }
  
  func months(fromDate date: Date) -> Int {
    return Calendar.current.dateComponents([ .month ], from: date, to: self).month!
  }
  
  func weeks(fromDate date: Date) -> Int {
    return Calendar.current.dateComponents([ .weekOfYear ], from: date, to: self).weekOfYear!
  }
  
  func days(fromDate date: Date) -> Int {
    return Calendar.current.dateComponents([ .day ], from: date, to: self).day!
  }
  
  func hours(fromDate date: Date) -> Int {
    return Calendar.current.dateComponents([ .hour ], from: date, to: self).hour!
  }
  
  func minutes(fromDate date: Date) -> Int {
    return Calendar.current.dateComponents([ .minute ], from: date, to: self).minute!
  }
  
  func seconds(fromDate date: Date) -> Double {
    return self.timeIntervalSince(date)
  }
  
  func nanoseconds(fromDate date: Date) -> Int {
    return Calendar.current.dateComponents([ .nanosecond ], from: date, to: self).nanosecond!
  }
  
  // MARK: - Static Helpers
  
  static public func yearsBetween(fromDate: Date, toDate: Date) -> Int {
    return toDate.years(fromDate: fromDate)
  }
  
  static public func monthsBetween(fromDate: Date, toDate: Date) -> Int {
    return toDate.months(fromDate: fromDate)
  }
  
  static public func weeksBetween(fromDate: Date, toDate: Date) -> Int {
    return toDate.weeks(fromDate: fromDate)
  }
  
  static public func daysBetween(fromDate: Date, toDate: Date) -> Int {
    return toDate.days(fromDate: fromDate)
  }
  
  static public func hoursBetweenDates(_ fromDate: Date, toDate: Date) -> Int {
    return toDate.hours(fromDate: fromDate)
  }
  
  static public func minutesBetweenDates(_ fromDate: Date, toDate: Date) -> Int {
    return toDate.minutes(fromDate: fromDate)
  }
  
  static public func secondsBetweenDates(_ fromDate: Date, toDate: Date) -> Double {
    return toDate.seconds(fromDate: fromDate)
  }
  
  static public func nanosecondsBetweenDates(_ fromDate: Date, toDate: Date) -> Int {
    return toDate.nanoseconds(fromDate: fromDate)
  }
  
  // MARK: - Date String Formats
  
  var dateFormat: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter.string(from: self)
  }
  
  var dateTimeFormat: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM-d-YYYY h:mm a"
    return dateFormatter.string(from: self)
  }
  
  var applicationDateFormat: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE MMM d, YYYY"
    return dateFormatter.string(from: self)
  }
  
  var applicationDateFormatNoDayOfWeek: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, YYYY"
    return dateFormatter.string(from: self)
  }
  
  var applicationTimeFormat: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a"
    return dateFormatter.string(from: self)
  }
  
  var formatted_hmma: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a"
    return dateFormatter.string(from: self)
  }
  
  var formatted_MdYY: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "M/d/YY"
    return dateFormatter.string(from: self)
  }
  
  var formatted_MdYYhms: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "M/d/YY h:mm:ss a"
    return dateFormatter.string(from: self)
  }
  
  static func timesampFormat(_ fromDate: Date, toDate: Date) -> String {
    let seconds: Double = Double(Date.nanosecondsBetweenDates(fromDate, toDate: toDate)) / 1000000000
    return "\(seconds.fourDecimals)"
  }
  
  static func parseServerDateString(_ dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter.date(from: dateString)
  }
  
  static func dateToServerDateString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter.string(from: date)
  }
}
