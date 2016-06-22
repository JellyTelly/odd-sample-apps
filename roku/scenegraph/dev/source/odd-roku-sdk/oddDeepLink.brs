REM ******************************************************
REM Fetches and displays object from a Roku deep link
REM ******************************************************
Function playLinkedMedia(args as object, deep_data as dynamic) as boolean
  mediaType = args.mediaType
  contentID = args.contentID
  collectionID = args.collectionID

  if mediaType = "videos"
    print "deep link video"

    video = oddApiGetRequest(AppSettings().odd_service_endpoint + "/videos/" + contentID)

    if video = invalid
      return false
    endif

    linkedMedia = videoFromJson(ParseJson(video).data, contentID)
    displayShowDetailScreen([linkedMedia], 0)
    return true

  else if mediaType = "livestream"
    print "deep link livestream"

    live_stream = oddApiGetRequest(AppSettings().odd_service_endpoint + "/liveStreams/" + contentID)

    if live_stream = invalid
      return false
    endif

    live_stream_json = ParseJson(live_stream)
    streamObj = liveStreamFromJson(live_stream_json.data.attributes, live_stream_json.data.id)
    showVideoScreen(streamObj)
    return true

  else if mediaType = "videoCollections"

    video_collection = oddApiGetRequest(AppSettings().odd_service_endpoint + "/collections/" + collectionID)

    if video_collection = invalid
      return false
    else

      video_collectionObj = videoCollectionFromJson(ParseJson(video_collection).data)

      if contentID = invalid

        if video_collectionObj.contents = "video"
          ' collection of all videos. show them in a poster.
          displayCategoryPosterScreen(video_collectionObj)
        else
          ' collection of videos/more collections or some unknown type. show them in a grid.
          displayCategoryGridScreen(video_collectionObj)
        end if

        return true

      else

        videos_from_collection = video_collectionObj.loadItemList()
        for showIndex=0 To videos_from_collection.count() - 1 Step +1
          if contentID = videos_from_collection[showIndex].contentID
              print "video from video collection"

              if video_collectionObj.contents = "video"
                ' collection of all videos. show them in a poster.
                ' if contentID present, send showIndex for posterView to focus on @barth'
                displayCategoryPosterScreen(video_collectionObj, showIndex)
              else
                ' collection of videos/more collections or some unknown type. show them in a grid.
                displayCategoryGridScreen(video_collectionObj)
              end if

              return true
          else
            print "video not found in collection"
          end if
        end for
      endif
    endif

  else
    print "video type not found"
    return false
  end if

End Function
