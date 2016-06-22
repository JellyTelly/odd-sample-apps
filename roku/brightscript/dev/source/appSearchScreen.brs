Function preShowSearchScreen(breadA=invalid, breadB=invalid) As Object

    if validateParam(breadA, "roString", "preShowSearchScreen", true) = false return -1
    if validateParam(breadB, "roString", "preShowSearchScreen", true) = false return -1

    port=CreateObject("roMessagePort")
    screen = CreateObject("roSearchScreen")
    screen.SetMessagePort(port)
    if breadA<>invalid and breadB<>invalid then
        screen.SetBreadcrumbText(breadA, breadB)
    end if

    return screen

End Function

Function showSearchScreen(screen As Object) As Integer

    if validateParam(screen, "roSearchScreen", "showSearchScreen") = false return -1

    screen.Show()
    history = CreateObject("roSearchHistory")
    screen.SetSearchTerms(history.GetAsArray())

    while true
      msg = wait(0, screen.GetMessagePort())
      if type(msg) = "roSearchScreenEvent"
        if msg.isScreenClosed()
          print "screen closed"
          return -1
        else if msg.isCleared()
          print "search terms cleared"
          history.Clear()
        else if msg.isPartialResult()
          print "partial search: "; msg.GetMessage()
        else if msg.isFullResult() and msg.GetMessage() <> ""
          search_term = msg.GetMessage()
          print "full search: "; search_term
          screen.SetSearchText(search_term)
          history.Push(search_term)
          screen.ClearSearchTerms()
          screen.SetSearchTerms(history.GetAsArray())

          search_results = searchOddCatalog(search_term)

          if search_results.count() = 0 then
            ShowErrorDialog("No search results found")
          else
            displaySearchResultPosterScreen(search_results)

            if checkAuthStatus() = invalid
							return -1
						end if

          end if
        else
          print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
        end if
      end if
    end while

End Function


Function displaySearchResultPosterScreen(search_results As Object) As Dynamic

    screen = preShowPosterScreen("Search Results", "")
    showSearchResultPosterScreen(screen, search_results)

    return 0

End Function


Function searchOddCatalog(search_term As String) As Dynamic
  odd_search = oddApiCatalogSearch(search_term)
  return odd_search.LoadSearchResults()
End Function
