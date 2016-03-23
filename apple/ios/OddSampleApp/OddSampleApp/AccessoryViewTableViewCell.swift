//
//  AccessoryViewTableViewCell.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDK

class AccessoryViewTableViewCell: UITableViewCell {
  
  @IBOutlet weak var thumbnailImageView: UIImageView!
  
  var topic: OddMediaObjectCollection?

  func configureForTopic(collection: OddMediaObjectCollection) {
    self.backgroundColor = UIColor.clearColor()
    self.selectionStyle = .None
    collection.thumbnail { (image) -> Void in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.thumbnailImageView.image = image
      })
    }
  }
  
}