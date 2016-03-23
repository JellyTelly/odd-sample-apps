//
//  RootViewController.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import UIKit
import OddSDK

class RootViewController: UIViewController {
  
  @IBOutlet weak var menuWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var homeViewContainer: UIView!
  var homeViewController: HomeViewController?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RootViewController.reInitializeApp), name: "restartAppForAuth", object: nil)
//    NSNotificationCenter.defaultCenter().addObserver(self, selector: "showWebview", name: "performAuth", object: nil)
    let windowWidth = self.view.frame.width
    menuWidthConstraint.constant = windowWidth * 0.8
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "homeViewEmbed" {
      print("homeViewEmbed")
      if let navCon = segue.destinationViewController as? UINavigationController,
        vc = navCon.topViewController as? HomeViewController {
          vc.ourContainerView = homeViewContainer
          self.homeViewController = vc
      }
    } else if segue.identifier == "homeMenuEmbedSegue" {
      print("homeMenuEmbed")
      if let navCon = segue.destinationViewController as? UINavigationController,
        vc = navCon.topViewController as? HomeMenuTableViewController {
          vc.rootController = self
      }
    }
  }
  
  
  // MARK: - Utility
  
  func selectedMediaObjectIdFromMenu(mediaObjectId: String?) {
    if let id = mediaObjectId, mediaObject = OddContentStore.sharedStore.mediaObjectWithId(id) {
      self.homeViewController?.selectedMediaObject(mediaObject)
    }
  }
  
  //  func selectedCollectionFromMenu( collection : OddVideoCollection) {
  //    print("Menu selected: \(collection.title)")
  //
  //    self.homeViewController?.selectedCollection(collection)
  ////    self.homeViewController?.toggleMenu(self)
  //  }
  
  func selectedSearchFromMenu() {
    print("Search Selected")
    self.homeViewController?.showSearch()
    //    self.homeViewController?.toggleMenu(self)
  }
  
  func selectedHomeFromMenu() {
    self.homeViewController?.toggleMenu(self)
  }
  // MARK: - UIView Delegate
  
  //  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
  //    return UIInterfaceOrientationMask.Portrait
  //  }
  //
  //  override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
  //    return UIInterfaceOrientation.Portrait
  //  }
  //
  //  override func shouldAutorotate() -> Bool {
  //    return false
  //  }
  
  //  override func viewWillLayoutSubviews() {
  //    UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
  //  }
  
}
