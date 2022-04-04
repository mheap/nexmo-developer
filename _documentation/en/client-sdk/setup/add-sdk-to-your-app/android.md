---
title: Android
language: android
---

# Overview

In this guide you learn how to add the Client SDK to your Android app.

## Prerequisites

The Client SDK requires a minimum Android API level of 23.

## To add the Client SDK to your project

### Open you Android project

Open your Android project codebase in your IDE.

### Add dependencies

First, you need to add a custom Maven URL repository to your Gradle configuration. 

> NOTE:  There are two languages used to define Gradle build scripts - Groovy (`build.gradle` file) and Kotlin Gradle Script (`build.gradle.kts` file). A Kotlin-Android project may still use Groovy as the language for the build scripts. Please check the file extension to determine the language for the build script files.

Add the following URL in your project-level `build.gradle` or `build.gradle.kts` file:

 ```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/add-sdk/android/maven'
``` 

> NOTE: The Arctic Fox release of Android Studio creates new projects with Gradle 7 or newer. If you have created a new application add the maven URL to repositories in `settings.gradle` file in the `dependencyResolutionManagement` block.

Now add the Client SDK to your project. Add the following dependency in your app level `build.gradle` file (typically `app/build.gradle`):

 ```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/add-sdk/android/dependencies'
``` 

> NOTE: SDK versions >=4 uses a newer version of WebRTC as a dependency. You may need to increase the memory allocated to the JVM in the `gradle.properties` file in the `org.gradle.jvmargs` setting.

### Set Java 1.8

Set Java 1.8 in your app level `build.gradle` or `build.gradle.kts` file (typically `app/build.gradle` or `app/build.gradle.kts`):

 ```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/add-sdk/android/gradlejava18'
``` 


### Add permissions

To use the In-App Voice features, add audio permissions using the following procedure:

1. Add the required permissions to the `AndroidManifest.xml` file:

![](/screenshots/tutorials/client-sdk/android-shared/android-manifest-file.png)


```xml
<manifest ...>
	<uses-permission android:name="android.permission.INTERNET" />
	<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
	<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
	<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
	<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
	<uses-permission android:name="android.permission.RECORD_AUDIO" />
	<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
</manifest>
```

#### Runtime Permissions

- For devices running Android version 6.0 Marshmallow (API level 23) or higher, you should request the `RECORD_AUDIO` permission at runtime:
```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/add-sdk/android/request-23-permissions'
``` 

- For devices running Android version 12 (API level 31) or higher, you should also request the `READ_PHONE_STATE` permission at runtime:
```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/add-sdk/android/request-31-permissions'
``` 

Read more about requesting runtime permissions on Android [here](https://developer.android.com/training/permissions/requesting). 

## Using NexmoClient in your App

### Building NexmoClient

Make sure to build the NexmoClient instance before using it.

 ```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/add-sdk/android/build-client'
``` 

### Setting connection listener

Set `NexmoConnectionListener` that will notify you on any changes on the connection to the SDK and the availability of its functionality:

 ```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/add-sdk/android/connection-listener'
``` 

### Login NexmoClient

After initializing `NexmoClient`, you need log in to it, using a `jwt` user token. This is described in the topic on [JWTs and ACLs](/client-sdk/concepts/jwt-acl).

Replace the token so as to authenticate the relevant user:

 ```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/add-sdk/android/login'
``` 

After the login succeeds, the logged in user is available via `NexmoClient.get().getUser()`.

## Conclusion

You added the Client SDK to your Android app, initialized it, and logged in to a `NexmoClient` instance. 

In production application good place to initialize `NexmoClient` is custom Android [Application](https://developer.android.com/reference/android/app/Application) class. You can later retrieve `NexmoClient` instance using `NexmoClient.get()` method and use additional `NexmoClient` functionality.

## See also

* [Data Center Configuration](/client-sdk/setup/configure-data-center) - this is an advanced optional configuration you can carry out after adding the SDK to your application.
