REM ******************************************************
REM Queries the odd catalog with a search term
REM ******************************************************
Function oddApiCatalogSearch(search_term As String) As Object

  search_result = CreateObject("roAssociativeArray")

  search_result.Type = "search_result"
  search_result.Url = OddConfig().search_endpoint
  search_result.searchTerm = search_term

  search_result.LoadSearchResults = load_search_results

  return search_result

End Function

Function load_search_results() As Object

  encodedTerms = HttpEncode(m.searchTerm)
  encodedEntityTypes = HttpEncode("video")
  response_json = oddApiGetRequest(m.Url + "?term=" + encodedTerms + "&limit=25" +  "&include=true&entityTypes=" + encodedEntityTypes) 'playing with limits'

  if response_json = invalid
    print "invalid response?"
    return invalid
  else
    search_results_json = ParseJson(response_json)

    search_results = CreateObject("roArray", 0, true)
    for each result_json in search_results_json.data
      if result_json.type = "video"
        search_results.Push(videoFromJson(result_json, result_json.id))
      else if result_json.type = "collection"
        search_results.Push(videoCollectionFromJson(result_json))
      end if
    end for
  end if

  return search_results

End Function
