//
//  HomeViewController.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//


import UIKit
import OddSDK

class HomeViewController: UIViewController, UINavigationControllerDelegate {
  
  var selectedCollection = OddMediaObjectCollection()
  var selectedVideo = OddVideo()
  
  var ourContainerView: UIView?
  var menuCloseTapGesture: UITapGestureRecognizer?
  var panGesture: UIPanGestureRecognizer?
  var homeView: OddView?
  
  var menuButtonIcon = UIImage(named: "hamburger")
  var searchButtonIcon = UIImage(named: "magnify")
  
  var menuButton: UIBarButtonItem?
  var searchButton: UIBarButtonItem?
  
  @IBOutlet weak var featuredCollectionsContainerView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.menuButton = UIBarButtonItem(image: menuButtonIcon, style: .plain, target: self, action: #selector(HomeViewController.toggleMenu(_:)))
    self.searchButton = UIBarButtonItem(image: searchButtonIcon, style: .plain, target: self, action: #selector(HomeViewController.showSearchAnimated))
    displayNavButtons(searchButton, leftButton: menuButton)
    
    self.view.backgroundColor = ThemeManager.defaultManager.currentTheme().promoHomeOptionBackgroundColor
    registerForNotifications()
    initializeHome()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    panGesture?.isEnabled = false
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    panGesture?.isEnabled = true
  }
  
  // MARK: - Configuration
  func registerForNotifications() {
//    NSNotificationCenter.defaultCenter().addObserver(self, selector: "contentLoaded", name: "oddContentStoreCompletedInitialLoad", object: nil)
  }
  
  func initializeHome() {
    DispatchQueue.main.async(execute: { () -> Void in
      self.registerForNotifications()
      self.setImageForTitleView("headerLogo", size: CGSize(width: 154, height: 29), centerForMissingRightButton: false)
      self.configureMenuSwipes()
      self.configureMenuCloseTap()
      self.navigationController?.delegate = self
    })
  }
  
  func configureMenuSwipes() {
    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(HomeViewController.toggleMenu(_:)))
    rightSwipe.direction = .right
    rightSwipe.numberOfTouchesRequired = 1
    
    self.view.addGestureRecognizer(rightSwipe)
    
    let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(HomeViewController.toggleMenu(_:)))
    leftSwipe.direction = .left
    leftSwipe.numberOfTouchesRequired = 1
    
    panGesture = UIPanGestureRecognizer(target: self, action: #selector(HomeViewController.handlePan(_:)))
    self.ourContainerView?.addGestureRecognizer(panGesture!)
    
    self.view.addGestureRecognizer(leftSwipe)
  }
  
