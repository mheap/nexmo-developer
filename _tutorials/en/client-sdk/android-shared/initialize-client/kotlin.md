---
title: Initialize the client
description: In this step you will initialize `NexmoClient`, so it can be used within the application.
---

# Initialize the client

[NexmoClient](https://developer.nexmo.com/sdk/stitch/android/com/nexmo/client/NexmoClient.html) is the main class used to interact with `Android-Client-SDK`. Prior to usage, we have to initialize the client by providing an instance of the Android [Context](https://developer.android.com/reference/android/content/Context) class. 

Locate the `onCreate` method in the `MainActivity` class and initialize `NexmoClient` using the builder. You can find this class in the Android view on the left or use `Navigate class` keyboard shortcut (Mac: `Cmd + O` ; Win: `Ctrl + O`).

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    setContentView(R.layout.activity_main);

    NexmoClient.Builder().build(this)
}
```

> **NOTE:** The above code will allow retrieving `NexmoClient` instance later by using `NexmoClient.get()`.

> **NOTE:** You can enable additional `Logcat` logging by using `logLevel()` method of the builder, for example, `NexmoClient.Builder().logLevel(ILogger.eLogLevel.SENSITIVE).build(this)`

If Android Studio can't find the reference to the `NexmoClient` class then you have to add the missing import. Roll over on the `NexmoClient` class, wait for window to appear and press `Import` (this action will be required in following steps as well).

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/missing-import-kotlin.png
```

You now have a working client. Your next step is to setup navigation.