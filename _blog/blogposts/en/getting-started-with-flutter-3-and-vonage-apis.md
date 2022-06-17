---
title: Getting started with Flutter 3 and Vonage APIs
description: Flutter 3 has now been released! Lets take a look at how we can use
  the Vonage APIs within a flutter application.
thumbnail: /content/blog/getting-started-with-flutter-3-and-vonage-apis/flutter-3.png
author: zachary-powell-1
published: true
published_at: 2022-05-19T13:03:16.756Z
updated_at: 2022-05-19T13:03:19.112Z
category: tutorial
tags:
  - android
  - ios
  - flutter
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
With the release of Flutter 3.0 (which includes a range of [stability and performance improvements](https://medium.com/flutter/whats-new-in-flutter-3-8c74a5bc32d0)) now is a great time to take a look at how you can use communication APIs to improve your user experience and enhance your cross-platform applications.

Thanks to Flutter's ability to use native platform SDKs we can seamlessly use the Vonage Android and iOS SDKs within our Flutter applications. Let's take a look at how we can create a simple Flutter application that's able to make a voice phone call to a physical phone. By the end of this guide, you will have a good understanding of how to use the Vonage Client SDKs to make a voice call and how you can use native Android and iOS SDKs in your Flutter application.

For this guide, we will create a basic app from scratch but you could just as quickly build the below into your application.

The full source code for this project can be found on [GitHub](https://github.com/Vonage-Community/blog-voice-flutter-app_to_phone).

## Vonage Setup

Before we get into the code there are a few things we need to do to set up the Vonage API and make use of it.

### Account Signup

Start by signing up for a free Vonage Developer account. This can be done via the [Dashboard](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav#_ga=2.264088904.534069361.1652863684-651521337.1652863684), once signed up you will find your account API key and API secret. Take a note of these for future steps.

![Vonage dashboard home page showing API key and API secret location](/content/blog/getting-started-with-flutter-3-and-vonage-apis/dashboard.png)

### Install the Vonage CLI

The [Vonage CLI](https://developer.nexmo.com/application/vonage-cli) allows you to carry out many operations on the command line. Examples include creating applications, purchasing numbers, and linking a number to an application all of which we will be doing today.

To install the CLI with NPM run:

```shell
npm install -g @vonage/cli
```

Set up the Vonage CLI to use your Vonage API Key and API Secret. You can get these from the [settings page](https://dashboard.nexmo.com/settings) in the Dashboard.

Run the following command in a terminal, while replacing `API_KEY` and `API_SECRET` with your own:

```shell
vonage config:set --apiKey=API_KEY --apiSecret=API_SECRET
```

### Buy a Vonage Number

Next, we need a Vonage number that the application can use, this is the phone number that will show on the phone that we call from the application. 

You can purchase a number using the Vonage CLI. The following command purchases an available number in the US. Specify [an alternate two-character country code](https://www.iban.com/country-codes) to purchase a number in another country.

```
vonage numbers:search US
vonage numbers:buy 15555555555 US
```

### Create a Webhook Server

When an inbound call is received, Vonage makes a request to a publicly accessible URL of your choice - we call this the `answer_url`. You need to create a webhook server that is capable of receiving this request and returning an [NCCO](https://developer.vonage.com/voice/voice-api/ncco-reference) containing a `connect` action that will forward the call to the [PSTN phone number](https://developer.vonage.com/concepts/guides/glossary#virtual-number). You do this by extracting the destination number from the `to` query parameter and returning it in your response.

On the command line create a new folder that will contain your webserver

```
mkdir app-to-phone-flutter
cd app-to-phone-flutter
```

Inside the folder, initialize a new Node.js project by running this command:

```
npm init -y
```

Next, install the required dependencies:

```
npm install express localtunnel --save
```

Inside your project folder, create a file named `server.js` and add the code as shown below - please make sure to replace `NUMBER` with your Vonage number (in [E.164](https://en.wikipedia.org/wiki/E.164) format), as well as `SUBDOMAIN` with an actual value. The value used will become part of the URLs you will set as webhooks in the next step.

```javascript
'use strict';

const subdomain = 'SUBDOMAIN';
const vonageNumber = 'NUMBER';

const express = require('express')
const app = express();
app.use(express.json());

app.get('/voice/answer', (req, res) => {
  console.log('NCCO request:');
  console.log(`  - callee: ${req.query.to}`);
  console.log('---');
  res.json([ 
    { 
      "action": "talk", 
      "text": "Please wait while we connect you."
    },
    { 
      "action": "connect",
      "from": vonageNumber,
      "endpoint": [ 
        { "type": "phone", "number": req.query.to } 
      ]
    }
  ]);
});

app.all('/voice/event', (req, res) => {
  console.log('EVENT:');
  console.dir(req.body);
  console.log('---');
  res.sendStatus(200);
});

app.listen(3000);

const localtunnel = require('localtunnel');
(async () => {
  const tunnel = await localtunnel({ 
      subdomain: subdomain, 
      port: 3000
    });
  console.log(`App available at: ${tunnel.url}`);
})();
```

You can now start the server by running, in the terminal, the following command:

```
node server.js
```

A notice will be displayed telling you the server is now available:

```
App available at: https://SUBDOMAIN.loca.lt
```

### Create a Vonage Application

In this step, you will create a Vonage [Application](https://developer.vonage.com/conversation/concepts/application) capable of in-app voice communication use cases.

Open a new terminal and, if required, navigate to your project directory.

Create a Vonage application by copying and pasting the command below into the terminal. Make sure to change the values of `--voice_answer_url` and `--voice_event_url` arguments, by replacing `SUBDOMAIN` with the actual value used in the previous step:

```
vonage apps:create "App to Phone Tutorial" --voice_answer_url=https://SUBDOMAIN.loca.lt/voice/answer --voice_event_url=https://SUBDOMAIN.loca.lt/voice/event 
```

A file named `vonage_app.json` is created/updated in your project directory and contains the newly created Vonage Application ID and the private key. A private key file named `app_to_phone_tutorial.key` is also created.

Make a note of the Application ID that is echoed in your terminal when your application is created:

![screenshot of the terminal with Application ID underlined](/content/blog/getting-started-with-flutter-3-and-vonage-apis/vonage-application-created.png)

### Link a Vonage number

Once you have a suitable number you can link it with your Vonage application. Replace `YOUR_VONAGE_NUMBER` with your newly bought number, replace `APPLICATION_ID` with your application id and run this command:

```
vonage apps:link APPLICATION_ID --number=YOUR_VONAGE_NUMBER
```

### Create a User

[Users](https://developer.vonage.com/conversation/concepts/user) are a key concept when working with the Vonage Client SDKs. When a user authenticates with the Client SDK, the credentials provided identify them as a specific user. Each authenticated user will typically correspond to a single user in your user's database.

To create a user named `Alice`, run the following command using the Vonage CLI:

```
vonage apps:users:create "Alice"
```

This will return a user ID similar to the following:

```
User ID: USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab
```

### Generate a JWT

The Client SDK uses [JWTs](https://developer.vonage.com/concepts/guides/authentication#json-web-tokens-jwt) for authentication. The JWT identifies the user name, the associated application ID and the permissions granted to the user. It is signed using your private key to prove that it is a valid token.

Run the following commands, remember to replace the `APPLICATION_ID` variable with the ID of your application and `PRIVATE_KEY` with the name of your private key file.

You are generating a JWT using the Vonage CLI by running the following command but remember to replace the `APP_ID` variable with your own value:

```
vonage jwt --app_id=APPLICATION_ID --subject=Alice --key_file=./PRIVATE_KEY --acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}'
```

The above commands set the expiry of the JWT to one day from now, which is the maximum.

![terminal screenshot of a generated sample JWT](/content/blog/getting-started-with-flutter-3-and-vonage-apis/generated-jwt-key-vonage.png)

We now have everything we need to use the Vonage Voice API within a flutter application. Let's now get the application itself set up.

## Flutter setup

If you haven't already, start by downloading and installing Flutter and its dependencies. You can do this by following the [Install Guide](https://docs.flutter.dev/get-started/install). Once you have Flutter setup correctly the next thing you will need to do is configure your IDE, how to do this will depend on the IDE you wish to use but the [Set up an editor](https://docs.flutter.dev/get-started/editor) guide will help you with this. 

For this guide, we will be using Android Studio. 

Once your IDE is set up follow the [test drive](https://docs.flutter.dev/get-started/test-drive) guide to set up a basic Flutter application with support for both Android and iOS. We will be using this base app as the start of this project, but of course, if you already have a Flutter project you want to use you can do this as well.

## Installing SDKs

With the project now set up we can install the Vonage client SDK. Currently, the Client SDK is not available as a Flutter package, so we will have to use the [Android native Client SDK](https://developer.nexmo.com/client-sdk/setup/add-sdk-to-your-app/android) and the [iOS native Client SDK](https://developer.vonage.com/client-sdk/setup/add-sdk-to-your-app/ios) Communicate between Android/iOS and Flutter will use [MethodChannel](https://api.flutter.dev/flutter/services/MethodChannel-class.html) - this way, Flutter will call Android/iOS methods, Android/iOS will call Flutter methods.

### Android SDK

To install the Android SDK open your project level `build.gradle` file which can be found at `android/build.gradle` and add the following repository:

```
maven {
    url "https://artifactory.ess-dev.com/artifactory/gradle-dev-local"
}
```

So that your all projects repositories now looks like this:

```
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url "https://artifactory.ess-dev.com/artifactory/gradle-dev-local"
        }
    }
}
```

Next, open your app-level `build.gradle` file which can be found at `android/app/build.gradle` and implement the Vonage SDK like so:

```
dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation "com.nexmo.android:client-sdk:4.1.0"
}
```

Finally, make sure your `minSdkVersion` is set to at least `23`:

```
    defaultConfig {
        applicationId "com.vonage.tutorial.voice.app_to_phone"
        minSdkVersion 23
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
```

The Android SDK is now set up and ready to be used for the Android build of the flutter application.

### iOS SDK

To install the iOS SDK start with generating the `PodFile` by opening a command line in the root of your Flutter project and then running the commands below:

```
cd ios/
pod init
```

This will generate the `PodFile`, open this file and add the below pod:

```
pod 'NexmoClient'
```

Make sure to also set the platform to at least ios 10

```
platform :ios, '10.0'
```

Your complete file should look something like this:

```
platform :ios, '11.0'

target 'Runner' do
  use_frameworks!

  pod 'NexmoClient'
end
```

Next from the command line, again in the iOS directory run:

```
pod update
```

This will download and install the Vonage SDK and its dependencies.

Finally to link this to your Flutter project, from the root directory of your project run the below Flutter command. This will trigger an iOS build and generate the files needed to make use of the SDK.

```
flutter build ios
```

Once complete and successfully built your SDK is set up and ready to be used.

## Code

By the nature of Flutter, the code can easily be broken down into three areas, the Flutter code which is written in Dart, the native Android code which is written in Kotlin and the native iOS code which is written in Swift.

### Flutter

Let's start with the flutter specific code, replace the content of `lib/main.dart` with the below code:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: CallWidget(title: 'app-to-phone-flutter'),
    );
  }
}

class CallWidget extends StatefulWidget {
  const CallWidget({Key key = const Key("any_key"), required this.title}) : super(key: key);
  final String title;

  @override
  _CallWidgetState createState() => _CallWidgetState();
}

class _CallWidgetState extends State<CallWidget> {
  SdkState _sdkState = SdkState.LOGGED_OUT;
  static const platformMethodChannel = MethodChannel('com.vonage');

  _CallWidgetState() {
    platformMethodChannel.setMethodCallHandler(methodCallHandler);
  }

  Future<dynamic> methodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'updateState':
        {
          setState(() {
            var arguments = 'SdkState.${methodCall.arguments}';
            _sdkState = SdkState.values.firstWhere((v) {return v.toString() == arguments;}
            );
          });
        }
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  Future<void> _loginUser() async {
    String token = "ALICE_TOKEN";

    try {
      await platformMethodChannel
          .invokeMethod('loginUser', <String, dynamic>{'token': token});
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _makeCall() async {
    try {
      await requestPermissions();

      await platformMethodChannel.invokeMethod('makeCall');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> requestPermissions() async {
    await [ Permission.microphone] .request();
  }

  Future<void> _endCall() async {
    try {
      await platformMethodChannel.invokeMethod('endCall');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 64),
            _updateView()
          ],
        ),
      ),
    );
  }

  Widget _updateView() {
    if (_sdkState == SdkState.LOGGED_OUT) {
      return ElevatedButton(
          onPressed: () { _loginUser(); },
          child: const Text("LOGIN AS ALICE")
      );
    } else if (_sdkState == SdkState.WAIT) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_sdkState == SdkState.LOGGED_IN) {
      return ElevatedButton(
          onPressed: () { _makeCall(); },
          child: const Text("MAKE PHONE CALL")
      );
    } else if (_sdkState == SdkState.ON_CALL) {
      return ElevatedButton(
          onPressed: () { _endCall(); },
          child: const Text("END CALL")
      );
    } else {
      return const Center(
          child: Text("ERROR")
      );
    }
  }
}

enum SdkState {
  LOGGED_OUT,
  LOGGED_IN,
  WAIT,
  ON_CALL,
  ERROR
}
```

This is the complete class needed to build the app's UI and trigger the platform-specific methods which we will write in a moment. Let's break down what's going on in each of the methods in this class.

Starting with the imports at the top of this class, we have the normal flutter imports but we are also using the [permission handler](https://pub.dev/packages/permission_handler/install) package. This is used to manage requesting permissions on iOS and Android for us. Make sure you have installed this by running the command:

```
flutter pub add permission_handler
```

At the root of your flutter project.

Next, we build the app, for this demo we have a very simple app with just one widget element which we have called `CallWidget`

```dart
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: CallWidget(title: 'app-to-phone-flutter'),
    );
  }
}
```

This `CallWidget` extends the `StatefulWidget` taking the title and initialising the `CallWidgetState`.

```dart
class CallWidget extends StatefulWidget {
  const CallWidget({Key key = const Key("any_key"), required this.title}) : super(key: key);
  final String title;

  @override
  _CallWidgetState createState() => _CallWidgetState();
}
```

The `CallWidgetState` will manage the UI elements, the current state of the app and all communication back to the native platform code.

```dart
class _CallWidgetState extends State<CallWidget> {
  SdkState _sdkState = SdkState.LOGGED_OUT;
  static const platformMethodChannel = MethodChannel('com.vonage');

  _CallWidgetState() {
    platformMethodChannel.setMethodCallHandler(methodCallHandler);
  }

  Future<dynamic> methodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'updateState':
        {
          setState(() {
            var arguments = 'SdkState.${methodCall.arguments}';
            _sdkState = SdkState.values.firstWhere((v) {return v.toString() == arguments;}
            );
          });
        }
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }
```

Here we set the starting state of the app as `SdkState.LOGGED_OUT`, we create the `MethodChannel` which will handle all communication between Flutter and native code. Then we go on to set the `methodCallHandler` in which the state is set to whatever state has been passed back up to Flutter from the native code. 

The UI is then built up using the `build` method, which simply created a `Box` that is of height 64. We will update this element depending on the app's state to display different information.

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 64),
            _updateView()
          ],
        ),
      ),
    );
  }
```

Next, the `_updateView` method is used to change what is currently displayed in the box based on the current state of the app. This state model allows for a clean UI only showing the user what they need to see at any given time in the app life cycle.

```dart
  Widget _updateView() {
    if (_sdkState == SdkState.LOGGED_OUT) {
      return ElevatedButton(
          onPressed: () { _loginUser(); },
          child: const Text("LOGIN AS ALICE")
      );
    } else if (_sdkState == SdkState.WAIT) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_sdkState == SdkState.LOGGED_IN) {
      return ElevatedButton(
          onPressed: () { _makeCall(); },
          child: const Text("MAKE PHONE CALL")
      );
    } else if (_sdkState == SdkState.ON_CALL) {
      return ElevatedButton(
          onPressed: () { _endCall(); },
          child: const Text("END CALL")
      );
    } else {
      return const Center(
          child: Text("ERROR")
      );
    }
  }
```

The _loginUser and _endCall methods are very similar in that all we are doing here is invoking the loginUser/endCall methods in the native code. This is how we trigger the native code when the user presses a button on the UI. Within the `_loginUser` we have a variable `token` this should be the JWT value you generated earlier using the Vonage CLI

```dart
Future<void> _loginUser() async {
    String token = "ALICE_TOKEN";

    try {
      await platformMethodChannel
          .invokeMethod('loginUser', <String, dynamic>{'token': token});
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _endCall() async {
    try {
      await platformMethodChannel.invokeMethod('endCall');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
```

The `_makeCall` method also involved a method on the native code, calling the `makeCall` method. However, before it does that we use the `requestPermissions` method to request the required run time permissions from the user. In this case that is just the microphone/audio recording.

```dart
Future<void> _makeCall() async {
    try {
      await requestPermissions();

      await platformMethodChannel.invokeMethod('makeCall');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> requestPermissions() async {
    await [ Permission.microphone] .request();
  }
```

And finally, we have a enum which holds the different states that the SDK and the app can be in.

```dart
enum SdkState {
  LOGGED_OUT,
  LOGGED_IN,
  WAIT,
  ON_CALL,
  ERROR
}
```

### Android

Next, let's take a look at the Android-specific code for this application. First, we need to set up the permissions that the app will need from the Android system. 
In your `AndroidManifest.xml` which is located at `android/app/src/main/AndroidManifest.xml` add the below permissions:

```xml
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
```

Next let's open the `MainActivity.kt` file which can be located at `android/app/src/main/kotlin/PACKAGE_NAME/MainActivity.kt`

The complete content for this file is as follows: 

```kotlin
import android.annotation.SuppressLint
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import com.nexmo.client.*
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus
import com.nexmo.client.request_listener.NexmoRequestListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var client: NexmoClient
    private var onGoingCall: NexmoCall? = null

    private val callEventListener = object : NexmoCallEventListener {
        override fun onMemberStatusUpdated(callMemberStatus: NexmoCallMemberStatus, callMember: NexmoMember) {
            if (callMemberStatus == NexmoCallMemberStatus.COMPLETED || callMemberStatus == NexmoCallMemberStatus.CANCELLED) {
                onGoingCall = null
                notifyFlutter(SdkState.LOGGED_IN)
            }
        }

        override fun onMuteChanged(mediaActionState: NexmoMediaActionState, callMember: NexmoMember) {}
        override fun onEarmuffChanged(mediaActionState: NexmoMediaActionState, callMember: NexmoMember) {}
        override fun onDTMF(dtmf: String, callMember: NexmoMember) {}
        override fun onLegTransfer(event: NexmoLegTransferEvent?, member: NexmoMember?) {}
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        initClient()
        addFlutterChannelListener()
    }

    private fun initClient() {
        client = NexmoClient.Builder().build(this)

        client.setConnectionListener { connectionStatus, _ ->
            when (connectionStatus) {
                ConnectionStatus.CONNECTED -> notifyFlutter(SdkState.LOGGED_IN)
                ConnectionStatus.DISCONNECTED -> notifyFlutter(SdkState.LOGGED_OUT)
                ConnectionStatus.CONNECTING -> notifyFlutter(SdkState.WAIT)
                ConnectionStatus.UNKNOWN -> notifyFlutter(SdkState.ERROR)
            }
        }
    }

    private fun addFlutterChannelListener() {
        flutterEngine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, "com.vonage").setMethodCallHandler { call, result ->

                when (call.method) {
                    "loginUser" -> {
                        val token = requireNotNull(call.argument<String>("token"))
                        loginUser(token)
                        result.success("")
                    }
                    "makeCall" -> {
                        makeCall()
                        result.success("")
                    }
                    "endCall" -> {
                        endCall()
                        result.success("")
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }
    }

    private fun loginUser(token: String) {
        client.login(token)
    }

    @SuppressLint("MissingPermission")
    private fun makeCall() {
        notifyFlutter(SdkState.WAIT)

        client.serverCall("PHONE_NUMBER", null, object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                onGoingCall = call
                onGoingCall?.addCallEventListener(callEventListener)
                notifyFlutter(SdkState.ON_CALL)
            }

            override fun onError(apiError: NexmoApiError) {
                notifyFlutter(SdkState.ERROR)
            }
        })
    }

    private fun endCall() {
        notifyFlutter(SdkState.WAIT)

        onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                onGoingCall?.removeCallEventListener(callEventListener)
                onGoingCall = null
                notifyFlutter(SdkState.LOGGED_IN)
            }

            override fun onError(apiError: NexmoApiError) {
                notifyFlutter(SdkState.ERROR)
            }
        })
    }

    private fun notifyFlutter(state: SdkState) {
        Handler(Looper.getMainLooper()).post {
            flutterEngine?.dartExecutor?.binaryMessenger?.let {
                MethodChannel(it, "com.vonage")
                    .invokeMethod("updateState", state.toString())
            }
        }
    }
}

enum class SdkState {
    LOGGED_OUT,
    LOGGED_IN,
    WAIT,
    ON_CALL,
    ERROR
}
```

Let's break this down and take a look at what's going on.

The first thing you will notice is that we are extending the class `FlutterActivity` this is a Flutter provided Activity class that handles a lot of the additional lifecycle and Flutter magic that makes it possible to run native code.

Next up we have three variables that we will be using:

```kotlin
    private lateinit var client: NexmoClient
    private var onGoingCall: NexmoCall? = null

    private val callEventListener = object : NexmoCallEventListener {
        override fun onMemberStatusUpdated(callMemberStatus: NexmoCallMemberStatus, callMember: NexmoMember) {
            if (callMemberStatus == NexmoCallMemberStatus.COMPLETED || callMemberStatus == NexmoCallMemberStatus.CANCELLED) {
                onGoingCall = null
                notifyFlutter(SdkState.LOGGED_IN)
            }
        }

        override fun onMuteChanged(mediaActionState: NexmoMediaActionState, callMember: NexmoMember) {}
        override fun onEarmuffChanged(mediaActionState: NexmoMediaActionState, callMember: NexmoMember) {}
        override fun onDTMF(dtmf: String, callMember: NexmoMember) {}
        override fun onLegTransfer(event: NexmoLegTransferEvent?, member: NexmoMember?) {}
    }
```

The `NexmoClient` is the object responsible for all of the SDK interactions, making a phone call, hanging up etc. The `onGoingCall` will be used to keep track of the current phone call while one is happening. Finally, we have a `NexmoCallEventListener` object, this will feedback on any events that happen during a call which we can use to then decide if a call has finished. 
Using the `onMemberStatusUpdated` method we check to see if the call is completed or cancelled. If this is the case we null the `onGoingCall` and send back the state `LOGGED_IN` to Flutter.

Next we override the `configureFlutterEngine` method, this lets us run code when the app is being created by the Flutter engine. Here we use this to run two methods, one to add a channel listener and another to set up the `NexmoClient`.

```kotlin
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        initClient()
        addFlutterChannelListener()
    }
```

Initialising the `NexmoClient` is straightforward thanks to the build method, we simply pass in the current context of the app. Then we create a `ConnectionListener` which will give us the current status of the client, these status maps to values we need to send back to Flutter. So using a when statement we can send the values as required.

```kotlin
    private fun initClient() {
        client = NexmoClient.Builder().build(this)

        client.setConnectionListener { connectionStatus, _ ->
            when (connectionStatus) {
                ConnectionStatus.CONNECTED -> notifyFlutter(SdkState.LOGGED_IN)
                ConnectionStatus.DISCONNECTED -> notifyFlutter(SdkState.LOGGED_OUT)
                ConnectionStatus.CONNECTING -> notifyFlutter(SdkState.WAIT)
                ConnectionStatus.UNKNOWN -> notifyFlutter(SdkState.ERROR)
            }
        }
    }
```

The `addFlutterChannelListener` adds a listener that will watch for any method calls from Flutter. As you can see these relate to the three methods we have in Flutter, this allows us to map these calls to specific methods within the native code.

```kotlin
    private fun addFlutterChannelListener() {
        flutterEngine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, "com.vonage").setMethodCallHandler { call, result ->

                when (call.method) {
                    "loginUser" -> {
                        val token = requireNotNull(call.argument<String>("token"))
                        loginUser(token)
                        result.success("")
                    }
                    "makeCall" -> {
                        makeCall()
                        result.success("")
                    }
                    "endCall" -> {
                        endCall()
                        result.success("")
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }
    }
```

The `loginUser` method is called when Flutter sends the loginUser method call, this passes in the JWT token we set and then triggers the login method on the client.

```kotlin
private fun loginUser(token: String) {
        client.login(token)
    }
```

The `makeCall` method is called when Flutter sends the makeCall method call, this starts a phone call to the specified phone number `"PHONE_NUMBER"` you should replace this with an actual phone number that you wish to call.
Again, here we pass back the state to Flutter depending on if the call is successful and starts or if there is some kind of error.

```kotlin
    private fun makeCall() {
        notifyFlutter(SdkState.WAIT)

        client.serverCall("PHONE_NUMBER", null, object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                onGoingCall = call
                onGoingCall?.addCallEventListener(callEventListener)
                notifyFlutter(SdkState.ON_CALL)
            }

            override fun onError(apiError: NexmoApiError) {
                notifyFlutter(SdkState.ERROR)
            }
        })
    }
```

The `endCall` method is called when Flutter sends the `endCall` method call, this ends the current phone call (if there is one). 

```kotlin
    private fun endCall() {
        notifyFlutter(SdkState.WAIT)

        onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                onGoingCall?.removeCallEventListener(callEventListener)
                onGoingCall = null
                notifyFlutter(SdkState.LOGGED_IN)
            }

            override fun onError(apiError: NexmoApiError) {
                notifyFlutter(SdkState.ERROR)
            }
        })
    }
```

Finally, we have the `nofityFlutter` method, this is where we use the Flutter magic to send back the current state of the application so Flutter can update the UI. Using this we are able to involve the Flutter `updateState` method and pass the current state as a variable.

```kotlin
    private fun notifyFlutter(state: SdkState) {
        Handler(Looper.getMainLooper()).post {
            flutterEngine?.dartExecutor?.binaryMessenger?.let {
                MethodChannel(it, "com.vonage")
                    .invokeMethod("updateState", state.toString())
            }
        }
    }
```

And that's all the native code we need! At this point, we have a functioning Flutter application that we could build for Android and be able to make a phone call from the app to a physical phone.
But before we test the app let's take a look at how we can do the same for iOS.

### iOS

First, we need to set up the audio permissions within iOS, we already have the package in Flutter setup to request them so all we need to do is open the `ios/Runner/info.plist` file and add `Privacy - Microphone Usage Description` key with the value of "`Make a call"`

![Xcode showing the info file selected and pricacy microphone usage description set](/content/blog/getting-started-with-flutter-3-and-vonage-apis/screenshot-2022-05-18-at-14.42.32.png)

Next, open the file `ios/Runner/AppDelegate` this is where we will include the code to interface between flutter and the SDK much in the same way we have already done for Android. The complete code looks like this:

```swift
import UIKit
import Flutter
import NexmoClient

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    enum SdkState: String {
        case loggedOut = "LOGGED_OUT"
        case loggedIn = "LOGGED_IN"
        case wait = "WAIT"
        case onCall = "ON_CALL"
        case error = "ERROR"
    }
    
    var vonageChannel: FlutterMethodChannel?
    let client = NXMClient.shared
    var onGoingCall: NXMCall?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        initClient()
        addFlutterChannelListener()
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func initClient() {
        client.setDelegate(self)
    }
    
    func addFlutterChannelListener() {
        let controller = window?.rootViewController as! FlutterViewController
        
        vonageChannel = FlutterMethodChannel(name: "com.vonage",
                                             binaryMessenger: controller.binaryMessenger)
        vonageChannel?.setMethodCallHandler({ [weak self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
            switch(call.method) {
            case "loginUser":
                if let arguments = call.arguments as? [String: String],
                   let token = arguments["token"] {
                    self.loginUser(token: token)
                }
                result("")
            case "makeCall":
                self.makeCall()
                result("")
            case "endCall":
                self.endCall()
                result("")
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
    
    func loginUser(token: String) {
        self.client.login(withAuthToken: token)
    }
    
    func makeCall() {
        client.serverCall(withCallee: "PHONE_NUMBER", customData: nil) { [weak self] (error, call) in
            guard let self = self else { return }
            
            if error != nil {
                self.notifyFlutter(state: .error)
                return
            }
            
            self.onGoingCall = call
            self.onGoingCall?.setDelegate(self)
            self.notifyFlutter(state: .onCall)
        }
    }
    
    func endCall() {
        onGoingCall?.hangup()
        onGoingCall = nil
        notifyFlutter(state: .loggedIn)
    }
    
    func notifyFlutter(state: SdkState) {
        vonageChannel?.invokeMethod("updateState", arguments: state.rawValue)
    }
}

extension AppDelegate: NXMClientDelegate {
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        switch status {
        case .connected:
            notifyFlutter(state: .loggedIn)
        case .disconnected:
            notifyFlutter(state: .loggedOut)
        case .connecting:
            notifyFlutter(state: .wait)
        @unknown default:
            notifyFlutter(state: .error)
        }
    }
    
    func client(_ client: NXMClient, didReceiveError error: Error) {
        notifyFlutter(state: .error)
    }
}

extension AppDelegate: NXMCallDelegate {
    func call(_ call: NXMCall, didUpdate callMember: NXMMember, with status: NXMCallMemberStatus) {
        if (status == .completed || status == .cancelled) {
            onGoingCall = nil
            notifyFlutter(state: .loggedIn)
        }
    }
    
    func call(_ call: NXMCall, didUpdate callMember: NXMMember, isMuted muted: Bool) {
        
    }
    
    func call(_ call: NXMCall, didReceive error: Error) {
        notifyFlutter(state: .error)
    }
}
```

This is all the code you will need to also be able to build for iOS, now that we have all the code in place let's build the app and test it out!

## Build and Test

With everything now in place we can build and run the application, we will build the Android version and run it in the Android emulation.

**NOTE** make sure you have set the JWT in the Flutter code and the PHONE_NUMBER in the native code. Also, make sure your web server is still running.

Start the Android emulator so that flutter can attach to it, below is where you can do this in Android studio

![Android studio with device manager selected](/content/blog/getting-started-with-flutter-3-and-vonage-apis/screenshot-2022-05-18-at-16.24.37.png)

Once this is running you can select this device as the target for the Flutter build and press the green arrow to build and run the Flutter app (with Android native code).

![android studio with emulator selected and main.dart](/content/blog/getting-started-with-flutter-3-and-vonage-apis/screenshot-2022-05-18-at-16.24.53.png)

Once the application has build and installed you will be presented with the below left screen. Clicking the Login as Alice button will take you to the next screen. From here you can press the Make phone call button which will (on the first run) prompt you to allow the audio permissions. After this the phone call will start and the phone number you entered will be called connecting the audio session.

Once you wish to finish the call you can do so by pressing the end call button.

![The four UI screens of the app, from right to left. The App startup screen, the logged in screen, the permission request screen and finally the in call screen](/content/blog/getting-started-with-flutter-3-and-vonage-apis/app-screens.png)

And that's a wrap! You now have your fully functional app to phone call written in Flutter with support for both Android and iOS. But of course, this is not the end! With your knowledge of how to use Android and iOS SDKs take a look at the other [example projects](https://github.com/nexmo-community/client-sdk-tutorials) which will help you build other communication features into your Flutter application. If you want more detail make sure to check out the [developer portal](https://developer.vonage.com/) which has all the documentation and sample code you could ever need!
