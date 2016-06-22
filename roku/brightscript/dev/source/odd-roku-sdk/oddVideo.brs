REM ******************************************************
REM OddVideo
REM ******************************************************
Function videoFromJson(video_json As Object, collection_id As Dynamic) As Object

  video = CreateObject("roAssociativeArray")

  video_id = video_json.id
	video_meta = video_json.meta
	video_attributes = video_json.attributes

  video.Type             = "video"
  video.ContentId        = video_id
  video.Title            = video_attributes.title
  video.SDImage          = video_attributes.images.aspect16x9
  video.HDImage          = video_attributes.images.aspect16x9
  video.SDImage_Detail   = video_attributes.images.aspect16x9
  video.HDImage_Detail   = video_attributes.images.aspect16x9
  video.Synopsis         = video_attributes.description
  video.ContentQuality   = video_attributes.contentQuality
  video.StreamFormat     = video_attributes.streamFormat
  video.Live             = strtobool(video_attributes.live)

  video.StreamFormat = "mp4"
  video.Stream = { url: video_attributes.url,
    bitrate:0
    quality:["HD, SD"]
    contentid: video_id
  }

  video.Actors = CreateObject("roArray", 0, true)
  if video_attributes.actors <> invalid
    for each actor in video_attributes.actors
      video.Actors.Push(actor)
    end for
  endif

  video.Runtime = Int(video_attributes.duration / 1000)
  video.ContentType = "episode"

  'ad logic'
  If video_attributes.ads <> invalid and video_attributes.ads.type = "vmap" and video_attributes.ads.url <> invalid then
    video.AdUrl = video_attributes.ads.url
		if video_attributes.ads.provider = "freewheel"
			' freewheel requires some fields to be random numbers.
			' we expect the ad url to be contain ^0 / ^1 to mark where these field values should go
			' see Substitute docs for what ^0/^1 actually mean
			video.AdUrl = Substitute(video.AdUrl, tostr(Rnd(4096)), tostr(Rnd(4096)))
		end if
  else
    video.AdUrl = invalid
  end if

	video.entitled = video_meta.entitled
	video.sourceID = video_meta.sourceId
  video.collectionID = collection_id

  return video

End Function

Function videoForPosterScreen(video As Object) As Object

  poster_video = CreateObject("roAssociativeArray")

  ' hacky, but sometimes we need to know what type we are when selected from the list @TQ
  poster_video.Type = "video"

  poster_video.HDPosterUrl           = video.HDImage
  poster_video.SDPosterUrl           = video.SDImage
  poster_video.ShortDescriptionLine1 = video.Title
  poster_video.Description           = video.Synopsis

  return poster_video

End Function

Function videoForSpringboardScreen(video As Object) As Object

  springboard_video = CreateObject("roAssociativeArray")

  springboard_video.Title = video.Title
  springboard_video.SDPosterUrl = video.SDImage_Detail
  springboard_video.HDPosterUrl = video.HDImage_Detail
  springboard_video.Description = video.Synopsis
  springboard_video.ContentType = video.ContentType
  springboard_video.Length = video.Runtime

  springboard_video.Actors = CreateObject("roArray", 0, true)
  for each actor in video.Actors
    springboard_video.Actors.Push(actor)
  end for

  return springboard_video

End Function


Function videoForGridScreen(video As Object) As Object

  grid_video = CreateObject("roAssociativeArray")

  ' hacky, but sometimes we need to know what type we are when selected from the list @TQ
  grid_video.Type = "video"

  grid_video.SDPosterUrl = video.SDImage
  grid_video.HDPosterUrl = video.HDImage
  grid_video.ContentType = "episode"
  grid_video.ShortDescriptionLine1 = video.Title

  return grid_video

End Function
