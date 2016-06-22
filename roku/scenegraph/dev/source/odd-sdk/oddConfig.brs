REM ******************************************************
REM Loads the initial Odd Config that contains view data,
REM active features, and feature configuration
REM ******************************************************
Function initOddConfig(odd_service_endpoint as string) As Void

  global_config = GetGlobalAA()

  odd_config = CreateObject("roAssociativeArray")

  odd_config_response = oddApiGetRequest(odd_service_endpoint + "/config")

  if odd_config_response = invalid
    global_config["odd_config"] = invalid
  else
		print "Got config"
    odd_config_json = ParseJson(odd_config_response)

    odd_config["home_view_endpoint"] = odd_service_endpoint + "/views/" + odd_config_json.data.attributes.views.homepage

    odd_config["search_endpoint"] = odd_service_endpoint + "/search"

		if odd_config_json.data.attributes.features.authentication <> invalid
			odd_config["auth_enabled"] = odd_config_json.data.attributes.features.authentication.enabled
		else
			odd_config["auth_enabled"] = false
		end if

		odd_config["analytics"] = odd_config_json.data.attributes.features.metrics

		' pull in raw features for any custom stuff that might be in there...
		odd_config["features"] = odd_config_json.data.attributes.features

		odd_config["ads_enabled"] = false
		if odd_config_json.data.attributes.features.ads <> invalid and odd_config_json.data.attributes.features.ads.enabled <> invalid
			odd_config["ads_enabled"] = odd_config_json.data.attributes.features.ads.enabled
		end if

    if odd_config_json.data.attributes.features.ads <> invalid and odd_config_json.data.attributes.features.ads.nielsen <> invalid
			odd_config["ads_nielsen"] = odd_config_json.data.attributes.features.ads.nielsen
		end if

    global_config["odd_config"] = odd_config

  end if

End Function

REM ******************************************************
REM Config set as a globally accessible object
REM ******************************************************

Function OddConfig() As Object
  global_config = GetGlobalAA()
  return global_config.odd_config
End Function
