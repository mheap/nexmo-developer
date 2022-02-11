---
title: How to Receive SMS Messages with Node-RED
description: In this tutorial, you will learn about receiving SMS messages with
  the Vonage SMS API, by implementing a webhook endpoint using Node-RED.
thumbnail: /content/blog/receive-sms-messages-node-red-dr/receive-sms-node-red.png
author: julia
published: true
published_at: 2019-04-24T17:01:45.000Z
updated_at: 2021-05-14T16:38:58.825Z
category: tutorial
tags:
  - sms-api
  - javascript
  - node-red
comments: true
redirect: ""
canonical: ""
---
*This is the second article in a series of “Getting Started with Nexmo and Node-RED” tutorials.*

In the [previous article](https://www.nexmo.com/blog/2019/04/17/send-sms-messages-node-red-dr/), you set up your Vonage API account and Node-RED editor, learned how to send SMS messages, and learned how to handle delivery receipts. Now it's time to learn about receiving SMS messages by implementing a webhook endpoint using Node-RED.

Get this flow from the [Node-RED Library](https://flows.nodered.org/flow/0d452314094ebb09e4c518cc749f7278) or follow along!

## Prerequisites

Before getting started, you’ll need a few things:

* [Node.js](https://nodejs.org/en/) and [Node-RED](https://nodered.org/docs/getting-started/installation) installed on your machine
* Optional: [ngrok](https://ngrok.com/download)—get up to speed with [Aaron's blog post](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/)

<sign-up number></sign-up>

## Defining a Webhook Endpoint

In order to receive SMS messages using the Vonage API, you need to associate a webhook endpoint with a virtual number that you have rented from Vonage. Inbound Messages to that number will then be sent to your webhook endpoint.

First, set up this webhook endpoint in your Node-RED editor. Connect a `http` input node to a `http response` node, as well as to a `debug` node, so that you can view your inbound messages in the debug area. 
In the `http` input node, select `GET` as a `Method` and fill in the `URL` field with something like `/inbound-sms`.
The `http response` node should have `200` set as `Status code`, but don't worry about it, this is the default value.

![](/content/blog/how-to-receive-sms-messages-with-node-red/inbound-sms-flow-get.gif)

## Exposing Your Local Server to the Internet

Next you'll have to expose your local server to the internet, so that Vonage can access it. If you’re running Node-RED on a public webserver instead of your local machine, you can skip this stage. 
Otherwise, a convenient way to do this is by using a tunneling service like [ngrok](https://ngrok.com).

[Download](https://ngrok.com/download) and install **ngrok**, then run it in the terminal to start a tunnel on port `1880`.

```bash
$ ./ngrok http 1880
```

![ngrok](/content/blog/how-to-receive-sms-messages-with-node-red/ngrok-send-sms-nodered.png)

## Setting Up the Endpoint

The last step is letting the Vonage SMS API know where it should forward the inbound messages.
Associate a webhook endpoint with one of your virtual numbers by going to [Your numbers](https://dashboard.nexmo.com/your-numbers), then clicking the settings icon next to the number you'd like to configure. 
Next, fill in the *Inbound Webhook URL* field with `YOUR_NGROK_URL/inbound-sms` and `Save changes`.

![Inbound webhook for number](/content/blog/how-to-receive-sms-messages-with-node-red/inbound-sms-webhook-for-number-1.png)

Now, if you send a text message to your virtual number, you should see the message object appear in the debug sidebar.

![sms debug](/content/blog/how-to-receive-sms-messages-with-node-red/received-sms-in-debug-1.png)

The message payload will contain a couple of key values that should be noted:

| KEY                     | DESCRIPTION                                                                                                                                                                                                                     |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`msisdn`**            | Mobile Station International Subscriber Directory Number (MSISDN) is a number used to identify a mobile phone number internationally. In this case, this will be the sender's number in E.164 format. For example 447401234567. |
| **`to`**                | Your Nexmo number that the SMS was sent to, in E.164 format.                                                                                                                                                                    |
| **`text`**              | The content of the received SMS message.                                                                                                                                                                                        |
| **`type`**              | The type of the message body received (**`text`** key). Possible values are `text`, `unicode` and `binary`.                                                                                                                     |
| **`keyword`**           | The first word in the message body. This is typically used with short codes.                                                                                                                                                    |
| **`message-timestamp`** | The time when Nexmo started to push this Delivery Receipt to your webhook endpoint.                                                                                                                                             |

Find out more about these parameters in the [Vonage API Reference for Inbound SMS](https://developer.nexmo.com/api/sms#inbound-sms).

## Next Steps

At this point, we're only logging the inbound messages in the debug area, but the possibilities are endless. Store them in a database, forward, translate, post them—or why not set up an autoresponder?

Ready to take it one step further? Have a look at [Sam](https://twitter.com/sammachin)'s flow for [Receiving Concatenated SMS Messages from Nexmo](https://flows.nodered.org/flow/525d526e7e6cd006a97ae522b0c670b6).

## Resources

* [How to Send SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/17/send-sms-messages-node-red-dr/)
* [Announcing the Nexmo Node-RED Package](https://www.nexmo.com/blog/2019/02/21/nexmo-node-red-package-dr/)
* [API Reference for Inbound SMS](https://developer.nexmo.com/api/sms#inbound-sms)
* Learn more about the Vonage [SMS API](https://developer.nexmo.com/api/sms)
* Have a closer look at [Node-RED](https://nodered.org/docs/)

## Try Another Tutorial

* [Send Group Notifications with Google Sheets and Node-RED](https://www.nexmo.com/blog/2020/03/06/sms-notifications-google-sheets-nodered-dr)
* [How to Build an IVR using Node-RED and the Nexmo APIs](https://www.nexmo.com/blog/2020/01/08/interactive-voice-response-node-red-dr)
* [Build Your Own Voicemail With Node-RED and the Nexmo Voice API](https://www.nexmo.com/blog/2019/11/14/build-voicemail-node-red-voice-api-dr)
* [Forward a Call via a Voice Proxy with Node-RED](https://www.nexmo.com/blog/2019/10/17/forward-call-via-voice-proxy-node-red-dr)
* [Build a Conference Call with Node-RED](https://www.nexmo.com/blog/2019/10/07/conference-call-node-red-dr)
* [Verify Phone Numbers with Node-RED](https://www.nexmo.com/blog/2019/09/25/verify-phone-numbers-with-node-red-dr)
* [How to Stream Audio into a Call with Node-RED](https://www.nexmo.com/blog/2019/07/15/stream-audio-node-red-dr)
* [How to Make Text-to-Speech Phone Calls with Node-RED](https://www.nexmo.com/blog/2019/06/14/make-text-to-speech-phone-calls-node-red-dr/)
* [How to Receive Phone Calls with Node-RED](https://www.nexmo.com/blog/2019/05/09/receive-phone-calls-node-red-dr/)