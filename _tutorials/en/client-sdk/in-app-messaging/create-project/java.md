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

### Add Nexmo dependency

You need to add a custom Maven URL repository to your Gradle configuration. Add the following `maven` block inside `allprojects` block in the top-level `build.gradle` file:

```groovy
allprojects {
    repositories {
        google()
        jcenter()
        
        maven {
            url "https://artifactory.ess-dev.com/artifactory/gradle-dev-local"
        }
    }
}
```

Now add the Client SDK to the project. Add the following dependency in the app level `build.gradle` file (typically `app/build.gradle`):

```groovy
dependencies {
    // ...

    implementation 'com.nexmo.android:client-sdk:2.8.0'
}
```

### Set Java 1.8

Set Java 1.8 in the app level `build.gradle` file (typically `app/build.gradle`):

 ```groovy
android {
    // ...

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```


### Add Navigation component dependencies

To navigate between screens you will use [Navigation component](https://developer.android.com/guide/navigation).

To add navigation component dependency define a variable `ext.android_navigation_version` containing version in top level `build.gradle` file:

```groovy
buildscript {
    ext.android_navigation_version = '2.3.2'

    // ...
}
```

Now in the same file add dependency for Gradle safe args plugin that provides type safety when navigating and passing data between destinations.
Add new classpath in the `dependencies` block:

```groovy
dependencies {
    classpath "com.android.tools.build:gradle:4.1.1"
    classpath "androidx.navigation:navigation-safe-args-gradle-plugin:$android_navigation_version"
}
```

Finaly you add navigation component dependencies in the app level `build.gradle` file (typically `app/build.gradle`):

```groovy
dependencies {
    // ...

    implementation "androidx.navigation:navigation-fragment:$android_navigation_version"
    implementation "androidx.navigation:navigation-ui-ktx:$android_navigation_version"
}
```

Click `Sync project with Gradle Files` icon to make sure uild scripts have been correctly configured:

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/sync-project-wth-gradle-files.png
```