//
//  CustomSeparator.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
  
  func addSeparatorLineToBottom(){
    let lineFrame = CGRectMake(8, self.bounds.size.height - 1, self.bounds.size.width - 16, 1)
    let line = UIView(frame: lineFrame)
    line.backgroundColor = ThemeManager.defaultManager.currentTheme().tableViewSeparatorColor
    addSubview(line)
  }
}