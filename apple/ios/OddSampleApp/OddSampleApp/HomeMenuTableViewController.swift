//
//  HomeMenuTableViewController.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//
import UIKit
import OddSDK

enum MenuItemType : String {
  case Video = "video"
  case Search = "search"
  case Home = "home"
  case Collection = "collection"
}

struct MenuItem {
  var title: String?
  var type: MenuItemType?
  var objectId: String?
  
  func tableViewCellReuseIdentifier() -> String {
    var reuseIdentifier: String
    switch type {
    case .Some(.Video):                 reuseIdentifier = "textLabelMenuCell"
    case .Some(.Search):                reuseIdentifier = "searchMenuCell"
    case .Some(.Home):                  reuseIdentifier = "textLabelMenuCell"
    case .Some(.Collection):            reuseIdentifier = "textLabelMenuCell"
    default:                            reuseIdentifier = "textLabelMenuCell"
    }
    
    return reuseIdentifier
  }
  
  static func menuItemFromJson(json: Dictionary<String, AnyObject>) -> MenuItem {
    //   print("MENU OBJECT JSON \(json)")
    var newItem = MenuItem()
    if let type = json["type"] as? String, id = json["id"] as? String, attributes = json["attributes"] as? Dictionary<String, AnyObject> {
      newItem.objectId = id
      newItem.type = MenuItemType(rawValue: type)
      newItem.title = attributes["title"] as? String
    }
    return newItem
  }
  
  static func menuItemFromCollection(collection: OddMediaObjectCollection) -> MenuItem {
    var newItem = MenuItem()
    newItem.objectId = collection.id
    newItem.type = MenuItemType(rawValue: "collection")
    newItem.title = collection.title
    return newItem
  }
  
  static func menuItemFromVideo(video: OddVideo) -> MenuItem {
    var newItem = MenuItem()
    newItem.objectId = video.id
    newItem.type = MenuItemType(rawValue: "video")
    newItem.title = video.title
    return newItem
  }
}

extension UITableViewCell {
  
  func configureCellAccessoryViewForCellType(type: MenuItemType) {
    if type == .Search { return }
    let accessoryView = UIView(frame: CGRectMake(0, 0, 8, self.frame.height * 0.3 ) )
    let disclosureImageView = UIImageView(frame: CGRectMake(0, 0, 8, self.frame.height * 0.3) )
    disclosureImageView.image = UIImage(named: "disclosure-arrow")
    disclosureImageView.image = disclosureImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
    disclosureImageView.tintColor = ThemeManager.defaultManager.currentTheme().sideMenuCellAccessoryColor
    accessoryView.addSubview(disclosureImageView)
    self.accessoryView = accessoryView
  }
  
  func styleWithTheme() {
    self.textLabel?.textColor = ThemeManager.defaultManager.currentTheme().sideMenuCellTitleTextLabelColor
    self.selectionStyle = .None
    self.backgroundColor = ThemeManager.defaultManager.currentTheme().sideMenuCellBackgroundColor
    self.tintColor = ThemeManager.defaultManager.currentTheme().sideMenuCellAccessoryColor
  }
}

class HomeMenuTableViewController: UITableViewController {
  
  var rootController: RootViewController?
  var homeMenuView: OddView?
  var menuItems: Array<MenuItem> = []
  var itemSelected: Bool = false
  
  let initialMenuData: Array<Dictionary<String, AnyObject>> = [
    ["type":"search", "id":"search", "attributes": ["title" : "Search"]],
    ["type":"home", "id":"home-view", "attributes": ["title" : "Home"]],
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigationController()
    configureMenuItems()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeMenuTableViewController.clearItemSelected), name: "menuAnimationComplete", object: nil)
  }
  
  func reload() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView.reloadData()
    })
  }
  
  func configureMenuItems() {
    for menuItemJson in initialMenuData {
      self.menuItems.append(MenuItem.menuItemFromJson(menuItemJson))
    }
    guard let menuView = self.homeMenuView, items = menuView.relationshipNodeWithName("items") else {
        OddLogger.error("Unable to determine menuItemids")
        return
    }
    
    if let collectionIds = items.idsOfType(.Collection) {
      OddContentStore.sharedStore.objectsOfType(.Collection, ids: collectionIds, include: "entities") { (objects, errors) in
        objects.forEach({ (object) in
          if let collection = object as? OddMediaObjectCollection {
            self.menuItems.append(MenuItem.menuItemFromCollection(collection))
          }
        })
        self.reload()
      }
    }
    
    if let videoIds = items.idsOfType(.Video) {
      OddContentStore.sharedStore.objectsOfType(.Video, ids: videoIds, include: nil) { (objects, errors) in
        objects.forEach({ (object) in
          if let video = object as? OddVideo {
            self.menuItems.append(MenuItem.menuItemFromVideo(video))
          }
        })
        self.reload()
      }
    }

    
  }
  
  func configureNavigationController() {
    let navigationBar = self.navigationController?.navigationBar
    navigationBar?.setBackgroundImage(UIImage(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
    navigationBar?.shadowImage = UIImage()
    navigationBar?.barStyle = .Black
    navigationBar?.translucent = false
    navigationBar?.barTintColor = ThemeManager.defaultManager.currentTheme().sideMenuNavigationBarColor
    self.view.backgroundColor = ThemeManager.defaultManager.currentTheme().sideMenuNavigationBarColor
    self.setImageForTitleView("sideMenuLogo", size: CGSizeMake(154, 29), centerForMissingRightButton: false)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return menuItems.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    // Configure the cell...
    var cell: UITableViewCell
    var searchCell: MenuSearchCell
    do {
      let menuItem = try self.menuItems.lookup(UInt(indexPath.row))
      if menuItem.type == .Search {
        searchCell = tableView.dequeueReusableCellWithIdentifier(menuItem.tableViewCellReuseIdentifier(), forIndexPath: indexPath) as! MenuSearchCell
        searchCell.configureForSearch()
        return searchCell
      } else {
        cell = tableView.dequeueReusableCellWithIdentifier(menuItem.tableViewCellReuseIdentifier(), forIndexPath: indexPath)
        if let type = menuItem.type {
          cell.configureCellAccessoryViewForCellType(type)
        }
        cell.textLabel?.text = menuItem.title
        cell.styleWithTheme()
        return cell
      }
    } catch {
      cell = tableView.dequeueReusableCellWithIdentifier("textLabelMenuCell", forIndexPath: indexPath)
      cell.textLabel?.text = "error: no menu item"
      cell.styleWithTheme()
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if !itemSelected {
      itemSelected = true
      self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
      
      do {
        let selectedItem = try self.menuItems.lookup(UInt(indexPath.row))
        if let delegate = self.rootController, type = selectedItem.type {
          switch type {
          case .Search:
            delegate.selectedSearchFromMenu()
          case .Home:
            delegate.selectedHomeFromMenu()
          case .Collection, .Video:
            delegate.selectedMediaObjectIdFromMenu(selectedItem.objectId)
          }
        }
      } catch {
        print("Error selecting menu Item")
      }
    }
  }
  
  //MARK: Utility
  func clearItemSelected() {
    //    print("clearing item selected")
    self.itemSelected = false
  }
  
  
}
