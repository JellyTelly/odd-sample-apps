//
//  CollectionInfoViewController.swift
//  tvOSSampleApp
//
//  Created by Patrick McConnell on 1/28/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDKtvOS

class CollectionInfoViewController: UIViewController {
  
  @IBOutlet var collectionThumbnailImageView: UIImageView!
  @IBOutlet var collectionTitleLabel: UILabel!
  @IBOutlet weak var collectionNotesTextView: UITextView!
  
  var collection = OddMediaObjectCollection() {
    didSet {
      configureForCollection()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  

  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let id = segue.identifier else { return }
    switch id {
    case "videoTableEmbed":
      guard let vc = segue.destination as? CollectionInfoVideoTableViewController,
      let node = self.collection.relationshipNodeWithName("entities"),
        let ids = node.allIds else { break }
      
      OddContentStore.sharedStore.objectsOfType(.video, ids: ids, include:nil, callback: { (objects, errors) -> Void in
        if let videos = objects as? Array<OddVideo> {
          vc.videos = videos
        }
      })
      
    default:
      break
    }

  }


  // MARK: - Helpers
  
  func configureForCollection() {
    DispatchQueue.main.async { () -> Void in
      self.collectionTitleLabel?.text = self.collection.title
      self.collectionNotesTextView?.text = self.collection.notes
      
      self.collection.thumbnail { (image) -> Void in
        if let thumbnail = image {
          self.collectionThumbnailImageView?.image = thumbnail
        }
      }
    }
    
  }
  
}
