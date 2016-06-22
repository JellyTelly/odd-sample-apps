'******************************************************
'** Parses data from oddworks into odd media objects for the home screen
'******************************************************
Function loadHomeScreenView() As Dynamic

  settings = AppSettings()
  home_view_response = oddApiGetRequest(OddConfig().home_view_endpoint + "?include=promotion,featuredMedia,featuredCollections")

  if home_view_response = invalid
    return invalid
  end if

  home_view_json = ParseJson(home_view_response)

  'putting raw home_view in global for deep link access'
  global_config = GetGlobalAA()
  global_config["deep_link"] = home_view_json

  home_view = CreateObject("roAssociativeArray")

  'set up length'
  home_view.liveStreams = CreateObject("roArray", 1 , false)
  home_view.promotions = CreateObject("roArray", 1, false)

  home_view.featuredVideos = CreateObject("roArray", 0, true)
  home_view.featuredCollections = CreateObject("roArray", 0, true)
  home_view.showCollections = CreateObject("roArray", 0, true)

  if home_view_json.data.relationships.promotion <> invalid
    promotion_entry = home_view_json.data.relationships.promotion.data
    promotion = oddApiFindInIncludes(promotion_entry.id, home_view_json.included)
    home_view.promotions.Push(promotionFromJson(promotion))
  end if

  if home_view_json.data.relationships.featuredMedia.data <> invalid
    featured_media_entry = home_view_json.data.relationships.featuredMedia.data
    urlString$ = settings.odd_service_endpoint + "/" + "video" + "s/" + featured_media_entry.id
    video_response = oddApiGetRequest(urlString$)
    video = ParseJson(video_response)
    home_view.featuredVideos.Push(videoFromJson(video.data, featured_media_entry.id))
  end if

  if home_view_json.data.relationships.featuredCollections <> invalid
    featured_collection_data = home_view_json.data.relationships.featuredCollections.data
    featured_collection_response = oddApiGetRequest(settings.odd_service_endpoint + "/" + "collection" + "s/" + featured_collection_data.id + "?include=entities")
    featured_collection = ParseJson(featured_collection_response)
    featured_collection_contents_data = featured_collection.data.relationships.entities.data
    for each video_collection_entry in featured_collection_contents_data
      collection = oddApiFindInIncludes(video_collection_entry.id, featured_collection.included)
      if home_view.featuredCollections.Count() >= 2
        home_view.showCollections.Push(videoCollectionFromJson(collection))
      else
        home_view.featuredCollections.Push(videoCollectionFromJson(collection))
      end if
    end for
  end if

  return home_view

End Function


'******************************************************
'** Perform any startup/initialization stuff prior to
'** initially showing the screen.
'******************************************************
Function preShowHomeScreen() As Object

  port=CreateObject("roMessagePort")
  screen = CreateObject("roGridScreen")
  screen.SetMessagePort(port)
  screen.SetGridStyle("two-row-flat-landscape-custom")

  app = CreateObject("roAppManager")
  app.SetTheme(AppThemeAlternate().themeSearchOverhangSlice)

  return screen

End Function


