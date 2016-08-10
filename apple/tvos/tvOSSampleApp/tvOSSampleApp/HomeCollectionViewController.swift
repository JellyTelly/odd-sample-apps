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
      DispatchQueue.main.async(execute: { () -> Void in
        self.collectionView?.reloadData()
      })
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureSDK()
  }
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let node = self.collection.relationshipNodeWithName("entities") else { return 0 }
    return node.numberOfRelationships
  }
  
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CollectionCell else { return UICollectionViewCell() }
    
    // fetch the collection associated with this cell
    let currentCollection = self.collections[(indexPath as NSIndexPath).row]
    cell.configureWithCollection(currentCollection)
    return cell
    
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("Selected: \((indexPath as NSIndexPath).row)")
    
    // you really want to be sure this is not an index out of bounds
    let selectedCollection = self.collections[(indexPath as NSIndexPath).row]
    self.performSegue(withIdentifier: "showCollectionInfoSegue", sender: selectedCollection)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let id = segue.identifier else { return }
    switch id {
    case "showCollectionInfoSegue":
      guard let vc = segue.destination as? CollectionInfoViewController else { break }

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
      
    OddContentStore.sharedStore.objectsOfType(.view, ids: [homeViewId], include: "featuredMedia,featuredCollections,promotion") { (objects, errors) in
      if errors != nil {
        OddLogger.error("Unable to fetch homeview: \(errors!.first?.localizedDescription)")
        return
      } else {
        guard let homeview = objects.first as? OddView else {
          OddLogger.error("Unable to fetch homeview")
          return
        }
        
        // at this point the homeview, featuredMedia, featuredCollections and promotion should all be in the OddMediaStore cache
        
        guard let featuredCollection = homeview.relationshipNodeWithName("featuredCollections"),
          let node = featuredCollection.relationship as? OddRelationship else {
          OddLogger.error("Unable to determine featuredCollection")
          return
        }
        
        let featuredCollectionId = node.id
        
        OddContentStore.sharedStore.objectsOfType(.collection, ids: [featuredCollectionId], include: "entities", callback: { (objects, errors) in
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
    OddLogger.logLevel = .info
    
    OddContentStore.sharedStore.API.serverMode = .local
    /*
    If you are running your own Oddworks server the server will provide tokens for each channel
    and device you have configured when it launches. Paste the apple-tv token below. 
    
    If you are using an Oddworks hosted server the token will be provided for you.
     
    This line is required to allow access to the API. Once you have entered your authToken uncomment
    to continue
     */
    OddContentStore.sharedStore.API.authToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjaGFubmVsIjoibmFzYSIsInBsYXRmb3JtIjoiYXBwbGUtdHYiLCJ1c2VyIjoiYThkY2I5MmMtYjVhMC00ZWI1LTg0ZDItZWU4ZmQ3ZDUxZmFmIiwiaWF0IjoxNDcwMjQyMDQ1LCJhdWQiOlsicGxhdGZvcm0iXSwiaXNzIjoidXJuOm9kZHdvcmtzIn0.X3gbXqW4qe7ShXFCqtzIT1cqZ7SfOTkgBWC0VFzL0n4"

    
    OddContentStore.sharedStore.initialize { (success, error) in
      if success {
        self.configureOnContentLoaded()
      }
    }
  }
  

  func fetchCollections() {
    guard let node = self.collection.relationshipNodeWithName("entities"),
      let ids = node.allIds  else { return }
    
    OddContentStore.sharedStore.objectsOfType(.collection, ids: ids, include: nil) { (objects, errors) in
      if let theCollections = objects as? Array<OddMediaObjectCollection> {
        self.collections = theCollections
      }
    }
  }
  
}
