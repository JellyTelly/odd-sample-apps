//
//  VideoInfoTableViewCell.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDK

class VideoInfoTableViewCell: MediaInfoTableViewCell {

  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var durationBackground: UIView!
  
  func configureWithVideo(video: OddVideo) {
    self.titleLabel.text = video.title
    self.titleLabel.textColor = ThemeManager.defaultManager.currentTheme().tableViewCellTitleLabelColor
    self.notesLabel.text = video.notes
    self.notesLabel.textColor = ThemeManager.defaultManager.currentTheme().tableViewCellTextLabelColor
    self.durationLabel.text = video.durationAsTimeString()
    self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = .Gray
    video.thumbnail { (image) -> Void in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.thumbnailImageView.image = image
      })
    }
  }
  
}