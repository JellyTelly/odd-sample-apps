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
  
  var featuredMedia: OddVideo?
  var featuredCollections: Array<OddMediaObjectCollection>?
  var homeVC: HomeViewController?
  var homeView: OddView?
  
  var playerCell: LivePlayerTableViewCell?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.estimatedRowHeight = 272
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.separatorColor = UIColor.clear
    self.tableView.backgroundColor = ThemeManager.defaultManager.currentTheme().tableViewBackgroundColor
    loadFeaturedContent()
  }
  
  func fixTableViewInsets() {
    let zContentInsets = UIEdgeInsets.zero
    self.tableView.contentInset = zContentInsets
    self.tableView.scrollIndicatorInsets = zContentInsets
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    fixTableViewInsets()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.playerCell?.stopPlaying()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.playerCell?.configureMediaPlayer()
  }
  
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.featuredCollections != nil ? self.featuredCollections!.count : 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = UITableViewCell()
    switch (indexPath as NSIndexPath).row {
    case 0:
      if let video = self.featuredMedia {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "VideoPlayerTableViewCell", for: indexPath) as? LivePlayerTableViewCell {
          cell.configureWithVideo(video)
          self.playerCell = cell
          return cell
        }
      }
    default:
      if let collections = featuredCollections {
        do {
          let featured = try collections.lookup( UInt(indexPath.row) )
          let cell = tableView.dequeueReusableCell(withIdentifier: "MediaInfoTableViewCell", for: indexPath) as? MediaInfoTableViewCell
          if let cell = cell {
            cell.configureWithCollection(featured)
            return cell
          }
        } catch {
          cell = tableView.dequeueReusableCell(withIdentifier: "errorCell", for: indexPath)
          return cell
        }
      }
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if (indexPath as NSIndexPath).row == 0 {
      return UITableViewAutomaticDimension
    } else {
      return 80
    }
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if cell is VideoPlayerTableViewCell {
    } else {
      cell.addSeparatorLineToBottom()
    }
  }
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? LivePlayerTableViewCell {
      cell.stopPlaying()
    }
  }
  
  override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
    selectedCell.contentView.backgroundColor = ThemeManager.defaultManager.currentTheme().sideMenuCellBackgroundColor
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let collections = featuredCollections, (indexPath as NSIndexPath).row != 0 {
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
    DispatchQueue.main.async(execute: { () -> Void in
      self.tableView.reloadData()
    })
  }
  
  func loadFeaturedContent() {
    // Load the featured Collection
    guard let homeview = self.homeView,
      let featuredCollection = homeview.relationshipNodeWithName("featuredCollections"),
      let featuredCollectionNode = featuredCollection.relationship as? OddRelationship else {
        OddLogger.error("Unable to determine featuredCollection")
        return
    }
    let featuredCollectionId = featuredCollectionNode.id
    
    OddContentStore.sharedStore.objectsOfType(.collection, ids: [featuredCollectionId], include: "entities", callback: { (objects, errors) in
      if errors != nil {
        OddLogger.error("Error loading featuredCollection")
        return
      }
      if let featuredCollection = objects.first as? OddMediaObjectCollection,
        let ids = featuredCollection.relationshipNodeWithName("entities")?.allIds {
          // Load the contents of that featured Collection
          OddContentStore.sharedStore.objectsOfType(.collection, ids: ids, include: "entities", callback: { (objects, errors) in
            if errors != nil {
              OddLogger.error("Error loading featuredCollection")
              return
            }
            if let featuredCollections = objects as? Array<OddMediaObjectCollection> {
              self.featuredCollections = featuredCollections
              
              // Load the featured Media Object
              guard let featuredMedia = homeview.relationshipNodeWithName("featuredMedia"),
                let featuredMediaNode = featuredMedia.relationship as? OddRelationship else {
                  OddLogger.error("Unable to determine featuredMedia")
                  return
              }
              let featuredMediaId = featuredMediaNode.id
              OddContentStore.sharedStore.objectsOfType(.video, ids: [featuredMediaId], include: "entities", callback: { (objects, errors) in
                if errors != nil {
                  OddLogger.error("Error loading featuredCollection")
                  return
                }
                if let featuredMedia = objects.first as? OddVideo {
                  self.featuredMedia = featuredMedia
                  self.reload()
                }
              })
            }
          })
      }
    })
  }

}
