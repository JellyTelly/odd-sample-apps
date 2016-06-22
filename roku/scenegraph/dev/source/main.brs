' ********** Copyright 2015 Roku Corp.  All Rights Reserved. ********** 

Sub RunUserInterface()
    screen = CreateObject("roSGScreen")
    scene = screen.CreateScene("HomeScene")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.Show()

    settings = initAppConfig()

    ' initialize global OddConfig
    odd_config = invalid
    while odd_config = invalid
      initOddConfig(settings.odd_service_endpoint)
      odd_config = OddConfig()
      if odd_config = invalid
        return ' back, close app
      end if
    end while

    homeContent = LoadOddHomeScreenContent()
    scene.gridContent = ParseXMLContent(homeContent)

    while true
        msg = wait(0, port)
        print "------------------"
        print "msg = "; msg
    end while
    
    if screen <> invalid then
        screen.Close()
        screen = invalid
    end if
End Sub

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

  home_view = []


  if home_view_json.data.relationships.featuredMedia.data <> invalid
    featured_media_entry = home_view_json.data.relationships.featuredMedia.data
    urlString$ = settings.odd_service_endpoint + "/" + "video" + "s/" + featured_media_entry.id
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
    featured_collection_response = oddApiGetRequest(settings.odd_service_endpoint + "/" + "collection" + "s/" + featured_collection_data.id + "?include=entities")
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

  return home_view

End Function



Function ParseXMLContent(list As Object)
    RowItems = createObject("RoSGNode","ContentNode")
    print list
    print list[0].Title
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
