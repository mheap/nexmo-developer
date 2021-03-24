---
title: Add permissions
description: In this step you add permissions
---

# Add permissions

## Declare permissions in Android Manifest

Add the required permissions to the `AndroidManifest.xml` file:

![Android Manifest](/screenshots/tutorials/client-sdk/android-shared/android-manifest-file.png)

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="com.vonage.tutorial">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    ...
```

## Request permissions at runtime

To simplify the tutorial, the permissions are requested each time the application runs. To request permissions, add the following code to the `onCreate` method of the `MainActivity` class:

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // request permissions
        val callsPermissions = arrayOf(Manifest.permission.RECORD_AUDIO)
        ActivityCompat.requestPermissions(this, callsPermissions, 123)
    }
```

After pasting the above snippet some of the class references (imports) can be missing. The missing class is marked using red color. You have to add the missing imports to fix this error. Rollover on the red text, wait for the window to appear, and press `Import` (this action will be required in the following steps as well).

> **NOTE** You can also add missing import by placing caret at red text and pressing Option + Return on MacOS or Alt+Enter on Windows.

# Run the app

You now launch the app. Use the physical phone (with [USB Debugging enabled](https://developer.android.com/studio/debug/dev-options#enable)) or create a new [Android Virtual Device](https://developer.android.com/studio/run/managing-avds). When the virtual device is available press the `Launch` button: 

![Launch app](/screenshots/tutorials/client-sdk/android-shared/launch-app.png)

Notice the prompt asking for permission to use the microphone:

![Permissions dialog](/screenshots/tutorials/client-sdk/app-to-phone/permission-dialog.png)

