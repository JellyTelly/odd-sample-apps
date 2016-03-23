//
//  HomeTableViewController.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/17/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDK

class HomeTableViewController: UITableViewController {
  
  var featuredVideo: OddVideo? {
    return OddContentStore.sharedStore.featuredMediaObject as? OddVideo
  }
  var featuredCollections: Array<OddMediaObjectCollection>? {
    return OddContentStore.sharedStore.featuredCollections
  }
  
  var homeVC: HomeViewController?
  
  var playerCell: LivePlayerTableViewCell?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.estimatedRowHeight = 272
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.separatorColor = UIColor.clearColor()
    self.tableView.backgroundColor = ThemeManager.defaultManager.currentTheme().tableViewBackgroundColor
  }
  
  func fixTableViewInsets() {
    let zContentInsets = UIEdgeInsetsZero
    self.tableView.contentInset = zContentInsets
    self.tableView.scrollIndicatorInsets = zContentInsets
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    fixTableViewInsets()
  }
  
  override func viewWillDisappear(animated: Bool) {
    self.playerCell?.stopPlaying()
  }
  
  override func viewWillAppear(animated: Bool) {
    self.playerCell?.configureMediaPlayer()
  }
  
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.featuredCollections != nil ? self.featuredCollections!.count : 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = UITableViewCell()
    switch indexPath.row {
    case 0:
      if let video = self.featuredVideo {
        if let cell = tableView.dequeueReusableCellWithIdentifier("VideoPlayerTableViewCell", forIndexPath: indexPath) as? LivePlayerTableViewCell {
          cell.configureWithVideo(video)
          self.playerCell = cell
          return cell
        }
      }
    default:
      if let collections = featuredCollections {
        do {
          let featured = try collections.lookup( UInt(indexPath.row) )
          let cell = tableView.dequeueReusableCellWithIdentifier("MediaInfoTableViewCell", forIndexPath: indexPath) as? MediaInfoTableViewCell
          if let cell = cell {
            cell.configureWithCollection(featured)
            return cell
          }
        } catch {
          cell = tableView.dequeueReusableCellWithIdentifier("errorCell", forIndexPath: indexPath)
          return cell
        }
      }
    }
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.row == 0 {
      return UITableViewAutomaticDimension
    } else {
      return 80
    }
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if cell is VideoPlayerTableViewCell {
    } else {
      cell.addSeparatorLineToBottom()
    }
  }
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if let cell = cell as? LivePlayerTableViewCell {
      cell.stopPlaying()
    }
  }
  
  override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
    let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
    selectedCell.contentView.backgroundColor = ThemeManager.defaultManager.currentTheme().sideMenuCellBackgroundColor
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if let collections = featuredCollections where indexPath.row != 0 {
      do {
        let selectedCollection = try collections.lookup( UInt(indexPath.row) )
        self.homeVC?.selectedMediaObject(selectedCollection)
      } catch {
        print("Selected video not found")
      }
    }
  }
  
  // MARK: - Helpers
  func reload() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView.reloadData()
    })
  }

}
