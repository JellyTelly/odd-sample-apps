# OddSampleApp
A sample application build on the Odd Networks Platform

## Setup

### OddWorksDeviceSDK

Our SDK is hosted via [Bintray](https://bintray.com/oddnetworks/oddworks/device-sdk/view).

#### Compiling the SDK

Include the Oddworks Maven repository in the `repositories` section of the app's `build.gradle` file:

```groovy
repositories {
    // ...
    maven {
        url  "http://oddnetworks.bintray.com/oddworks"
    }
}
```

Include OddWorksDeviceSDK in the `dependencies` section of the app's `build.gradle` file:

```groovy
dependencies {
    // ...
    compile 'io.oddworks:device-sdk:beta-1.0.0'
}
```

#### SDK Config File

In `app/src/main/res/values/` you'll need to create an `sdk_strings.xml` file, or add your Oddworks REST API Access Token as a string resource.

    // app/src/main/res/values/sdk_strings.xml
    <?xml version="1.0" encoding="utf-8"?>
    <resources>
        <string name="x_access_token">your-x-access-token-here</string>
    </resources>
