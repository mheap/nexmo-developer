---
title: Make a Call
description: How to make an in-app or server-managed call.
navigation_weight: 5
---

# Make a Call

## Overview

This guide covers the functionalities in your Vonage Client application, in order to start in-app or server-managed voice calls.

Before you begin, make sure you [added the SDK to your app](/client-sdk/setup/add-sdk-to-your-app).

## Start an In-App Call

The quickest way to start an in-app call is by conducting an in-app to in-app call, meaning between two users.

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/guides/make-call/in-app'
frameless: false
```

The possible voice capabilities are very limited, as this doesn't utilize [the Voice API](/voice/voice-api/overview). This method is recommended mostly for onboarding. Later, it is recommended to use a server managed call.

## Start a Server Managed Call

This method allows you to conduct in-app calls as well as phone calls while taking advantage of the rich [Voice API features](/voice/voice-api/overview).

When your client app calls this method, the `answer_url` [webhook](/concepts/guides/webhooks) that is configured for your [Vonage Application](/concepts/guides/applications) will execute. That defines the [logic and capabilities](/voice/voice-api/ncco-reference) of the call.

On the client side, start the call as such:

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/guides/make-call/server-managed'
frameless: false
```
### Custom Data

The server call method has a parameter for custom data. This allows you to pass additional context in a key-value format to the server running your `answer_url`. 

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/guides/make-call/custom-data'
frameless: false
```

The data will be available on the request's query made to your `answer_url` server:

```json
{
  "to": "447000000000",
  "from_user": "Alice",
  "conversation_uuid": "CON-8dd32088-66be-42ae-b0af-c9e12ca588ed",
  "uuid": "54c255ca-9c1c-4ecd-b175-a1d022dc7b07",
  "custom_data": {
      "device_name": "Alice app"
    }
}
```

## Listen For Call Events

To see updates on the state of a call, for example, to know if the other member answered or hung up the call, you should listen to call events.

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/guides/make-call/listen-to-call-events'
frameless: false
```

## Reference

* [Client SDK Reference - Web](/sdk/client-sdk/javascript)
* [Client SDK Reference - iOS](/sdk/client-sdk/ios)
* [Client SDK Reference - Android](/sdk/client-sdk/android)
* [Client SDK Samples - Android](https://github.com/nexmo-community/client-sdk-android-samples)