Function preShowPosterScreen(breadA=invalid, breadB=invalid) As Object

    port=CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)
    if breadA<>invalid and breadB<>invalid then
        screen.SetBreadcrumbText(breadA, breadB)
    end if

    screen.SetListStyle("flat-episodic-16x9")
    return screen

End Function

Function showPosterScreen(screen As Object, videos As Object, video_collection as object, showIndex as integer) As Integer

		if checkAuthStatus() = invalid
			return -1
		end if

    curShow = showIndex

    if videos = invalid

      ' show error dialog, wait for input?
      print "invalid video_collection"
      ShowErrorDialog("Could not load requested content. Please try again in a few minutes.", "Connection Error")
      return -1

    else

      videoList = CreateObject("roArray", videos.Count(), false)
      for each video in videos
        videoList.Push(videoForPosterScreen(video))
      end for

      screen.SetContentList(videoList)
      screen.Show()

			if OddConfig().analytics.viewLoad.enabled = true
				oddApiPostMetric(OddConfig().analytics.viewLoad.action, "videoCollection", video_collection.contentID, invalid)
			end if

      'for deep link @barth'
      if curShow <> -1
        displayShowDetailScreen(videos, curShow)
      endif

      while true
          msg = wait(0, screen.GetMessagePort())
          if type(msg) = "roPosterScreenEvent" then
              print "showPosterScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()
              if msg.isListItemSelected() then
                  curShow = msg.GetIndex()
                  print "list item selected | current video = "; curShow
                  curShow = displayShowDetailScreen(videos, curShow)
                  screen.SetFocusedListItem(curShow)
                  print "list item updated  | new video = "; curShow

									if OddConfig().analytics.viewLoad.enabled = true
										oddApiPostMetric(OddConfig().analytics.viewLoad.action, "videoCollection", video_collection.contentID, invalid)
									end if
              else if msg.isRemoteKeyPressed() then
                if msg.GetIndex() = 10
                  displaySearchScreen()
                end if
              else if msg.isScreenClosed() then
                  return -1
              end if

              if checkAuthStatus() = invalid
                return -1
              end if

          end If
      end while

    end if

End Function


Function showSearchResultPosterScreen(screen As Object, search_results As Object) As Integer

    curShow = 0

    if search_results = invalid

      ' show error dialog, wait for input?
      print "invalid search_results"
      ShowErrorDialog("Could not load search results.", "Error")
      return -1

    else

      resultList = CreateObject("roArray", search_results.Count(), false)
      for each result in search_results
        if result.Type = "video"
          resultList.Push(videoForPosterScreen(result))
        else if result.Type = "video_collection"
          resultList.Push(videoCollectionForPosterScreen(result))
        end if
      end for

      screen.SetContentList(resultList)
      screen.Show()

      while true
          msg = wait(0, screen.GetMessagePort())
          if type(msg) = "roPosterScreenEvent" then
              print "showPosterScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()
              if msg.isListItemSelected() then
                  curShow = msg.GetIndex()
                  'print "list item selected | current video = "; m.curShow
                  if search_results[curShow].Type = "video"
                    displayShowDetailScreen(search_results, curShow)
                  else if search_results[curShow].Type = "video_collection"
                    displayCategoryPosterScreen(search_results[curShow])
                  end if
                  screen.SetFocusedListItem(curShow)
                  print "list item updated  | new video = "; curShow
              else if msg.isScreenClosed() then
                  return -1
              end if
          end If
      end while

    end if

End Function
