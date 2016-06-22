Function Main(args as Dynamic) as void

    initAppConfig()
    initTheme()

    settings = AppSettings()
    auth_settings = AppAuth()

    canvas = preShowCanvasScreen()
    canvas.ShowMessage("Retrieving...")
    canvas.Show()

    ' initialize global OddConfig
    odd_config = invalid
    while odd_config = invalid
      initOddConfig(settings.odd_service_endpoint)
      odd_config = OddConfig()

      if odd_config = invalid
        result = ShowConnectionFailedRetry()
        if result = 1
          return ' back, close app
        end if
        ' else retry
      end if
    end while

		if OddConfig().analytics.appInit.enabled = true
			oddApiPostMetric(OddConfig().analytics.appInit.action, "nil", "nil", invalid)
		end if

		' clearAuth()
		if checkAuthStatus() = invalid
			displayAuthScreen(canvas)
		end if

    home_view = initHomeView(canvas)
    if home_view = invalid
      return
    end if

    deepLinked = false
    'Playing content if found from deep link @barth'
    if args.mediaType <> invalid
      global_config = GetGlobalAA()
      deep_data = global_config["deep_link"]
			print "Playing deep link media"
			print args.mediaType
      ' returns true when deep link successfully played @barth
      deepLinked = playLinkedMedia(args, deep_data)
    end if

    ' before play livestream check if app set for livestream and if deeplinked occured @barth'
    if settings.livestream <> "false" and deepLinked <> true
      if home_view.liveStreams.Count() > 0 then
        showVideoScreen(home_view.liveStreams[0])
      end if
    end if

    screen = preShowHomeScreen()

    home_return_status = -2 ' reload homeScreen
		while home_return_status = -2
			home_return_status = showHomeScreen(screen, home_view)
			if home_return_status = -2
    		screen = preShowHomeScreen()
				home_view = initHomeView(canvas)
		    if home_view = invalid
		      return
		    end if
			end if
		end while

    canvas.ClearMessage()
    canvas.Close()

End Function

Function displayAuthScreen(parent_screen)
	authResult = showAuthScreen()
	if authResult <> true
		'user not authed, close the app
		print "not authorized to continue"
		if parent_screen <> invalid
			parent_screen.Close()
		end if
	end if
End Function

Function initTheme() as Void

  app = CreateObject("roAppManager")
  app.SetTheme(AppTheme())
  app.SetTheme(AppThemeAlternate().themeBlankOverhangSlice)

end Function