'******************************************************
'** Display the home screen and wait for events from
'** the screen. The screen will show retreiving while
'** we fetch and parse the feeds
'******************************************************
Function showHomeScreen(screen, home_view) As Integer

    gridCellItems = buildHomeGridCellItems(screen, home_view)
    screen.Show()

    if OddConfig().analytics.viewLoad.enabled = true
      oddApiPostMetric(OddConfig().analytics.viewLoad.action, "home", "nil", invalid)
    end if

    if checkAuthStatus() = invalid
      if authorizationRequired() = true
        if userAccessToken() = invalid
          displayAuthScreen(invalid)
          clearRequireAuthorization()
          ' refresh home_screen
          screen.Close()
          return -2
        else
          ShowSubscriptionRequired()
          clearRequireAuthorization()
        end if
      else
        ShowRegistrationExpired()
        displayAuthScreen(screen)
        ' refresh home_screen
        screen.Close()
        return -2
      end if
    end if

    while true
      msg = wait(0, screen.GetMessagePort())
      if type(msg) = "roGridScreenEvent" then
          print "showHomeScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()

          if msg.isListItemFocused() then

            'print "Focused msg: ";msg.GetMessage();"row: ";msg.GetIndex();
            'print " col: ";msg.GetData()

          else if msg.isListItemSelected() then
            'print "Selected msg: ";msg.GetMessage();"row: ";msg.GetIndex();
            'print " col: ";msg.GetData()

            gridCellItemType = gridCellItems[msg.GetIndex()][msg.GetData()].Type

            if gridCellItemType = "live_stream" then
              if AppSettings().organizationID = "itprotv"
                'send the whole array w/ selected index for remote left/right actions to update the springboard @barth'
                showIndex = displayShowDetailScreen(gridCellItems[msg.GetIndex()],  msg.GetData())
                screen.SetFocusedListItem(msg.GetIndex(), showIndex)
              else
                showVideoScreen(gridCellItems[msg.GetIndex(), msg.GetData()])
              end if

              ' refresh home_screen
              screen.Close()
              return -2

              if OddConfig().analytics.viewLoad.enabled = true
                oddApiPostMetric(OddConfig().analytics.viewLoad.action, "home", "nil", invalid)
              end if
            else if gridCellItemType = "video" then
              'send the whole array w/ selected index for remote left/right actions to update the springboard @barth'
              showIndex = displayShowDetailScreen(gridCellItems[msg.GetIndex()],  msg.GetData())
              screen.SetFocusedListItem(msg.GetIndex(), showIndex)

              ' refresh home_screen
              screen.Close()
              return -2

              if OddConfig().analytics.viewLoad.enabled = true
                oddApiPostMetric(OddConfig().analytics.viewLoad.action, "home", "nil", invalid)
              end if
            else if gridCellItemType = "promotion" then
              displayPromotionDetailScreen(gridCellItems[msg.GetIndex()][msg.GetData()])

              ' refresh home_screen
              screen.Close()
              return -2

              if OddConfig().analytics.viewLoad.enabled = true
                oddApiPostMetric(OddConfig().analytics.viewLoad.action, "home", "nil", invalid)
              end if
            else if gridCellItemType = "video_collection" then
              gridCellCollection = gridCellItems[msg.GetIndex()][msg.GetData()]

              if gridCellCollection.contents = "video"
                ' collection of all videos. show them in a poster.
                displayCategoryPosterScreen(gridCellCollection)
              else
                ' collection of videos/more collections or some unknown type. show them in a grid.
                displayCategoryGridScreen(gridCellCollection)
              end if

              ' refresh home_screen
              screen.Close()
              return -2

              if OddConfig().analytics.viewLoad.enabled = true
                oddApiPostMetric(OddConfig().analytics.viewLoad.action, "home", "nil", invalid)
              end if
            else
              print "unknown itemType."
              print gridCellItemType
            end if

          else if msg.GetIndex() = 10
            displaySearchScreen()
          else if msg.isScreenClosed() then
            return -1
          end if

      end if

    end while

    return 0

End Function

Function initHomeView(parent_screen) As Dynamic

  home_view = invalid
  while home_view = invalid
    print "loadingHomeScreenView"
    home_view = loadHomeScreenView()

    if home_view = invalid
      print "Got invalid homeScreen"
      if checkAuthStatus() = invalid
        displayAuthScreen(parent_screen)
      else
        result = ShowConnectionFailedRetry()
        if result = 1
          return invalid ' back, close app
        end if
      end if
      ' else retry
    end if
  end while

  return home_view

End Function

