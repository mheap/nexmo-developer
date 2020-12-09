---
title: Create an Android project
description: In this step you create an Android project and add the Android Client SDK library.
---

# Create an Android project

## Project overview

You will be building nd Android application with the following screens:

- **login** - responsible for logging the user
- **chat** - allows to send/receive chat messages and logut the user

```screenshot
image: public/screenshots/tutorials/client-sdk/android-in-app-messaging-chat/nav-graph.png
```

## New Android Project

Open Android Studio and, from the menu, select `File` > `New` > `New Project...`. Select a `Empty Activity` template type and click `Next`.

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/create-project-empty-activity.png
```

Enter `chat app` as project name, `com.vonage.tutorial.messaging` as package, select `Java` language and press `Finish` button.

```screenshot
image: public/screenshots/tutorials/client-sdk/android-in-app-messaging-chat/configure-your-project-java.png
```

You now have a brand new Android Project.

### Add permission

Add `INTERNET` perission into `AndroidManifest.xml` file:

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/android-manifest-file.png
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="com.vonage.tutorial">

    <uses-permission android:name="android.permission.INTERNET" />
    ...
```