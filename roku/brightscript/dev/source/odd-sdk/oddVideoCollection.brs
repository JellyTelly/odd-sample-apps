REM ******************************************************
REM oddVideoCollection
REM ******************************************************
Function videoCollectionFromJson(video_collection_json As Object) As Object

  video_collection = CreateObject("roAssociativeArray")

  video_collection_attributes = video_collection_json.attributes

  collection_contains_collection = false
  collection_contains_video = false
  if video_collection_json.relationships.entities <> invalid
    video_collection_relations = video_collection_json.relationships.entities.data
    for each related_entity in video_collection_relations
      if related_entity.type = "collection"
        collection_contains_collection = true
      else if related_entity.type = "video"
        collection_contains_video = true
      end if
    end for
  end if

	if collection_contains_collection and collection_contains_video
		video_collection.contents = "mixed"
	else if collection_contains_collection
		video_collection.contents = "collection"
	else if collection_contains_video
		video_collection.contents = "video"
	else
		video_collection.contents = "unknown"
	end if

  video_collection.Type = "video_collection"
  video_collection.contentID = video_collection_json.id
  
  video_collection.sourceId = video_collection_json.meta.sourceId
  video_collection.color = video_collection_json.meta.color

  video_collection.Url = video_collection_json.links.self

  video_collection.Title = video_collection_attributes.title
  video_collection.SDImage = video_collection_attributes.images.aspect16x9
  video_collection.HDImage = video_collection_attributes.images.aspect16x9
  video_collection.description = video_collection_attributes.description

  video_collection.loadItemList = load_item_list

  return video_collection

End Function

Function videoCollectionForPosterScreen(video_collection As Object) As Object

  poster_video_collection = CreateObject("roAssociativeArray")

  ' hacky, but sometimes we need to know what type we are when selected from the list @TQ
  poster_video_collection.Type = "video_collection"

  poster_video_collection.ShortDescriptionLine1 = video_collection.Title
  poster_video_collection.SDPosterUrl = video_collection.SDImage
  poster_video_collection.HDPosterUrl = video_collection.HDImage
  poster_video_collection.Description = video_collection.description

  return poster_video_collection

End Function

Function videoCollectionForGridScreen(video_collection As Object) As Object

  grid_video_collection = CreateObject("roAssociativeArray")

  ' hacky, but sometimes we need to know what type we are when selected from the list @TQ
  ' may not need this if we have it in the videoCollection object
  grid_video_collection.Type = "video_collection"

  grid_video_collection.SDPosterUrl = video_collection.SDImage
  grid_video_collection.HDPosterUrl = video_collection.HDImage
	grid_video_collection.ContentType = "episode"
  grid_video_collection.ShortDescriptionLine1 = video_collection.Title

  return grid_video_collection

End Function

'get the individual items for the collection'
REM ******************************************************
REM Queries the server for the contents of the collection
REM ******************************************************
Function load_item_list() As Object

  response_json = oddApiGetRequest(m.Url + "?include=entities")

  'print "Query collection"
  'print m.Url + "?include=true"

  if response_json = invalid
    print "invalid response?"
    return invalid
  else
    item_collection_json = ParseJson(response_json)

    itemList = CreateObject("roArray", 0, true)

		' PrintAA(item_collection_json)

    for each related_item_json in item_collection_json.data.relationships.entities.data
			item_json = oddApiFindInIncludes(related_item_json.id, item_collection_json.included)
			if item_json.type = "video"
      	itemList.Push(videoFromJson(item_json, m.sourceID))
			else if item_json.type = "collection"
				itemList.Push(videoCollectionFromJson(item_json))
			else
				' unknown entity type? skip? @TQ
			end if
    end for
  end if

  return itemList

End Function
