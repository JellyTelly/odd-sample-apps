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
  var url: URL?
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
      self.url = url as URL
    }
    
    configureMediaPlayer()
    
    let options = NSKeyValueObservingOptions([.new, .old])
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
      player = AVPlayer(url: url)
      if let player = player {
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
          self.checkPlayerStatus()
        }
        self.player = player
        self.showsPlaybackControls = true
      }
    }
  }
  
  func checkPlayerStatus() {
    if let player = self.player, let header = self.liveStreamHeaderView {
      let alpha: CGFloat = player.rate != 0 && player.error == nil ? 0 : 0.5
      UIView.animate(withDuration: 0.25, animations: { () -> Void in
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
    let value = UIInterfaceOrientation.portrait.rawValue
    UIDevice.current.setValue(value, forKey: "orientation")
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
    if context == &myContext {
      if keyPath == "bounds" {
        if let theChange = change,
          let oldValue = theChange[NSKeyValueChangeKey.oldKey],
          let newValue = theChange[NSKeyValueChangeKey.newKey] {
            let oldBounds: CGRect = oldValue.cgRectValue
            let newBounds: CGRect = newValue.cgRectValue
            let wasFullScreen = oldBounds.equalTo(UIScreen.main.bounds)
            let isFullscreen = newBounds.equalTo(UIScreen.main.bounds)
            
            if isFullscreen && !wasFullScreen {
              if oldBounds.equalTo(CGRect(x: 0,y: 0, width: newBounds.size.height, height: newBounds.size.width)) {
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
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }
  
  
}
