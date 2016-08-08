//
//  GradientNavigationController.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/17/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import Foundation
import UIKit

extension CAGradientLayer {
  class func gradientLayerForBounds(bounds: CGRect) -> CAGradientLayer {
    
    //    let edgeColor = UIColor(red:0.17, green:0.05, blue:0.36, alpha:1)
    //    let centerColor =  UIColor(red:0.35, green:0.13, blue:0.65, alpha:1)
    
    let theme = ThemeManager.defaultManager.currentTheme()
    let edgeColor = theme.primaryNavigationBarGradientEdgeColor
    let centerColor = theme.primaryNavigationBarGradientCenterColor
    
    let layer = CAGradientLayer()
    layer.frame = bounds
    
    layer.startPoint = CGPoint(x: 0, y: 0.5)
    layer.endPoint = CGPoint(x: 1, y: 0.5)
    let colors: [CGColorRef] = [
      edgeColor.CGColor,
      centerColor.CGColor,
      edgeColor.CGColor
    ]
    layer.colors = colors
    layer.opaque = false
    layer.locations = [0.0, 0.5, 1.0]
    
    return layer
  }
  
}

class GradientNavigationController: UINavigationController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationBar.translucent = false
    //    self.navigationBar.tintColor = UIColor(red:0.37, green:0.2, blue:0.67, alpha:1)
    self.navigationBar.tintColor = ThemeManager.defaultManager.currentTheme().primaryNavigationBarTintColor
    let fontDictionary = [ NSForegroundColorAttributeName:UIColor.whiteColor() ]
    self.navigationBar.titleTextAttributes = fontDictionary
    resetImage()
  }
  
  func resetImage() {
    self.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
  }
  
  private func imageLayerForGradientBackground() -> UIImage {
    
    var updatedFrame = self.navigationBar.bounds
    // take into account the status bar
    let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
    
    updatedFrame.size.height += statusBarHeight
    let layer = CAGradientLayer.gradientLayerForBounds(updatedFrame)
    UIGraphicsBeginImageContext(layer.bounds.size)
    layer.renderInContext(UIGraphicsGetCurrentContext()!)
    
    //    var imageLayer = CALayer()
    //
    //    let center = CGSizeMake(self.navigationBar.bounds.width / 2, self.navigationBar.bounds.height / 2 + statusBarHeight)
    //
    //    let logoWidth: CGFloat = 154
    //    let logoHeight: CGFloat = 29
    //
    //    imageLayer.bounds = CGRectMake(center.width - logoWidth / 2, center.height - logoHeight / 2 , logoWidth, logoHeight)
    //    imageLayer.contents = UIImage(named: "headerLogo")?.CGImage
    //    imageLayer.renderInContext(UIGraphicsGetCurrentContext())
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }
}
