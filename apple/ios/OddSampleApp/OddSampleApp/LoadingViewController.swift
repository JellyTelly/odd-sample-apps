//
//  LoadingViewController.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDK

class LoadingViewController: UIViewController {
  
  var delegate: HomeViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    OddContentStore.sharedStore.API.serverMode = .Beta
    OddLogger.logLevel = .Warn
    // Do any additional setup after loading the view, typically from a nib.
    registerForNotifications()
    initializeContentStore()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  func logContentStoreInfo() {
    //    let info = OddContentStore.sharedStore.mediaObjectInfo()
    //    print("*** \(info) ***")
  }
  
  func configureOnContentLoaded() {
    logContentStoreInfo()
    //      self.topics = collections
    //      dispatch_async(dispatch_get_main_queue(), { () -> Void in
    //        //        self.collectionView?.reloadData()
    //      })
    //display the root view controller with the collection
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      UIView.setAnimationsEnabled(false)
      self.performSegueWithIdentifier("appInit", sender: self)
      UIView.setAnimationsEnabled(true)
    })
  }
  
  func registerForNotifications() {
    OddLogger.info("Registering For Notifications")
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoadingViewController.configureOnContentLoaded), name: OddConstants.OddContentStoreCompletedInitialLoadNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoadingViewController.showConnectionErrorAlert), name: OddConstants.OddErrorFetchingConfigNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoadingViewController.showConnectionErrorAlert), name: OddConstants.OddErrorFetchingHomeViewNotification, object: nil)
  }
  
  func showConnectionErrorAlert() {
    
  }
  
  func initializeContentStore() {
    OddContentStore.sharedStore.API.authToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ2ZXJzaW9uIjoxLCJkZXZpY2VJRCI6IjAzNTc1YmYwLWQ1OGQtMTFlNS05N2I0LTc1MGE2ZGUzYjQ5ZSIsInNjb3BlIjpbImRldmljZSJdLCJpYXQiOjE0NTU3MjM3MzJ9.WzDb0i6jaj1h0O88705BYpO4BCmOvLiERduMM5nn7lI"
    
    OddContentStore.sharedStore.initialize()
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //      if segue.identifier == "appInit" {
    //        if let vc = segue.destinationViewController as? RootViewController {
    //          vc.
    //        }
    //      }
  }
  
  
}
