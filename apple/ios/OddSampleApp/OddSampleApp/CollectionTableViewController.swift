//
//  CollectionTableViewController.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/17/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDK

class CollectionTableViewController: UITableViewController {

  var mediaObjectCollection: OddMediaObjectCollection? {
    didSet {
      configureForCollection()
    }
  }
  var mediaObjects: Array<OddVideo> = Array()
  var selectedVideo: OddVideo?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setImageForTitleView("headerLogo", size: CGSizeMake(154, 29), centerForMissingRightButton: true)
    
    self.tableView.estimatedRowHeight = 80
    self.tableView.rowHeight = UITableViewAutomaticDimension
    
    self.tableView.separatorColor = UIColor.clearColor()
    self.tableView.backgroundColor = ThemeManager.defaultManager.currentTheme().tableViewBackgroundColor
  }
  
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return mediaObjects.count
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let subject = self.mediaObjectCollection {
      let headerView = UIView(frame: CGRectMake(0,0, CGRectGetWidth(self.tableView.bounds), 18))
      headerView.backgroundColor = ThemeManager.defaultManager.currentTheme().tableViewSectionHeaderBackgroundColor
      let titleLabel = UILabel(frame: CGRectMake(0,3, headerView.frame.width, 20))
      titleLabel.textColor = ThemeManager.defaultManager.currentTheme().tableViewSectionHeaderTextLabelColor
      titleLabel.text = subject.title
      titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
      titleLabel.textAlignment = .Center
      headerView.addSubview(titleLabel)
      return headerView
    } else {
      return nil
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      if let subject = self.mediaObjectCollection {
        if let cell = tableView.dequeueReusableCellWithIdentifier("AccessoryViewCell", forIndexPath: indexPath) as? AccessoryViewTableViewCell {
          cell.configureForTopic(subject)
          return cell
        }
      }
    } else {
      do {
        let video = try mediaObjects.lookup( UInt(indexPath.row) ), cell = tableView.dequeueReusableCellWithIdentifier("VideoInfoTableViewCell", forIndexPath: indexPath) as? VideoInfoTableViewCell
        if let cell = cell {
          cell.configureWithVideo(video)
          return cell
        }
      }catch {
        let cell = tableView.dequeueReusableCellWithIdentifier("errorCell", forIndexPath: indexPath)
        return cell
      }
    }
    self.tableView.separatorColor = UIColor.clearColor()
    let cell = UITableViewCell()
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return indexPath.row == 0 ? 233 : 80
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if cell is AccessoryViewTableViewCell {
    } else {
      cell.addSeparatorLineToBottom()
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row != 0 {
      do {
        self.selectedVideo = try self.mediaObjects.lookup( UInt(indexPath.row) )
        self.performSegueWithIdentifier("showVideoSegue", sender: self)
      } catch {
        print("Selected topic not found")
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let id = segue.identifier else { return }
    switch id {
    case "showVideoSegue":
      guard let vc = segue.destinationViewController as? VideoTableViewController, video = self.selectedVideo else { break }
      vc.configureWithInfo(video, related: self.mediaObjectCollection)
    default:
      break
    }
  }
  
  func configureForCollection() {
    mediaObjects.removeAll()
    fetchMediaObjects()
  }
  
  // MARK: - Helpers
  func reload() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView.reloadData()
    })
  }
  
  func fetchMediaObjects() {
    if let collection = self.mediaObjectCollection, ids = collection.relationshipNodeWithName("entities")?.allIds {
      OddContentStore.sharedStore.fetchObjectsOfType(.Video, ids: ids, include: nil, callback: { (objects, errors) -> () in
        if let videos = objects as? Array<OddVideo> {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.mediaObjects = videos
            self.reload()
          })
        }
      })
    }
  }

}
