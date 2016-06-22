REM ******************************************************
REM OddLivestream
REM ******************************************************
Function liveStreamFromJson(live_stream_json As Object, stream_id As String) As Object

  live_stream_meta = live_stream_json.meta

	if live_stream_json.attributes <> invalid
		live_stream_json = live_stream_json.attributes
	end if

  live_stream = CreateObject("roAssociativeArray")

  live_stream.Type             = "live_stream" ' todo set in json

  live_stream.ContentId        = stream_id

  live_stream.Title            = live_stream_json.title
  live_stream.SDImage          = live_stream_json.sdImg
  live_stream.HDImage          = live_stream_json.hdImg

  live_stream.Synopsis         = live_stream_json.synopsis

  live_stream.ContentQuality   = live_stream_json.contentQuality
  live_stream.StreamFormat     = live_stream_json.streamFormat
  live_stream.Live             = strtobool(live_stream_json.live)

  live_stream.StreamQualities  = CreateObject("roArray", 0, true)
  live_stream.StreamBitrates   = CreateObject("roArray", 0, true)
  live_stream.StreamUrls       = CreateObject("roArray", 0, true)

  for each stream_quality in live_stream_json.media.streamQuality
    live_stream.StreamQualities.Push(stream_quality)
  end for

  for each bitrate in live_stream_json.media.streamBitrate
    live_stream.StreamBitrates.Push(strtoi(bitrate))
  end for

  for each stream_url in live_stream_json.media.streamUrl
    live_stream.StreamUrls.Push(stream_url)
  end for

  'Set Default screen values for items not in feed
'  live_stream.HDBranded = false
'  live_stream.IsHD = false
'  live_stream.StarRating = "90"
  live_stream.ContentType = "episode"

  live_stream.entitled = true
  if live_stream_meta <> invalid and live_stream_meta.entitled <> invalid
	 live_stream.entitled = live_stream_meta.entitled
  end if


  return live_stream

End Function

Function liveStreamForPosterScreen(live_stream As Object) As Object

  poster_live_stream = CreateObject("roAssociativeArray")

  ' hacky, but sometimes we need to know what type we are when selected from the list @TQ
  poster_live_stream.Type = "live_stream"

  poster_live_stream.HDPosterUrl           = live_stream.HDImage
  poster_live_stream.SDPosterUrl           = live_stream.SDImage
  poster_live_stream.ShortDescriptionLine1 = live_stream.Title
  poster_live_stream.Description           = live_stream.Synopsis

  return poster_live_stream

End Function

Function liveStreamForSpringboardScreen(live_stream As Object) As Object

  springboard_live_stream = CreateObject("roAssociativeArray")

  springboard_live_stream.Title = live_stream.Title
  springboard_live_stream.SDPosterUrl = live_stream.SDImage
  springboard_live_stream.HDPosterUrl = live_stream.HDImage
  springboard_live_stream.Description = live_stream.Synopsis
  springboard_live_stream.ContentType = live_stream.ContentType

  return springboard_live_stream

End Function

Function liveStreamForGridScreen(live_stream As Object) As Object

  grid_live_stream = CreateObject("roAssociativeArray")

  ' hacky, but sometimes we need to know what type we are when selected from the list @TQ
  grid_live_stream.Type = "live_stream"

  grid_live_stream.SDPosterUrl = live_stream.SDImage
  grid_live_stream.HDPosterUrl = live_stream.HDImage
  grid_live_stream.ContentType = live_stream.ContentType
  grid_live_stream.ShortDescriptionLine1 = live_stream.Title

  return grid_live_stream

End Function

Function loadDynamicLiveStreams() As Dynamic
	url = AppSettings().odd_service_endpoint + "/liveStreams?filter=isLive%3Dtrue"

	print "Loading Live streams"
	print url

	response_json = oddApiGetRequest(url)

	if response_json = invalid
    print "invalid response?"
    return invalid
  else
    live_stream_collection_json = ParseJson(response_json)

		'PrintAA(live_stream_collection_json.data)

    liveStreamList = CreateObject("roArray", 0, true)

    for each live_stream_json in live_stream_collection_json.data
			if live_stream_json.type = "liveStream"
				print "Got live stream"
				liveStreamList.Push(liveStreamFromJson(live_stream_json, live_stream_json.id))
			else
				print live_stream_json.type
				' unknown entity type? skip? @TQ
			end if
    end for
  end if

  return liveStreamList

End Function
