# odd-sample-apps

[![slack.oddnetworks.com](http://slack.oddnetworks.com/badge.svg)](http://slack.oddnetworks.com)

Sample applications demonstrating how to work with the Odd Networks API on various platforms

## Apple

For more information on using the iOS & tvOS frameworks visit our [Oddworks SDK documentation for iOS & tvOS](http://apple.guide.oddnetworks.com)

Unless noted sample app code is provided in Swift

### tvOS Sample App

The tvOS Sample App is available in both Swift and Objective-C versions.

This Application demonstrates connecting to the OddNetworks API using the ODDtvOSSDK. The app uses sample data from NASA to show how to work with OddMediaObjectCollections and OddVideos
  
### iOS Sample App in Objective-C

This Objective-C application demonstrates how to connect to the Oddnetworks API via the OddSDK.

### iOS Search Sample App

Demonstrates using the Oddnetworks SDK to perform a search on your media catalog.

Available in both Objective-C and Swift.

## Android

For more information on using the Android frameworks visit our [Oddworks SDK documentation for Android](http://android.guide.oddnetworks.com)


All Android sample app code is provided in Java

### mobile

This application demonstrates connecting to the Oddworks API using the Oddworks SDK for Android. It uses the collections and assets from our sample NASA organization.

## Roku

Includes two Roku sample applications.

**Note: due to the nature of Roku's scripting language based SDK the Oddworks Roku SDK is included as a [git-submodule](https://github.com/ingydotnet/git-subrepo). There are two ways to include the required Oddworks SDK files in the Roku sample apps**

- git-subrepo - Install the [git-submodule](https://github.com/ingydotnet/git-subrepo) tool, switch to the odd-sdk folder and use the command
```git subrepo pull </path/to/the/odd-roku/sdk>```

- manually download the odd-roku-sdk and copy the files to the odd-sdk folder of the sample project

**The first method is preferred as you can always pull any updates to the odd-roku-sdk. The second method requires manual management of the SDK dependencies**


### brightscript

A sample Roku app written with the Brightscript Component based framework.

### scenegraph

Sample app that built using Roku's new Scene Graph XML components.