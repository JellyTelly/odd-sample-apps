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
  
  func configureWithCollection(collection: OddMediaObjectCollection) {
    self.backgroundColor = UIColor.clearColor()
    self.titleLabel.text = collection.title
    self.notesLabel.text = collection.notes
    self.titleLabel.textColor = ThemeManager.defaultManager.currentTheme().tableViewCellTitleLabelColor
    self.notesLabel.textColor = ThemeManager.defaultManager.currentTheme().tableViewCellTextLabelColor
    self.selectionStyle = .Gray
    collection.thumbnail { (image) -> Void in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.thumbnailImageView.image = image
      })
    }
  }
}