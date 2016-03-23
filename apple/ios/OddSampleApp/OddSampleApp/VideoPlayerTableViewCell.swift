//
//  VideoPlayerTableViewCell.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDK

class VideoPlayerTableViewCell: UITableViewCell {
  
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var playerView: UIView!
  
  @IBOutlet weak var relatedTitleLabel: UILabel!
  @IBOutlet weak var relatedView: UIView!
  
  @IBOutlet weak var actionButton: UIButton!
  var moviePlayer : OddAVPlayer?
  var video: OddVideo?
  var playerConfigured: Bool = false
  var relatedShow = true
  
  func configureWithVideo(video: OddVideo, showRelated: Bool) {
    if !showRelated {
      self.relatedShow = false
      self.relatedView.hidden = true
      self.relatedTitleLabel.hidden = true
    }
    self.video = video
    self.backgroundColor = UIColor.clearColor()
    self.titleLabel.text = video.title
    self.titleLabel.textColor = ThemeManager.defaultManager.currentTheme().tableViewCellTitleLabelColor
    titleLabel.backgroundColor = UIColor.clearColor()
    
    self.descriptionLabel.text = video.notes
    self.descriptionLabel.textColor = ThemeManager.defaultManager.currentTheme().tableViewCellTextLabelColor
    self.relatedTitleLabel.textColor = ThemeManager.defaultManager.currentTheme().tableViewSectionHeaderTextLabelColor
    self.relatedTitleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    self.relatedView.backgroundColor = ThemeManager.defaultManager.currentTheme().tableViewSectionHeaderBackgroundColor
    self.selectionStyle = UITableViewCellSelectionStyle.None
    self.userInteractionEnabled = true
    self.backgroundColor = UIColor.clearColor()
    configureMediaPlayer()
  }
  
  func stopPlaying() {
    self.moviePlayer?.player?.pause()
    self.moviePlayer = nil
    self.moviePlayer?.player = nil
  }
  
  func configureMediaPlayer() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      if self.relatedShow {
        for view in self.playerView.subviews {
          view.removeFromSuperview()
        }
      }

      if let _ = self.video {
        self.configureForNativePlayer()
      }
    })
  }
  
  func configureForNativePlayer() {
    if let video = self.video,
      urlString = video.urlString {
        if !playerConfigured || relatedShow {
          playerConfigured = true
          //        video.thumbnail({ (image) -> () in
          self.moviePlayer = OddAVPlayer(video: video, playerView: self.playerView, media: video, url: urlString, thumbnail: nil, liveStreamHeaderView: nil)
          self.moviePlayer?.player?.play()
          //        })
        } else {
          self.moviePlayer?.player?.play()
        }
    }
  }
  
}