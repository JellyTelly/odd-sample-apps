Library "Roku_Ads.brs"

Function PlayVideoContent(content as Object) as Object
    videoScreen = CreateObject("roVideoScreen")
    videoScreen.SetContent(content)
    ' need a reasonable notification period set if midroll/postroll ads are to be
    ' rendered at an appropriate time
    videoScreen.SetPositionNotificationPeriod(1)
    videoScreen.SetMessagePort(CreateObject("roMessagePort"))
    if content.Live
      videoScreen.EnableTrickPlay(false)
    end if
    videoScreen.Show()

    return videoScreen
End Function

Function showVideoScreen(videoContent as Object)
    adIface = Roku_Ads()
    print "Roku_Ads library version: " + adIface.getLibVersion()
    ' Normally, would set publisher's ad URL here.  Otherwise uses default Roku ad server (with single preroll placeholder ad)

    if videoContent.AdUrl <> invalid
			print "*** using videoContent.AdUrl"
			print videoContent.AdUrl
			' adIface.setDebugOutput(true)
      adIface.setAdUrl(videoContent.AdUrl)
    end if

		if OddConfig().ads_enabled
	    adPods = adIface.getAds()
	    if videoContent.Live
	      playContent = true
	    else
        if OddConfig().ads_nielsen <> invalid and OddConfig().ads_nielsen.enabled = true
          print "Nielsen Ads enabled"
          adIface.enableNielsenDAR(true)
          adIface.setNielsenAppId(OddConfig().ads_nielsen.appID)
          adIface.setNielsenGenre(OddConfig().ads_nielsen.genre)
          adIface.setNielsenProgramId(videoContent.Title)
          adIface.setContentLength(videoContent.runtime)
				else
					print "Nielsen Ads disabled"
        end if
	      playContent = adIface.showAds(adPods) ' show preroll ad pod (if any)
	    end if
		else
	  	playContent = true
		end if

    curPos = 0
		statsAttributes = CreateObject("roAssociativeArray")
    if playContent
			videoScreen = PlayVideoContent(videoContent)

			if OddConfig().analytics.videoPlay.enabled = true
				if videoContent.Live
            oddApiPostMetric(OddConfig().analytics.videoPlay.action, "liveStream", videoContent.ContentId, invalid)
        else
            oddApiPostMetric(OddConfig().analytics.videoPlay.action, "video", videoContent.ContentId, invalid)
        endif
			end if
    end if

    while playContent
        videoMsg = wait(0, videoScreen.GetMessagePort())
        if type(videoMsg) = "roVideoScreenEvent"

            if videoMsg.isPlaybackPosition()
                ' cache current playback position for resume functionality
                curPos = videoMsg.GetIndex()
                RegWrite(videoContent.ContentId, curPos.toStr())

								if OddConfig().analytics.videoPlaying.enabled = true
									statsAttributes.timeElapsed = curPos * 1000
									if statsAttributes.timeElapsed MOD OddConfig().analytics.videoPlaying.interval = 0
										if videoContent.Live
											statsAttributes.videoDuration = ""
				          		oddApiPostMetric(OddConfig().analytics.videoPlaying.action, "liveStream", videoContent.ContentId, statsAttributes)
				        		else
											statsAttributes.videoDuration = videoContent.runtime * 1000
				            	oddApiPostMetric(OddConfig().analytics.videoPlaying.action, "video", videoContent.ContentId, statsAttributes)
				        		endif
									end if
								end if
            end if

						if OddConfig().ads_enabled
	            'check for midroll/postroll ad pods
	            adPods = adIface.getAds(videoMsg)
	            if videoContent.Live <> true and adPods <> invalid and adPods.Count() > 0
	                ' stop video playback to prepare for midroll ad render
	                videoScreen.Close()
	                playContent = adIface.showAds(adPods)
	                if playContent
	                    ' resume video playback after midroll ads
	                    videoContent.PlayStart = curPos
	                    videoScreen = PlayVideoContent(videoContent)
	                end if
	                ' if !playContent, User exited ad view, returning to content selection
	            end if ' adPods <> invalid
						end if

            if videoMsg.isFullResult() or videoMsg.isRequestFailed() or videoMsg.isPartialResult() or videoMsg.isScreenClosed()
								' curPos = videoMsg.GetIndex()
								' use last curPos from playback, setting here gives us 0 @TQ

								if OddConfig().analytics.videoPlaying.enabled = true
									statsAttributes.timeElapsed = curPos * 1000
									if videoContent.Live
										statsAttributes.videoDuration = ""
				            oddApiPostMetric(OddConfig().analytics.videoStop.action, "liveStream", videoContent.ContentId, statsAttributes)
				        	else
										statsAttributes.videoDuration = videoContent.runtime * 1000
				            oddApiPostMetric(OddConfig().analytics.videoStop.action, "video", videoContent.ContentId, statsAttributes)
				        	endif
								end if

                playContent = false
            end if

            if videoMsg.isRequestFailed()
              error_message = videoMsg.GetMessage()
              print "Video request failure: "; videoMsg.GetIndex(); " " error_message
              ShowErrorDialog(error_message, "Requested video could not be played")

							if OddConfig().analytics.videoError.enabled = true
              	if videoContent.Live
                	oddApiPostMetric(OddConfig().analytics.videoError.action, "liveStream", videoContent.ContentId, invalid)
              	else
                	oddApiPostMetric(OddConfig().analytics.videoError.action, "video", videoContent.ContentId, invalid)
              	endif
							end if

            elseif videoMsg.isFullResult()
              RegDelete(videoContent.ContentId)
            end if

        else
          print "Unexpected message class: "; type(msg)
        end if

    end while

End Function
