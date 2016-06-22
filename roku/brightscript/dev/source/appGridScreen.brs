Function preShowGridScreen(breadA=invalid, breadB=invalid) As Object
	port=CreateObject("roMessagePort")
	screen = CreateObject("roGridScreen")
	screen.SetMessagePort(port)
	screen.SetGridStyle("two-row-flat-landscape-custom")

  if breadA<>invalid and breadB<>invalid then
  	screen.SetBreadcrumbText(breadA, breadB)
  end if

  return screen
End Function

Function showGridScreen(screen As Object, grid_collection_items As Object, collection As Object) As Integer

		if checkAuthStatus() = invalid
			return -1
		end if

		if grid_collection_items = invalid
      ' show error dialog, wait for input?
      print "invalid video_collection"
      ShowErrorDialog("Could not load requested content. Please try again in a few minutes.", "Connection Error")
      return -1
		end if

    rowTitles = CreateObject("roArray", grid_collection_items.Count(), false)
    for each collection_item in grid_collection_items
      rowTitles.Push(collection_item.Title)
    end for

    screen.SetupLists(rowTitles.Count())
    screen.SetListNames(rowTitles)

    gridCellItems = CreateObject("roArray", rowTitles.Count(), false)

    grid_row_index = 0
    for each featured_collection in grid_collection_items
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

        gridCellItems[grid_row_index] = collection_items
        screen.SetContentList(grid_row_index, list)
      end if

      grid_row_index = grid_row_index + 1
    end for

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

    screen.SetDescriptionVisible(false)
    if first_viewable_row_index <> invalid
		  screen.SetFocusedListItem(first_viewable_row_index, 0)
    else
      screen.ShowMessage("No items found")
    end if

    screen.Show()

		if OddConfig().analytics.viewLoad.enabled = true
			oddApiPostMetric(OddConfig().analytics.viewLoad.action, "videoCollection", collection.contentID, invalid)
		end if

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roGridScreenEvent" then
            print "showGridScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()

            if msg.isListItemFocused() then

              'print "Focused msg: ";msg.GetMessage();"row: ";msg.GetIndex();
              'print " col: ";msg.GetData()

            else if msg.isListItemSelected() then
              'print "Selected msg: ";msg.GetMessage();"row: ";msg.GetIndex();
              'print " col: ";msg.GetData()

              gridCellItemType = gridCellItems[msg.GetIndex()][msg.GetData()].Type

              if gridCellItemType = "video" then
                'send the whole array w/ selected index for remote left/right actions to update the springboard @barth'
                showIndex = displayShowDetailScreen(gridCellItems[msg.GetIndex()], msg.GetData())
                screen.SetFocusedListItem(msg.GetIndex(), showIndex)
								if OddConfig().analytics.viewLoad.enabled = true
									oddApiPostMetric(OddConfig().analytics.viewLoad.action, "videoCollection", collection.contentID, invalid)
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

								if OddConfig().analytics.viewLoad.enabled = true
									oddApiPostMetric(OddConfig().analytics.viewLoad.action, "videoCollection", collection.contentID, invalid)
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

            if checkAuthStatus() = invalid
              return -1
            end if

        end If
    end while

    return 0

End Function
