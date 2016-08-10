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
    case .some(.Video):                 reuseIdentifier = "textLabelMenuCell"
    case .some(.Search):                reuseIdentifier = "searchMenuCell"
    case .some(.Home):                  reuseIdentifier = "textLabelMenuCell"
    case .some(.Collection):            reuseIdentifier = "textLabelMenuCell"
    default:                            reuseIdentifier = "textLabelMenuCell"
    }
    
    return reuseIdentifier
  }
  
  static func menuItemFromJson(_ json: Dictionary<String, AnyObject>) -> MenuItem {
    //   print("MENU OBJECT JSON \(json)")
    var newItem = MenuItem()
    if let type = json["type"] as? String,
      let id = json["id"] as? String,
      let attributes = json["attributes"] as? Dictionary<String, AnyObject> {
        newItem.objectId = id
        newItem.type = MenuItemType(rawValue: type)
        newItem.title = attributes["title"] as? String
    }
    return newItem
  }
  
  static func menuItemFromCollection(_ collection: OddMediaObjectCollection) -> MenuItem {
    var newItem = MenuItem()
    newItem.objectId = collection.id
    newItem.type = MenuItemType(rawValue: "collection")
    newItem.title = collection.title
    return newItem
  }
  
  static func menuItemFromVideo(_ video: OddVideo) -> MenuItem {
    var newItem = MenuItem()
    newItem.objectId = video.id
    newItem.type = MenuItemType(rawValue: "video")
    newItem.title = video.title
    return newItem
  }
}

extension UITableViewCell {
  
  func configureCellAccessoryViewForCellType(_ type: MenuItemType) {
    if type == .Search { return }
    let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: self.frame.height * 0.3 ) )
    let disclosureImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 8, height: self.frame.height * 0.3) )
    disclosureImageView.image = UIImage(named: "disclosure-arrow")
    disclosureImageView.image = disclosureImageView.image!.withRenderingMode(.alwaysTemplate)
    disclosureImageView.tintColor = ThemeManager.defaultManager.currentTheme().sideMenuCellAccessoryColor
    accessoryView.addSubview(disclosureImageView)
    self.accessoryView = accessoryView
  }
  
  func styleWithTheme() {
    self.textLabel?.textColor = ThemeManager.defaultManager.currentTheme().sideMenuCellTitleTextLabelColor
    self.selectionStyle = .none
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
    NotificationCenter.default.addObserver(self, selector: #selector(HomeMenuTableViewController.clearItemSelected), name: "menuAnimationComplete" as NSNotification.Name, object: nil)
  }
  
  func reload() {
    DispatchQueue.main.async(execute: { () -> Void in
      self.tableView.reloadData()
    })
  }
  
  func configureMenuItems() {
    for menuItemJson in initialMenuData {
      self.menuItems.append(MenuItem.menuItemFromJson(menuItemJson))
    }
    guard let menuView = self.homeMenuView,
      let items = menuView.relationshipNodeWithName("items") else {
        OddLogger.error("Unable to determine menuItemids")
        return
    }
    
    if let collectionIds = items.idsOfType(.collection) {
      OddContentStore.sharedStore.objectsOfType(.collection, ids: collectionIds, include: "entities") { (objects, errors) in
        objects.forEach({ (object) in
          if let collection = object as? OddMediaObjectCollection {
            self.menuItems.append(MenuItem.menuItemFromCollection(collection))
          }
        })
        self.reload()
      }
    }
    
    if let videoIds = items.idsOfType(.video) {
      OddContentStore.sharedStore.objectsOfType(.video, ids: videoIds, include: nil) { (objects, errors) in
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
    navigationBar?.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
    navigationBar?.shadowImage = UIImage()
    navigationBar?.barStyle = .black
    navigationBar?.isTranslucent = false
    navigationBar?.barTintColor = ThemeManager.defaultManager.currentTheme().sideMenuNavigationBarColor
    self.view.backgroundColor = ThemeManager.defaultManager.currentTheme().sideMenuNavigationBarColor
    self.setImageForTitleView("sideMenuLogo", size: CGSize(width: 154, height: 29), centerForMissingRightButton: false)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return menuItems.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Configure the cell...
    var cell: UITableViewCell
    var searchCell: MenuSearchCell
    do {
      let menuItem = try self.menuItems.lookup(UInt((indexPath as NSIndexPath).row))
      if menuItem.type == .Search {
        searchCell = tableView.dequeueReusableCell(withIdentifier: menuItem.tableViewCellReuseIdentifier(), for: indexPath) as! MenuSearchCell
        searchCell.configureForSearch()
        return searchCell
      } else {
        cell = tableView.dequeueReusableCell(withIdentifier: menuItem.tableViewCellReuseIdentifier(), for: indexPath)
        if let type = menuItem.type {
          cell.configureCellAccessoryViewForCellType(type)
        }
        cell.textLabel?.text = menuItem.title
        cell.styleWithTheme()
        return cell
      }
    } catch {
      cell = tableView.dequeueReusableCell(withIdentifier: "textLabelMenuCell", for: indexPath)
      cell.textLabel?.text = "error: no menu item"
      cell.styleWithTheme()
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if !itemSelected {
      itemSelected = true
      self.tableView.deselectRow(at: indexPath, animated: true)
      
      do {
        let selectedItem = try self.menuItems.lookup(UInt((indexPath as NSIndexPath).row))
        if let delegate = self.rootController,
          let type = selectedItem.type {
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
