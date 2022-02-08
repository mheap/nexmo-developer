---
title: Introducing Custom Channels in Conversations
description: The Conversation API and associated Client SDKs now support the
  ability to use custom channels, find out more about how to integrate them.
thumbnail: /content/blog/introducing-custom-channel-in-conversations-dr/E_Client-SDK-Update_1200x600.png
author: brittbarak
published: true
published_at: 2020-02-05T08:28:27.000Z
updated_at: 2021-04-27T20:09:06.128Z
category: announcement
tags:
  - client-sdk
  - conversations
comments: true
redirect: ""
canonical: ""
---
At Vonage, we are committed to building the most robust, flexible and scalable platforms possible so that you can continue creating great conversation experiences for your users. With that in mind, we're happy to announce a new sibling for in-app voice and messages channels: Custom Channels! 

Using custom events, you can create a custom integration with any channel you can imagine. For example, other [messaging platforms](https://www.nexmo.com/blog/2019/11/01/integrating-the-conversation-api-with-wechat-dr), [emails](https://developer.nexmo.com/use-cases/client-sdk-sendinblue-order-confirm), or [payments](https://developer.nexmo.com/use-cases/digital-marketplace-client-sdk). 

## How It Works:

### 1. Defining the `Custom Event` Object
A custom event has a `type` and a `body`. The `type` is your chosen name for the custom channel, which starts with the key `"custom:"`. The `body` is key-value pairs that define the data you'd like to pass in the event.

### 2. Sending Custom Events 
You can send custom events to a Conversation through [Conversations API](https://developer.nexmo.com/conversation/code-snippets/event/create-custom-event), or Client SDKs.

When sending an event through the Android or iOS SDKs, the `"custom:"` prefix for the event type is automatically added on your behalf.

Below are examples of how this can be achieved using the three supported [Client SDKs](https://developer.nexmo.com/client-sdk/overview).


#### Android

```java
var sendListener: NexmoRequestListener<Void> = object: NexmoRequestListener<Void> {
    override fun onError(error: NexmoApiError) {...}
    override fun onSuccess(var1: Void?) {...}
}

conversation.sendCustomEvent("my_type", hashMapOf("myKey" to "myValue"), sendListener)
```

#### iOS

```swift
conversation.sendCustom(withEvent: "my_type", data: ["myKey": "myValue"], completionHandler: { (error) in
    if let error = error {...}
    NSLog("Custom event sent.")
})
```

#### JavaScript

```javascript
conversation.sendCustomEvent({ type: 'custom:my_type', body: { myKey: 'myValue' }}).then((custom_event) => { ... });
```

### 3. Receiving Custom Events
Receiving a custom event is similar to receiving any other event in you’ll receive it on your application's RTC `event_url`.
 
In our three supported Client SDKs, you'll receive it as shown below:


#### Android
```java
var customEventListener: NexmoCustomEventListener = NexmoCustomEventListener { event ->
    Log.d(TAG, "Received custom event with type " + event.customType + ": " + event.data)
}

conversation.addCustomEventListener(customEventListener)
```

#### iOS
```swift
//In `NXMConversationDelegate`:

func conversation(_ conversation: NXMConversation, didReceive event: NXMCustomEvent) {
    NSLog("Received custom event with type \(String(describing: event.customType)): \(String(describing: event.data))");
}
```

#### JavaScript
```javascript
conversation.on('custom:my_type', (from, event) => {
  console.log(event.body);
});
```


### 4. Sending Push Notifications 
If your Android or iOS application is running in the background, you might want to notify your user about an incoming custom event with a push notification.

To do that, you must define the payload to send per push notification on a per type basis:

`PUT https://api.nexmo.com/v2/applications/:your_nexmo_application_id`

```json
{
	"capabilities": {
		"rtc": {
			...
			"push_notifications": {
				"custom:my_type": {
					enabled: true,
					template: {
						notification: {
						body: "Value sent: '${event.body.my_key}' !”
					},
					data: {
						image: "https://example.image.jpg",
                                                myKey: myValue
					}
				}
			}
		}
	}
}
```

### 5. Receiving Push Notification

After [setting up push notifications](https://developer.nexmo.com/client-sdk/setup/set-up-push-notifications) for your mobile apps, you’re ready to receive your custom push. You can access the custom data that you previously defined as follows:

#### Android
```java
if (NexmoClient.isNexmoPushNotification(message!!.data)) {  
    NexmoPushPayload nexmoPushPayload = nexmoClient.processPushPayload(message!!.data, pushListener)
    when(nexmoPushPayload.pushTemplate){
        Custom ->
            nexmoPushEvent.customData //got custom push data 😀
        Default ->
            nexmoPushEvent.eventData // got default push event data
    }
}
``` 

#### iOS
```ios
NSDictionary* pushData = [get the payload];
 
if ([NXMClient.shared.isNexmoPush:pushData]) {
    NXMPushPayload nexmoPushPayload = [NXMClient.shared processPushPayload:pushData];
  
    if (nexmoPushPayload.template == NXMPushTemplateCustom){
        nexmoPushEvent.customData //got custom push data 😀
    }
    if (nexmoPushPayload.template == NXMPushTemplateDefault){
        nexmoPushEvent.eventData // got default push event data
    }
}
``` 


## Integration Complete 
You now have all you need to a custom channel with custom push notifications into your conversation experiences. We can't wait to see which channels you’ll add and how you'll use them to enrich your user's conversation with you!

## What's Next?
* Check out the full guides custom events guides for [Conversations API](https://developer.nexmo.com/conversation/code-snippets/event/create-custom-event) and for [Client SDKs](https://developer.nexmo.com/client-sdk/custom-events). 
* Find examples for custom channel integrations with [WeChat](https://www.nexmo.com/blog/2019/11/01/integrating-the-conversation-api-with-wechat-dr), [SendinBlue emails](https://developer.nexmo.com/use-cases/client-sdk-sendinblue-order-confirm), or [payments with Stripe](https://developer.nexmo.com/use-cases/digital-marketplace-client-sdk).
* Explore more Conversations [API](https://developer.nexmo.com/conversation/overview) and [Client SDK](https://developer.nexmo.com/client-sdk/overview) features in our public documentation.


Should you have any questions or feedback - let us know on our [Community Slack](https://developer.nexmo.com/community) or support@nexmo.com
