//
//  ThemeManager.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//


import Foundation
import UIKit

private let _defaultManager = ThemeManager()

/////////////////////////////
// SET THEME DEFAULTS HERE //
/////////////////////////////


struct Theme {
  
  var unreadThemes: Array<String> = []
  
  //Organization
  var organizationName : String = "Odd Networks"
  var organizationId : String = "odd-networks"
  
  //TableViews
  var tableViewBackgroundColor : UIColor = .lightGrayColor()
  var tableViewSeparatorColor : UIColor = .whiteColor()
  var tableViewAccessoryCellDescriptionColor : UIColor = .darkGrayColor()
  var tableViewCellTintColor: UIColor = .clearColor()
  var tableViewCellTitleLabelColor : UIColor = .blackColor()
  var tableViewCellTextLabelColor : UIColor = .darkGrayColor()
  var tableViewCellSecondaryTextLabelColor: UIColor = .lightGrayColor()
  var tableViewSectionHeaderTextLabelColor : UIColor = .lightGrayColor()
  var tableViewSectionHeaderBackgroundColor : UIColor = .darkGrayColor()
  
  //LoadingViews
  var loadingViewActivityColor: UIColor = .lightGrayColor()
  var loadingViewTextLabelColor: UIColor = .whiteColor()
  var loadingViewBackgroundColor: UIColor = .darkGrayColor()
  
  //Authentication
  var authModalBackgroundColor: UIColor = .blackColor()
  var authModalTextLabelColor: UIColor = .whiteColor()
  var authMenuTextLabelColor: UIColor = .whiteColor()
  var authMenuButtonBackgroundColor: UIColor = .darkGrayColor()
  var authMenuButtonTextLabelColor: UIColor = .whiteColor()
  var authMenuBackgroundColor: UIColor = .blackColor()
  
  //Promotion
  var promoHomeOptionBackgroundColor: UIColor = .blackColor()
  var promoPromoOptionBackgroundColor: UIColor = .blackColor()
  var promoHeaderArrowColor: UIColor = .whiteColor()
  var promoHeaderTextLabelColor: UIColor = .whiteColor()
  
  //Player
  var playerTitleOverlayAlpha: CGFloat =  0.5
  var playerTitleOverlayTextLabelColor: UIColor = .lightGrayColor()
  var playerTitleOverlayBackgroundColor: UIColor = .darkGrayColor()
  var playerTitleTextLabelColor: UIColor = .blackColor()
  var playerDescriptionTextLabelColor: UIColor = .darkGrayColor()
  var playerControlsColor: UIColor = .darkGrayColor()
  
  //PrimaryNavigationBar
  var primaryNavigationBarTintColor : UIColor = .blackColor()
  var primaryNavigationBarGradientCenterColor : UIColor = .whiteColor()
  var primaryNavigationBarGradientEdgeColor : UIColor = .whiteColor()
  
  //SideMenu
  var sideMenuSectionHeaderBackgroundColor : UIColor = .darkGrayColor()
  var sideMenuSectionHeaderTextColor : UIColor = .whiteColor()
  var sideMenuNavigationBarColor : UIColor = .lightGrayColor()
  var sideMenuCellTitleTextLabelColor: UIColor = .blackColor()
  var sideMenuCellBackgroundColor : UIColor = .clearColor()
  var sideMenuCellAccessoryColor : UIColor = .blackColor()
  var sideMenuCellSeparatorColor : UIColor = .lightGrayColor()
  
  //Thumbnail
  // needs to be completed....
  //  var defaultThumbnailImageName: String = "oddworksDefaultThumbnail"
}

typealias KeyValue = Dictionary<String, AnyObject>

class ThemeManager: NSObject {
  
  var _themeSettings : Theme?
  
  class var defaultManager: ThemeManager {
    return _defaultManager
  }
  
