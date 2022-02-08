---
title: Build a Chat App with Lifecycle-Aware Components for Android
description: Learn how to add lifecycle-aware components to a simple Android
  chat app using the Nexmo Stitch Android SDK. The components will help make
  your code easier to maintain.
thumbnail: /content/blog/build-a-chat-app-with-lifecycle-aware-components-for-android-dr/29681523_10214313232718463_78717085_o.jpg
author: chrisguzman
published: true
published_at: 2018-03-28T16:40:29.000Z
updated_at: 2021-05-12T20:03:16.184Z
category: tutorial
tags:
  - android
comments: true
redirect: ""
canonical: ""
---
The Nexmo In-App SDK makes it easy for you to build chat features into your Android apps. When combined with [Android Architecture Components](https://developer.android.com/topic/libraries/architecture/index.html), the Nexmo In-App SDK can help you produce better-organized, easier to maintain, and lighter-weight code. In this post, we're going to take [our first Android quickstart](https://developer.nexmo.com/stitch/in-app-messaging/guides/1-simple-conversation?platform=android) and add lifecycle-aware components so that it's a bit easier to maintain.

If you followed along with the first quickstart, you'll see that we subscribe and unsubscribe to message events in the lifecycle callbacks within our activities. But by adding lifecycle-aware components to our app, we can move the code of dependent components out of the lifecycle methods and into the components themselves.


## Before You Begin

Before we begin you should complete [the first quickstart](https://developer.nexmo.com/stitch/in-app-messaging/guides/1-simple-conversation?platform=android) or you can clone [the source code of the quickstart](https://github.com/Nexmo/conversation-android-quickstart/tree/master/examples/1-simple-conversation). You'll also need to generate a user JWT and retrieve a conversation ID. You can follow the [setup instructions for quickstart 1](https://developer.nexmo.com/stitch/in-app-messaging/guides/1-simple-conversation?platform=android#1-setup) to learn how to generate those.

## Adding Lifecycle-Aware Components

### Set up the dependencies

We'll begin by adding the Google Maven repository. Open the `build.gradle` file for the project and add `google()` like so:

```groovy
//build.gradle
allprojects {
    repositories {
        jcenter()
        google()
    }
}
```

Then we can add the Lifecycles dependency. Let's open the `build.gradle` file for the app and make sure it contains the following dependencies:

```groovy
// app/build.gradle
dependencies {
    implementation "android.arch.lifecycle:extensions:1.1.1"
    annotationProcessor "android.arch.lifecycle:compiler:1.1.1"
}
```

### Implement a `LifecycleObserver`

Currently, the demo app subscribes and unsubscribes from message events in the `ChatActivity`. This works fine for a quickstart to get up and running but if we continue this pattern, our activity can become bloated with too many calls that manage the UI and other components in response to the current state of the lifecycle. So we're going to separate our concerns by creating a class that can monitor the lifecycle of `ChatActivity` by adding annotations to this new class's methods.

Let's make a new class named `StitchListenerComponent` that will implement `LifecycleObserver`. Since our `ChatActivity` is using the `onResume` and `onPause` lifecycle callbacks, we'll make two methods in our `StitchListenerComponent`: `onPause()` and `onResume()`. Then we can annotate those methods with the relevant `@OnLifecycleEvent` annotation. We're also going to create a constructor and member variables so that the `StitchListenerComponent` can handle receiving messages and the `SubscriptionList` that belongs to the `Conversation`.

```java
class StitchListenerComponent implements LifecycleObserver {
  private Conversation conversation;
  private final EditText msgEditTxt;
  private final TextView chatTxt;
  private SubscriptionList subscriptions = new SubscriptionList();

  StitchListenerComponent(Conversation conversation, EditText msgEditTxt, TextView chatTxt) {
      this.conversation = conversation;
      this.msgEditTxt = msgEditTxt;
      this.chatTxt = chatTxt;
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
  void onPause() {

  }

  @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
  void onResume() {

  }
}
```

Then in `ChatActivity` we can observe the lifecycle with the `StitchListenerComponent` class we just created:

```java
//ChatActivity
...
@Override
protected void onCreate(Bundle savedInstanceState) {
  ...
  getLifecycle().addObserver(new StitchListenerComponent(conversation, msgEditTxt, chatTxt));
}
```

### Moving the logic

Now that we've created our custom `LifecycleObserver`, we can move the logic that reacts to changes in lifecycle status from `ChatActivity` to `StitchListenerComponent`. We can remove the `onResume`, `onPause`, `addListener`, and `showMessage` methods from `ChatActivity`. Instead, all of that logic will live in `StitchListenerComponent` like so:

```java
class StitchListenerComponent implements LifecycleObserver {
  //constructor and member variables
  ...

  @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
  void onPause() {
      subscriptions.unsubscribeAll();
      Log.d(TAG, "onPause: Unsubscribe");
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
  void onResume() {
      Log.d(TAG, "onResume: Subscribe to message events");
      conversation.messageEvent().add(new ResultListener<Event>() {
          @Override
          public void onSuccess(Event message) {
              showMessage(message);
          }
      }).addTo(subscriptions);
  }

  private void showMessage(final Event message) {
      if (message.getType().equals(EventType.TEXT)) {
          Text text = (Text) message;
          msgEditTxt.setText(null);
          final String prevText = chatTxt.getText().toString();
          chatTxt.setText(prevText + "\n" + text.getText());
      }
  }
}
```
The methods include some log statements so that you can see for yourself that the methods annotated with `@OnLifecycleEvent` are being called. Open up logcat and check it out!

## See the Chat App in Action

After making the changes detailed in this post, run the app to see it work. The app will still function the same as before, but now it's in a better organized, more maintained state. Future developers working on this app will be grateful! If you'd like to see the app in its final state, you can check out the source code on our [community github page](https://github.com/nexmo-community/stitch-android-lifecycle-components).

## What's Next?

If you'd like to continue learning how to use the Nexmo In-App SDK for Android, check out our quickstarts where we show you how to [invite and chat with another user](https://developer.nexmo.com/stitch/in-app-messaging/guides/2-inviting-members?platform=android) and [use more event listeners](https://developer.nexmo.com/stitch/in-app-messaging/guides/3-utilizing-events?platform=android) to show chat history and when a user is typing. 

If you have more questions about using the Nexmo In-App SDK we encourage you to join the [Nexmo community slack](https://developer.nexmo.com/community/slack/) and check out our [#stitch](https://nexmo-community.slack.com/messages/C9H152ATW) channel or email us directly at [ea-support@nexmo.com](mailto:ea-support@nexmo.com).