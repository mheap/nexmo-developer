---
title: First Look at the Nexmo Messages and Dispatch APIs
description: We moved the Nexmo Messages API and Dispatch API out of developer
  preview and officially into Beta.
thumbnail: /content/blog/nexmo-messages-dispatch-apis-dr/Olympus-Beta-tech2-3.png
author: martyn
published: true
published_at: 2018-10-10T13:01:50.000Z
updated_at: 2021-04-19T13:49:40.554Z
category: announcement
tags:
  - messaging-api
  - mms
  - sms
comments: true
redirect: https://www.nexmo.com/legacy-blog/2018/10/10/nexmo-messages-dispatch-apis-dr
canonical: https://www.nexmo.com/legacy-blog/2018/10/10/nexmo-messages-dispatch-apis-dr
---
Today we moved the Nexmo Messages API and Dispatch API out of developer preview and officially into Beta.

That's great for us but what does it mean for you? Well, in short, we're now able to offer you the ability to send messages via Facebook Messenger, WhatsApp, Viber, SMS and MMS using just one API.

Better still, we've built in the ability to create fallbacks, so if your message isn't read on one channel then you can send a backup to another one, or switch to SMS/MMS ensuring that the information you need to convey always gets read.

Let's take a deeper look into how you can work with these two new APIs.

## Messages and Dispatch Architecture

This powerful combination of APIs can be used both independently or in unison depending on what you are trying to achieve.

There are two APIs at play here. The [Messages API](https://developer.nexmo.com/messages/overview) which handles the sending of any messages to the desired service, and the [Dispatch API](https://developer.nexmo.com/dispatch/overview) which is used to build *failover templates* of messages based on delivery events, such as read receipts.

![Messages API and Dispatch API Overview](/content/blog/first-look-at-the-nexmo-messages-and-dispatch-apis/messages-dispatch-overview-1.png)



## Sending a Message with the Messages API

Currently, there are two ways to use the Messages API. Either by making requests [directly to the API endpoints](https://developer.nexmo.com/api/messages-olympus), or by using the Beta release of our [Node JS client library](https://github.com/Nexmo/nexmo-node/tree/beta).

For the following examples, we'll be using NodeJS. Let's start by taking a look at the code needed to send a message via Facebook Messenger.

```javascript
const Nexmo = require('nexmo');

const nexmo = new Nexmo({
  ... // API credentials
});

nexmo.channel.send(
  { type: 'messenger', id: 'RECIPIENT_ID' },
  { type: 'messenger', id: 'SENDER_ID' },
  {
    content: {
      type: 'text',
      text: 'This is a message from the Messages API'
    }
  },
  (err, data) => {
    console.log(data.message_uuid);
  }
);
```

As you can see, the API requires a series of objects to be passed to it in order to know what to do. Pay particular attention to the first two:

```javascript
{ type: 'messenger', id: 'RECIPIENT_ID' },
{ type: 'messenger', id: 'SENDER_ID' },
```

This is where the platform you want to send on is specified, along with your ID (in Facebook's case this would be the ID given to your business profile page), and the ID of the recipient.

We've standardised this format throughout the API. Would you like to take a guess at how you would send a message via WhatsApp instead of Facebook Messenger?

```javascript
nexmo.channel.send(
  { type: 'whatsapp', number: 'TO_NUMBER' },
  { type: 'whatsapp', number: 'WHATSAPP_NUMBER' },
  {
    content: {
      type: 'text',
      text: 'This is a message from the Messages API'
    }
  },
  (err, data) => {
    console.log(data.message_uuid);
  }
);
```

I'll go ahead and believe that you guessed correctly. The only change needed to shift sending to a completely different messaging service is to the first two objects, other than that the code is exactly the same.

We have several more in-depth tutorials on sending messages with the Messages API ready for you to check out:

* [Sending Viber Service Messages with the Messages API](https://developer.nexmo.com/tutorials/sending-viber-service-messages-with-messages-api)
* [Sending Facebook Messenger messages with the Messages API](https://nexmo.developer.com/tutorials/sending-facebook-messenger-messages-with-messages-api)
* [Sending WhatsApp messages with the Messages API](https://developer.nexmo.com/tutorials/sending-whatsapp-messages-with-messages-api)

It is also worth noting that if you just wanted to send regular SMS messages via the Messages API, you can do so, as it forms an integral part of the service that the Dispatch API performs.

We'll take a look at Dispatch next, but check out the [Sending SMS Messages with the Messages API tutorial](https://developer.nexmo.com/tutorials/sending-sms-messages-with-messages-api) if that's something you're doing now and want to see how it fits into this new way of working.

## Handling Message Failover with the Dispatch API

Ensuring your messages and replies get to your customers is crucial to providing a top-notch experience. As developers, being able to seamlessly 'fail over' from one preferential messaging service to a backup, such as SMS, means that you can keep the conversation flowing.

Herein lies the Dispatch API's reason for being. Let's take a look at what it takes to use it.

The code below is an example of a 'failover template' and it's being used to send the important contents of the `myMessage` variable.

A failover template is made up of three required parts:

1. The initial message you want to send (on whichever messaging platform you want to send it, in this case it is a Viber Service Message).
2. A `condition_status` to wait for. The code above waits 600 seconds (10 minutes) for a `delivered` status to be returned. If this doesn't happen, the failover will kick in.
3. The second object in the array is the instruction of what to do if the first message 'fails'. In this case, the `myMessage` content is sent via SMS to the user.

```javascript
const Nexmo = require('nexmo');

const nexmo = new Nexmo({
 ... // API credentials
});

const myMessage = 'Really important information!'

nexmo.dispatch.create('failover', [
  {
    from: { type: 'viber_service_msg', id: 'VIBER_SERVICE_MESSAGE_ID' },
    to: { type: 'viber_service_msg', number: 'TO_NUMBER' },
    message: {
      content: {
        type: 'text',
        text: myMessage
      }
    },
    failover: {
      expiry_time: 600,
      condition_status: 'delivered'
    }
  },
  {
    from: { type: 'sms', number: 'FROM_NUMBER' },
    to: { type: 'sms', number: 'TO_NUMBER' },
    message: {
      content: {
        type: 'text',
        text: myMessage
      }
    }
  },
  (err, data) => {
    console.log(data.dispatch_uuid);
  }
]);
```

You can find further details the [documentation for Dispatch workflows](https://developer.nexmo.com/dispatch/concepts/workflows) including which `condition_status` you can expect from the different platforms.

For a more detailed look at building with the Dispatch API, see our [Sending a Facebook Message with failover](https://developer.nexmo.com/tutorials/sending-facebook-message-with-failover) tutorial.

## Your Feedback Is Important

Nexmo always welcomes your feedback. Your suggestions help us improve the product and we'd love to know what you are building with these APIs.

If you do need help, please email [support@nexmo.com](mailto://support@nexmo.com) and include Messages & Dispatch APIs in the subject line. Please note that during the Beta period, support times are limited to Monday to Friday.

You can also find the Nexmo Developer Relations team and offer up your feedback in the [Nexmo Community Slack](https://developer.nexmo.com/community/slack) channel.