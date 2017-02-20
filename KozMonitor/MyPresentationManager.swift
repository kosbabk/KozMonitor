//
//  MyPresentationManager.swift
//  KozMonitor
//
//  Created by Kelvin Kosbab on 2/20/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

protocol MyPresenationManager {
  var presentationInteractor: MyInteractor? { get set }
  var dismissInteractor: MyInteractor? { get set }
  init(presentationInteractor: MyInteractor, dismissInteractor: MyInteractor)
  init(presentationInteractor: MyInteractor)
  init(dismissInteractor: MyInteractor)
  init()
}
