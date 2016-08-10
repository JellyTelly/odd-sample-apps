//
//  MenuSearchCell.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit

class MenuSearchCell: UITableViewCell {
  
  func configureTextFieldElements(_ textField: UITextField) {
    
    let iconSize: CGFloat = 18
    
    let container = UIView(frame: CGRect(x: 4, y: 0, width: 28, height: 18))
    let magnifyView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconSize, height: iconSize))
    magnifyView.image = UIImage(named: "magnify")
    magnifyView.image = magnifyView.image!.withRenderingMode(.alwaysTemplate)
    magnifyView.tintColor = .lightGray
    
    container.addSubview(magnifyView)
    magnifyView.center.x += 4
    //    magnifyView.center.y -= 4
    
    textField.leftView = container
    
    textField.leftViewMode = .always
  }
  
  
  func configureForSearch( ) {
    //    cell.textLabel?.text = "Search"
    //    cell.imageView?.image = UIImage(named: "magnify")
    let width = self.contentView.frame.width
    let searchField = UITextField(frame: CGRect(x: 16, y: 8, width: width, height: 30))
    searchField.backgroundColor = UIColor.white
    searchField.placeholder = "Search"
    searchField.returnKeyType = .search
    searchField.isUserInteractionEnabled = false
    searchField.tag = 999
    
    configureTextFieldElements(searchField)
    
    self.contentView.addSubview(searchField)
    
    self.accessoryType = .none
    self.selectionStyle = .none
    self.backgroundColor = ThemeManager.defaultManager.currentTheme().sideMenuCellBackgroundColor
  }
  
}
