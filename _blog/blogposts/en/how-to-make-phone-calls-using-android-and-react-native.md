---
title: How to Make Phone Calls Using Android and React Native
description: This blog post will take you through a project, which will show you
  how to use the Vonage Client SDK to build a React Native Android app which
  will call a phone number.
thumbnail: /content/blog/how-to-make-phone-calls-using-android-and-react-native/react_inapp-call_android_1200x600.png
author: abdul-ajetunmobi
published: true
published_at: 2021-04-22T12:01:11.269Z
updated_at: 2021-04-07T15:18:39.999Z
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
This blog post will take you through a project, which will show you how to use the [Vonage Client SDK](https://developer.nexmo.com/client-sdk/overview) to build a [React Native](https://reactnative.dev) Android app which will call a phone number. If you would like to explore using the Client SDK with iOS, check out this [blog post](https://learn.vonage.com/blog/2021/04/20/how-to-make-phone-calls-using-ios-and-react-native/).

## Prerequisites

* [Android Studio](https://developer.android.com/studio), with JDK 8 or newer to build and run the app on an emulator.
* A [GitHub](https://github.com/) account.
* Our Command Line Interface, which you can install with `npm install @vonage/cli -g`.
* [Homebrew](https://brew.sh/) to install the React Native dependencies.

<sign-up number></sign-up>

## Set Up React Native

To build and run a React Native app, you first need to install the dependencies, Node and Watchman. You can do so using Homebrew. In your terminal run:

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

Then change directory into the new folder `cd react-native-app-to-phone`.

Now that you have cloned the project, you can install the project dependencies. You can install the React Native specific dependencies by running `npm install`. This command will install the dependencies listed in the `package.json` file. A dependency you should note is [`react-native-permissions`](https://github.com/zoontek/react-native-permissions), an open-source project that provides a unified way to request permissions on both iOS and Android.

React Native also needs some environment variables to be set up. Edit your `PATH` with:

```sh
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

Once done, load the config into the current shell using the `source` command. You can find more detailed instructions in the [React Native documentation](https://reactnative.dev/docs/environment-setup).

## The Vonage Application

To create the application, we will be using our command-line interface. If you have not set up the CLI yet, do so by running the command `vonage config:set --apiKey=api_key --apiSecret=api_secret` in your terminal, where the API Key and Secret are the API key and secret found on your [account’s settings](https://dashboard.nexmo.com/settings) page.

### Create an NCCO

A [Call Control Object (NCCO)](https://developer.nexmo.com/voice/voice-api/ncco-reference) is a JSON array that you use to control the flow of a Voice API call. The NCCO must be public and accessible by the internet. To accomplish that, you will be using a GitHub Gist that provides a convenient way to host the configuration.

Go to [https://gist.github.com](https://gist.github.com/) and enter `call.json` into the "Filename including extension" box. The contents of the gist will be the following JSON:

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

Create the gist, then click the "Raw" button to get a URL for your NCCO. Keep note of it for the next step.

![ncco raw button](/content/blog/how-to-make-phone-calls-using-android-and-react-native/gist1.png)

### Create a Vonage Application

You now need to create a Vonage Application. An application contains the security and configuration information you need to connect to Vonage. In your terminal, create a Vonage application using the following command replacing `GIST_URL` with the URL from the previous step:

```sh
vonage apps:create "Phone to App Tutorial" --voice_event_url=https://example.com/ --voice_answer_url=GIST-URL 
```

A file named `vonage_app.json` is created in your project directory and contains the newly created Vonage Application ID and the private key. A private key file named `phone_to_app_tutorial.key` is also created. 

### Create a JWT

The Client SDK uses JWTs for authentication. The JWT identifies the user name, the associated application ID and the permissions granted to the user. It is signed using your private key to prove that it is a valid token. Create a user for your application, you can do so by running `vonage apps:users:create Alice` to create a user called Alice. Then create a JWT for the Alice user by running the following command replacing `APP_ID` with your application ID from earlier: 

```sh
vonage jwt --app_id=APP_ID --subject=Alice --key_file=./phone_to_app_tutorial.key --acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}'
```

## Run the Project

First, you will need to prepare an Android device for the project to run on. Open the project's `android` directory in Android Studio. The project will start loading and download the dependencies, including the Client SDK, via the Gradle Sync. You can view the dependencies on the Android app's `build.gradle` file (*android/app/build.gradle*). In the toolbar at the top, look for the AVD Manager button:

![avd manager button](/content/blog/how-to-make-phone-calls-using-android-and-react-native/avd.png)

If you already have an emulator setup, run it. If not, click the *Create Virtual Device* button and go through the wizard. Make sure to create a device with API level 29 or newer as required by React Native.

![emulator](/content/blog/how-to-make-phone-calls-using-android-and-react-native/emulator.png)

With all the dependencies installed and the emulator running, you can now run the project. Start [Metro](https://facebook.github.io/metro) with `npx react-native start`. With that running, open a new terminal window in the same directory and run `npx react-native run-android`. This command will build and run the android project for the emulator you prepared. The app consists of a label showing the connection status, a label to show the call status and an action button.

![android app UI](/content/blog/how-to-make-phone-calls-using-android-and-react-native/ui.png)

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

![android app UI logged in](/content/blog/how-to-make-phone-calls-using-android-and-react-native/login.png)

## How to Communicate With Native Code

### Permissions

As mentioned earlier, the project uses the [`react-native-permissions`](https://github.com/zoontek/react-native-permissions) library to make working with permissions across platforms easier. In the `componentDidMount` function, you can see the extent of the code required in JavaScript to request permissions, along with adding the permission to the `AndroidManifest.xml` file.
:

```javascript
if (Platform.OS === 'ios') {
    request(PERMISSIONS.IOS.MICROPHONE);
} else if (Platform.OS === 'android') {
    request(PERMISSIONS.ANDROID.RECORD_AUDIO);
}
```

### The Client SDK

The Client SDK is a native dependency, so there needs to be a way to communicate between the JavaScript code on `App.tsx` and the native Android code. There are two ways of doing this depending on the direction of the information. [`NativeModules`](https://reactnative.dev/docs/native-modules-intro) expose native classes to JavaScript to allow for you to execute native code. The `NativeEventEmitter` API allows native code to send signals to JavaScript code. Look at the `componentDidMount` function in the `App` class. You can see that the JavaScript code is listening for two different signals, `onStatusChange` and `onCallStateChange`, which will update the UI and action that the button performs. 

```javascript
eventEmitter.addListener('onStatusChange', (data) => {
...
});

eventEmitter.addListener('onCallStateChange', (data) => {
...
});
```

![diagram showing the flow between javascript code and native code](/content/blog/how-to-make-phone-calls-using-android-and-react-native/arch.png)

If you open the `android` directory of the project you will see a class called `EventEmitter` (*android/app/src/main/java/com/rnapptophone/EventEmitter.java*). The `EventEmitter` class has a function that sends the signals to the JavaScript code. 

```java
public void sendEvent(String eventName, @Nullable WritableMap params) {
    this.context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, params);
}
```

These functions are called from the `ClientManager` class (*iandroid/app/src/main/java/com/rnapptophone/ClientManager.java*). The `ClientManager` class is a wrapper around the Client SDK. Both classes extend the `ReactContextBaseJavaModule` class, which requires both subclasses to return a name as a String which is used as the `NativeModules` name. `ClientManager.java` makes use of an annotation, `ReactMethod`. This annotation marks the method to be exposed to JavaScript. For example, here is the login function that you would have used earlier:

```objective_c
@ReactMethod
public void login(String jwt) {
    client.login(jwt);
}
```

This is how it would be called in JavaScript:

```javascript
ClientManager.login("ALICE_JWT")
```

## What Next?

 You can find the complete project on [GitHub](https://github.com/nexmo-community/react-native-app-to-phone), and the  iOS version of this blog on [learn.vonage.com](https://learn.vonage.com/blog/2021/04/20/how-to-make-phone-calls-using-ios-and-react-native/). You can do a lot more with the Client SDK, learn more on [developer.vonage.com](https://developer.nexmo.com/client-sdk/overview).