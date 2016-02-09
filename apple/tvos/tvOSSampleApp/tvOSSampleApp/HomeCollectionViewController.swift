//
//  HomeCollectionViewController.swift
//  tvOSSampleApp
//
//  Created by Patrick McConnell on 1/28/16.
//  Copyright © 2016 Patrick McConnell. All rights reserved.
//

import UIKit
import OddSDKtvOS

class HomeCollectionViewController: UICollectionViewController {
  
  var collections = Array<OddMediaObjectCollection>()
  
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
    return self.collections.count
  }
  
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as? CollectionCell else { return UICollectionViewCell() }
    
    // fetch the collection associated with this cell
    let currentCollection = self.collections[indexPath.row]
    
    // call our custom cell class to confgure itself with the collection data
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
    if let featuredCollections = OddContentStore.sharedStore.featuredCollections {
      self.collections = featuredCollections
      
      // reload the collection view on the main thread so changes are immediate
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.collectionView?.reloadData()
      })
    }
  }
  
  
  // Setup the SDK to commuicate with our Oddworks account
  func configureSDK() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "configureOnContentLoaded", name: OddConstants.OddContentStoreCompletedInitialLoadNotification, object: nil)
    
    // Setting the log level to .Info provides additional information from the OddContentStore
    // The OddLogger has 3 levels: .Info, .Warning and .Error. The default is .Error
    //    OddLogger.logLevel = .Info
    
    
    /* Please visit https://www.oddnetworks.com/getstarted/ to get the demo app authentication token
    this line is required to allow access to the API. Once you have entered your authToken uncomment 
    to continue
    OddContentStore.sharedStore.API.authToken = <insert your authToken here>
    */
    
    OddContentStore.sharedStore.initialize()
  }
  
  
}
