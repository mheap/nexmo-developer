---
title: Java
language: java
---

# Enable Audio in your Application

In this guide we'll cover adding audio events to the Conversation we have created in the [creating a chat app tutorial](/client-sdk/tutorials/in-app-messaging/introduction/java) guide. We'll deal with sending and receiving media events to and from the conversation.

## Concepts

This guide will introduce you to the following concepts:

- **Audio Leg** - A server side API term. Legs are a part of a conversation. When audio is enabled on a conversation, a leg is created
- **Media Event** - a `NexmoMediaEvent` event that fires on a Conversation when the media state changes for a member

## Before you begin

Run through the [creating a chat app tutorial](/client-sdk/tutorials/in-app-messaging/introduction/java). You will be building on top of this project.

## Add audio permissions

Since enabling audio uses the device microphone, you will need to ask the user for permission. 

Add new entry in the `app/src/AndroidManifest.xml` file (below last `<uses-permission` tag):

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### Request permission on application start

Request permissions inside the `onCreate` method of the `MainActivity` class:

``` java
String[] callsPermissions = { Manifest.permission.RECORD_AUDIO };
ActivityCompat.requestPermissions(this, callsPermissions, 123);
```

## Add audio UI

You will now need to add two buttons for the user to enable and disable audio. Open the `app/src/main/res/layout/activity_main.xml` file and add two new buttons (`enableMediaButton` and `disableMediaButton`) right below `logoutButton` button: 

``` xml
<!--...-->
<Button
        android:id="@+id/enableMediaButton"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        app:layout_constraintBottom_toTopOf="@id/conversationEventsScrollView"
        app:layout_constraintLeft_toLeftOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        android:text="Enable Audio" />

<Button
        android:id="@+id/disableMediaButton"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        app:layout_constraintBottom_toTopOf="@id/conversationEventsScrollView"
        app:layout_constraintLeft_toLeftOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        android:visibility="gone"
        android:text="Disable Audio"
        tools:visibility="visible"/>
<!--...-->
```

Now you need to make sure that these buttons are accessible in the fragment. Add two new properties in the `ChatFragment` class:

```java
private Button enableMediaButton;
private Button disableMediaButton;
```

retrieve the buttons' reference by adding `findViewById` calls in the `onCreate` method:

```java
enableMediaButton = view.findViewById(R.id.enableMediaButton);
disableMediaButton = view.findViewById(R.id.disableMediaButton);
```

Add click event listeners for the buttons, inside the `onCreate` method:

```java
enableMediaButton.setOnClickListener(it -> {
    conversation.enableMedia();
    enableMediaButton.setVisibility(View.GONE);
    disableMediaButton.setVisibility(View.VISIBLE);
});

disableMediaButton.setOnClickListener(it -> {
    conversation.disableMedia();
    enableMediaButton.setVisibility(View.VISIBLE);
    disableMediaButton.setVisibility(View.GONE);
});
```

> **NOTE:** When enabling audio in a conversation establishes an audio leg for a member of the conversation. The audio is only streamed to other members of the conversation who have also enabled audio.

## Display audio events

When enabling media, `NexmoMediaEvent` events are sent to the conversation. To display these events you will need to add a `NexmoMediaEventListener`. Add the `NexmoMediaEventListener` below `addMessageEventListener` inside `getConversation` method:

```java
conversation.addMediaEventListener(new NexmoMediaEventListener() {
    @Override
    public void onMediaEnabled(@NonNull NexmoMediaEvent nexmoMediaEvent) {
        updateConversation(nexmoMediaEvent);
    }

    @Override
    public void onMediaDisabled(@NonNull NexmoMediaEvent nexmoMediaEvent) {
        updateConversation(nexmoMediaEvent);
    }
});
```

Add support of the `NexmoMediaEvent` inside `updateConversationView` method by adding new branch to `if-else` statement:

```java
else if (event instanceof NexmoMediaEvent) {
    NexmoMediaEvent nexmoMediaEvent = (NexmoMediaEvent) event;
    String userName = nexmoMediaEvent.getEmbeddedInfo().getUser().getName();
    line = userName + "media state: " + nexmoMediaEvent.getMediaState();
}
```

## Build and run

Press `Cmd + R` to build and run again. Once logged in you can enable or disable audio. To test it out you can run the app on two different devices.

## Reference

* [Client SDK Reference - Android](/sdk/client-sdk/android)
* [Client SDK Samples - Android](https://github.com/nexmo-community/client-sdk-android-samples)