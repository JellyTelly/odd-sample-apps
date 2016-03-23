//
//  LivePlayerTableViewCell.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/17/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDK

class LivePlayerTableViewCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var playerView: UIView!
  
  var moviePlayer : OddAVPlayer?
  var video: OddVideo?
  var playerConfigured: Bool = false
  
  func configureWithVideo(video: OddVideo) {
    self.video = video
    self.titleLabel.backgroundColor = UIColor.clearColor()
    self.titleLabel.text = video.title
    self.titleLabel.textColor = ThemeManager.defaultManager.currentTheme().playerTitleOverlayTextLabelColor
    self.titleLabel.backgroundColor = UIColor.clearColor()
    self.backgroundColor = UIColor.clearColor()
    self.selectionStyle = UITableViewCellSelectionStyle.None
    self.userInteractionEnabled = true
    configureMediaPlayer()
  }
  
  func stopPlaying() {
    self.moviePlayer?.player?.pause()
    self.moviePlayer?.player = nil
    self.moviePlayer = nil
  }
  
  func configureMediaPlayer() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      for view in self.playerView.subviews {
        view.removeFromSuperview()
      }
      if let _ = self.video {
        self.configureForNativePlayer()
      }
    })
  }
  
  func configureForNativePlayer() {
    if let video = self.video,
      urlString = video.urlString {
        self.moviePlayer = OddAVPlayer(video: video, playerView: self.playerView, media: video, url: urlString, thumbnail: nil, liveStreamHeaderView: nil)
    }
  }
  
}