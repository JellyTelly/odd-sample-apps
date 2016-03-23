//
//  VideoTableViewController.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/17/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDK

class VideoTableViewController: UITableViewController {

  var selectedVideo: OddVideo?
  var related: OddMediaObjectCollection?

  var relatedContents: Array<OddVideo> = Array()
  
  var playerViewCell: VideoPlayerTableViewCell?
  
  
  func configureWithInfo(video: OddVideo, related: OddMediaObjectCollection?) {
    self.related = related
    self.selectedVideo = video
    configureForVideo()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setImageForTitleView("headerLogo", size: CGSizeMake(154, 29), centerForMissingRightButton: true)
    
    self.tableView.estimatedRowHeight = 80
    self.tableView.rowHeight = UITableViewAutomaticDimension
    
    self.tableView.separatorColor = UIColor.clearColor()
    
    self.tableView.backgroundColor = ThemeManager.defaultManager.currentTheme().tableViewBackgroundColor
  }
  
  override func viewWillDisappear(animated: Bool) {
    self.playerViewCell?.stopPlaying()
    self.playerViewCell?.moviePlayer?.player = nil
    self.playerViewCell?.moviePlayer = nil
    self.playerViewCell = nil
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return relatedContents.count == 0 ? 1 : relatedContents.count
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = UITableViewCell()
    do {
      let video = try relatedContents.lookup( UInt(indexPath.row) )
      if indexPath.row == 0 {
        if let cell = tableView.dequeueReusableCellWithIdentifier("PlayerViewCell", forIndexPath: indexPath) as? VideoPlayerTableViewCell {
          cell.configureWithVideo(video, showRelated: related != nil)
          self.playerViewCell = cell
          return cell
        }
      }
      else {
        if let cell = tableView.dequeueReusableCellWithIdentifier("VideoInfoCell", forIndexPath: indexPath) as? VideoInfoTableViewCell {
          cell.configureWithVideo(video)
          return cell
        }
      }
    }catch {
      cell = tableView.dequeueReusableCellWithIdentifier("errorCell", forIndexPath: indexPath)
    }
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return indexPath.row == 0 ? UITableViewAutomaticDimension : 80
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if cell is VideoPlayerTableViewCell {
    } else {
      cell.addSeparatorLineToBottom()
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == 0 { return }
    do {
      self.selectedVideo = try self.relatedContents.lookup( UInt(indexPath.row) )
      self.playerViewCell?.stopPlaying()
      configureForVideo()
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
      })
    } catch {
      print("Selected topic not found")
    }
  }
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if let cell = cell as? VideoPlayerTableViewCell {
      cell.stopPlaying()
    }
  }
  
  func configureForVideo() {
    relatedContents.removeAll()
    if let _ = related {
      fetchMediaObjects()
    } else if let selected = selectedVideo {
      self.relatedContents.append(selected)
      reload()
    }
  }
  
  // MARK: - Helpers
  func reload() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView.reloadData()
    })
  }
  
  func fetchMediaObjects() {
    if let selected = self.selectedVideo {
      self.relatedContents.append(selected)
    }
    //remove the selected video from the topics video list here
    if let related = self.related, video = self.selectedVideo {
      //      print("Related Count: \(related.objectIds.count)")
      OddContentStore.sharedStore.fetchObjectsOfType(.Video, ids: related.objectIds, callback: { (objects) -> () in
        if let contents = objects as? Array<OddVideo> {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            for related in contents {
              if related.id != video.id {
                self.relatedContents.append(related)
              }
            }
            self.playerViewCell = nil
            self.reload()
          })
        }
      })
    }
  }

}
