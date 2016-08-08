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
  var homeView: OddView?
  var menuView: OddView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    OddContentStore.sharedStore.API.serverMode = .Local
    OddLogger.logLevel = .Info
    // Do any additional setup after loading the view, typically from a nib.
    initializeContentStore()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func configureOnContentLoaded() {
    let contentStoreInfo = OddContentStore.sharedStore.mediaObjectInfo()
    print( "\(contentStoreInfo)" )
    guard let config = OddContentStore.sharedStore.config,
      let homeViewId = config.idForViewName("homepage"), menuViewId = config.idForViewName("menu") else {
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
        self.homeView = homeview
        print("Home Errors: \(errors)")
        OddContentStore.sharedStore.objectsOfType(.View, ids: [menuViewId], include: "items") { (objects, errors) in
          if errors != nil {
            print(errors)
            OddLogger.error("Unable to fetch menuview: \(errors!.first?.localizedDescription)")
            return
          } else {
            guard let menuview = objects.first as? OddView else {
              OddLogger.error("Unable to fetch menuview")
              return
            }
            self.menuView = menuview
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              UIView.setAnimationsEnabled(false)
              self.performSegueWithIdentifier("appInit", sender: self)
              UIView.setAnimationsEnabled(true)
            })
          }
        }
      }
    }
  }
  
  func initializeContentStore() {
    /*
     If you are running your own Oddworks server the server will provide tokens for each channel
     and device you have configured when it launches. Paste the apple-tv token below.
     
     If you are using an Oddworks hosted server the token will be provided for you.
     
     This line is required to allow access to the API. Once you have entered your authToken uncomment
     to continue
     */
    OddContentStore.sharedStore.API.authToken = "<your auth token>"
    
    OddContentStore.sharedStore.initialize { (success, error) in
      if success {
        self.configureOnContentLoaded()
      }
    }
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "appInit" {
      if let vc = segue.destinationViewController as? RootViewController {
        vc.homeView = self.homeView
        vc.menuView = self.menuView
      }
    }
  }
  
  
}
