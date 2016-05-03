//
//  HomeCollectionViewController.swift
//  tvOSSampleApp
//
//  Created by Patrick McConnell on 1/28/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDKtvOS

class HomeCollectionViewController: UICollectionViewController {
  
  var collection = OddMediaObjectCollection() {
    didSet {
      self.fetchCollections()
    }
  }
  
  var collections = Array<OddMediaObjectCollection>() {
    didSet {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.collectionView?.reloadData()
      })
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureSDK()
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
  }
  */
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let node = self.collection.relationshipNodeWithName("entities") as? OddRelationshipNode else { return 0 }
    return node.numberOfRelationships
  }
  
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as? CollectionCell else { return UICollectionViewCell() }
    
    // fetch the collection associated with this cell
    let currentCollection = self.collections[indexPath.row]
    cell.configureWithCollection(currentCollection)
    return cell
    
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    print("Selected: \(indexPath.row)")
    
    // you really want to be sure this is not an index out of bounds
    let selectedCollection = self.collections[indexPath.row]
    self.performSegueWithIdentifier("showCollectionInfoSegue", sender: selectedCollection)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let id = segue.identifier else { return }
    switch id {
    case "showCollectionInfoSegue":
      guard let vc = segue.destinationViewController as? CollectionInfoViewController else { break }

      if let collection = sender as? OddMediaObjectCollection {
          vc.collection = collection
      }
      
    default:
      break
    }
  }
  
  // MARK: - Helpers
  
  // The content store now has data so lets present the 
  // featuredCollections
  func configureOnContentLoaded() {
    let contentStoreInfo = OddContentStore.sharedStore.mediaObjectInfo()
    print( "\(contentStoreInfo)" )
    
    guard let config = OddContentStore.sharedStore.config,
      let homeViewId = config.idForViewName("homepage") else {
      OddLogger.error("Error loading config. Unable to configure application")
      return
    }
      
    OddContentStore.sharedStore.objectsOfType(.View, ids: [homeViewId], include: "featuredMedia,featuredCollections,promotion") { (objects, errors) in
      if errors != nil {
        OddLogger.error("Unable to fetch homeview: \(errors!.first?.localizedDescription)")
        return
      } else {
        guard let homeview = objects.first as? OddView else {
          OddLogger.error("Unable to fetch homeview")
          return
        }
        
        // at this point the homeview, featuredMedia, featuredCollections and promotion should all be in the OddMediaStore cache
        
        guard let featuredCollection = homeview.relationshipNodeWithName("featuredCollections") as? OddRelationshipNode,
          let node = featuredCollection.relationship as? OddRelationship else {
          OddLogger.error("Unable to determine featuredCollection")
          return
        }
        
        let featuredCollectionId = node.id
        
        OddContentStore.sharedStore.objectsOfType(.Collection, ids: [featuredCollectionId], include: "entities", callback: { (objects, errors) in
          if errors != nil {
            OddLogger.error("Error loading featuredCollection")
            return
          }
          
          if let featuredCollection = objects.first as? OddMediaObjectCollection {
            self.collection = featuredCollection
          }
          
        })
        
      }
    }
  }
  
  
  // Setup the SDK to commuicate with our Oddworks account
  func configureSDK() {
    // Setting the log level to .Info provides additional information from the OddContentStore
    // The OddLogger has 3 levels: .Info, .Warning and .Error. The default is .Error
    OddLogger.logLevel = .Info
    
    OddContentStore.sharedStore.API.serverMode = .Local
    /* Please visit https://www.oddnetworks.com/getstarted/ to get the demo app authentication token
    this line is required to allow access to the API. Once you have entered your authToken uncomment 
    to continue*/
    OddContentStore.sharedStore.API.authToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ2ZXJzaW9uIjoxLCJjaGFubmVsIjoibmFzYSIsInBsYXRmb3JtIjoiYXBwbGUtdHYiLCJzY29wZSI6WyJwbGF0Zm9ybSJdLCJpYXQiOjE0NjE4NzU5OTV9.uMJ6ckqkI283bhUrYJL30-8R6mzYBqa0H5gDNqqMaDY"

    
    OddContentStore.sharedStore.initialize { (success, error) in
      if success {
        self.configureOnContentLoaded()
      }
    }
  }
  

  func fetchCollections() {
    guard let node = self.collection.relationshipNodeWithName("entities") as? OddRelationshipNode,
      let ids = node.allIds  else { return }
    
    OddContentStore.sharedStore.objectsOfType(.Collection, ids: ids, include: nil) { (objects, errors) in
      if let theCollections = objects as? Array<OddMediaObjectCollection> {
        self.collections = theCollections
      }
    }
  }
  
}
