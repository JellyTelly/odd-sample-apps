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
    OddContentStore.sharedStore.API.serverMode = .local
    OddLogger.logLevel = .info
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
      let homeViewId = config.idForViewName("homepage"), let menuViewId = config.idForViewName("menu") else {
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
        self.homeView = homeview
        print("Home Errors: \(errors)")
        OddContentStore.sharedStore.objectsOfType(.view, ids: [menuViewId], include: "items") { (objects, errors) in
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
            DispatchQueue.main.async(execute: { () -> Void in
              UIView.setAnimationsEnabled(false)
              self.performSegue(withIdentifier: "appInit", sender: self)
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
   // OddContentStore.sharedStore.API.authToken = "<your auth token>"
    OddContentStore.sharedStore.API.authToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjaGFubmVsIjoibmFzYSIsInBsYXRmb3JtIjoiYXBwbGUtaW9zIiwidXNlciI6ImFkNjI3MGVmLTVjYTUtNGMxOS1iNDU4LTkxYmFlOGU0OTAwYSIsImlhdCI6MTQ3MDc1OTc5NSwiYXVkIjpbInBsYXRmb3JtIl0sImlzcyI6InVybjpvZGR3b3JrcyJ9.llj5k4Y7t_6mihFdcXFlWqc-HWWNbrvEZ0l-nUFcR6E"
    
    OddContentStore.sharedStore.initialize { (success, error) in
      if success {
        self.configureOnContentLoaded()
      }
    }
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "appInit" {
      if let vc = segue.destination as? RootViewController {
        vc.homeView = self.homeView
        vc.menuView = self.menuView
      }
    }
  }
  
  
}
