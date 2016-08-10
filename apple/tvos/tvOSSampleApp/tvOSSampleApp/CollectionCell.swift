//
//  CollectionCell.swift
//  tvOSSampleApp
//
//  Created by Patrick McConnell on 1/28/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDKtvOS

class CollectionCell: UICollectionViewCell {
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  
  func configureWithCollection(_ collection: OddMediaObjectCollection) {
    
    self.titleLabel?.text = collection.title
    
    collection.thumbnail { (image) -> Void in
      if let thumbnail = image {
        DispatchQueue.main.async(execute: { () -> Void in
          self.thumbnailImageView?.image = thumbnail
        })
      }
    }
  }
  
  func becomeFocusedUsingAnimationCoordinator(_ coordinator: UIFocusAnimationCoordinator) {
    coordinator.addCoordinatedAnimations({ () -> Void in
      self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
      self.layer.shadowColor = UIColor.black.cgColor
      self.layer.shadowOffset = CGSize(width: 10, height: 10)
      self.layer.shadowOpacity = 0.2
      self.layer.shadowRadius = 5
      }) { () -> Void in }
  }
  
  func resignFocusUsingAnimationCoordinator(_ coordinator: UIFocusAnimationCoordinator) {
    coordinator.addCoordinatedAnimations({ () -> Void in
      self.transform = CGAffineTransform.identity
      self.layer.shadowColor = nil
      self.layer.shadowOffset = CGSize.zero
      }) { () -> Void in }
  }
  
  override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocus(in: context, with: coordinator)
    
    guard let nextFocusedView = context.nextFocusedView else { return }
    
    if nextFocusedView == self {
      self.becomeFocusedUsingAnimationCoordinator(coordinator)
      self.addParallaxMotionEffects()
    } else {
      self.resignFocusUsingAnimationCoordinator(coordinator)
      self.motionEffects = []
    }
  }

    
}
