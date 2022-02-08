---
title: Reconnecting Calls on Android and iOS
description: This post will cover how to mitigate call connection issues when
  using the Vonage Client SDK for Android and iOS.
thumbnail: /content/blog/reconnecting-calls-on-android-and-ios/reconnecting-calls.jpg
author: abdul-ajetunmobi
published: true
published_at: 2022-01-25T10:51:24.183Z
updated_at: 2022-01-24T13:12:42.354Z
category: tutorial
tags:
  - swift
  - kotlin
  - conversation-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
The Vonage [Client SDK](https://developer.vonage.com/client-sdk/overview) allows you to build applications for iOS, Android, and the Web that feature voice and messaging communications backed by the Vonage [Conversation API](https://developer.vonage.com/conversation/overview).

When building such apps, it is essential to consider how changes in connectivity can affect the app's experience. The typical scenario of being on a cellular connection and reaching home and connecting to WiFi could present challenges as the device switches between the connections. This post will cover how to mitigate such issues when using the Vonage Client SDK for Android and iOS.

## Automatically Reconnecting Calls

Available in SDK versions 3.2.0 and newer, is a new property on the configuration for the Client called `autoMediaReoffer`:

```kotlin
val client = NexmoClient.Builder().autoMediaReoffer(true).build(this)
```

```swift
let config = NXMClientConfig()
config.autoMediaReoffer = true
NXMClient.setConfiguration(config)
```

Setting this to true means the Client will attempt to automatically reconnect a call when there is a change in internet connectivity. The Client also provides a listener in Android and a delegate function in iOS to monitor connectivity changes:

```kotlin
call?.conversation?.addMediaStatusListener(object: NexmoMediaStatusListener {
    override fun onMediaConnectionStateChange(legId: String, status: EMediaConnectionState) {
        // Update UI and/or reconnect
    }
})
```

```swift
call.conversation.delegate = self

func conversation(_ conversation: NXMConversation, onMediaConnectionStateChange state: NXMMediaConnectionStatus, legId: String) {
        // Update UI and/or reconnect
    }
```

Monitoring when the SDK is experiencing changes in connection will allow you to update your app's UI to give feedback to your users. The listener/delegate function has an enum for the state of the connection. The enum has 3 cases:

* Connected - The connection is active and exchanging data.

* Disconnected - The connection has been interrupted. The client will try to reconnect (providing `autoMediaReoffer` is true).

* Closed - The connection is closed and no longer active.

## Recovering Calls or Moving Devices

The Client SDKs now also have the flexibility to allow you to recover a call if your app dies or for you to move a call between devices. The `reconnectCall` function takes a conversation ID and a [leg](https://developer.vonage.com/conversation/concepts/leg) ID and will reconnect your SDK to an existing call:

```kotlin
client.reconnectCall("conversationId", "legId", object : NexmoRequestListener<NexmoCall> {
    override fun onSuccess(result: NexmoCall?) {
        // handle call
    }

    override fun onError(error: NexmoApiError) {
        // handle error
    }
})
```

```swift 
NXMClient.shared.reconnectCall(withConversationId: "", andLegId: "") { error, call in
    if error != nil {
        // handle error
        return
    }
    // handle call
}
```

To recover a call, you can store these two properties in some local storage, and when your app reopens, you can attempt a reconnection. If you are trying to move calls between two devices, you can send the two properties to the new device and reconnect from there. Using `reconnectCall` on the new device will join the call and close the connection on the old device. 

## What Next?

You can read the [guide](https://developer.vonage.com/client-sdk/in-app-voice/guides/reconnect-call) on call reconnection, which has additional code samples in Java and Objective-C. To learn more about the Client SDK, visit [developer.vonage.com](https://developer.nexmo.com/client-sdk/overview).