' ********** Copyright 2015 Roku Corp.  All Rights Reserved. **********

Sub RunUserInterface()
    screen = CreateObject("roSGScreen")
    scene = screen.CreateScene("HomeScene")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.Show()

    settings = initAppConfig()
    theme = AppTheme()
    print "Theme: "; theme

    ' initialize global OddConfig
    odd_config = invalid
    while odd_config = invalid
      initOddConfig(settings.oddServiceEndpoint)
      odd_config = OddConfig()
      if odd_config = invalid
        return ' back, close app
      end if
    end while

    homeContent = LoadOddHomeScreenContent()
    scene.gridContent = ParseXMLContent(homeContent)

		' this locates the videoPlayer in the details screen in order to track play events
		scene.findNode("DetailsScreen").findNode("VideoPlayer").observeField("state", port)
		' register for a notification when the video player playhead position changes
		scene.findNode("DetailsScreen").findNode("VideoPlayer").observeField("position", port)
		' read the config for how often to send playhead events
		interval = OddConfig().analytics.videoPlaying.interval / 1000
		' set the video player to report position info at the desired interval
		scene.findNode("DetailsScreen").findNode("VideoPlayer").notificationInterval = 5

    ApplyTheme(scene)
    
		m.scene = scene
    while true
        msg = wait(0, port)
				msgType = type(msg)
				if msgType = "roSGNodeEvent"
					if msg.getNode() = "VideoPlayer"

						if msg.getField() = "state"
							' this message is telling us the video player changed state so record an event
							OnVideoPlayerStateChange(msg.getData())
						else if msg.getField() = "position"
							' this message is a notification of the current videos playhead position
							' we store it for later reporting
							OnVideoPlayheadPositionChange(msg.getData())
						end if



					end if
      	end if

        ' print "------------------"
				' print "msg"; msg
				' print "node "; msg.getNode()
				'	print "field name "; msg.getField()
				' print "data "; msg.getData()

    end while

    if screen <> invalid then
        screen.Close()
        screen = invalid
    end if
End Sub

Sub ApplyTheme(scene)
    hud = scene.findNode("DetailsScreen").findNode("HudRectangle")
    hud.color = AppTheme().hudBackgroundColor
    
    hudDescription = scene.findNode("DetailsScreen").findNode("Description")
    title = hudDescription.findNode("Title")
    releaseData = hudDescription.findNode("ReleaseDate")
    description = hudDescription.findNode("DescriptionText")

    title.color = AppTheme().hudTitleTextColor
    releaseData.color = AppTheme().hudReleaseDateTextColor
    description.color = AppTheme().hudDescriptionTextColor
End Sub

Sub OnVideoPlayerStateChange(data)
	content = m.scene.findNode("DetailsScreen").getField("content")
	' print "************** OnVideoPlayerStateChange ******************"
	contentInfo = { id: content.Id, title: content.Title, type: content.Type, thumbnail: content.HDPOSTERURL}
	statAttribs = { timeElapsed: 0, videoDuration: content.Length, errorMessage: invalid}

	print "CONTENT: "; contentInfo
	print "STATS: "; statAttribs

	print data
	if data = "buffering"
		if OddConfig().analytics.videoLoad.enabled
			print "video:load"
			action = OddConfig().analytics.videoLoad.action
			oddApiPostMetric(action, contentInfo, statAttribs)
		end if
	else if data = "playing"
		if OddConfig().analytics.videoPlay.enabled
			print "video:play"
			action = OddConfig().analytics.videoPlay.action
			oddApiPostMetric(action, contentInfo, statAttribs)
		end if
	else if data = "stopped"
		if OddConfig().analytics.videoStop.enabled
			print "video:stop"
			action = OddConfig().analytics.videoStop.action
			oddApiPostMetric(action, contentInfo, statAttribs)
		end if
	end if
end Sub