  func configureMenuCloseTap() {
    menuCloseTapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.toggleMenu(_:)))
    menuCloseTapGesture!.numberOfTouchesRequired = 1
    menuCloseTapGesture!.numberOfTapsRequired = 1
    self.view.addGestureRecognizer(menuCloseTapGesture!)
    menuCloseTapGesture!.isEnabled = false
  }
  
  func displayNavButtons(_ rightButton: UIBarButtonItem?, leftButton: UIBarButtonItem?) {
    if let rightButton = rightButton {
      self.navigationItem.rightBarButtonItem = rightButton
    } else {
      self.navigationItem.rightBarButtonItem = nil
    }
    if let leftButton = leftButton {
      self.navigationItem.leftBarButtonItem = leftButton
    } else {
      self.navigationItem.leftBarButtonItem = nil
    }
  }
  
  // hides the menu if it contains no items or if we are displaying the launch promo view
  func toggleMenuButton() -> UIBarButtonItem? {
    
    var button: UIBarButtonItem
    
    //    let numberOfMenuItems = OddContentStore.sharedStore.homeMenu.menuItemCollections.count
    
    if self.navigationItem.leftBarButtonItem != nil {
      return nil
    } else {
      button = UIBarButtonItem(image: self.menuButtonIcon, style: .plain, target: self, action: #selector(HomeViewController.toggleMenu(_:)))
      return button
    }
  }
  
  @IBAction func toggleMenu(_ sender: AnyObject) {
    let offset = self.view.frame.width * 0.8
    var offscreen = false
    if sender is UIPanGestureRecognizer {
      offscreen = self.ourContainerView?.frame.origin.x < offset / 2
    } else {
      offscreen = self.ourContainerView?.frame.origin.x > 0
    }
    
    if sender is UISwipeGestureRecognizer {
      if sender.direction == .right && offscreen { return }
      if sender.direction == .left && !offscreen { return }
    }
    
    
    UIView.animate(withDuration: 0.2, animations: { () -> Void in
      if offscreen {
        self.ourContainerView?.frame.origin.x = 0
      } else {
        self.ourContainerView?.frame.origin.x = 0 + offset
      }
      }, completion: { (complete) -> Void in
        if !offscreen {
          NotificationCenter.default.post(Notification(name: "menuAnimationComplete" as NSNotification.Name, object: self))
        }
    })
    featuredCollectionsContainerView.isUserInteractionEnabled = offscreen
    menuCloseTapGesture?.isEnabled = !offscreen
  }
  
  @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
    let offset = self.view.frame.width * 0.8
    if let container = self.ourContainerView {
      if gestureRecognizer.state == UIGestureRecognizerState.began || gestureRecognizer.state == UIGestureRecognizerState.changed {
        let translation = gestureRecognizer.translation(in: container)
        if let superView = gestureRecognizer.view {
          
          if superView.frame.origin.x + translation.x > offset  {return}
          if superView.frame.origin.x + translation.x < 0 {return}
          
          superView.center = CGPoint(x: superView.center.x + translation.x, y: superView.center.y)
          gestureRecognizer.setTranslation(CGPoint(x: 0,y: 0), in: superView)
        }
      } else if gestureRecognizer.state == UIGestureRecognizerState.ended {
        toggleMenu(gestureRecognizer)
      }
    }
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let id = segue.identifier else { return }
    switch id {
    case "homeTableEmbedSegue":
      guard let vc = segue.destination as? HomeTableViewController else { break }
      vc.homeVC = self
      vc.homeView = self.homeView
//      vc.mediaObjectCollection =
      //get the default mediaObjectCollectionHere and stick a player on top with the livestream
    case "showCollectionSegue":
      guard let vc = segue.destination as? CollectionTableViewController else { break }
      vc.mediaObjectCollection = self.selectedCollection
    case "showVideoSegue":
      guard let vc = segue.destination as? VideoTableViewController else { break }
      vc.configureWithInfo(self.selectedVideo, related: nil)
    case "showSearchFromButtonSegue" :
      if let vc = segue.destination as? SearchTableViewController {
        vc.searchField?.becomeFirstResponder()
      }
    case "showSearchSegue" :
      if let vc = segue.destination as? SearchTableViewController {
        vc.searchField?.becomeFirstResponder()
      }
    default:
      break
    }
  }
  
  // this method dismisses the menu after any subview is animated over the home view
  // helps avoid showing the home view then animating to the subview
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    if viewController is CollectionTableViewController || viewController is SearchTableViewController || viewController is VideoTableViewController {
      if self.ourContainerView?.frame.origin.x > 0 {
        DispatchQueue.main.async(execute: { () -> Void in
          if self.ourContainerView?.frame.origin.x > 0 {
            self.toggleMenu(self)
          }
        })
      }
    }
  }
  
  func selectedMediaObject( _ object: OddMediaObject) {
    if let collection = object as? OddMediaObjectCollection {
      self.selectedCollection = collection
      DispatchQueue.main.async(execute: { () -> Void in
        self.performSegue(withIdentifier: "showCollectionSegue", sender: self)
      })
    }
    if let video = object as? OddVideo {
      self.selectedVideo = video
      DispatchQueue.main.async(execute: { () -> Void in
        self.performSegue(withIdentifier: "showVideoSegue", sender: self)
      })
    }
  }

  func showSearch() {
    print("showSearch")
    self.performSegue(withIdentifier: "showSearchSegue", sender: self)
  }
  
  func showSearchAnimated() {
    print("showSearchAnimated")
    self.performSegue(withIdentifier: "showSearchAnimatedSegue", sender: self)
  }
  
  // MARK: - Unwinds
  @IBAction func exitSearch( _ segue: UIStoryboardSegue ) {
    print("end search")
  }
  
}
