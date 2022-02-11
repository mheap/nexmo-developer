---
title: How to Make Phone Calls on Web, iOS and Android with Ionic
description: Learn how to use the Vonage Client SDK to build an Ionic app that
  lets you call a phone number.
thumbnail: /content/blog/how-to-make-phone-calls-on-web-ios-and-android-with-ionic/voice-calls_ionic_1200x600.png
author: abdul-ajetunmobi
published: true
published_at: 2021-05-19T10:36:11.665Z
updated_at: 2021-05-10T09:57:11.749Z
category: tutorial
tags:
  - ionic
  - conversation-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
This blog post takes you through a project that showcases how to build an [Ionic](https://ionicframework.com) app that lets you make a call across three platforms using the [Vonage Client SDK](https://developer.nexmo.com/client-sdk/overview). The project for this blog post uses [React](https://reactjs.org).

## Prerequisites

* A [GitHub](https://github.com) account.
* [Xcode 12](https://developer.apple.com/xcode/), to build and run the app on an iOS simulator.
* [Android Studio](https://developer.android.com/studio), with JDK 8 or newer to build and run the app on an emulator.
* Our Command Line Interface, which you can install with `npm install @vonage/cli -g`.

<sign-up></sign-up>

## Set Up Ionic

Ionic can be installed with npm but requires [Node.js](https://nodejs.org). Ensure that you have Node.js installed before continuing. Install Ionic with the following command:

`npm install -g @ionic/cli`

## Clone the Project

You can clone the project to your local machine by running the following command in your terminal:

`git clone git@github.com:nexmo-community/ionic-app-to-phone.git`

Then change directory into the new folder `cd ionic-app-to-phone`.

Now that you have cloned the project, you can install the project dependencies by running `npm install`. This command will install the dependencies listed in the `package.json` file. Note the `nexmo-client` listed; this is the Client SDK. 

Ionic also needs some environment variables to be set up for Android development. Edit your `PATH` with:

```sh
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/tools/bin
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
```

Once done, load the config into the current shell using the `source` command. You can find more detailed instructions in the [Ionic documentation](https://ionicframework.com/docs/developing/android#configuring-command-line-tools).

## The Vonage Application

To create the application, we will be using our command-line interface. If you have not set up the CLI yet, do so by running the command `vonage config:set --apiKey=api_key --apiSecret=api_secret` in your terminal, where the API Key and Secret are the API key and secret found on your [account’s settings](https://dashboard.nexmo.com/settings) page.

### Create an NCCO

A [Nexmo Call Control Object (NCCO)](https://developer.nexmo.com/voice/voice-api/ncco-reference) is a JSON array that you use to control the flow of a Voice API call. The NCCO must be public and accessible by the internet. To accomplish that, you will be using a GitHub Gist that provides a convenient way to host the configuration.

Go to https://gist.github.com/ and enter `call.json` into the "Filename including extension" box. The contents of the gist will be the following JSON:

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

![ncco raw button](/content/blog/how-to-make-phone-calls-on-web-ios-and-android-with-ionic/gist.png)

### Create a Vonage Application

You now need to create a Vonage Application. An application contains the security and configuration information you need to connect to Vonage. In your terminal, create a Vonage application using the following command replacing `GIST_URL` with the URL from the previous step:

```sh
vonage apps:create "App to Phone Tutorial" --voice_event_url=https://example.com/ --voice_answer_url=GIST-URL 
```

file named `vonage_app.json` is created in your project directory and contains the newly created Vonage Application ID and the private key. A private key file named `app_to_phone_tutorial.key` is also created. 

### Create a JWT

The Client SDK uses JWTs for authentication. The JWT identifies the user name, the associated application ID and the permissions granted to the user. It is signed using your private key to prove that it is a valid token. Create a user for your application, you can do so by running `vonage apps:users:create Alice` to create a user called Alice. Then create a JWT for the Alice user by running the following command replacing `APP_ID` with your application ID from earlier: 

```sh
vonage jwt --app_id=APP_ID --subject=Alice --key_file=./app_to_phone_tutorial.key --acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}'
```

## Run the Project

Now that you have set up the Vonage application, you can make some calls.

### Web

The first platform that you will run the project on is the Web. To do so, edit the `Home.tsx` file (*/ionic-app-to-phone/src/pages/Home.tsx*) by replacing `ALICE_JWT` with the JWT you generated earlier. 

Once done, run the project from your terminal using `ionic serve`. This command will start a local server on your machine on port 8100 and open the app in your web browser. Click the login button, which uses the JWT to authenticate the Client SDK. Once logged in, you can now make a call to the phone number specified in the NCCO.

![web log in interface](/content/blog/how-to-make-phone-calls-on-web-ios-and-android-with-ionic/web.png)

### iOS

Ionic uses [Capacitor](https://capacitorjs.com) to build the web app you just used for native platforms. Keep the Ionic development server running in your terminal and open a new terminal window in the same directory. The iOS and Android apps require the development server to be available via HTTPS, so you can use [localtunnel](https://github.com/localtunnel/localtunnel) to create an HTTPS URL. Enter the following command into your terminal, replacing `SUBDOMAIN` with a unique string: 

`npx localtunnel --port 8100 --subdomain=SUBDOMAIN`

This command will open a tunnel to your machine's port 8100. 

Building a native project with Capacitor happens in 3 stages. First, the web code is built. Next, the code is copied to each platform then platform-specific tools are used to build the app.  
Open a new terminal window in the same directory. You can do the first stage and second stage with `ionic capacitor sync ios`. Then run the iOS project using Capacitor, replacing `SUBDOMAIN` with your unique string:

`ionic capacitor run ios -l --external --livereload-url=https://SUBDOMAIN.loca.lt`

This command opens Xcode for you and enables live reload of the code. Build and Run (CMD + R) in Xcode, and when the app is running on the simulator/device you pick, you can log in and make a call, the same as on the web. 

![ios idle interface](/content/blog/how-to-make-phone-calls-on-web-ios-and-android-with-ionic/ios.png)

Since Ionic is web-based, the iOS app can use the same Client SDK JavaScript dependency and works with no platform-specific code changes.

### Android

The process for android is very similar to iOS. In your terminal window running the iOS project, quit the process with Ctrl+C, then run `ionic capacitor sync android`. Then run the Android project using Capacitor, replacing `SUBDOMAIN` with your unique string:

`ionic capacitor run android -l --external --livereload-url=https://SUBDOMAIN.loca.lt`

This command will open Android Studio for you, where you can Build and Run the app on an emulator or device. When the app runs on the emulator/device you pick, you can log in and make a call, the same as on the web and iOS without any code changes.

![android calling interface](/content/blog/how-to-make-phone-calls-on-web-ios-and-android-with-ionic/android.png)

## What Next?

You can find the complete project on [GitHub](https://github.com/nexmo-community/ionic-app-to-phone.git). You can do a lot more with the Client SDK, learn more on [developer.vonage.com](https://developer.nexmo.com/client-sdk/overview).
