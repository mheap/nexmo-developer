---
title: "Making Video Calls Using Vonage Video and Flutter "
description: Let's take a closer look at a Vonage Video Flutter app that allows
  us to make video calls
thumbnail: /content/blog/making-video-calls-using-vonage-video-and-flutter/flutter_videocall_1200x600.png
author: igor-wojda
published: true
published_at: 2021-07-06T15:06:53.931Z
updated_at: 2021-07-06T15:06:53.964Z
category: announcement
tags:
  - Flutter
  - video-api
  - mobile
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Flutter is gaining more and more popularity, so we decided to build a simple application that allows making video calls between two devices. Two technologies used to build the app are Flutter and Vonage Video SDKs. Let's quickly recap these technologies:

* [Flutter](https://flutter.dev/) - open-source UI software development kit used to develop cross-platform applications for Android, iOS, Linux, and Mac. The main programming language is [Dart](https://dart.dev/).
* [Vonage Video](https://tokbox.com/developer/sdks/android/) - used to build video calls between various devices. The programming languages used are [Kotlin](https://kotlinlang.org/) for the Android platform and [Swift](https://www.swift.com/) for the iOS platform.

This application is a Flutter equivalent of the Basic-Video-Chat application ([Basic-Video-Chat Android](https://github.com/opentok/opentok-android-sdk-samples/tree/main/Basic-Video-Chat) / [Basic-Video-Chat iOS](https://github.com/opentok/opentok-ios-sdk-samples/tree/main/Basic-Video-Chat)). Here are the main features of the application:

* Connect to a Vonage Video session
* Publish an audio-video stream to the session
* Subscribe to another client's audio-video stream

> NOTE: The application source code is available on [GitHub](https://github.com/opentok/opentok-flutter-basic-video-chat).

Flutter is the main technology here. It is a foundation used to build a mobile application that runs on Android and iOS. It will be responsible for managing and displaying the UI, and it will contain the application logic. This way application logic is only written once for both platforms.

Under the hood, this Flutter application will use [Android Vonage Video SDK](https://tokbox.com/developer/sdks/android/) and [iOS Vonage Video SDK](https://tokbox.com/developer/sdks/ios/) (via Android/iOS native projects):

![Flutter application under the hood](/content/blog/making-video-calls-using-opentok-and-flutter/method-channel.png)

Platform (Android, iOS) native code communicates with Flutter by using Flutter [MethodChannel](https://api.flutter.dev/flutter/services/MethodChannel-class.html), that uses method calls. MethodChannel serves as a bridge to send messages between Flutter and native code (added to the native Android project and native iOS project). This allows us to log-in the user and set up the video session to make a video call:  

![Flutter application flow](/content/blog/making-video-calls-using-vonage-video-and-flutter/flutter-application.png)

Flutter can send messages to the native (Android / iOS) part of the app and the native part of the app can send a message back to Flutter. Flutter calls the `initSession` method and passes the `apiKey`, `sessionId`, and `token` to native code to start a Vonage Video session. The native code will inform the Flutter part of the app about a successful login (or error) and the Flutter-side code will update the UI.

> NOTE: A Flutter app can be packaged as an Android or iOS application, but never both at the same time. When the target platform is set to Android, MethodChannel communicates with Android native app code. When the target platform is set to iOS, then MethodChannel communicates with iOS native app code.

To run the [application](https://github.com/opentok/opentok-flutter-basic-video-chat) you will have to install Flutter. 
This varies from platform to platform, as you can see in the [detailed instructions](https://flutter.dev/docs/get-started/install).

> NOTE: Make sure to run `flutter doctor` to verify your local flutter setup.

To log into the Vonage Video session, you will need a [Vonage Video account](https://tokbox.com/account/#/) and to generate `initSession`, `apiKey`, and `sessionId`. You can get these values in the [Vonage Video Dashboard](https://tokbox.com/account/#/). Now open the `main.dart` file and use those values in the corresponding variables:

```
static String API_KEY = "";
static String SESSION_ID = "";
static String TOKEN = "";
```

Launch the mobile app to start the video call.

> NOTE: You can use [Developer playground](https://tokbox.com/developer/tools/playground/) to connect to the same session as the mobile device running the Flutter app.

## Summary

There are still a few [drawbacks](https://github.com/opentok/opentok-flutter-basic-video-chat#known-issues), but the overall integration of Flutter and Vonage Video is quite smooth. Even without a native Flutter package, it is possible to quickly create build a full-fledged Flutter app that utilizes Vonage Video mobile SDKs under the hood and runs on Android and iOS devices.