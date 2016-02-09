//
//  CollectionInfoTableViewController.swift
//  tvOSSampleApp
//
//  Created by Patrick McConnell on 1/28/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import AVKit
import OddSDKtvOS

class CollectionInfoVideoTableViewController: UITableViewController {
  
  var videos = Array<OddVideo>() {
    didSet {
      self.tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return videos.count
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("videoCell", forIndexPath: indexPath)
    
    
    let currentVideo = self.videos[indexPath.row]
    
    cell.textLabel?.text = currentVideo.title
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let currentVideo = self.videos[indexPath.row]
    
    let playerVC = AVPlayerViewController()
    
    if let urlString = currentVideo.urlString {
      if let videoURL = NSURL(string: urlString) {
        let mediaItem = AVPlayerItem(URL: videoURL)
        let player = AVPlayer(playerItem: mediaItem)
        playerVC.player = player
        playerVC.player?.play()
        self.presentViewController(playerVC, animated: true, completion: { () -> Void in
          
        })
      }
    }
  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
