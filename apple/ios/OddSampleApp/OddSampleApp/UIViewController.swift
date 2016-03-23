//
//  UIViewController.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  
  func setImageForTitleView( imageName: String, size: CGSize, centerForMissingRightButton: Bool ) {
    if let headerImage = UIImage(named: imageName) {
      let imageView = UIImageView(image: headerImage)
      imageView.contentMode = .ScaleAspectFit
      self.navigationItem.titleView = imageView
      
      self.navigationItem.titleView?.frame = CGRectMake(0, 0, size.width, size.height)
    }
    
    if centerForMissingRightButton == true {
      addFakeBackButton()
    }
  }
  
  func addFakeBackButton() {
    // this is a hack to center the logo image when only one bar button item is present.
    // iOS automatically gives the title view all the available space and centers the
    // title within.
    // we are adding a fake right bar button to compensate
    let backButtonWidth: CGFloat = 58
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView:  UIView(frame: CGRectMake(0, 0, backButtonWidth, 0)) )
  }
  
}