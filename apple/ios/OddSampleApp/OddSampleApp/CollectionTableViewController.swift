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
    
    self.setImageForTitleView("headerLogo", size: CGSize(width: 154, height: 29), centerForMissingRightButton: true)
    
    self.tableView.estimatedRowHeight = 80
    self.tableView.rowHeight = UITableViewAutomaticDimension
    
    self.tableView.separatorColor = UIColor.clear
    self.tableView.backgroundColor = ThemeManager.defaultManager.currentTheme().tableViewBackgroundColor
  }
  
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return mediaObjects.count
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let subject = self.mediaObjectCollection {
      let headerView = UIView(frame: CGRect(x: 0,y: 0, width: self.tableView.bounds.width, height: 18))
      headerView.backgroundColor = ThemeManager.defaultManager.currentTheme().tableViewSectionHeaderBackgroundColor
      let titleLabel = UILabel(frame: CGRect(x: 0,y: 3, width: headerView.frame.width, height: 20))
      titleLabel.textColor = ThemeManager.defaultManager.currentTheme().tableViewSectionHeaderTextLabelColor
      titleLabel.text = subject.title
      titleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyleHeadline)
      titleLabel.textAlignment = .center
      headerView.addSubview(titleLabel)
      return headerView
    } else {
      return nil
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (indexPath as NSIndexPath).row == 0 {
      if let subject = self.mediaObjectCollection {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AccessoryViewCell", for: indexPath) as? AccessoryViewTableViewCell {
          cell.configureForTopic(subject)
          return cell
        }
      }
    } else {
      do {
        let video = try mediaObjects.lookup( UInt(indexPath.row) ), cell = tableView.dequeueReusableCell(withIdentifier: "VideoInfoTableViewCell", for: indexPath) as? VideoInfoTableViewCell
        if let cell = cell {
          cell.configureWithVideo(video)
          return cell
        }
      }catch {
        let cell = tableView.dequeueReusableCell(withIdentifier: "errorCell", for: indexPath)
        return cell
      }
    }
    self.tableView.separatorColor = UIColor.clear
    let cell = UITableViewCell()
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return (indexPath as NSIndexPath).row == 0 ? 233 : 80
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if cell is AccessoryViewTableViewCell {
    } else {
      cell.addSeparatorLineToBottom()
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if (indexPath as NSIndexPath).row != 0 {
      do {
        self.selectedVideo = try self.mediaObjects.lookup( UInt(indexPath.row) )
        self.performSegue(withIdentifier: "showVideoSegue", sender: self)
      } catch {
        print("Selected topic not found")
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let id = segue.identifier else { return }
    switch id {
    case "showVideoSegue":
      guard let vc = segue.destination as? VideoTableViewController,
        let video = self.selectedVideo else { break }
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
    DispatchQueue.main.async(execute: { () -> Void in
      self.tableView.reloadData()
    })
  }
  
  func fetchMediaObjects() {
    if let collection = self.mediaObjectCollection,
      let ids = collection.relationshipNodeWithName("entities")?.allIds {
        OddContentStore.sharedStore.fetchObjectsOfType(.video, ids: ids, include: nil, callback: { (objects, errors) -> () in
          if let videos = objects as? Array<OddVideo> {
            DispatchQueue.main.async(execute: { () -> Void in
              self.mediaObjects = videos
              self.reload()
            })
          }
      })
    }
  }

}
