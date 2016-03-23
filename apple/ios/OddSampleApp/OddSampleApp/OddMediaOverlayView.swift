//
//  OddMediaOverlayView.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDK

class OddMediaOverlayView: UIView {
  //passed in
  var playerController: OddAVPlayer!
  var playerContainer: UIView!
  var thumbnail: UIImage?
  var mediaObject: OddMediaObject?
  
  var chromecastNoticeImageView: UIImageView?
  var videoOverlayView: UIView?
  var overlayButton: UIImageView?
  var liveStreamHeaderView: UIView?
  var playButtonIcon = UIImage(named: "icon_play_solid")
  var chromecastOverlay = UIImage(named: "cast_on")
  
  //local
  var chromecastConnected: Bool {
    //    if OddChromeCastManager.defaultManager.currentMediaObjectId == mediaObject?.id && OddChromeCastManager.defaultManager.connectionState == GCKConnectionState.Connected {
    //      return true
    //    } else {
    //      return false
    //    }
    return false
  }
  
  init(container: UIView, playerController: OddAVPlayer, mediaObject: OddMediaObject?, thumbnail: UIImage?) {
    self.playerContainer = container
    self.thumbnail = thumbnail
    self.playerController = playerController
    self.liveStreamHeaderView = playerController.liveStreamHeaderView
    self.mediaObject = mediaObject
    super.init(frame: self.playerContainer.bounds)
    self.videoOverlayView = UIView(frame: self.bounds)
    self.addSubview(videoOverlayView!)
    configureThumbnailOverlay()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureThumbnailOverlay() {
    
    let thumbnailView = UIImageView(frame: self.bounds)
    thumbnailView.contentMode = .ScaleAspectFill
    thumbnailView.image = thumbnail
    thumbnailView.accessibilityIdentifier = thumbnail?.accessibilityIdentifier
    
    self.videoOverlayView?.addSubview(thumbnailView)
    
    let playButtonContainerSize: CGFloat = 70
    
    let playButtonContainer = UIView(frame: CGRectMake(0, 0, playButtonContainerSize, playButtonContainerSize))
    playButtonContainer.layer.cornerRadius = playButtonContainerSize/2;
    playButtonContainer.layer.masksToBounds = true
    playButtonContainer.backgroundColor = UIColor.whiteColor()
    playButtonContainer.alpha = 0.3
    playButtonContainer.center = self.center
    
    let playButton = self.chromecastConnected ? UIImageView(image: self.chromecastOverlay) : UIImageView(image: self.playButtonIcon)
    
    playButton.center = playButtonContainer.center
    playButton.alpha = 0.6
    
    self.videoOverlayView?.addSubview(playButtonContainer)
    self.videoOverlayView?.addSubview(playButton)
    self.overlayButton = playButton
    
    self.gestureRecognizers?.removeAll()
    let tap = UITapGestureRecognizer(target: playerController, action: #selector(playerController.playButtonPressed))
    tap.numberOfTapsRequired = 1
    tap.numberOfTouchesRequired = 1
    self.addGestureRecognizer(tap)
    
    self.playerContainer.addSubview(self)
    
    if let header = self.liveStreamHeaderView {
      header.alpha = 0.5
      playerContainer.bringSubviewToFront(header)
    }
  }
  
  func hideThumbnailOverlay() {
    self.videoOverlayView?.hidden = true
    self.userInteractionEnabled = false
  }
}
