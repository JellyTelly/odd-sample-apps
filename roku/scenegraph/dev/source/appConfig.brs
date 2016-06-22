Function initAppConfig() As Dynamic

  initJson = ReadAsciiFile("pkg:/config/app_config.json")
  appConfig = ParseJson(initJson)

  global_config = GetGlobalAA()
  global_config["app_config"] = appConfig
  print "Loading config..."
  while global_config["app_config"] = invalid
    print "..."
  end while

  return global_config["app_config"].settings

End Function

Function AppSettings() As Object

  global_config = GetGlobalAA()
  return global_config["app_config"].settings

End Function

Function AppTheme() As Object

  global_config = GetGlobalAA()
  return global_config["app_config"].theme

End Function

Function AppThemeAlternate() As Object

  global_config = GetGlobalAA()
  return global_config["app_config"].themeAlternate

End Function

Function AppAuth() As Object

  global_config = GetGlobalAA()
  return global_config["app_config"].auth

End Function

Function AppCustomAPIConfig() As Object

  global_config = GetGlobalAA()
  return global_config["app_config"].custom_api_config

End Function