Function buildHomeGridCellItems(screen, home_view) As Object

  print "building GridItems"

  settings = AppSettings()

  ' featured_row + featured_collections + shows
  rowTitles = CreateObject("roArray", 1 + home_view.featuredCollections.Count() + 1, false)

  'first featured is livestream, video, and promotion @barth'
  rowTitles.Push(settings.outside_section_titles[0])

  'these are the actual "featured collections" @barth'
  for each featured_collection in home_view.featuredCollections
    rowTitles.Push(featured_collection.Title)
  end for

  'Collections that you have to drill down on through poster screen to get to detail @barth'
  rowTitles.Push(settings.outside_section_titles[1])

  screen.SetupLists(rowTitles.Count())
  screen.SetListNames(rowTitles)

  gridCellItems = CreateObject("roArray", rowTitles.Count(), false)

  ' using this list to create videos with all of the grid screens @barth'
  list = CreateObject("roArray", home_view.liveStreams.Count() + home_view.promotions.Count() + home_view.featuredVideos.Count(), false) ' live + promo + featured

  for each live_stream in home_view.liveStreams
    list.Push(videoForGridScreen(live_stream))
  end for

  for each promotion in home_view.promotions
    list.Push(promotionForGridScreen(promotion))
  end for

  for each video in home_view.featuredVideos
    list.Push(videoForGridScreen(video))
  end for

  featured_row_items = CreateObject("roArray", home_view.liveStreams.Count() + home_view.promotions.Count() + home_view.featuredVideos.Count(), true)
  featured_row_items.Append(home_view.liveStreams)
  featured_row_items.Append(home_view.promotions)
  featured_row_items.Append(home_view.featuredVideos)

  gridCellItems[0] = featured_row_items ' save original items so they can be passed when their row/col is selected

  'push the list of featured video views for the gridscreen @barth'
  screen.SetContentList(0, list)

  ' load featured video collections (Top/Most Recent/etc)
  grid_row_index = 1 ' skip featured row @TQ
  for each featured_collection in home_view.featuredCollections
    collection_items = featured_collection.loadItemList()

    if collection_items = invalid
      gridCellItems[grid_row_index] = invalid
    else
      list = CreateObject("roArray", collection_items.Count(), false)
      for each item in collection_items
        if item.type = "video"
          list.Push(videoForGridScreen(item))
        else if item.type = "video_collection"
          list.Push(videoCollectionForGridScreen(item))
        else
          ' unknown entity... skip? @TQ
          ' this may break things, other option is to try to remove invalid from collection_items to pass to grid
          list.Push(invalid)
        end if
      end for

      'inserting the video objects to send to detail view @barth'
      gridCellItems[grid_row_index] = collection_items
      screen.SetContentList(grid_row_index, list)
    end if

    grid_row_index = grid_row_index + 1
  end for

  ' load show video collections
  grid_row_index = 1 + home_view.featuredCollections.Count() ' skip featured row and featured collections @TQ
  list = CreateObject("roArray", home_view.showCollections.Count(), false)
  for each show_collection in home_view.showCollections
    list.Push(videoCollectionForGridScreen(show_collection))
  end for
  gridCellItems[grid_row_index] = home_view.showCollections
  screen.SetContentList(grid_row_index, list)

  row_index = 0
  for each grid_row in gridCellItems
    if grid_row = invalid or grid_row.Count() = 0
      screen.SetListVisible(row_index, false)
    end if
    row_index = row_index + 1
  end for

  row_index = 0
  first_viewable_row_index = invalid
  while row_index < gridCellItems.Count() and first_viewable_row_index = invalid
    if gridCellItems[row_index] <> invalid and gridCellItems[row_index].Count() > 0
      first_viewable_row_index = row_index
    end if
    row_index = row_index + 1
  end while

  if first_viewable_row_index <> invalid
    screen.SetFocusedListItem(first_viewable_row_index, 0)
  else
    screen.ShowMessage("No items found")
  end if

  screen.SetFocusRingVisible(true)
  screen.SetDescriptionVisible(false)

  return gridCellItems

End Function

Function clearHomeGridCellItems(screen, gridCellItems)
  screen.SetFocusRingVisible(false)
  row_index = 0
  for each grid_row in gridCellItems
    screen.SetListVisible(row_index, false)
    row_index = row_index + 1
  end for
End Function

Function displayCategoryGridScreen(video_collection As Object) As Dynamic
    screen = preShowGridScreen(video_collection.Title, "")
    showGridScreen(screen, video_collection.loadItemList(), video_collection)
    return 0
End Function

Function displayCategoryPosterScreen(video_collection As Object, showIndex = -1) As Dynamic
    screen = preShowPosterScreen(video_collection.Title, "")
    showPosterScreen(screen, video_collection.loadItemList(), video_collection, showIndex)
    return 0
End Function

Function displayShowDetailScreen(videos As Object, videoIndex as Integer) As Integer
    if videos.count() > 1
      screen = preShowDetailScreen("< Previous | Next >", "")
    else
      screen = preShowDetailScreen(videos[videoIndex].Title, "")
    end if

    showIndex = showDetailScreen(screen, videos, videoIndex)
    return showIndex
End Function

Function displayPromotionDetailScreen(promotion As Object) As Dynamic
    screen = preShowDetailScreen("Promotion", "")
    app = CreateObject("roAppManager")
    app.SetTheme(AppThemeAlternate().themeBlankOverhangSlice)
    showPromotionDetailScreen(screen, promotion)
    app.SetTheme(AppThemeAlternate().themeSearchOverhangSlice)
    return 0
End Function

Function displaySearchScreen() As Dynamic
    app = CreateObject("roAppManager")
    screen = preShowSearchScreen("Search", "")
    app.SetTheme(AppThemeAlternate().themeBlankOverhangSlice)
    showSearchScreen(screen)
    app.SetTheme(AppThemeAlternate().themeSearchOverhangSlice)
    return 0
End Function
