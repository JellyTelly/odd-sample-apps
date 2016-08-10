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
  
  
  func configureWithInfo(_ video: OddVideo, related: OddMediaObjectCollection?) {
    self.related = related
    self.selectedVideo = video
    configureForVideo()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setImageForTitleView("headerLogo", size: CGSize(width: 154, height: 29), centerForMissingRightButton: true)
    
    self.tableView.estimatedRowHeight = 80
    self.tableView.rowHeight = UITableViewAutomaticDimension
    
    self.tableView.separatorColor = UIColor.clear
    
    self.tableView.backgroundColor = ThemeManager.defaultManager.currentTheme().tableViewBackgroundColor
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.playerViewCell?.stopPlaying()
    self.playerViewCell?.moviePlayer?.player = nil
    self.playerViewCell?.moviePlayer = nil
    self.playerViewCell = nil
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return relatedContents.count == 0 ? 1 : relatedContents.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = UITableViewCell()
    do {
      let video = try relatedContents.lookup( UInt(indexPath.row) )
      if (indexPath as NSIndexPath).row == 0 {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerViewCell", for: indexPath) as? VideoPlayerTableViewCell {
          cell.configureWithVideo(video, showRelated: related != nil)
          self.playerViewCell = cell
          return cell
        }
      }
      else {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "VideoInfoCell", for: indexPath) as? VideoInfoTableViewCell {
          cell.configureWithVideo(video)
          if let selected = self.selectedVideo, selected.id == video.id {
            cell.backgroundColor = UIColor.lightGray
          }
          return cell
        }
      }
    }catch {
      cell = tableView.dequeueReusableCell(withIdentifier: "errorCell", for: indexPath)
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return (indexPath as NSIndexPath).row == 0 ? UITableViewAutomaticDimension : 80
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if cell is VideoPlayerTableViewCell {
    } else {
      cell.addSeparatorLineToBottom()
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if (indexPath as NSIndexPath).row == 0 { return }
    do {
      self.selectedVideo = try self.relatedContents.lookup( UInt(indexPath.row) )
      self.playerViewCell?.stopPlaying()
      configureForVideo()
      DispatchQueue.main.async(execute: { () -> Void in
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
      })
    } catch {
      print("Selected topic not found")
    }
  }
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
    DispatchQueue.main.async(execute: { () -> Void in
      self.tableView.reloadData()
    })
  }
  
  func fetchMediaObjects() {
    if let selected = self.selectedVideo {
      self.relatedContents.append(selected)
    }
    if let related = self.related?.relationshipNodeWithName("entities")?.allIds {
      OddContentStore.sharedStore.fetchObjectsOfType(.video, ids: related, include: nil, callback: { (objects, errors) -> () in
        if let contents = objects as? Array<OddVideo> {
          DispatchQueue.main.async(execute: { () -> Void in
            for related in contents {
              self.relatedContents.append(related)
            }
            self.playerViewCell = nil
            self.reload()
          })
        }
      })
    }
  }

}
