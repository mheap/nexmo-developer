---
title: Make App-To-Phone Call Using iOS and Flutter
description: "Build iOS application using Flutter and utilise Vonage Client SDK
  to make a call from mobile application to the phone. "
thumbnail: /content/blog/make-app-to-phone-call-using-ios-and-flutter/flutter_inapp-call-2_1200x600.png
author: igor-wojda
published: true
published_at: 2021-04-01T10:52:47.957Z
updated_at: 2021-04-01T10:52:49.721Z
category: tutorial
tags:
  - ios
  - flutter
  - conversation-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Today we will build an `iOS` application using [Flutter](https://flutter.dev/) and utilize [Vonage Client SDK](https://developer.nexmo.com/client-sdk/overview) to make a call from a mobile application to the phone using [Vonage Conversation API](https://www.vonage.com/communications-apis/conversation/). The application will have 3 screens (3 UI states):

![UI states: logon, make a call, and end call](/content/blog/make-app-to-phone-call-using-ios-and-flutter/ui-states.png)

## Prerequisites

The source code for our `Flutter iOS` application is available on [GitHub](https://github.com/nexmo-community/client-sdk-voice-app-to-phone-flutter).

Before we begin building the `Flutter` application for the `iOS` device, we'll need to prepare with the following prerequisites:

* Create a Call Control Object ([NCCO](https://developer.nexmo.com/voice/voice-api/guides/ncco))
* Install the `Vonage CLI` (previously `Nexmo CLI`)
* Setup the `Vonage application`
* Install the `Flutter SDK`
* Create the `Flutter` project

## Vonage Application

### Create An NCCO

A [Call Control Object (NCCO)](https://developer.nexmo.com/voice/voice-api/ncco-reference) is a `JSON` array that we use to control the flow of a `Voice API call`.

The `NCCO` needs to be public and accessible by the internet. To accomplish this, in this tutorial we'll be using [GitHub Gist](https://gist.github.com/) which provides a convenient way to host the configuration. Let's add a new gist:

1. Go to <https://gist.github.com/> (we have to be logged into Github)
2. Create a new gist with `ncco.json` as the filename
3. Copy and paste the following `JSON` object into the gist:

```json
[
    {
        "action": "talk",
        "text": "Please wait while we connect you."
    },
    {
        "action": "connect",
        "endpoint": [
            {
                "type": "phone",
                "number": "PHONE_NUMBER"
            }
        ]
    }
]
```

4. Replace `PHONE_NUMBER` with your phone number ([Vonage numbers are in E.164 format](https://developer.nexmo.com/concepts/guides/glossary#e-164-format), `+` and `-` are not valid. Make sure to specify the country code when entering the number, for example, US: 14155550100 and UK: 447700900001)
5. Click the `Create secret gist` button
6. Click the `Raw` button
7. Take note of the URL shown in the browser, we will be using it in the next step

### Install Vonage CLI

The [Vonage CLI](https://developer.nexmo.com/application/nexmo-cli) allows us to carry out many operations using the command line. If we want to carry out tasks such as creating applications, creating conversations, purchasing Vonage numbers, and so on, we will need to install the Vonage CLI. 

Vonage CLI requires `Node.js`, so we will need to [install Node.js first](https://nodejs.org/en/download/).

To install the Beta version of the CLI with npm, run this command:

```cmd
npm install nexmo-cli@beta -g
```

Set up the `Vonage CLI` to use the Vonage `API Key` and `API Secret`. We can get these from the [settings page](https://dashboard.nexmo.com/settings) in the Dashboard.

Run the following command in the terminal, while replacing `API_KEY` and `API_SECRET` with values from the [Dashboard](https://dashboard.nexmo.com/settings):

```cmd
nexmo setup API_KEY API_SECRET
```

### Setup Vonage Application

1. Create the project directory. Run the following command in the terminal:

```cmd
mkdir vonage-tutorial
```

2. Change into the project directory:

```cmd
cd vonage-tutorial
```

3. Create a Vonage application by copying and pasting the command below into the terminal. Make sure to change the value of `--voice-answer-url` argument by replacing `GIST-URL` with the gist URL from the previous step.

```
nexmo app:create "App to Phone Tutorial" --capabilities=voice --keyfile=private.key --voice-event-url=https://example.com/ --voice-answer-url=GIST-URL
```

Make a note of the `Application ID` that is echoed in the terminal when the application is created.

> NOTE: A hidden file named `.nexmo-app` is created in the project directory and contains the newly created `Vonage Application ID` and the private key. A private key file named `private.key` is also created in the current folder.

### Create User

Each participant is represented by a [User](https://developer.nexmo.com/conversation/concepts/user) object and must be authenticated by the `Client SDK`. In a production application, we would typically store this user information in a database.

Execute the following command to create a user called `Alice`:

```cmd
nexmo user:create name="Alice"
```

### Generate JWT

The `JWT` is used to authenticate the user. Execute the following command in the terminal to generate a `JWT` for the user `Alice`. In the following command replace the `APPLICATION_ID` with the ID of the application:

```
nexmo jwt:generate sub=Alice exp=$(($(date +%s)+86400)) acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}' application_id=APPLICATION_ID
```

The command above sets the expiry of the `JWT` to one day from now, which is the maximum.

Make a note of the `JWT` we generated for `Alice`.

> NOTE: In a production environment, the application should expose an endpoint that generates a `JWT` for each client request.

## Install Xcode

Open AppStore and install [Xcode](https://developer.apple.com/xcode/).

## Flutter Setup

### Install Flutter SDK

Download and install `Flutter SDK`.

This step will vary on `MacOS`, `Win`, and `Linux`, but in general, it boils down to downloading `Flutter SDK` for a given OS, extracting the `Flutter SDK` file, and adding the `sdk\bin` folder to the system `PATH` variable. Detailed instruction for all platforms can be found [here](https://flutter.dev/docs/get-started/install).

Fortunately, `Flutter` comes with a tool that allows us to verify if `SDK` and all required "components" are present and configured correctly. Run this command:

```cmd
flutter doctor
```

`Flutter Doctor` will verify if `Flutter SDK` is installed and other components are installed and configured correctly.

## Create Flutter Project

We will create a `Flutter` project using the terminal:

```cmd
flutter create app_to_phone_flutter
```

The above command creates `app_to_phone_flutter` folder containing the `Flutter` project.

> `Flutter` project contains `ios` folder, which contains the `iOS` project; `android` folder containing the `Android` project; and `web` folder containing `web` project.

Open the `pubspec.yaml` file, and add `permission_handler` dependency (just below `sdk: flutter`):

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  permission_handler: ^6.0.1+1
```

> Indentation matters in `yaml` files, so make sure `permission_handler` is at the same indentation level as the `flutter:` item.

Now run this command (path is the root of the `Flutter` project) to download the above dependency:

```cmd
flutter pub get
```

The above command will also create `Podfile` in `ios` subfolder. Open `ios\Podfile` uncomment `platform` line and update the platform version to `11`:

```
platform :ios, '11.0'
```

At the end of the same file add `pod 'NexmoClient'`:

```
target 'Runner' do
  use_frameworks!
  use_modular_headers!
  pod 'NexmoClient'
```

Open `app_to_phone_flutter/ios` folder in the termnal and install pods:

```cmd
pod install
```

The above command will download all required dependencies including `Flutter`, permissions handler, and `Client SDK`.

Open `Runner.xcworkspace` in `Xcode` and run the app to verify that the above setup was performed correctly.

## Two-way Flutter/iOS Communication

Currently, `Client SDK` is not available as a `Flutter` package, so we will have to use [Android native Client SDK](https://developer.nexmo.com/client-sdk/setup/add-sdk-to-our-app/ios) and communicate between `iOS` and `Flutter` using [MethodChannel](https://api.flutter.dev/flutter/services/MethodChannel-class.html) - this way, `Flutter` will call Android methods, `iOS` will call `Flutter` methods. 

Flutter code will be stored in the `lib/main.dart` file, while `iOS` native code will be stored in the `ios/Runner/AppDelegate.swift` file.

## Init Flutter Application

Flutter applications are built using a programming language called [Dart](https://dart.dev/).

Open `lib/main.dart` file, and replace all of the contents with the following code:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: CallWidget(title: 'app-to-phone-flutter'),
    );
  }
}

class CallWidget extends StatefulWidget {
  CallWidget({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CallWidgetState createState() => _CallWidgetState();
}

class _CallWidgetState extends State<CallWidget> {
  SdkState _sdkState = SdkState.LOGGED_OUT;

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
            SizedBox(height: 64),
            _updateView()
          ],
        ),
      ),
    );
  }

  Widget _updateView() {
    if (_sdkState == SdkState.LOGGED_OUT) {
      return ElevatedButton(
          child: Text("LOGIN AS ALICE")
      );
    }
  }

  Future<void> _loginUser() async {
      // Login user
  }

  Future<void> _makeCall() async {
      // Make call
  }

  Future<void> _endCall() async {
      // End call
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

The above code contains custom `CallWidget` which will be responsible for managing the application state (logging the user and managing the call). The `SdkState` enum represents possible states of Vonage `Client SDK`. This enum will be defined twice - one for the Flutter using `Dart` and one for `iOS` using Swift. The widget contains the `_updateView` method that will change the UI based on the `SdkState` value.

Run the application from the `Xcode`:

![Running the application from xcode](/content/blog/make-app-to-phone-call-using-ios-and-flutter/run-xcode.png)

The `Login as Alice` button should be displayed:

![Logged out screen showing Login as Alice button](/content/blog/make-app-to-phone-call-using-ios-and-flutter/loggedout.png)

### Login Screen

The `Login as Alice` button is disabled so now add `onPressed` handler to the `ElevatedButton` to allow logging in:

```dart
Widget _updateView() {
    if (_sdkState == SdkState.LOGGED_OUT) {
      return ElevatedButton(
          onPressed: () { _loginUser(); },
          child: Text("LOGIN AS ALICE")
      );
    }
  }
```

Update body of `_loginUser` method to communicate with native code and login the user:

```dart
Future<void> _loginUser() async {
    String token = "ALICE_TOKEN";

    try {
      await platformMethodChannel.invokeMethod('loginUser', <String, dynamic>{'token': token});
    } on PlatformException catch (e) {
      print(e);
    }
  }
```

Replace the `ALICE_TOKEN` with the `JWT` token we obtained previously from `Vonage CLI` to authenticate the user `Alice` for the conversation access. `Flutter` will call the `loginUser` method and pass the `token` as an argument. The `loginUser` method is defined in the `MainActivity` class (we will get there in a moment). To call this method from `Flutter` we have to define a `MethodChannel`. Add `platformMethodChannel` field at the top of `_CallWidgetState` class:

Add `platformMethodChannel` field at the top of `_CallWidgetState` class:

```dart
class _CallWidgetState extends State<CallWidget> {
  SdkState _sdkState = SdkState.LOGGED_OUT;
  static const platformMethodChannel = const MethodChannel('com.vonage');
```

The `com.vonage` string represents the unique channel id that we will also refer to the native `iOS` code (`AppDelegate` class). Now we need to handle this method call on the native `iOS` side. 

Open `ios/Runner/AppDelegate` class and `vonageChannel` property that will hold the reference to the `FlutterMethodChannel`:

```swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var vonageChannel: FlutterMethodChannel?
    
...
```

To listen for method calls originating from `Flutter` add `addFlutterChannelListener` method inside `AppDelegate` class (same level as above `application` method):

```swift
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
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
```

The above method "translates" the `Flutter` method calls to methods defined in the `AppDelegate` class (the `loginUser` for now).

And missing the `loginUser` methods inside the same class (we will fill the body soon):

```swift
func loginUser(token: String) {

}
```

Now add `addFlutterChannelListener` method call inside the `application` method:

```swift
override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        addFlutterChannelListener()
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
```

The code is in place - after pressing the `Login As Alice` button the Flutter app will call the `_loginUser` method. Through the `Flutter` platform channel, the method will call the `loginUser` method defined in the `AppDelegate` class.

Run the application from `Xcode` to make sure it is compiling.

Before we will be able to log in user we need to initialize the `Vonage SDK Client`.

### Initialize Client

Open `AppDelegate` class and add the `NexmoClient` import at the top of the file:

```swift
import NexmoClient
```

In the same file add `client` property that will hold a reference to `Vonage Client`.

```swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var vonageChannel: FlutterMethodChannel?
    let client = NXMClient.shared

...
```

Now add `initClient` method to initialize the client:

```swift
func initClient() {
        client.setDelegate(self)
    }
```

To call the `initClient` method from the existing `application` method, we're going to need to add the `initClient()` line as shown in the example below:

```swift
override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        initClient()
        addFlutterChannelListener()
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
```

Before allowing conversation we need to know that the user has correctly logged in. In the `AppDelegate` file add a delegate to listen for `Vonage Client SDK` connection state changes:

```swift
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
}
```

Finally, the `notifyFlutter` method needs to be added to the same class:

```swift
    func client(_ client: NXMClient, didReceiveError error: Error) {
        notifyFlutter(state: .error)
    }
}
```

### Login the User

Modify `loginUser` method body to call `login` on the client instance:

```swift
func loginUser(token: String) {
        self.client.login(withAuthToken: token)
    }
```

This method will allow us to log-in the user (`Alice`) using the `Client SDK` to access the conversation.

### Notify Flutter About Client SDK State Change

To notify `Flutter` of any changes to the state in the `Client SDK`, we'll need to add an `enum` to represents the states of the `Client SDK`. We've already added the equivalent `SdkState` enum in the `main.dart` file. Add the following `SdkState` enum, at the bottom of the `MainActivity.kt` file:

```swift
enum SdkState: String {
        case loggedOut = "LOGGED_OUT"
        case loggedIn = "LOGGED_IN"
        case wait = "WAIT"
        case onCall = "ON_CALL"
        case error = "ERROR"
    }
```

To send these states to `Flutter` (from above delegate) we need to add `notifyFlutter` method in the `AppDelegate` class:

```swift
func notifyFlutter(state: SdkState) {
        vonageChannel?.invokeMethod("updateState", arguments: state.rawValue)
    }
```

Notice that we store the state in the enum, but we are sending it as a string.

### Retrieve SDK State Update By Flutter

To retrieve state updates in `Flutter` we have to listen for method channel updates. Open `main.dart` file and add `_CallWidgetState` constructor with custom handler:

```dart
_CallWidgetState() {
    platformMethodChannel.setMethodCallHandler(methodCallHandler);
  }
```

Inside the same class (`_CallWidgetState`) add the handler method:

```dart
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

These methods receive the "signal" from Android and convert it to an enum. Now update the contents of the `_updateView` method to support `SdkState.WAIT` and `SdkState.LOGGED_IN` states, as shown in the example below:

```dart
Widget _updateView() {
    if (_sdkState == SdkState.LOGGED_OUT) {
      return ElevatedButton(
          onPressed: () { _loginUser(); },
          child: Text("LOGIN AS ALICE")
      );
    }  else if (_sdkState == SdkState.WAIT) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_sdkState == SdkState.LOGGED_IN) {
      return ElevatedButton(
          onPressed: () { _makeCall(); },
          child: Text("MAKE PHONE CALL")
      );
    }
  }
```

During `SdkState.WAIT` the progress bar will be displayed. After successful login application will show the `MAKE PHONE CALL` button.

Run the app and click the button labeled `LOGIN AS ALICE`. The `MAKE PHONE CALL` button should appear, which is another state of the `Flutter` app based on the `SdkState` enum`). An example of this is shown in the image below:

![Make a phone call UI state](/content/blog/make-app-to-phone-call-using-ios-and-flutter/makeaphonecall.png)

### Make A Call

We now need to add functionality to make a phone call. Open the `main.dart` file and update the body of `_makeCall` method as shown below:

```dart
Future<void> _makeCall() async {
    try {
      await platformMethodChannel
          .invokeMethod('makeCall');
    } on PlatformException catch (e) {
      print(e);
    }
  }
```

The above method will communicate with `iOS` so we have to update code in the `AppDelegate` class as well. Add `makeCall` clauses to the `switch` statement inside `addFlutterChannelListener` method:

```swift
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
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
```

Now in the same file add the `onGoingCall` property, which defines if and when a call is ongoing:

```swift
var onGoingCall: NXMCall?
```

> NOTE: Currently the `Client SDK` does not store ongoing call reference, so we have to store it in the `AppDelegate` class. We will use it later to end the call.

Now in the same class add `makeCall` method:

```swift
func makeCall() {
        client.call("IGNORED_NUMBER", callHandler: .server) { [weak self] (error, call) in
            guard let self = self else { return }
            
            if error != nil {
                self.notifyFlutter(state: .error)
                return
            }
            
            self.onGoingCall = call
            self.notifyFlutter(state: .onCall)
        }
    }
```

The above method sets the state of the `Flutter` app to `SdkState.WAIT` and waits for the `Client SDK` response (error or success). Now we need to add support for both states (`SdkState.ON_CALL` and `SdkState.ERROR`) inside `main.dart` file. Update body of the `_updateView` method to show the same as below:

```dart
Widget _updateView() {
    if (_sdkState == SdkState.LOGGED_OUT) {
      return ElevatedButton(
          onPressed: () { _loginUser(); },
          child: Text("LOGIN AS ALICE")
      );
    } else if (_sdkState == SdkState.WAIT) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_sdkState == SdkState.LOGGED_IN) {
      return ElevatedButton(
          onPressed: () { _makeCall(); },
          child: Text("MAKE PHONE CALL")
      );
    } else if (_sdkState == SdkState.ON_CALL) {
      return ElevatedButton(
          onPressed: () { _endCall(); },
          child: Text("END CALL")
      );
    } else {
      return Center(
        child: Text("ERROR")
      );
    }
  }
```

Each state change will result in UI modification. Before making a call the application needs specific permissions to use the microphone. In the next step, we're going to add the functionality in the project to request these permissions.

### Request Permissions

The application needs to be able to access the microphone, so we have to request access to the microphone (`Permission.microphone` for `Flutter` ). 

Open `ios/Runner/info.plist` file and add `Privacy - Microphone Usage Description` key with `Make a call` value:

![Setting add microphone permission](/content/blog/make-app-to-phone-call-using-ios-and-flutter/microphone-permission.png)

We already added the [permission_handler](https://pub.dev/packages/permission_handler) package to the `Flutter` project. Now at the top of the `main.dart` file, we'll need to import the `permission_handler` package as shown in the example below:

```dart
import 'package:permission_handler/permission_handler.dart';
```

To trigger the request for certain permissions, we'll need to add the `requestPermissions()` method within the `_CallWidgetState` class inside the `main.dart` file. So add this new method inside the class:

```dart
Future<void> requestPermissions() async {
    await [ Permission.microphone ].request();
  }
```

The above method will request permissions using `permission_handler`.

In the same class, modify the body of the `_makeCall` class to request permissions before calling the method via the method channel:

```dart
Future<void> _makeCall() async {
    try {
      await requestPermissions();
 
      ...
  }
```

Run the app and click `MAKE PHONE CALL` to start a call. The permissions dialogue will appear and, after granting the permissions, the call will start.

> Reminder: we defined the phone number earlier in the `NCCO`

The state of the application will be updated to `SdkState.ON_CALL` and the UI will be updated:

![On call UI](/content/blog/make-app-to-phone-call-using-ios-and-flutter/oncall.png)

### End Call

To end the call we need to trigger the method on the native `iOS` application using `platformMethodChannel`. Inside `main.dart` file, update the body of the `_endCall` method:

```dart
Future<void> _endCall() async {
    try {
      await platformMethodChannel.invokeMethod('endCall');
    } on PlatformException catch (e) {}
  }
```

The above method will communicate with `iOS`, so we have to update code in the `AppDelegate` class as well. Add `endCall` clauses to the `switch` statement inside the `addFlutterChannelListener` method:

```swift
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
```

Now in the same class add the `endCall` method:

```swift
func endCall() {
        onGoingCall?.hangup()
        onGoingCall = nil
        notifyFlutter(state: .loggedIn)
    }
```

The above method sets the state of the `Flutter` app to `SdkState.WAIT` and waits for the response from the `Client SDK`, which can be either error or success. Both UI states are already supported in the `Flutter` application (`_updateView` method).

We have handled ending the call by pressing the `END CALL` button in the `Flutter` application UI. However, the call can also end outside of the `Flutter` app, e.g. the call will be rejected or answered, and later ended by the callee (on the real phone). 

To support these cases we have to add the `NexmoCallEventListener` listener to the call instance and listen for call-specific events. 

In the `AppDelegares.swift` file add `NXMCallDelegate`:

```swift
extension AppDelegate: NXMCallDelegate {
    func call(_ call: NXMCall, didUpdate callMember: NXMCallMember, with status: NXMCallMemberStatus) {
        if (status == .completed || status == .cancelled) {
            onGoingCall = nil
            notifyFlutter(state: .loggedIn)
        }
    }
    
    func call(_ call: NXMCall, didUpdate callMember: NXMCallMember, isMuted muted: Bool) {
        
    }
    
    func call(_ call: NXMCall, didReceive error: Error) {
        notifyFlutter(state: .error)
    }
}
```

To register above listener modify `onSuccess` callback inside `makeCall` method: 

```swift
func makeCall() {
        client.call("IGNORED_NUMBER", callHandler: .server) { [weak self] (error, call) in
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
```

Run the app and make a phone call from the mobile application to a physical phone number.

# Summary

We have successfully built the application. By doing so we have learned how to make a phone call from a mobile application to the phone using Vonage `Client SDK`. For the complete project please check [GitHub](https://github.com/nexmo-community/client-sdk-voice-app-to-phone-flutter). This project additionally contains the Android native code (`android` folder) allowing us to run this app on Android as well.

To familiarize yourself with other functionalities please check [other tutorials](https://developer.vonage.com/client-sdk/tutorials) and [Vonage developer center](https://developer.vonage.com/).

# References

* [Vonage developer center](https://developer.vonage.com/)
* [Write the first Flutter app](https://flutter.dev/docs/get-started/codelab)
* [Flutter Plaftorm chanels](https://flutter.dev/docs/development/platform-integration/platform-channels)