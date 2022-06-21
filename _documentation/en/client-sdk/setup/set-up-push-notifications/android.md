---
title: Android
language: android
---

# Overview

On incoming events such as a new message, or an incoming call, the user often expects to receive a push notification. If the app is not active (it is in the background), push notifications are the only way to notify app about new events.

This guide explains how to configure your Android app to receive push notifications from the Client SDK.

## Connect Vonage to Firebase

To receive push notifications you need to connect Vonage with Firebase. To do so, you will need the following:

1. Your Vonage Application ID
1. Your Vonage Application's private key (upload tool method) or a Vonage admin JWT (terminal method)
1. Your Firebase project ID
1. Your Firebase server key

### Get a Vonage application ID

Obtain your Vonage API Application id. You can access the existing applications in the [dashboard](https://dashboard.nexmo.com/voice/your-applications). If you don't have an application already you can create a new application via [Vonage CLI](/client-sdk/setup/create-your-application).

### Get a Firebase Project ID

Get your Firebase project id from the [Firebase console](https://console.firebase.google.com/). Navigate to `Firebase console -> Project settings -> General`.

![Displaying the project settings location](/screenshots/setup/client-sdk/set-up-push-notifications/firebase-project-settings.png)

![Displaying the project ID location](/screenshots/setup/client-sdk/set-up-push-notifications/firebase-project-id.png)

### Get a Firebase Server Key

Get your Firebase Server Key from the [Firebase console](https://console.firebase.google.com/). Navigate to `Firebase console ->  Project settings -> Service accounts` and generate a new private key. 

![Displaying the project settings location](/screenshots/setup/client-sdk/set-up-push-notifications/firebase-project-settings.png)

![Displaying the server key location](/screenshots/setup/client-sdk/set-up-push-notifications/firebase-token.png)

## Connect your Vonage Application to Firebase

You connect Vonage with your Firebase application by making a POST request. You can to this request using the Upload Tool or making a POST request directly.

### Using the Upload Tool

The Android Push Certificate Uploading Tool, available on [GitHub](https://github.com/nexmo-community/android-push-uploader), allows you to upload with a user interface.

To use the tool you will need to run it locally or deploy it. You can follow the the instructions in the GitHub project's [README](https://github.com/nexmo-community/android-push-uploader#running-the-project). 

Once you have the tool running, enter your Vonage Application ID, private key file, Firebase project ID, and Firebase server key then click upload. The status of your upload will be shown on the page once it is complete:

![Android Push Certificate Uploading Tool success](/images/client-sdk/push-notifications/android-push-uploader-success.png)

### Using the Terminal

To connect the Vonage backend push service with the Firebase application you need to make a single POST request. Before making request you will have to generate Vonage developer JWT (above upload tool generates this JWT under the hood).

> **NOTE** [JWTs](https://jwt.io) are used to authenticate a user into the Client SDK.

To generate a Vonage admin JWT run the following command. Remember to replace the `VONAGE_APP_ID` with ID of your Vonage application:

```bash
vonage jwt --key_file=./private.key --acl='{"paths":{"/*/users/**":{},"/*/conversations/**":{},"/*/sessions/**":{},"/*/devices/**":{},"/*/image/**":{},"/*/media/**":{},"/*/applications/**":{},"/*/push/**":{},"/*/knocking/**":{},"/*/legs/**":{}}}' --app_id=VONAGE_APP_ID
```

> **NOTE** An admin JWT is a JWT without a sub claim. More details on how to generate a JWT can be found in the [setup guide](/tutorials/client-sdk-generate-test-credentials#generate-a-user-jwt).

Fill `VONAGE_APP_ID`, `VONAGE_JWT`, `FIREBASE_PROJECT_ID` and `FIREBASE_SERVER_KEY` with previously obtained values and run the below command to send the request:

```sh
VONAGE_APP_ID=
VONAGE_JWT=
FIREBASE_PROJECT_ID=
FIREBASE_SERVER_KEY=

curl -v -X PUT \
   -H "Authorization: Bearer $VONAGE_JWT" \
   -H "Content-Type: application/json" \
   -d "{\"token\":\"$FIREBASE_SERVER_KEY\", \"projectId\":\"$FIREBASE_PROJECT_ID\"}" \
   https://api.nexmo.com/v1/applications/$VONAGE_APP_ID/push_tokens/android  
```

> **NOTE** There is no validation at this endpoint. The `200` return code means that Vonage got the data and stored it but hasn't checked that values are valid.

If all the values are correct you should see `200` response code in the terminal.

## Set up Firebase project for your Android application

In order to enable push notifications for your Android application, you need to configure your Android application.

## Configure your Android project 

Let's start with configuring your Android project with the required dependencies.

### Add the Client SDK dependency

[Add the Client SDK](/client-sdk/setup/add-sdk-to-your-app/android) to your project.

### Add Firebase Configuration to your App

Before we set up the push notification-specific configuration there are a few general steps you need to take to set up Firebase within your app. 

> **NOTE** that you can skip this step if your application is already using other Firebase products.

From your Firebase project click on the "add Android app" option:

![Add App getting started screen with options for ios, android, web, unity and flutter](/screenshots/setup/client-sdk/set-up-push-notifications/firebase-add-app.png)

Fill in the displayed form to register your application with the Firebase project

![Form to register your application with your Firebase project, package name is required.](/screenshots/setup/client-sdk/set-up-push-notifications/firebase-add-app-detail.png)

You will then be presented with a "Download google-services.json" button, click this and download the file.

Now switch over to the Project view in Android Studio to see your project root directory.

Move the google-services.json file you downloaded into your Android app module root directory.

![Android studio with project view selected and the google-service.json added in the app module directory](/screenshots/setup/client-sdk/set-up-push-notifications/android_studio_project_panel.png)

Finally, you need to add the Google services plugin, which will load the google-services.json file. Modify your project-level `build.gradle` file to include this:

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/push-notifications/android/google-services-project'
```

And in your App-level `build.gradle` implement the base Firebase BoM

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/push-notifications/android/google-services-app'
```

### Add Firebase Cloud Messaging dependency

In your IDE, in your app level `build.gradle` file (usually `app/build.gradle`), add the `firebase-messaging` dependency:

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/push-notifications/android/dependencies'
```

> **NOTE:** The latest version number can be found on the [Firebase website](https://firebase.google.com/docs/cloud-messaging/android/client#add_firebase_sdks_to_your_app).

### Implement a custom service class to receive push notifications

If you do not have one already, create a class (service) that extends `FirebaseMessagingService`. 

In order for Vonage to be able to send push notifications to a device, the Vonage server has to know the device's `InstanceID`.

In your class that extends [`FirebaseMessagingService`](https://firebase.google.com/docs/reference/android/com/google/firebase/messaging/FirebaseMessagingService),  override `onNewToken()` method and update the `NexmoClient` by passing a new `token`:

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/push-notifications/android/firebase-new-token'
```

Make sure your service is declared in your `AndroidManifest.xml` (typically `app/src/main/AndroidManifest.xml`) by adding `service` tag inside `application` tag:

![Arrow showing the location of the manifest file](/screenshots/tutorials/client-sdk/android-shared/android-manifest-file.png)

```xml
<service android:name=".MyFirebaseMessagingService"
		 android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

### Receive push notifications

Push notifications are received in your implementation of `MyFirebaseMessagingService`, on `onMessageReceived()` method. You can use `NexmoClient.isNexmoPushNotification(message.data))` to determine if the message is sent from Vonage server.

Use `processPushNotification(message.data, listener)` to process the data received from Firebase Cloud Messaging (FCM) into a ready to use object:

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/push-notifications/android/firebase-receive-push-notifications'
```

> **NOTE:** In order to process the push notification and apply any methods on the `NexmoCall` object (for example, answer, hangup, and so on), the `NexmoClient` has to be initialized and the user has to be [logged in](/client-sdk/getting-started/add-sdk-to-your-app/android).

## Configure Push Notification TTL

You can configure the time-to-live (TTL) for push notifications, this will stop stale push notifications being delivered to a device after they are no longer relevant. The default value is 120 seconds. To set the TTL, configure the `NexmoClient`:

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/push-notifications/android/ttl'
```

> Changes to the `NexmoClient` configuration must be done before the first call to `NexmoClient().get()`.

## Putting it all together

Now you can test your push notification setup by calling your app's user. The incoming call will trigger `onIncomingCall` callback as shown above. If you have registered an incoming call listener with `NexmoClient.addIncomingCallListener` elsewhere in your Android app, this listener will take precedence over `onIncomingCall`on the `NexmoPushEventListener`. 

## Conclusion

In this guide you have seen how to set up push notifications. You can also find a sample project that uses the [ConnectionService](https://developer.android.com/reference/android/telecom/ConnectionService) API and push notifications to handle an incoming call using the Android system UI on [GitHub](https://github.com/Vonage-Community/sample-client_sdk-android-connection_service).
