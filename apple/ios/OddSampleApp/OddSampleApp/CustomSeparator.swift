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
    let lineFrame = CGRect(x: 8, y: self.bounds.size.height - 1, width: self.bounds.size.width - 16, height: 1)
    let line = UIView(frame: lineFrame)
    line.backgroundColor = ThemeManager.defaultManager.currentTheme().tableViewSeparatorColor
    addSubview(line)
  }
}
