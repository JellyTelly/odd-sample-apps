//
//  MediaInfoTableViewCell.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/17/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDK

class MediaInfoTableViewCell: UITableViewCell {
  
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var notesLabel: UILabel!
  
  func configureWithCollection(_ collection: OddMediaObjectCollection) {
    self.backgroundColor = UIColor.clear
    self.titleLabel.text = collection.title
    self.notesLabel.text = collection.notes
    self.titleLabel.textColor = ThemeManager.defaultManager.currentTheme().tableViewCellTitleLabelColor
    self.notesLabel.textColor = ThemeManager.defaultManager.currentTheme().tableViewCellTextLabelColor
    self.selectionStyle = .gray
    collection.thumbnail { (image) -> Void in
      DispatchQueue.main.async(execute: { () -> Void in
        self.thumbnailImageView.image = image
      })
    }
  }
}
