//
//  OddAVPlayer.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import AVKit
import OddSDK

private var myContext = 0

class OddAVPlayer: AVPlayerViewController {
  
  //External
  var playerView: UIView!
  var liveStreamHeaderView: UIView?
  
  //Internal
  var mediaOverlayView: OddMediaOverlayView?
  
  var playerWasFullscreen = false
  
  //Media Data
  var mediaObject: OddMediaObject?
  var url: NSURL?
  var thumbnail: UIImage?
  var video: OddVideo?
  
  convenience init(video: OddVideo, playerView: UIView, media: OddMediaObject, url: String, thumbnail: UIImage?, liveStreamHeaderView: UIView?) {
    self.init()
    self.video = video
    self.playerView = playerView
    self.mediaObject = media
    self.thumbnail = thumbnail
    
    if let headerView = liveStreamHeaderView {
      self.liveStreamHeaderView = headerView
    }
    if let url = NSURL(string: url) {
      self.url = url
    }
    
    configureMediaPlayer()
    
    let options = NSKeyValueObservingOptions([.New, .Old])
    self.contentOverlayView?.addObserver(self, forKeyPath: "bounds", options: options, context: &myContext)
  }
  
  deinit {
    self.removeObserver(self, forKeyPath: "videoBounds", context: &myContext)
  }
  
  func configureMediaPlayer() {
    showsPlaybackControls = false
    view.frame = playerView.bounds
    playerView.addSubview(self.view)
    if let thumbnail = self.thumbnail {
      mediaOverlayView = OddMediaOverlayView(container: playerView, playerController: self, mediaObject: mediaObject, thumbnail: thumbnail)
    }
    prepareMediaData()
  }
  
  func prepareMediaData() {
    var player: AVPlayer?
    if let url = self.url {
      player = AVPlayer(URL: url)
      if let player = player {
        player.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(1, 1), queue: dispatch_get_main_queue()) { (CMTime) -> Void in
          self.checkPlayerStatus()
        }
        self.player = player
        self.showsPlaybackControls = true
      }
    }
  }
  
  func checkPlayerStatus() {
    if let player = self.player, header = self.liveStreamHeaderView {
      let alpha: CGFloat = player.rate != 0 && player.error == nil ? 0 : 0.5
      UIView.animateWithDuration(0.25, animations: { () -> Void in
        header.alpha = alpha
      })
    }
  }
  
  func stop() {
    self.player?.pause()
    self.player = nil
  }
  
  func playButtonPressed() {
    mediaOverlayView?.hideThumbnailOverlay()
    self.player?.play()
    
    //    OddMetricManager.defaultManager.postMetric(.VideoPlay, beacon: nil, content: OddContentStore.sharedStore.featuredLiveStream)
  }
  
  // MARK: - Fullscreen transitions
  
  func rotateToPortrait() {
    let value = UIInterfaceOrientation.Portrait.rawValue
    UIDevice.currentDevice().setValue(value, forKey: "orientation")
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if context == &myContext {
      if keyPath == "bounds" {
        if let theChange = change,
          oldValue = theChange[NSKeyValueChangeOldKey],
          newValue = theChange[NSKeyValueChangeNewKey] {
            let oldBounds: CGRect = oldValue.CGRectValue
            let newBounds: CGRect = newValue.CGRectValue
            let wasFullScreen = CGRectEqualToRect(oldBounds, UIScreen.mainScreen().bounds)
            let isFullscreen = CGRectEqualToRect(newBounds, UIScreen.mainScreen().bounds)
            
            if isFullscreen && !wasFullScreen {
              if CGRectEqualToRect(oldBounds, CGRectMake(0,0, newBounds.size.height, newBounds.size.width)) {
                print("ROTATED FULLSCREEN")
              } else {
                print("ENTERED FULLSCREEN")
              }
            } else if !isFullscreen && wasFullScreen {
              print("EXITED FULLSCREEN")
              rotateToPortrait()
            }
        }
      }
    } else {
      super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
  }
  
  
}