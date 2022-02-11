---
title: How to Make Phone Calls Using iOS and React Native
description: This blog post will take you through a project, which will show you
  how to use the Vonage Client SDK to build a React Native iOS app which will
  call a phone number.
thumbnail: /content/blog/how-to-make-phone-calls-using-ios-and-react-native/react_inapp-call_ios_1200x600.png
author: abdul-ajetunmobi
published: true
published_at: 2021-04-20T12:28:18.757Z
updated_at: 2021-04-20T12:28:20.233Z
category: tutorial
tags:
  - react-native
  - conversation-api
  - cross-platform
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
This tutorial will show you how to use the [Vonage Client SDK](https://developer.nexmo.com/client-sdk/overview) to build a [React Native](https://reactnative.dev) iOS app with the functionality to call a phone number.

## Prerequisites

* [Xcode 12](https://developer.apple.com/xcode/), to build and run the app on an iOS simulator.
* A [GitHub](https://github.com/) account.
* [Cocoapods](https://cocoapods.org) to install the Vonage Client SDK for iOS.
* Our Command Line Interface, which you can install with `npm install @vonage/cli -g`.
* [Homebrew](https://brew.sh/) to install the React Native dependencies.

<sign-up number></sign-up>

## Set Up React Native

To build and run a React Native app, first, you need to install two dependencies, Node and Watchman. You can do so using Homebrew by running the following in your terminal:

```sh
brew install node
brew install watchman
```

If you already have Node installed, ensure it is Node 12 or newer. You can find more information about getting your environment set up in the [React Native documentation](https://reactnative.dev/docs/environment-setup).

## Clone the Project

You can clone the project to your local machine by running the following command in your terminal: 

```sh
git clone git@github.com:nexmo-community/react-native-app-to-phone.git
```

Then, in your Terminal, change directory into the new folder with the following command:

```sh
cd react-native-app-to-phone
```

Now that the project has been cloned, you can install the project dependencies. You can install the React Native specific dependencies by running `npm install`. This command will install the dependencies listed in the `package.json` file. A dependency you should note is [`react-native-permissions`](https://github.com/zoontek/react-native-permissions), an open-source project that provides a unified way to request permissions on both iOS and Android. You can inspect the iOS dependencies by looking at the `Podfile`. It includes the Client SDK and the required pod for microphone permissions from `react-native-permissions`.

## The Vonage Application

To create the application, we will be using our command-line interface. If you have not set up the CLI yet, do so by running the command nexmo setup API_KEY API_SECRET in your terminal, where the API key and secret are the API key and secret found on your [account’s settings](https://dashboard.nexmo.com/settings) page.

### Create an NCCO

A [Call Control Object (NCCO)](https://developer.nexmo.com/voice/voice-api/ncco-reference) is a JSON array that you use to control the flow of a Voice API call. The NCCO must be public and accessible to the internet. To accomplish this, you will be using a GitHub Gist which provides a convenient way to host the configuration.

Go to [https://gist.github.com](https://gist.github.com/) and enter `call.json` into the "Filename including extension" box. Copy the JSON example below into the contents of the gist:

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
                "user": "447000000000"
            }
        ]
    }
]
```

Create the gist, then click the "Raw" button to get a URL for your NCCO. Keep note of this URL, which is required in the next step.

![ncco raw button](/content/blog/how-to-make-phone-calls-using-ios-and-react-native/gist.png)

### Create a Vonage Application

You now need to create a Vonage Application. An application contains the security and configuration information you need to connect to Vonage. In your terminal, create a Vonage application using the following command replacing `GIST_URL` with the URL from the previous step:

```sh
vonage apps:create "Phone to App Tutorial" --voice_event_url=https://example.com/ --voice_answer_url=GIST-URL 
```

A file named `vonage_app.json` is created in your project directory and contains the newly created Vonage Application ID and the private key. A private key file named `phone_to_app_tutorial.key` is also created. 

### Create a JWT

The Client SDK uses JWTs for authentication. The JWT identifies the user name, the associated application ID, and the permissions granted to the user. It is signed using your private key to prove that it is a valid token. Create a user for your application, you can do so in your Terminal by running the following command: `vonage apps:users:create Alice` to create a user called Alice. Then create a JWT for the Alice user by running the following command replacing `APP_ID` with your application ID from earlier: 

```sh
vonage jwt --app_id=APP_ID --subject=Alice --key_file=./phone_to_app_tutorial.key --acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}'
```

## Run the Project

With all the dependencies installed, you can now run the project. First start [Metro](https://facebook.github.io/metro) with `npx react-native start`. With that running, open a new terminal window in the same directory and run `npx react-native run-ios`. This command will build and run the iOS project in an iOS simulator. When the app loads, you will be prompted to allow microphone permissions then be shown the app. It consists of a label showing the connection status, a label to show the call status and an action button.

![iOS app UI](/content/blog/how-to-make-phone-calls-using-ios-and-react-native/ui.png)

If you open the `App.tsx` folder you can take a look at how this is built in the `render` function:

```javascript
render() {
    return (
      <SafeAreaView>
        <View style={styles.status}>
          <Text>
            {this.state.status}
          </Text>

          <View style={styles.container}>
            <Text style={styles.callState}>
              Call Status: {this.state.callState}
            </Text>
            <Pressable
              style={styles.button}
              onPress={this.state.callAction}>
              <Text style={styles.buttonText}>{this.state.button}</Text>
            </Pressable>
          </View>
        </View>
      </SafeAreaView>
    );
}
```

If you are have used React before, this syntax will be familiar to you.  A `Text` component is used for the labels, a `Pressable` component for the button, along with the styling CSS at the top. All three components make use of [state](https://reactnative.dev/docs/state). State data is parameters for components that will change over time. The state is initialized at the top of the `App` class in the constructor with default information. You can paste the JWT you created in the previous step and save the file (CMD + S). The simulator will reload, and now when you press the login button, the Client SDK will connect. You now will be able to place a phone call. 

![iOS app UI logged in](/content/blog/how-to-make-phone-calls-using-ios-and-react-native/login.png)

## How to Communicate With Native Code

### Permissions

As mentioned earlier, the project uses the [`react-native-permissions`](https://github.com/zoontek/react-native-permissions) library to make working with permissions across platforms easier. In the `componentDidMount` function you can see the extent of the code required in JavaScript to request permissions:

```javascript
if (Platform.OS === 'ios') {
    request(PERMISSIONS.IOS.MICROPHONE);
} else if (Platform.OS === 'android') {
    request(PERMISSIONS.ANDROID.RECORD_AUDIO);
}
```

Along with installing the accompanying iOS code required in the `Podfile`, the usage description also needs to be added to the `info.plist` file. 

### The Client SDK

The Client SDK is a native dependency, so there needs to be a way to communicate between the JavaScript code on `App.tsx` and the native iOS code. There are two ways of doing this depending on the direction of the information. [`NativeModules`](https://reactnative.dev/docs/native-modules-intro) expose native classes to JavaScript to allow for you to execute native code. The `NativeEventEmitter` API allows native code to send signals to JavaScript code. Look at the `componentDidMount` function in the `App` class. You can see that the JavaScript code is listening for two different signals, `onStatusChange` and `onCallStateChange`, which will update the UI and action that the button performs. 

```javascript
eventEmitter.addListener('onStatusChange', (data) => {
...
});

eventEmitter.addListener('onCallStateChange', (data) => {
...
});
```

![diagram showing the flow between javascript code and native code](/content/blog/how-to-make-phone-calls-using-ios-and-react-native/arch.png)

If you open the `ios` directory of the project, you will see a class called `EventEmitter` (*ios/RNAppToPhone/EventEmitter.m*). The `EventEmitter` class exports the supported events and has two functions that send signals to the JavaScript code. 

```objective_c
- (NSArray<NSString *> *)supportedEvents {
  return @[@"onStatusChange", @"onCallStateChange"];
}

- (void)sendStatusEventWith:(nonnull NSString *)status {
  if (_hasListeners) {
    [self sendEventWithName:@"onStatusChange" body:@{ @"status": status }];
  }
}

- (void)sendCallStateEventWith:(nonnull NSString *)state {
  if (_hasListeners) {
    [self sendEventWithName:@"onCallStateChange" body:@{ @"state": state }];
  }
}
```

These functions are called from the `ClientManager` class (*ios/RNAppToPhone/ClientManager.m*). The `ClientManager` class is a wrapper around the Client SDK and conforms to the `NXMClientDelegate`, which has information about the Client's connection status. Both classes feature the `RCT_EXPORT_MODULE` macro, which exports and registers the native module classes with React Native allowing them to be used as `NativeModules`. `ClientManager.m` makes use of an additional macro, `RCT_EXPORT_METHOD`. This macro allows for the method to be called from JavaScript. For example, here is the login function that you would have used earlier:

```objective_c
RCT_EXPORT_METHOD(login:(NSString *)jwt) {
  [ClientManager.shared.client loginWithAuthToken:jwt];
}
```

This is how it would be called in JavaScript:

```javascript
ClientManager.login("ALICE_JWT")
```

## What Next?

In this tutorial, we've learned how to build an iOS app with the React Native framework. We've also added functionality to make a phone call to a physical phone number. You can find the complete project on [GitHub](https://github.com/nexmo-community/react-native-app-to-phone), and the Android version of this blog on [learn.vonage.com](https://learn.vonage.com/blog/2021/04/22/how-to-make-phone-calls-using-android-and-react-native/).

Below are a few other tutorials or documentation referencing the Conversation API:

* [NCCO reference](https://developer.nexmo.com/voice/voice-api/ncco-reference)
* [Client SDK](https://developer.nexmo.com/client-sdk/overview)
* [Building a Drop-in Audio App With SwiftUI and Vapor - Part 1](https://learn.vonage.com/blog/2021/03/02/building-a-drop-in-audio-app-with-swiftui-vapor-and-vonage-part-1/)

As always, if you have any questions, advice or ideas you’d like to share with the community, then please feel free to jump on our [Community Slack workspace](https://developer.nexmo.com/community/slack). I'd love to hear how you've gotten on with this tutorial and how your project works.