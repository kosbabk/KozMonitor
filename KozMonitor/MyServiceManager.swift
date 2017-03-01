//
//  MyServiceManager.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/25/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation

class MyServiceManager : NSObject {
  
  // MARK: - Singleton
  
  static let shared: MyServiceManager = MyServiceManager()
  
  private override init() { super.init() }
  
  // MARK: - Properties
  
  var backgroundSession: URLSession? = nil
  var currentTaskCompletionHandler: (() -> Void)? = nil
  
  private func createBackgroundSession() -> URLSession {
    let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "\(self.className).BackgroundSessionConfiguration")
    return URLSession(configuration: backgroundConfiguration, delegate: self, delegateQueue: nil)
  }
  
  // MARK: - Background Download Task
  
  func handleBackgroundFetch(completion: @escaping () -> Void) {
    
    // Update the last request date in global
    Global.shared.lastBackgroundFetchDate = Date() as NSDate
    MyDataManager.shared.saveMainContext()
    
    if Global.shared.backgroundFetchGetEnabled {
      self.startDownloadTask {
        completion()
      }
    } else {
      completion()
    }
  }
  
  func startDownloadTask(completion: @escaping () -> Void) {
    
    guard let url = Global.shared.requestUrl else {
      completion()
      return
    }
    
    // Publish the application event
    _ = ApplicationEvent.createOrUpdate(date: Date(), eventType: .backgroundFetchGetStarted, fetchInterval: Global.shared.backgroundFetchInterval, requestPath: Global.shared.requestPath)
    MyDataManager.shared.saveMainContext()
    
    // Save the completion handler
    self.currentTaskCompletionHandler = completion
    
    // Build the download task
    let session = self.backgroundSession ?? self.createBackgroundSession()
    self.backgroundSession = session
    let downloadTask = session.downloadTask(with: url)
    downloadTask.resume()
  }
}

extension MyServiceManager : URLSessionDownloadDelegate {
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if let error = error {
      print("\(self.className) : didCompleteWithError \(error)")
    }
    self.downloadTaskCompleted()
  }
  
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    print("\(self.className) : urlSessionDidFinishEvents")
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    print("\(self.className) : Did finish downloading")
  }
  
  private func downloadTaskCompleted() {
    
    // Publish the application event
    let eventType: ApplicationEventType = .backgroundFetchGetCompleted
    _ = ApplicationEvent.createOrUpdate(date: Date(), eventType: eventType, fetchInterval: Global.shared.backgroundFetchInterval, requestPath: Global.shared.requestPath)
    MyDataManager.shared.saveMainContext()
    
    // Publish a local notification if enabled
    MyNotificationManger.shared.publishNotification(title: eventType.description, body: eventType.body)
    
    // Update the last request date in global
    Global.shared.lastRequestDate = Date() as NSDate
    MyDataManager.shared.saveMainContext()
    
    // Execute background task completion handler
    self.currentTaskCompletionHandler?()
    self.currentTaskCompletionHandler = nil
  }
}
