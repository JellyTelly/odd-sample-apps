REM ******************************************************
REM Fetches all included objects for selected object
REM ******************************************************
Function oddApiFindInIncludes(search_id As String, includes As Object) As Dynamic

  for each entry in includes
    if entry.id = search_id
      return entry
    end if
  end for

  return invalid

End Function


' oddApiGetRequest(settings.odd_service_endpoint + "/" + "promotion" + "s/" + promotion_entry.id)

REM ******************************************************
REM Formats a get request to the odd API
REM ******************************************************
Function oddApiGetRequest(url As String) As Dynamic

  oddApiRequest = NewHttp(url)

  di = CreateObject("roDeviceInfo")
  locale = di.GetCurrentLocale()
	oddApiRequest.Http.AddHeader("Accept-Language", locale)
  oddApiRequest.Http.AddHeader("x-access-token", AppAuth().deviceAccessToken)
	if userAccessToken() <> invalid
		oddApiRequest.Http.AddHeader("Authorization", "Bearer " + userAccessToken())
	end if
  oddApiRequest.Http.AddHeader("Accept", "application/json")
	oddApiRequest.Http.AddHeader("x-odd-user-agent", x_odd_user_agent_header())
  oddApiRequest.Http.SetCertificatesFile("common:/certs/ca-bundle.crt")

	response = oddApiRequest.GetWithTimeout(100)

	if response = invalid
		' request failed hard. timeout?
		return invalid
	else if response.GetResponseCode() = 401
		print "Got a 401. Blow away auth..."
    clearAuth()
		return invalid
	else
		response_json = response.GetString()

  	if response_json = "" then
    	print "oddApiRequest failed."
    	print url
    	print response.GetResponseCode()
			print "***"
    	return invalid
  	else
    	'print "Request Success"
    	'print url
  		return response_json
  	end if
	end if

End Function

REM ******************************************************
REM Formats a post request to the odd API
REM ******************************************************
Function oddApiPostRequest(url As String, postBody As String) As Dynamic

  oddApiRequest = NewHttp(url)

  di = CreateObject("roDeviceInfo")
  locale = di.GetCurrentLocale()
	oddApiRequest.Http.AddHeader("Accept-Language", locale)
  oddApiRequest.Http.AddHeader("x-access-token", AppAuth().deviceAccessToken)
	if userAccessToken() <> invalid
		oddApiRequest.Http.AddHeader("Authorization", "Bearer " + userAccessToken())
	end if
  oddApiRequest.Http.AddHeader("Accept", "application/json")
  oddApiRequest.Http.AddHeader("Content-Type", "application/x-www-form-urlencoded")
	oddApiRequest.Http.AddHeader("x-odd-user-agent", x_odd_user_agent_header())
  oddApiRequest.Http.SetCertificatesFile("common:/certs/ca-bundle.crt")

	response = oddApiRequest.PostFromStringWithTimeout(postBody, 100)

	if response = invalid
		' request failed hard. timeout?
		return invalid
	else
		response_json = response.GetString()

  	if response_json = "" then
    	print "oddApiRequest failed."
    	print url
    	print response.GetResponseCode()
			print "***"
    	return invalid
  	else
    	'print "Request Success"
    	'print url
  		return response_json
  	end if
	end if

End Function

REM ******************************************************
REM Posts a metric to the odd api. 
REM Takes an action string, contentType string, contentId string, and statAttribs object
REM ******************************************************
Function oddApiPostMetric(action as String, contentType as String, contentId as string, statAttribs as Object) as Dynamic
  'Metric Reporting:
  ' 1) Video plays and errors, with played media id
  ' 2) Home and app init
  ' 3) Detail and poster views, with viewed media id

  ' query videos
  print "Metric Post:"
  settings = AppSettings()

  oddApiRequest = NewHttp(settings.odd_service_endpoint + "/events")
  di = CreateObject("roDeviceInfo")
  locale = di.GetCurrentLocale()
  oddApiRequest.Http.AddHeader("Accept-Language", locale)
  oddApiRequest.Http.AddHeader("x-access-token", AppAuth().deviceAccessToken)
	if userAccessToken() <> invalid
		oddApiRequest.Http.AddHeader("Authorization", "Bearer " + userAccessToken())
	end if
  oddApiRequest.Http.AddHeader("Accept", "application/json")
  oddApiRequest.Http.AddHeader("Content-Type", "application/x-www-form-urlencoded")
	oddApiRequest.Http.AddHeader("x-odd-user-agent", x_odd_user_agent_header())
  oddApiRequest.Http.SetCertificatesFile("common:/certs/ca-bundle.crt")

  content = "type=event&attributes[action]=" + action

  if contentType <> "nil"
    content = content + "&attributes[contentType]=" + contentType
  end if

  if contentId <> "nil"
    content = content + "&attributes[contentId]=" + contentId
  end if

	if statAttribs <> invalid
		content = content + "&attributes[elapsed]=" + tostr(statAttribs.timeElapsed)
		content = content + "&attributes[duration]=" + tostr(statAttribs.videoDuration)
	end if

	'print "sending metrics:"
	'print content

  response = oddApiRequest.PostFromStringWithTimeout(content, 100)

	if response = invalid
		' print "request failed hard. timeout?"
		return invalid
	else if response.GetResponseCode() <> 201
	  print "oddApiPostMetricRequest failed."
		print content
		print response
	  return false
	else
	  ' print "oddApiPostMetricRequest success."
	  return true
	end if

End Function

REM ******************************************************
REM Attaches a user agent header to provide the API with more information on the device
REM ******************************************************
Function x_odd_user_agent_header() as String

	appInfo = CreateObject("roAppInfo")
 	deviceInfo = CreateObject("roDeviceInfo")

	platformName = "ROKU"
	modelName = "ROKU"
	modelVersion = deviceInfo.GetModel()
	osName = "ROKU"
	osVersion = deviceInfo.GetVersion()
	oddBuildNumber = appInfo.GetVersion()

	return "platform[name]=" + platformName + "&model[name]=" + modelName + "&model[version]=" + modelVersion + "&os[name]=" + osName + "&os[version]=" + osVersion + "&build[version]=" + oddBuildNumber
End Function