Sub OnVideoPlayheadPositionChange(elapsed)
print "OnVideoPlayheadPositionChange"
	if OddConfig().analytics.videoPlaying.enabled = false
		return
	end if

	content = m.scene.findNode("DetailsScreen").getField("content")
	contentInfo = { id: content.Id, title: content.Title, type: content.Type, thumbnail: content.HDPOSTERURL}
	statAttribs = { timeElapsed: elapsed, videoDuration: content.Length, errorMessage: invalid}

	print "CONTENT: "; contentInfo
	print "STATS: "; statAttribs

	action = OddConfig().analytics.videoPlaying.action
	oddApiPostMetric(action, contentInfo, statAttribs)
end Sub

Function LoadOddHomeScreenContent() As Dynamic
	settings = AppSettings()

  home_view_response = oddApiGetRequest(OddConfig().home_view_endpoint + "?include=promotion,featuredMedia,featuredCollections")

  if home_view_response = invalid
    return invalid
  end if

  home_view_json = ParseJson(home_view_response)

  'putting raw home_view in global for deep link access'
  global_config = GetGlobalAA()
  global_config["deep_link"] = home_view_json

	print "USER ID: "; GetUserID()
	print "SESSION ID: "; GenerateNewSessionId()

	print "HOME LOADED"

	if OddConfig().analytics.appInit.enabled = true
		oddApiPostAppInitMetric()
		' contentInfo = { id: "1234abcd", title: "A video", type: "video", thumbnail: "http://someimage.png"}
		' oddApiPostMetric(OddConfig().analytics.videoPlay.action, contentInfo,  invalid)
	end if
  home_view = []

  if home_view_json.data.relationships.featuredMedia.data <> invalid
    featured_media_entry = home_view_json.data.relationships.featuredMedia.data
    urlString$ = settings.oddServiceEndpoint + "/" + "video" + "s/" + featured_media_entry.id
    video_response = oddApiGetRequest(urlString$)
    video = ParseJson(video_response)
    featuredVideo = videoFromJson(video.data, featured_media_entry.id)
    featuredArray = CreateObject("roArray", 1, false)
    featuredArray.push(videoForHomeSceneScreen(featuredVideo))
    featuredMedia = {
      TITLE: "Featured",
      ContentList: featuredArray
    }
    home_view.push(featuredMedia)
  end if

  if home_view_json.data.relationships.featuredCollections <> invalid
    featured_collection_data = home_view_json.data.relationships.featuredCollections.data
    featured_collection_response = oddApiGetRequest(settings.oddServiceEndpoint + "/" + "collection" + "s/" + featured_collection_data.id + "?include=entities")
    featured_collection = ParseJson(featured_collection_response)
    featured_collection_contents_data = featured_collection.data.relationships.entities.data
    for itemIndex=0 To featured_collection_contents_data.count() - 1 Step + 1
      video_collection_entry = featured_collection_contents_data[itemIndex]
      collection_json = oddApiFindInIncludes(video_collection_entry.id, featured_collection.included)
      featuredCollection = videoCollectionFromJson(collection_json)
      featuredCollectionItem = {
        TITLE: featuredCollection.title,
        ContentList: []
      }
      collectionContents = featuredCollection.loadItemList()
      for each item in collectionContents
        if item.type = "video"
          featuredCollectionItem.ContentList.push(videoForHomeSceneScreen(item))
        end if
      end for
      home_view.push(featuredCollectionItem)
    end for
  end if

	if home_view <> invalid
		contentInfo = { id: "1234abcd", title: "Home Screen", type: "view", thumbnail: "http://someimage.png"}
		oddApiPostMetric(OddConfig().analytics.viewLoad.action, contentInfo,  invalid)
	endif

  return home_view

End Function


Function ParseXMLContent(list As Object)
    RowItems = createObject("RoSGNode","ContentNode")
    ' print list
    ' print list[0].Title
    for each rowAA in list
    'for index = 0 to 1
        row = createObject("RoSGNode","ContentNode")
        row.Title = rowAA.Title

        for each itemAA in rowAA.ContentList
            item = createObject("RoSGNode","ContentNode")
            ' We don't use item.setFields(itemAA) as doesn't cast streamFormat to proper value
            for each key in itemAA
                item[key] = itemAA[key]
            end for
            row.appendChild(item)
        end for
        RowItems.appendChild(row)
    end for

    return RowItems
End Function
