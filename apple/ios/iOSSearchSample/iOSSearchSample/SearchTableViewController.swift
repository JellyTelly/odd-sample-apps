//
//  SearchTableViewController.swift
//  iOSSearchSample
//
//  Created by Patrick McConnell on 2/23/16.
//  Copyright © 2016 Oddnetworks. All rights reserved.
//

/***

A simple application to show how to use the Oddnetworks SDK to search through
your catalog of media objects.

***/


import UIKit
import OddSDK

class SearchTableViewController: UITableViewController {
  
  @IBOutlet weak var searchTextField: UITextField!
  
  // we will display the two types of objects returned in a
  // default search: videos and collections
  var videoResults = Array<OddVideo>()
  var collectionResults = Array<OddMediaObjectCollection>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureSDK()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // one section for videos and one for collections
    return 2
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // we will show "no results" if the results array is empty
    // so we always want at least one cell
    switch section {
      case 0: return self.videoResults.count == 0 ? 1 : self.videoResults.count
      case 1: return self.collectionResults.count == 0 ? 1 : self.collectionResults.count
      default: return 0
    }
  }
  

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath)
  
    var currentMediaObject: OddMediaObject?
    var mediaObjectType = "OddVideo"
    
    if indexPath.section == 0 && !self.videoResults.isEmpty {
      // videos
      currentMediaObject = self.videoResults[indexPath.row]
    } else if !self.collectionResults.isEmpty {
      // collections
      currentMediaObject = self.collectionResults[indexPath.row]
      mediaObjectType = "OddMediaObjectCollection"
    }
  
    if currentMediaObject != nil {
      // there are results for this object type...
      cell.textLabel?.text = currentMediaObject?.title
      cell.detailTextLabel?.text = mediaObjectType
    } else {
      /// no results...
      cell.textLabel?.text = "No Search Results"
      cell.detailTextLabel?.text = ""
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 0 ? "Videos" : "Collections"
  }
  
  // MARK: - Helpers
  
  // Setup the SDK to commuicate with our Oddworks account
  func configureSDK() {
    // Setting the log level to .Info provides additional information from the OddContentStore
    // The OddLogger has 3 levels: .Info, .Warning and .Error. The default is .Error
    //    OddLogger.logLevel = .Info
    
    /* Please visit https://www.oddnetworks.com/getstarted/ to get the demo app authentication token
    this line is required to allow access to the API. Once you have entered your authToken uncomment
    to continue
    OddContentStore.sharedStore.API.authToken = <insert your authToken here>
    */

    OddContentStore.sharedStore.API.authToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ2ZXJzaW9uIjoxLCJkZXZpY2VJRCI6IjkxNWU2MmQwLWI5MzctMTFlNS04NWZiLTk5ZDM0MDQyNGU1ZCIsInNjb3BlIjpbImRldmljZSJdLCJpYXQiOjE0NTI2MDg0MDF9.zMVD7BZssmJ7Bzo5wDYA1jjrLyU_hNg-vgWZIQJtaX8"
    
    // if your app is doing more than just searching you will want to initialize
    // the content store. In this sample we do not need to do so. Since all searches
    // are performed on the server we will not require a local copy of any of our
    // media objects. Any objects returned by a search will be added to the local store
    // for future use
//    OddContentStore.sharedStore.initialize()
  }

  // MARK: - Search

  func fetchSearchResults(term: String) {
    OddContentStore.sharedStore.searchForTerm(term) { (videos, collections) -> Void in
      print("Search found \(videos!.count) videos and \(collections!.count) collections for the term: '\(term)'")
      self.displaySearchResults(videos, collections: collections)
    }
  }
  
  // if no results are found clear any old data and redraw the tableview
  // to indicate "no results"
  func resetSearchTable() {
    self.videoResults.removeAll()
    self.collectionResults.removeAll()
    self.tableView?.reloadData()
  }
  
  func displaySearchResults(var videos: Array<OddVideo>?, var collections: Array<OddMediaObjectCollection>?) {
    
    if videos == nil { videos = Array<OddVideo>() }
    if collections == nil { collections = Array<OddMediaObjectCollection>() }
    
    self.videoResults = videos!
    self.collectionResults = collections!
    
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView?.reloadData()
    })
  }

  
  // MARK: - UITextFieldDelegate
  
  
  // we are the delegate for the text field in the navigation bar
  // this method will be called when the 'search' key is pressed on the keyboard
  // initiating a search
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField.text?.characters.count > 0 {
      let query = textField.text?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
      print("Searching for: \(query!)")
      fetchSearchResults(query!)
    } else {
      resetSearchTable()
    }
    
    textField.resignFirstResponder()
    
    return true
  }

}