  // this will return a theme struct with either default values or
  // values from the bundles theme file
  func currentTheme() -> Theme {
    if _themeSettings == nil {
      
      let themeFileName = "OddTheme_NASA"
      
      // look for a tile named "OddTheme_<BundleName>" in the target (i.e. "OddTheme_Poker Central")
      //      if let bundleName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName") as? String {
      //        themeFileName = "OddTheme_\(bundleName)"
      print("THEME NAME: \(themeFileName)")
      //      }
      
      // set to default values in case a theme settings file is not found
      _themeSettings = Theme()
      
      // build the theme from the theme settings file if found
      if let path = NSBundle.mainBundle().pathForResource(themeFileName, ofType: "plist") {
        if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
          buildThemeFromDictionary(dict)
        }
      }
    }
    
    return _themeSettings!
  }
  
  
  func rgbaFromDictionary( dict: Dictionary<String, AnyObject>) -> UIColor? {
    if let r = dict["Red"] as? CGFloat,
      g = dict["Green"] as? CGFloat,
      b = dict["Blue"] as? CGFloat,
      a = dict["Alpha"] as? CGFloat {
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    return nil
  }
  
  // returns a theme instance with any settings loaded from the bundles theme file
  // where a setting is not defined in the theme file the default will be used
  func buildThemeFromDictionary( dict : Dictionary<String, AnyObject> ) {
    var newTheme = Theme()
    
    ////MARK: Organization
    if let organization = dict["Organization"] as? KeyValue {
      if let id = organization["Id"] as? String, name = organization["Name"] as? String {
        newTheme.organizationId = id
        newTheme.organizationName = name
      } else {
        newTheme.unreadThemes.append("organizationName")
        newTheme.unreadThemes.append("organizationId")
      }
    } else {
      newTheme.unreadThemes.append("organization")
    }
    
    ////MARK: TableViews
    if let tableViews = dict["TableViews"] as? KeyValue {
      
      if let background = tableViews["Background"] as? KeyValue, backgroundColor = background["Color"] as? KeyValue {
        if let colorBackground = rgbaFromDictionary(backgroundColor) {
          newTheme.tableViewBackgroundColor = colorBackground
        }
      } else {
        newTheme.unreadThemes.append("tableViewBackgroundColor")
      }
      
      if let separators = tableViews["Separators"] as? KeyValue, separatorColor = separators["Color"] as? KeyValue {
        if let colorSeparator = rgbaFromDictionary(separatorColor) {
          newTheme.tableViewSeparatorColor = colorSeparator
        }
      } else {
        newTheme.unreadThemes.append("tableViewSeparatorColor")
      }
      
      if let cells = tableViews["Cells"] as? KeyValue {
        if let accessoryCell = cells["AccessoryCell"] as? KeyValue, accessoryCellDescription = accessoryCell["Description"] as? KeyValue, accessoryCellDescriptionColor = accessoryCellDescription["Color"] as? KeyValue, tintColor = cells["TintColor"] as? KeyValue, text = cells["Text"] as? KeyValue, textColor = text["Color"] as? KeyValue, title = cells["Title"] as? KeyValue, titleColor = title["Color"] as? KeyValue, secondaryText = cells["SecondaryText"] as? KeyValue, secondaryTextColor = secondaryText["Color"] as? KeyValue {
          if let colorAccessoryCellDescription = rgbaFromDictionary(accessoryCellDescriptionColor), colorTint = rgbaFromDictionary(tintColor), colorText = rgbaFromDictionary(textColor), colorTitle = rgbaFromDictionary(titleColor), colorSecondaryText = rgbaFromDictionary(secondaryTextColor) {
            newTheme.tableViewAccessoryCellDescriptionColor = colorAccessoryCellDescription
            newTheme.tableViewCellTintColor = colorTint
            newTheme.tableViewCellTextLabelColor = colorText
            newTheme.tableViewCellTitleLabelColor = colorTitle
            newTheme.tableViewCellSecondaryTextLabelColor = colorSecondaryText
          }
        } else {
          newTheme.unreadThemes.append("tableViewAccessoryCellTitleColor")
          newTheme.unreadThemes.append("tableViewCellTintColor")
          newTheme.unreadThemes.append("tableViewCellTextLabelColor")
          newTheme.unreadThemes.append("tableViewCellTitleLabelColor")
          newTheme.unreadThemes.append("tableViewCellSecondaryTextLabelColor")
        }
      } else {
        newTheme.unreadThemes.append("tableViewCells")
      }
      
      if let sectionHeaders = tableViews["SectionHeaders"] as? KeyValue {
        if let text = sectionHeaders["Text"] as? KeyValue, textColor = text["Color"] as? KeyValue, background = sectionHeaders["Background"], backgroundColor = background["Color"] as? KeyValue {
          if let colorText = rgbaFromDictionary(textColor), colorBackground = rgbaFromDictionary(backgroundColor) {
            newTheme.tableViewSectionHeaderTextLabelColor = colorText
            newTheme.tableViewSectionHeaderBackgroundColor = colorBackground
          }
        } else {
          newTheme.unreadThemes.append("tableViewSectionHeaderTextLabelColor")
          newTheme.unreadThemes.append("tableViewSectionHeaderBackgroundColor")
        }
      } else {
        newTheme.unreadThemes.append("tableViewSectionHeaders")
      }
    } else {
      newTheme.unreadThemes.append("tableViews")
    }
    
    ////MARK: LoadingView
    if let loading = dict["LoadingView"] as? KeyValue {
      if let background = loading["Background"] as? KeyValue, backgroundColor = background["Color"] as? KeyValue, text = loading["Text"] as? KeyValue, textColor = text["Color"] as? KeyValue, activity = loading["Activity"] as? KeyValue, activityColor = activity["Color"] as? KeyValue {
        if let colorBackground = rgbaFromDictionary(backgroundColor), colorText = rgbaFromDictionary(textColor), colorActivity = rgbaFromDictionary(activityColor) {
          newTheme.loadingViewBackgroundColor = colorBackground
          newTheme.loadingViewTextLabelColor = colorText
          newTheme.loadingViewActivityColor = colorActivity
        }
      } else {
        newTheme.unreadThemes.append("loadingViewBackgroundColor")
        newTheme.unreadThemes.append("loadingViewTextLabelColor")
        newTheme.unreadThemes.append("loadingViewActivityColor")
      }
    } else {
      newTheme.unreadThemes.append("loadingView")
    }
    
    ////Mark: Auth
    if let auth = dict["Auth"] as? KeyValue {
      if let modal = auth["Modal"] as? KeyValue {
        if let background = modal["Background"] as? KeyValue, backgroundColor = background["Color"] as? KeyValue, text = modal["Text"] as? KeyValue, textColor = text["Color"] as? KeyValue  {
          if let colorBackground = rgbaFromDictionary(backgroundColor), colorText = rgbaFromDictionary(textColor) {
            newTheme.authModalBackgroundColor = colorBackground
            newTheme.authModalTextLabelColor = colorText
          }
        } else {
          newTheme.unreadThemes.append("authModalBackgroundColor")
          newTheme.unreadThemes.append("authModalTextLabelColor")
        }
      } else {
        newTheme.unreadThemes.append("authModal")
      }
      if let menu = auth["Menu"] as? KeyValue {
        if let button = menu["Button"] as? KeyValue, background = button["Background"] as? KeyValue, backgroundColor = background["Color"] as? KeyValue, text = button["Text"] as? KeyValue, textColor = text["Color"] as? KeyValue {
          if let colorBackground = rgbaFromDictionary(backgroundColor), colorText = rgbaFromDictionary(textColor) {
            newTheme.authMenuButtonBackgroundColor = colorBackground
            newTheme.authMenuButtonTextLabelColor = colorText
          }
        } else {
          newTheme.unreadThemes.append("authMenuButton")
        }
        if let text = menu["Text"] as? KeyValue, textColor = text["Color"] as? KeyValue, background = menu["Background"] as? KeyValue, backgroundColor = background["Color"] as? KeyValue  {
          if let colorBackground = rgbaFromDictionary(backgroundColor), colorText = rgbaFromDictionary(textColor) {
            newTheme.authMenuBackgroundColor = colorBackground
            newTheme.authMenuTextLabelColor = colorText
          }
        } else {
          newTheme.unreadThemes.append("authMenuBackgroundColor")
          newTheme.unreadThemes.append("authMenutextColor")
        }
      } else {
        newTheme.unreadThemes.append("authMenu")
      }
    } else {
      newTheme.unreadThemes.append("auth")
    }
    
    ////MARK: Promotion
    if let promotion = dict["Promotion"] as? KeyValue {
      if let header = promotion["Header"] as? KeyValue {
        if let homeOptionBackground = header["HomeOptionBackground"] as? KeyValue, homeOptionBackgroundColor = homeOptionBackground["Color"] as? KeyValue, promoOptionBackground = header["PromoOptionBackground"] as? KeyValue, promoOptionBackgroundColor = promoOptionBackground["Color"] as? KeyValue, arrow = header["Arrow"] as? KeyValue, arrowColor = arrow["Color"] as? KeyValue, text = header["Text"] as? KeyValue, textColor = text["Color"] as? KeyValue {
          if let colorHomeOptionBackground = rgbaFromDictionary(homeOptionBackgroundColor), colorPromoOptionBackground = rgbaFromDictionary(promoOptionBackgroundColor), colorArrow = rgbaFromDictionary(arrowColor), colorText = rgbaFromDictionary(textColor) {
            newTheme.promoHomeOptionBackgroundColor = colorHomeOptionBackground
            newTheme.promoPromoOptionBackgroundColor = colorPromoOptionBackground
            newTheme.promoHeaderArrowColor = colorArrow
            newTheme.promoHeaderTextLabelColor = colorText
          }
        } else {
          newTheme.unreadThemes.append("promoHomeOptionBackgroundColor")
          newTheme.unreadThemes.append("promoPromoOptionBackgroundColor")
          newTheme.unreadThemes.append("promoHeaderArrowColor")
          newTheme.unreadThemes.append("promoHeaderTextLabelColor")
        }
      } else {
        newTheme.unreadThemes.append("promoHeader")
      }
    } else {
      newTheme.unreadThemes.append("promo")
    }
    
    ////MARK: Player
    if let player = dict["Player"] as? KeyValue {
      if let titleOverlay = player["TitleOverlay"] as? KeyValue {
        if let alpha = titleOverlay["Alpha"] as? CGFloat, text = titleOverlay["Text"] as? KeyValue, textColor = text["Color"] as? KeyValue, background = titleOverlay["Background"] as? KeyValue, backgroundColor = background["Color"] as? KeyValue {
          newTheme.playerTitleOverlayAlpha = alpha
          if let colorText = rgbaFromDictionary(textColor), colorBackground = rgbaFromDictionary(backgroundColor) {
            newTheme.playerTitleOverlayTextLabelColor = colorText
            newTheme.playerTitleOverlayBackgroundColor = colorBackground
          }
        } else {
          newTheme.unreadThemes.append("playerTitleOverlayAlpha")
          newTheme.unreadThemes.append("playerTitleOverlayTextLabelColor")
          newTheme.unreadThemes.append("playerTitleOverlayBackgroundColor")
        }
      } else {
        newTheme.unreadThemes.append("playerTitleOverlay")
      }
      if let title = player["Title"] as? KeyValue, titleColor = title["Color"] as? KeyValue, description = player["Description"] as? KeyValue, descriptionColor = description["Color"] as? KeyValue, controls = player["Controls"] as? KeyValue, controlsColor = controls["Color"] as? KeyValue {
        if let colorTitle = rgbaFromDictionary(titleColor), colorDescription = rgbaFromDictionary(descriptionColor), colorControls = rgbaFromDictionary(controlsColor) {
          newTheme.playerTitleTextLabelColor = colorTitle
          newTheme.playerDescriptionTextLabelColor = colorDescription
          newTheme.playerControlsColor = colorControls
        }
      } else {
        newTheme.unreadThemes.append("playerControlsColor")
        newTheme.unreadThemes.append("playerTitleTextLabelColor")
        newTheme.unreadThemes.append("playerDescriptionTextLabelColor")
      }
    } else {
      newTheme.unreadThemes.append("player")
    }
    
    ////MARK: PrimaryNavigationBar
    if let primaryNavBar = dict["PrimaryNavigationBar"] as? KeyValue {
      if let tintColor = primaryNavBar["TintColor"] as? KeyValue {
        if let colorTint = rgbaFromDictionary(tintColor) {
          newTheme.primaryNavigationBarTintColor = colorTint
        }
      } else {
        newTheme.unreadThemes.append("primaryNavigationBarTintColor")
      }
      if let gradient = primaryNavBar["Gradient"] as? KeyValue, centerColor = gradient["CenterColor"] as? KeyValue, edgeColor = gradient["EdgeColor"] as? KeyValue {
        if let colorCenter = rgbaFromDictionary(centerColor), colorEdge = rgbaFromDictionary(edgeColor) {
          newTheme.primaryNavigationBarGradientCenterColor = colorCenter
          newTheme.primaryNavigationBarGradientEdgeColor = colorEdge
        }
      } else {
        newTheme.unreadThemes.append("primaryNavigationBarGradient")
      }
    } else {
      newTheme.unreadThemes.append("primaryNavigationBar")
    }
    
    ////MARK: SideMenu
    if let menu = dict["SideMenu"] as? KeyValue {
      if let sectionHeader = menu["SectionHeader"] as? KeyValue, sectionHeaderBackground = sectionHeader["Background"] as? KeyValue, sectionHeaderBackgroundColor = sectionHeaderBackground["Color"] as? KeyValue, sectionHeaderText = sectionHeader["Text"] as? KeyValue, sectionHeaderTextColor = sectionHeaderText["Color"] as? KeyValue, navBar = menu["NavigationBar"] as? KeyValue, navBarColor = navBar["Color"] as? KeyValue {
        if let colorSectionHeaderBackground = rgbaFromDictionary(sectionHeaderBackgroundColor), colorSectionHeaderText = rgbaFromDictionary(sectionHeaderTextColor), colorNavBar = rgbaFromDictionary(navBarColor) {
          newTheme.sideMenuSectionHeaderBackgroundColor = colorSectionHeaderBackground
          newTheme.sideMenuSectionHeaderTextColor = colorSectionHeaderText
          newTheme.sideMenuNavigationBarColor = colorNavBar
        }
      } else {
        newTheme.unreadThemes.append("sideMenuSectionHeaderBackgroundColor")
        newTheme.unreadThemes.append("sideMenuSectionHeaderTextColor")
        newTheme.unreadThemes.append("sideMenuNavigationbarColor")
      }
      if let cells = menu["Cells"] as? KeyValue {
        if let title = cells["Title"] as? KeyValue, titleColor = title["Color"] as? KeyValue, background = cells["Background"] as? KeyValue, backgroundColor = background["Color"] as? KeyValue, accessory = cells["Accessory"] as? KeyValue, accessoryColor = accessory["Color"] as? KeyValue, separator = cells["Separators"] as? KeyValue, separatorColor = separator["Color"] as? KeyValue {
          if let colorTitle = rgbaFromDictionary(titleColor), colorBackground = rgbaFromDictionary(backgroundColor), colorAccessory = rgbaFromDictionary(accessoryColor), colorSeparator = rgbaFromDictionary(separatorColor) {
            newTheme.sideMenuCellTitleTextLabelColor = colorTitle
            newTheme.sideMenuCellBackgroundColor = colorBackground
            newTheme.sideMenuCellAccessoryColor = colorAccessory
            newTheme.sideMenuCellSeparatorColor = colorSeparator
          }
        } else {
          newTheme.unreadThemes.append("sideMenuCellTitleLabelColor")
          newTheme.unreadThemes.append("sideMenuCellBackgroundColor")
          newTheme.unreadThemes.append("sideMenuCellAccessoryColor")
          newTheme.unreadThemes.append("sideMenuCellSeparatorColor")
        }
      } else {
        newTheme.unreadThemes.append("sideMenuCells")
      }
    } else {
      newTheme.unreadThemes.append("sideMenu")
    }
    
    //MARK: THEME GENERATION END
    
    //MARK: Reporting Unread Theme Groups
    if newTheme.unreadThemes.count > 0 {
      print("NOTICE: UNREAD THEME VARIABLES:")
      for unread in newTheme.unreadThemes {
        print(unread)
      }
      print("END OF UNREAD THEME VARIABLES")
    } else {
      print("NOTICE: all theme variables accounted for...")
    }
    
    
    _themeSettings = newTheme
  }
  
}
