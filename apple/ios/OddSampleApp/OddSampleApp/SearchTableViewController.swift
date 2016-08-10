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
    self.tableView.tableFooterView = UIView(frame: CGRect.zero)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.activateSearchField()
  }
  
  func haveSearchResults() -> Bool {
    return self.foundVideos != nil || self.foundCollections != nil
  }
  
  func configureNavBar() {
    let width = self.view.frame.width  * 0.7
    searchField = UITextField(frame: CGRect(x: 0, y: 0, width: width, height: 30))
    if let searchField = searchField {
      searchField.backgroundColor = UIColor.white
      searchField.placeholder = "Search"
      searchField.returnKeyType = .search
      searchField.delegate = self
      searchField.tintColor = .darkGray
      
      configureTextFieldElements(searchField)
      
      let searchItem = UIBarButtonItem(customView: searchField)
      self.navigationItem.leftBarButtonItem = searchItem
    }
    
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(SearchTableViewController.exitSearch))
    self.navigationItem.rightBarButtonItem = cancelButton
  }
  
  func configureTextFieldElements(_ textField: UITextField) {
    let iconSize: CGFloat = 18
    let container = UIView(frame: CGRect(x: 4, y: 0, width: 28, height: 18))
    let magnifyView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconSize, height: iconSize))
    magnifyView.image = UIImage(named: "magnify")
    magnifyView.image = magnifyView.image!.withRenderingMode(.alwaysTemplate)
    magnifyView.tintColor = .lightGray
    
    container.addSubview(magnifyView)
    magnifyView.center.x += 4
    //    magnifyView.center.y -= 4
    textField.leftView = container
    
    textField.leftViewMode = .always
  }
  
  func fetchSearchResults( _ term: String ) {
    OddContentStore.sharedStore.searchForTerm(term) { (videos, collections) -> Void in
      print("Found \(videos!.count) videos and \(collections!.count) collections")
      let courseCollections = self.cleanCollections(collections)
      self.foundCollections = courseCollections
      self.foundVideos = videos
      DispatchQueue.main.async(execute: { () -> Void in
        self.tableView.reloadData()
      })
    }
  }
  
  func cleanCollections(_ collections: Array<OddMediaObjectCollection>?) -> Array<OddMediaObjectCollection>? {
    if collections == nil { return nil }
    
    return collections
  }
  
  func exitSearch() {
    print("Exit Search")
    performSegue(withIdentifier: "exitSearchUnwind", sender: self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return haveSearchResults() ? 2 : 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SearchInfoCell", for: indexPath) as! VideoInfoTableViewCell
    
    self.tableView.separatorColor = UIColor.clear
    cell.addSeparatorLineToBottom()
    cell.textLabel?.text = ""
    cell.notesLabel.text = ""
    cell.accessoryType = .none
    
    let titleColor = ThemeManager.defaultManager.currentTheme().tableViewCellTitleLabelColor
    let subtitleColor = ThemeManager.defaultManager.currentTheme().tableViewCellTextLabelColor
    
    cell.textLabel?.textColor = titleColor
    cell.detailTextLabel?.textColor = subtitleColor
    cell.titleLabel?.textColor = titleColor
    cell.notesLabel?.textColor = subtitleColor
    
    cell.backgroundColor = .clear
    cell.contentView.backgroundColor = .clear
    cell.thumbnailImageView.isHidden = false
    cell.durationBackground?.isHidden = true
    
    if haveSearchResults() {
      if (indexPath as NSIndexPath).section == 0 { // collections
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
            cell.accessoryType = .disclosureIndicator
          }
          
        }
      } else {
        if let videos = foundVideos {
          if videos.count == 0 {
            cell.titleLabel.text = "No Videos Found"
          } else {
            let currentVideo = videos[indexPath.row]
            //            currentVideo.configureCell(cell)
            cell.backgroundColor = .clear
            currentVideo.thumbnail({ (thumbnail) -> () in
              cell.thumbnailImageView.image = thumbnail
            })
            cell.titleLabel.text = currentVideo.title
            cell.notesLabel.text = currentVideo.notes
            cell.durationBackground?.isHidden = false
            cell.durationLabel?.text = currentVideo.durationAsTimeString()
            cell.accessoryType = .disclosureIndicator
          }
        }
      } // videos
    } else {
      cell.titleLabel.text = ""
      cell.thumbnailImageView.image = nil
      cell.thumbnailImageView.isHidden = true
      cell.textLabel?.text = "No Search Results..."
      cell.textLabel?.textColor = ThemeManager.defaultManager.currentTheme().tableViewCellTitleLabelColor
      self.tableView.separatorStyle = .none
    }
    
    //    if haveSearchResults() {
    //      cell.backgroundColor = UIColor(red:0.08, green:0.09, blue:0.15, alpha:1)
    //      cell.contentView.backgroundColor = UIColor(red:0.08, green:0.09, blue:0.15, alpha:1)
    //    } else {
    cell.backgroundColor = .clear
    cell.contentView.backgroundColor = .clear
    //    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let text = section == 0 ? "Collections" : "Videos"
    
    let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 29)
    let headerView = UIView(frame: frame)
    
    headerView.backgroundColor = ThemeManager.defaultManager.currentTheme().tableViewSectionHeaderBackgroundColor
    
    let labelFrame = CGRect(x: 8, y: 0, width: tableView.frame.width - 8, height: 29)
    let label = UILabel(frame: labelFrame)
    label.text = text
    
    label.textColor = ThemeManager.defaultManager.currentTheme().tableViewSectionHeaderTextLabelColor
    
    headerView.addSubview(label)
    
    return headerView
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return haveSearchResults() ? 29 : 0
  }
  
  //MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showCollectionDetail" {
      if let vc = segue.destination as? CollectionTableViewController,
        let collection = self.selectedCollection {
          vc.mediaObjectCollection = collection
//          vc.course = collection
      }
    } else if segue.identifier == "showVideoDetail" {
      if let vc = segue.destination as? VideoTableViewController,
        let video = selectedVideo {
          vc.configureWithInfo(video, related: nil)
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if !haveSearchResults() { return }
    do {
      if (indexPath as NSIndexPath).section == 0 { // video collections
        if let collections = foundCollections {
          self.selectedCollection = try collections.lookup( UInt(indexPath.row) )
          self.performSegue(withIdentifier: "showCollectionDetail", sender: self)
        }
      } else {
        if let videos = foundVideos {
          self.selectedVideo = try videos.lookup( UInt(indexPath.row) )
          self.performSegue(withIdentifier: "showVideoDetail", sender: self)
        }
      }
    } catch {
      self.tableView?.deselectRow(at: indexPath, animated: true)
      print("clicked cell with no data")
    }
  }
  
  //MARK: helpers
  func showSearchErrorAlert() {
    let alert = UIAlertController(title: "Search Error", message: "Server responded with an error. Please try again.", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
      self.resetSearchTable()
    }
    alert.addAction(action)
    self.present(alert, animated: true) { () -> Void in
      DispatchQueue.main.async(execute: { () -> Void in
        NotificationCenter.default.post(Notification(name: "endedSearch" as NSNotification.Name, object: nil))
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
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField.text?.characters.count > 0 {
      let query = textField.text?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
      print("search for: \(query)")
      fetchSearchResults(query!)
    } else {
      resetSearchTable()
    }
    
    textField.resignFirstResponder()
    
    return true
  }
}

