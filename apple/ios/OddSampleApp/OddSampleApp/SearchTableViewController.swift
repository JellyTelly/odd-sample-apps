//
//  SearchTableViewController.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDK

class SearchTableViewController: UITableViewController, UITextFieldDelegate {
  
  var searchField: UITextField?
  var searching: Bool = false
  
  var foundVideos: Array<OddVideo>?
  var foundCollections: Array<OddMediaObjectCollection>?
  
  var selectedCollection: OddMediaObjectCollection?
  var selectedVideo: OddVideo?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    configureNavBar()
    self.tableView.backgroundColor = ThemeManager.defaultManager.currentTheme().tableViewBackgroundColor
    self.tableView.contentInset = UIEdgeInsetsMake( -36, 0, 0, 0)
    self.tableView.tableFooterView = UIView(frame: CGRectZero)
  }
  
  override func viewDidAppear(animated: Bool) {
    self.activateSearchField()
  }
  
  func haveSearchResults() -> Bool {
    return self.foundVideos != nil || self.foundCollections != nil
  }
  
  func configureNavBar() {
    let width = self.view.frame.width  * 0.7
    searchField = UITextField(frame: CGRectMake(0, 0, width, 30))
    if let searchField = searchField {
      searchField.backgroundColor = UIColor.whiteColor()
      searchField.placeholder = "Search"
      searchField.returnKeyType = .Search
      searchField.delegate = self
      searchField.tintColor = .darkGrayColor()
      
      configureTextFieldElements(searchField)
      
      let searchItem = UIBarButtonItem(customView: searchField)
      self.navigationItem.leftBarButtonItem = searchItem
    }
    
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(SearchTableViewController.exitSearch))
    self.navigationItem.rightBarButtonItem = cancelButton
  }
  
  func configureTextFieldElements(textField: UITextField) {
    let iconSize: CGFloat = 18
    let container = UIView(frame: CGRectMake(4, 0, 28, 18))
    let magnifyView = UIImageView(frame: CGRectMake(0, 0, iconSize, iconSize))
    magnifyView.image = UIImage(named: "magnify")
    magnifyView.image = magnifyView.image!.imageWithRenderingMode(.AlwaysTemplate)
    magnifyView.tintColor = .lightGrayColor()
    
    container.addSubview(magnifyView)
    magnifyView.center.x += 4
    //    magnifyView.center.y -= 4
    textField.leftView = container
    
    textField.leftViewMode = .Always
  }
  
  func fetchSearchResults( term: String ) {
    OddContentStore.sharedStore.searchForTerm(term) { (videos, collections) -> Void in
      print("Found \(videos!.count) videos and \(collections!.count) collections")
      let courseCollections = self.cleanCollections(collections)
      self.foundCollections = courseCollections
      self.foundVideos = videos
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.tableView.reloadData()
      })
    }
  }
  
  func cleanCollections(collections: Array<OddMediaObjectCollection>?) -> Array<OddMediaObjectCollection>? {
    if collections == nil { return nil }
    
    return collections
  }
  
  func exitSearch() {
    print("Exit Search")
    performSegueWithIdentifier("exitSearchUnwind", sender: self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return haveSearchResults() ? 2 : 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if !haveSearchResults() {
      return 1
    }
    
    if section == 0 { // collections
      if let collections = foundCollections {
        return collections.count > 0 ? collections.count : 1
      }
      return 1
    } else {
      if let videos = foundVideos {
        return videos.count > 0 ? videos.count : 1
      }
      return 1
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SearchInfoCell", forIndexPath: indexPath) as! VideoInfoTableViewCell
    
    self.tableView.separatorColor = UIColor.clearColor()
    cell.addSeparatorLineToBottom()
    cell.textLabel?.text = ""
    cell.notesLabel.text = ""
    cell.accessoryType = .None
    
    let titleColor = ThemeManager.defaultManager.currentTheme().tableViewCellTitleLabelColor
    let subtitleColor = ThemeManager.defaultManager.currentTheme().tableViewCellTextLabelColor
    
    cell.textLabel?.textColor = titleColor
    cell.detailTextLabel?.textColor = subtitleColor
    cell.titleLabel?.textColor = titleColor
    cell.notesLabel?.textColor = subtitleColor
    
    cell.backgroundColor = .clearColor()
    cell.contentView.backgroundColor = .clearColor()
    cell.thumbnailImageView.hidden = false
    cell.durationBackground?.hidden = true
    
    if haveSearchResults() {
      if indexPath.section == 0 { // collections
        if let collections = foundCollections {
          if collections.count == 0 {
            cell.titleLabel.text = "No Collections Found"
          } else {
            let currentCollection = collections[indexPath.row]
            currentCollection.thumbnail({ (thumbnail) -> () in
              cell.thumbnailImageView.image = thumbnail
            })
            cell.titleLabel.text = currentCollection.title
            cell.notesLabel.text = currentCollection.notes
            cell.accessoryType = .DisclosureIndicator
          }
          
        }
      } else {
        if let videos = foundVideos {
          if videos.count == 0 {
            cell.titleLabel.text = "No Videos Found"
          } else {
            let currentVideo = videos[indexPath.row]
            //            currentVideo.configureCell(cell)
            cell.backgroundColor = .clearColor()
            currentVideo.thumbnail({ (thumbnail) -> () in
              cell.thumbnailImageView.image = thumbnail
            })
            cell.titleLabel.text = currentVideo.title
            cell.notesLabel.text = currentVideo.notes
            cell.durationBackground?.hidden = false
            cell.durationLabel?.text = currentVideo.durationAsTimeString()
            cell.accessoryType = .DisclosureIndicator
          }
        }
      } // videos
    } else {
      cell.titleLabel.text = ""
      cell.thumbnailImageView.image = nil
      cell.thumbnailImageView.hidden = true
      cell.textLabel?.text = "No Search Results..."
      cell.textLabel?.textColor = ThemeManager.defaultManager.currentTheme().tableViewCellTitleLabelColor
      self.tableView.separatorStyle = .None
    }
    
    //    if haveSearchResults() {
    //      cell.backgroundColor = UIColor(red:0.08, green:0.09, blue:0.15, alpha:1)
    //      cell.contentView.backgroundColor = UIColor(red:0.08, green:0.09, blue:0.15, alpha:1)
    //    } else {
    cell.backgroundColor = .clearColor()
    cell.contentView.backgroundColor = .clearColor()
    //    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let text = section == 0 ? "Courses" : "Videos"
    
    let frame = CGRectMake(0, 0, tableView.frame.width, 29)
    let headerView = UIView(frame: frame)
    
    headerView.backgroundColor = ThemeManager.defaultManager.currentTheme().tableViewSectionHeaderBackgroundColor
    
    let labelFrame = CGRectMake(8, 0, tableView.frame.width - 8, 29)
    let label = UILabel(frame: labelFrame)
    label.text = text
    
    label.textColor = ThemeManager.defaultManager.currentTheme().tableViewSectionHeaderTextLabelColor
    
    headerView.addSubview(label)
    
    return headerView
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 80
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return haveSearchResults() ? 29 : 0
  }
  
  //MARK: Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showCollectionDetail" {
      if let vc = segue.destinationViewController as? CollectionTableViewController,
        collection = self.selectedCollection {
          vc.mediaObjectCollection = collection
//          vc.course = collection
      }
    } else if segue.identifier == "showVideoDetail" {
      if let vc = segue.destinationViewController as? VideoTableViewController,
        video = selectedVideo {
          vc.configureWithInfo(video, related: nil)
      }
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if !haveSearchResults() { return }
    do {
      if indexPath.section == 0 { // video collections
        if let collections = foundCollections {
          self.selectedCollection = try collections.lookup( UInt(indexPath.row) )
          self.performSegueWithIdentifier("showCollectionDetail", sender: self)
        }
      } else {
        if let videos = foundVideos {
          self.selectedVideo = try videos.lookup( UInt(indexPath.row) )
          self.performSegueWithIdentifier("showVideoDetail", sender: self)
        }
      }
    } catch {
      self.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
      print("clicked cell with no data")
    }
  }
  
  //MARK: helpers
  func showSearchErrorAlert() {
    let alert = UIAlertController(title: "Search Error", message: "Server responded with an error. Please try again.", preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.resetSearchTable()
    }
    alert.addAction(action)
    self.presentViewController(alert, animated: true) { () -> Void in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "endedSearch", object: nil))
      })
    }
  }
  
  func activateSearchField() {
    self.searchField?.becomeFirstResponder()
  }
  
  func resetSearchTable() {
    self.foundVideos = nil
    self.foundCollections = nil
    self.searching = false
    self.tableView.reloadData()
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField.text?.characters.count > 0 {
      let query = textField.text?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
      print("search for: \(query)")
      fetchSearchResults(query!)
    } else {
      resetSearchTable()
    }
    
    textField.resignFirstResponder()
    
    return true
  }
}

