//
//  EmptyStateView.swift
//  Hunter Douglas v3
//
//  Created by Kelvin Kosbab on 2/16/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import Foundation
import UIKit

enum EmptyStateViewType {
  case basic, withImage, withButton, withImageButton
}

class EmptyStateView : UIView {
  
  // MARK: - Class Accessors
  private static func newView() -> EmptyStateView {
    return UINib(nibName: "EmptyStateView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EmptyStateView
  }
  
  static func newView(title: String, message: String, image: UIImage? = nil, buttonTitle: String? = nil, didSelectButton: (() -> Void)? = nil) -> EmptyStateView {
    let view = self.newView()
    view.titleLabel.text = title
    view.messageLabel.text = message
    view.imageView.image = image
    view.actionButton.setTitle(buttonTitle, for: .normal)
    view.didSelectActionButton = didSelectButton
    
    // Configure the state of the view
    if image != nil && buttonTitle != nil {
      view.viewType = .withImageButton
    } else if image != nil {
      view.viewType = .withImage
    } else if buttonTitle != nil {
      view.viewType = .withButton
    } else {
      view.viewType = .basic
    }
    return view
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var actionButton: UIButton!
  
  var didSelectActionButton: (() -> Void)? = nil
  
  var viewType: EmptyStateViewType = .basic {
    didSet {
      switch self.viewType {
      case .basic:
        self.imageView.isHidden = true
        self.titleLabel.isHidden = false
        self.messageLabel.isHidden = false
        self.actionButton.isHidden = true
        break
        
      case .withImage:
        self.imageView.isHidden = false
        self.titleLabel.isHidden = false
        self.messageLabel.isHidden = false
        self.actionButton.isHidden = true
        break
        
      case .withButton:
        self.imageView.isHidden = true
        self.titleLabel.isHidden = false
        self.messageLabel.isHidden = false
        self.actionButton.isHidden = false
        break
        
      case .withImageButton:
        self.imageView.isHidden = false
        self.titleLabel.isHidden = false
        self.messageLabel.isHidden = false
        self.actionButton.isHidden = false
        break
      }
    }
  }
  
  // MARK: - Lifecycle
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.actionButton.layer.cornerRadius = 10
    self.actionButton.layer.masksToBounds = true
  }
  
  // MARK: - Actions
  
  @IBAction func actionButtonSelected() {
    self.didSelectActionButton?()
  }
}
