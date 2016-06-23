Function userAccessToken() As Dynamic
	return RegRead("access_token", "odd_networks:" + AppSettings().organizationID)
End Function

Function writeAuth(access_token)
	RegWrite("access_token", access_token, "odd_networks:" + AppSettings().organizationID)
End Function

Function clearAuth()
	RegDelete("access_token", "odd_networks:" + AppSettings().organizationID)
End Function

Function setRequireAuthorization()
	OddConfig().require_authorization = true
End Function

Function clearRequireAuthorization()
	OddConfig().require_authorization = false
End Function

Function authorizationRequired() As Boolean
	if OddConfig().require_authorization = true
		return true
	else
		return false
	end if
End Function

Function authorizationEnabled() As Boolean
	if OddConfig().auth_enabled <> invalid and OddConfig().auth_enabled = true
		return true
	else
		return false
	end if
End Function

REM ******************************************************
REM Queries Odd Servers for auth status
REM ******************************************************
Function checkAuthStatus() As Dynamic

	'print "Auth Enabled"
	'print authorizationEnabled()
	'print "Auth Required"
	'print authorizationRequired()
	'print "User Token:"
	'print userAccessToken()

	if (authorizationEnabled() = true and userAccessToken() = invalid) or authorizationRequired() = true
		print "auth check failed"
		return invalid
	else
		print "auth check passed"
		return true
	end if
End Function

REM ******************************************************
REM Presents auth screen giving user options to authenticate
REM ******************************************************
Function showAuthScreen() as boolean

  settings = AppSettings()
  auth_settings = AppAuth()

  app = CreateObject("roAppManager")
  app.SetTheme(AppThemeAlternate().themeBlankOverhangSlice)

	screen = setupScreen(settings.appName)

  request_auth_code = true

  while request_auth_code
    auth_config = getAuthCode(settings.odd_service_endpoint + auth_settings.code_url)
    if auth_config <> invalid
			screen = refreshScreen(screen, settings.appName, auth_config.data.attributes.user_code, auth_config.data.attributes.verification_url)
      request_auth_code = false
    else
      error_dialog_result = ShowDialog2Buttons("Registration code error", "Unable to fetch registration code. Try again?", "Ok", "Cancel")
      if error_dialog_result = 1
        return false
      else
        ' continue trying to fetch auth_config
      end if
    end if
  end while

  authorize_timeout_count = 0
  device_not_authorized = true
  while authorize_timeout_count < auth_config.data.attributes.expires_in and device_not_authorized
    dlgMsg = wait(auth_config.data.attributes.interval * 1000, screen.GetMessagePort())
    if dlgMsg <> invalid
      if type(dlgMsg) = "roCodeRegistrationScreenEvent" then
        if dlgMsg.isScreenClosed() then
          return false
        else if dlgMsg.isButtonPressed()
          if dlgMsg.GetIndex() = 0
            new_auth_config = getAuthCode(settings.odd_service_endpoint + auth_settings.code_url)
            if new_auth_config <> invalid
              auth_config = new_auth_config
							screen = refreshScreen(screen, settings.appName, auth_config.data.attributes.user_code, auth_config.data.attributes.verification_url)
              authorize_timeout_count = 0
            else
              ShowDialog1Button("Registration code error", "Unable to fetch registration code.", "Ok")
              ' user can press get new code again or back to exit.
            end if
          end if
          if dlgMsg.GetIndex() = 1
            ' back option pressed
            return false
          end if
        end if
      end if
    end if
    access_token_response = getAccessToken(settings.odd_service_endpoint + auth_settings.token_url, auth_config.data.attributes.device_code)
    if access_token_response <> invalid
      device_not_authorized = false
    end if
    authorize_timeout_count = authorize_timeout_count + auth_config.data.attributes.interval
  end while

  if device_not_authorized
    ShowDialog1Button("Registration timeout", "Unable register within time limit. Please try again later.", "Ok")
    return false
  else
    access_token = access_token_response.data.attributes.access_token

		print "Got access token:"
    print access_token
    writeAuth(access_token)
    return true
  end if

End Function

Function getAuthCode(code_url As String) As Dynamic
  response_json = oddApiPostRequest(code_url, "")
  if response_json = invalid
    return invalid
  else
    auth_config_results_json = ParseJson(response_json)
    return auth_config_results_json
  end if
End Function

Function getAccessToken(access_token_url As String, device_code As String) As Dynamic
  request_body = "type=authorization&attributes[device_code]=" + device_code
  response_json = oddApiPostRequest(access_token_url, request_body)
  if response_json = invalid
    return invalid
  else
    print "getAccessToken response:"
    PrintAA(response_json)
    access_token_results_json = ParseJson(response_json)
    ' return access_token_results_json.data.attributes.access_token
		return access_token_results_json
  end if
End Function

Function setRegistrationScreenVerificationUrl(screen, verificationUrl) As Void
	screen.AddFocalText(" ", "spacing-dense")
	screen.AddFocalText("From your computer or mobile device, go to:", "spacing-dense")
	screen.AddFocalText(verificationUrl, "spacing-dense")
	screen.AddFocalText("and enter your code.", "spacing-dense")
	screen.AddFocalText(" ", "spacing-dense")
End Function

Function setupScreen(appName) As Dynamic
	port = CreateObject("roMessagePort")
	screen = CreateObject("roCodeRegistrationScreen")
	screen.SetMessagePort(port)
	screen.SetTitle("Device Registration")
	screen.AddParagraph("Please go online to register your Roku device with your " + appName + " account.")
	screen.SetRegistrationCode("retreiving...")
	screen.AddParagraph("Successfully registering online will grant you full access to " + appName + " on your Roku.")
	screen.AddButton(0, "get a new code")
	screen.AddButton(1, "back")
	screen.Show()
	return screen
End Function

Function refreshScreen(screen, appName, userCode, verificationUrl) As Dynamic
  port = CreateObject("roMessagePort")
	newScreen = CreateObject("roCodeRegistrationScreen")
	newScreen.SetMessagePort(port)
	newScreen.SetTitle("Device Registration")
	newScreen.AddParagraph("Please go online to register your Roku device with your " + appName + " account.")
	newScreen.AddFocalText(" ", "spacing-dense")
	newScreen.AddFocalText("From your computer or mobile device, go to:", "spacing-dense")
	newScreen.AddFocalText(verificationUrl, "spacing-dense")
	newScreen.AddFocalText("and enter this code:", "spacing-dense")
	newScreen.AddFocalText(" ", "spacing-dense")
	newScreen.SetRegistrationCode(userCode)
	newScreen.AddParagraph("Successfully registering online will grant you full access to " + appName + " on your Roku.")
	newScreen.AddButton(0, "get a new code")
	newScreen.AddButton(1, "back")
	newScreen.Show()
	if screen <> invalid
		screen.Close()
	end if
	return newScreen
End Function
