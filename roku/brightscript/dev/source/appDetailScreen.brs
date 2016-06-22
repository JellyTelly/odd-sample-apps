Function preShowDetailScreen(breadA=invalid, breadB=invalid) As Object

    port=CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")
    screen.SetDescriptionStyle("video")
    screen.SetMessagePort(port)
    screen.SetStaticRatingEnabled(false)

    if breadA<>invalid and breadB<>invalid then
        screen.SetBreadcrumbText(breadA, breadB)
    end if

    return screen

End Function

Function showPromotionDetailScreen(screen As Object, promotion As Object) As Integer
  screen.SetContent(promotionForSpringboardScreen(promotion))
  screen.Show()

	if OddConfig().analytics.viewLoad.enabled = true
  	oddApiPostMetric(OddConfig().analytics.viewLoad.action, "promotion", promotion.contentID, invalid)
	end if

  while true
    msg = wait(0, screen.GetMessagePort())
    if type(msg) = "roSpringboardScreenEvent" then
    print "recognizes springboard event"
        If msg.isScreenClosed() Then
          Return -1
        endif
    endif
  end while

End Function

'***************************************************************
'** The show detail screen (springboard) is where the user sees
'** the details for a show and is allowed to select a show to
'** begin playback.  This is the main event loop for that screen
'** and where we spend our time waiting until the user presses a
'** button and then we decide how best to handle the event.
'***************************************************************
Function showDetailScreen(screen As Object, showList As Object, showIndex as Integer) As Integer

		if checkAuthStatus() = invalid
			return -1
		end if

    refreshShowDetail(screen, showList, showIndex, false)

    'remote key id's for left/right navigation
    remoteKeyLeft  = 4
    remoteKeyRight = 5

    while true
        msg = wait(0, screen.GetMessagePort())

        if type(msg) = "roSpringboardScreenEvent" then
            print "SpringboardScreen event: "; msg.GetIndex(); " " msg.GetData()

            if msg.isScreenClosed()
                print "Screen closed"
                exit while
            else if msg.isRemoteKeyPressed()
                print "Remote key pressed"
                if msg.GetIndex() = remoteKeyLeft then
                    showIndex = getPrevShowIndex(showList, showIndex)
                    refreshShowDetail(screen, showList, showIndex, false)
                else if msg.GetIndex() = remoteKeyRight
                    showIndex = getNextShowIndex(showList, showIndex)
                    refreshShowDetail(screen, showList, showIndex, false)
                endif
            else if msg.isButtonPressed()
                print "ButtonPressed"
                print "ButtonPressed"
                if msg.GetIndex() = 1
                    PlayStart = RegRead(showList[showIndex].ContentId)
                    if PlayStart <> invalid then
                        showList[showIndex].PlayStart = PlayStart.ToInt()
                    endif
                    showVideoScreen(showList[showIndex])
                    refreshShowDetail(screen,showList,showIndex, true)
                endif
                if msg.GetIndex() = 2
                    showList[showIndex].PlayStart = 0
                    showVideoScreen(showList[showIndex])
                    refreshShowDetail(screen,showList,showIndex, true)
                endif
                if msg.GetIndex() = 3
									setRequireAuthorization()
                endif
                print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
            else if msg.GetIndex() = 1 or msg.GetIndex() = 2
                displaySearchScreen()
            endif

            if checkAuthStatus() = invalid
              return -1
            end if

        else
            print "Unexpected message class: "; type(msg)
        end if

    end while

    print "***"
    print "show index: ";showIndex

    return showIndex

End Function

'**************************************************************
'** Refresh the contents of the show detail screen. This may be
'** required on initial entry to the screen or as the user moves
'** left/right on the springboard.  When the user is on the
'** springboard, we generally let them press left/right arrow keys
'** to navigate to the previous/next show in a circular manner.
'** When leaving the screen, the should be positioned on the
'** corresponding item in the poster screen matching the current show
'**************************************************************
Function refreshShowDetail(screen As Object, showList As Object, showIndex as Integer, played as boolean) As Integer

    show = showList[showIndex]

    screen.ClearButtons()
    if played <> true
			if OddConfig().analytics.viewLoad.enabled = true
		  	oddApiPostMetric(OddConfig().analytics.viewLoad.action, "video", show.contentID, invalid)
			end if
    endif

    print "Displaying buttons"
    if showList[showIndex].entitled <> invalid
        print "Entitlements: " + showList[showIndex].entitled
    endif

		if showList[showIndex].entitled = true or showList[showIndex].entitled = invalid
	    if regread(show.contentid) <> invalid
	      screen.AddButton(1, "Resume playing")
	      screen.AddButton(2, "Play from beginning")
	    else
	      screen.addbutton(2,"Play")
	    end if
		else
	    screen.addbutton(3,"Subscription Required")
		end if

    screen.SetContent(videoForSpringboardScreen(show))
    screen.Show()

End Function

'********************************************************
'** Get the next item in the list and handle the wrap
'** around case to implement a circular list for left/right
'** navigation on the springboard screen
'********************************************************
Function getNextShowIndex(showList As Object, showIndex As Integer) As Integer

    nextIndex = showIndex + 1

    while nextIndex <> showIndex
      if nextIndex >= showList.Count() then
        'if it goes to the end set it as the first @barth'
        nextIndex = 0
      end if
			if nextIndex = showIndex
				exit while
			end if
      if showList[nextIndex].Type <> "video" and showList[nextIndex].Type <> "live_stream"
        'skip anything that is not a video'
        nextIndex = nextIndex + 1
      else
        exit while
      end if
    end while

		print showList[nextIndex].Type
    return nextIndex

End Function


'********************************************************
'** Get the previous item in the list and handle the wrap
'** around case to implement a circular list for left/right
'** navigation on the springboard screen
'********************************************************
Function getPrevShowIndex(showList As Object, showIndex As Integer) As Integer

    prevIndex = showIndex - 1

    while prevIndex <> showIndex
      if prevIndex < 0 then
      	'set to the end of the list if you go below zero'
        prevIndex = showList.Count() - 1
      end if
			if prevIndex = showIndex
				exit while
			end if
      if showList[prevIndex].Type <> "video" and showList[prevIndex].Type <> "live_stream"
        'skip anything that is not a video'
        prevIndex = prevIndex - 1
      else
        exit while
      end if
    end while

    return prevIndex

End Function
