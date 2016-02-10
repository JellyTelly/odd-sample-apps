# OddSampleApp
A sample application build on the Odd Networks Platform

## Setup

### OddWorksDeviceSDK

Our SDK is built and hosted via [JitPack](https://jitpack.io).

#### Compiling the SDK

Include Jitpack in the `repositories` section of the app's `build.gradle` file:

```groovy
repositories {
    // ...
    maven { url "https://jitpack.io" }
}
```

Include OddWorksDeviceSDK in the `dependencies` section of the app's `build.gradle` file:

```groovy
dependencies {
    // ...
    compile 'com.github.oddnetworks:OddWorksDeviceSDK:beta-1.0.0'
}
```

#### SDK Config File

In `app/src/main/res/values/` you'll need to create an `sdk_strings.xml` file, or add your Oddworks REST API Access Token as a string resource.

    // app/src/main/res/values/sdk_strings.xml
    <?xml version="1.0" encoding="utf-8"?>
    <resources>
        <string name="x_access_token">your-x-access-token-here</string>
    </resources>
