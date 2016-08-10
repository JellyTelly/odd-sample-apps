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

  func configureForTopic(_ collection: OddMediaObjectCollection) {
    self.backgroundColor = UIColor.clear
    self.selectionStyle = .none
    collection.thumbnail { (image) -> Void in
      DispatchQueue.main.async(execute: { () -> Void in
        self.thumbnailImageView.image = image
      })
    }
  }
  
}
