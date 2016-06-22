REM ******************************************************
REM Constucts a URL Transfer object
REM ******************************************************

Function CreateURLTransferObject(url As String) as Object
    obj = CreateObject("roUrlTransfer")
    obj.SetPort(CreateObject("roMessagePort"))
    obj.SetUrl(url)
    ' obj.AddHeader("Content-Type", "application/x-www-form-urlencoded")
    obj.EnableEncodings(true)
    return obj
End Function

REM ******************************************************
REM Url Query builder
REM so this is a quick and dirty name/value encoder/accumulator
REM ******************************************************

Function NewHttp(url As String) as Object
    obj = CreateObject("roAssociativeArray")
    obj.Http                        = CreateURLTransferObject(url)
    obj.FirstParam                  = true
    obj.AddParam                    = http_add_param
    obj.AddRawQuery                 = http_add_raw_query
    obj.PrepareUrlForQuery          = http_prepare_url_for_query
    obj.PostFromStringWithTimeout   = http_post_from_string_with_timeout
		obj.GetWithTimeout							= http_get_with_timeout

    if Instr(1, url, "?") > 0 then obj.FirstParam = false

    return obj
End Function

REM ******************************************************
REM HttpEncode - just encode a string
REM ******************************************************

Function HttpEncode(str As String) As String
    o = CreateObject("roUrlTransfer")
    return o.Escape(str)
End Function

REM ******************************************************
REM Prepare the current url for adding query parameters
REM Automatically add a '?' or '&' as necessary
REM ******************************************************

Function http_prepare_url_for_query() As String
    url = m.Http.GetUrl()
    if m.FirstParam then
        url = url + "?"
        m.FirstParam = false
    else
        url = url + "&"
    endif
    m.Http.SetUrl(url)
    return url
End Function

REM ******************************************************
REM Percent encode a name/value parameter pair and add the
REM the query portion of the current url
REM Automatically add a '?' or '&' as necessary
REM Prevent duplicate parameters
REM ******************************************************

Function http_add_param(name As String, val As String) as Void
    q = m.Http.Escape(name)
    q = q + "="
    url = m.Http.GetUrl()
    if Instr(1, url, q) > 0 return    'Parameter already present
    q = q + m.Http.Escape(val)
    m.AddRawQuery(q)
End Function

REM ******************************************************
REM Tack a raw query string onto the end of the current url
REM Automatically add a '?' or '&' as necessary
REM ******************************************************

Function http_add_raw_query(query As String) as Void
    url = m.PrepareUrlForQuery()
    url = url + query
    m.Http.SetUrl(url)
End Function

Function http_get_with_timeout(seconds as Integer) as Object
    timeout% = 1000 * seconds

    result = invalid
    m.Http.EnableFreshConnection(true) 'Don't reuse existing connections
    if (m.Http.AsyncGetToString())
        event = wait(timeout%, m.Http.GetPort())
        if type(event) = "roUrlEvent"
						'print "in http_get_with_timeout"
						'print "event code"
			print event.GetResponseCode()
            result = event
        elseif event = invalid
						Dbg("AsyncGetToString timeout")
            m.Http.AsyncCancel()
        else
            Dbg("AsyncGetToString unknown event", event)
        endif
    endif

    return result
End Function

REM ******************************************************
REM Performs Http.AsyncPostFromString() with a single timeout in seconds
REM To the outside world this appears as a synchronous API.
REM ******************************************************

Function http_post_from_string_with_timeout(val As String, seconds as Integer) as Dynamic
    print "http_post_from_string_with_timeout"

    timeout% = 1000 * seconds

    result = invalid
    m.Http.EnableFreshConnection(true) 'Don't reuse existing connections
    if (m.Http.AsyncPostFromString(val))
      event = wait(timeout%, m.Http.GetPort())
      if type(event) = "roUrlEvent"
			 'print "1"
			 result = event
      elseif event = invalid
				'print "2"
        Dbg("AsyncPostFromString timeout")
      	m.Http.AsyncCancel()
      else
				'print "3"
        Dbg("AsyncPostFromString unknown event", event)
        endif
    endif

    return result
End Function