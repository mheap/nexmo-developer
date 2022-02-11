---
title: Build a Conference Call with Node-RED
description: How to create a custom voice-based conferencing service and voice
  application with Nexmo's Voice API and Node-RED today
thumbnail: /content/blog/conference-call-node-red-dr/conference-call-node-red-featured.png
author: julia
published: true
published_at: 2019-10-07T21:52:57.000Z
updated_at: 2021-05-24T12:12:54.478Z
category: tutorial
tags:
  - voice-api
  - node-red
comments: true
redirect: ""
canonical: ""
---
In [previous tutorials](https://www.nexmo.com/blog/tag/node-red) you've had a chance to get your feet wet in the world of Nexmo APIs, making and receiving phone calls using the [Voice API](https://developer.nexmo.com/voice/voice-api/overview), and hopefully also customizing these experiences.

In today's tutorial, we'll take it a step further and build a voice-based conferencing service.

The user calls a predefined virtual number and inputs a meeting ID using the dial pad, then they get placed in the same conference call with everyone else who has provided the same ID.

Steps:

1. Prerequisites
2. Expose Your Local Server to the Internet
3. Define the Webhook Endpoint for Inbound Calls
4. Define the Webhook Endpoint for the Input Event
5. Create a Nexmo Voice Application
6. Set Up a Number to Call
7. Handle Your Call Events
8. Try it out!

## Prerequisites

Before getting started, you’ll need a few things:

* [Node.js](https://nodejs.org/en/) and [Node-RED](https://nodered.org/docs/getting-started/installation) installed on your machine
* A way to expose your server to the internet. This either means you're running a hosted version of Node-RED, or in case you're developing locally, using a tunneling service like [ngrok](https://ngrok.com/download)—get up to speed with this [Getting Started with Ngrok in Node-RED](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/) tutorial

  <sign-up></sign-up>

### Getting Your Credentials

To interact with the Voice API, you'll need to make note of a couple of things. Once you've created a Nexmo account, go to the [dashboard](https://dashboard.nexmo.com) to find your API key and secret.

Next, you'll need a *Voice-enabled* virtual number. Go to Numbers > [Buy numbers](https://dashboard.nexmo.com/buy-numbers) to get one.

![Buy number Nexmo dashboard](/content/blog/build-a-conference-call-with-node-red/buy-number-nexmo-dashboard.gif "Buy number Nexmo dashboard")

### Setting Up Your Node-RED Editor

First, you’ll need to [install](https://nodered.org/docs/getting-started/installation) the runtime and editor. This could be done either on your local machine, on a Single Board Computer (eg. Raspberry Pi), or through several cloud-hosted options. This example will be using your local machine, so once you've installed Node-RED globally, type the command below in your terminal to get started.

```bash
$ node-red
```

You can then access the Node-RED editor by pointing your browser at <http://localhost:1880>.

Once you have your editor open, you'll need to install the Nexmo nodes. You can do so under the *Manage palette* menu, by searching for the `node-red-contrib-nexmo` package and clicking install. 

Now you should see all of the Nexmo nodes appear on the left side of your screen—in your node palette, among other default nodes.

## Expose Your Local Server to the Internet

The Nexmo API will need access to your webhooks to make calls against them, so let's [make them accessible over the public internet](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/). If you’re running Node-RED on a public web server instead of your local machine, you're all set and ready to move on to the *[Create a Nexmo Voice Application](link_me)* step. 

Otherwise, a convenient way to do this is by using a tunneling service like [ngrok](https://ngrok.com).

First, you'll need to install the ngrok node. To do so, open up *Manage palette* from the hamburger menu in your Node-RED editor, search for the `node-red-contrib-ngrok` package, and click install. After restarting your editor, the *`ngrok`* node should appear in the node palette.

![ngrok manage palette](/content/blog/build-a-conference-call-with-node-red/ngrok-manage-palette.png "ngrok manage palette")

The `ngrok` node takes the strings *on* or *off* as input to start/stop the tunnel, and outputs the ngrok host address as the `msg.payload`.

The easiest way to set this up is to wire two `inject` nodes as the `ngrok` node's input, one with the payload of the string *on* and the other with *off*. For easier use, you could also set the `Name` of these nodes accordingly in the node properties, so that it's clear what functionality they have. Next, to display the host address in the debug sidebar, connect a `debug` node after `ngrok`.

As the last step before hitting *Deploy*, open up the `ngrok` node properties and specify the port number. In case of Node-RED, the default value is `1880`. The default ngrok Region is US but you can also set it to Europe or Asia. You can also add your authtoken for your ngrok account if you have one. Don't worry if you don't, just skip this step for now. The node will warn that it is not fully configured but this is not an issue.

![ngrok node properties](/content/blog/build-a-conference-call-with-node-red/ngrok-node-properties.png "ngrok node properties")

And you're all set! Once you hit **Deploy** and click on the **on** `inject` node's button, navigate to the URL displayed in the debug area (YOUR_URL for future reference) to find your Node-RED editor at a public address.

![ngrok node-red](/content/blog/build-a-conference-call-with-node-red/ngrok-nodered.png "ngrok node-red")

## Define the Webhook Endpoint for Inbound Calls

Nexmo calls are controlled using *Nexmo Call Control Objects*, also known as NCCOs. An NCCO defines a list of actions to be followed when a call is handled. There are lots of different actions available; find the corresponding nodes under the Nexmo palette in your Node-RED editor or check out the [NCCO Reference](https://developer.nexmo.com/api/voice/ncco) to find out more about them.

When handling inbound calls, you need your NCCO hosted at an *Answer URL*. In this case, we'll be using a `talk` action to ask tor the meeting ID, then an `input` action to collect it.

Add a *`voice webhook`* input node to your canvas, followed by a *`talk`* node, an *`input`* node and a *`return NCCO`* output node.

Next, in the *`voice webhook`* node, select `GET` as a `Method` and type `/answer` in the answer URL field. 

In the *`talk`* node properties set the `Text{}` field to the message you'd like to be read out when the call is answered. E.g. "Please enter the meeting ID". You can also select a `Voice Name`, see the [Text to Speech Guide](https://developer.nexmo.com/voice/voice-api/guides/text-to-speech#voice-names) for the full list of options.

Finally open the *`input`* node editor, set `YOUR_URL/input` as the `URL {}` and `POST` as a `Method`. 

At this time you could also set a couple of other parameters to further customize the experience:

| Name              | Description                                                                                                                                                                                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Submit On Hash`: | Set to true so the caller's activity is sent to your webhook endpoint at `YOUR_URL/input` after they press `#`. If `#` is not pressed the result is submitted after `Time Out` seconds. The default value is false. |
| `Time Out`:       | The result of the caller's activity is sent to the `YOUR_URL/input` webhook endpoint `Time Out` seconds after the last action. The default value is 3. Max is 10.                                                   |
| `Max Digits`:     | The number of digits the user can press. The maximum value is 20, the default is 4 digits.                                                                                                                          |

Find out more about these in the [NCCO Reference](https://developer.nexmo.com/voice/voice-api/ncco-reference#input).

![conference answer url](/content/blog/build-a-conference-call-with-node-red/conference-answer-url.gif "conference answer url")

## Define the Webhook Endpoint for the Input Event

You'll also need a second endpoint to capture the DTMF input from the user, and based on the code they have submitted, place them into a *conversation*.

Add another *`voice webhook`* input node to your canvas, followed by a *`talk`* node, a *`conversation`* node and a *`return NCCO`* output node. 

#### `voice webhook`

In the *`voice webhook`* node properties, select `POST` as a method and type `/input` in the answer URL field. 

If you were to connect a `debug` node after it, after finishing and running the flow, you would see the parameters returned to the `/input` URL:

| Name                | Description                                                            |
| ------------------- | ---------------------------------------------------------------------- |
| `uuid`              | The unique ID of the Call leg for the user initiating the input.       |
| `conversation_uuid` | The unique ID for this conversation.                                   |
| `timed_out`         | Returns true if this input timed out based on the value of `Time Out`. |
| `dtmf`              | The numbers input by your caller, in order.                            |

In our use case, we are trying to get the `dtmf` value, as this is the meeting ID provided by the caller.

Having a closer look at the debug sidebar on completions, we can see that it's going to be in the `dtmf` property of the `call` object nested inside the `msg` object, so we can reference it as `{{msg.call.dtmf}}` in the other nodes of this path.

![dtmf debug](/content/blog/build-a-conference-call-with-node-red/dtmf-debug.png "dtmf debug")

#### `talk`

Next, open up the *`talk`* node editor and set the `Text{}` field to the message you'd like to be read out once the caller inputs the meeting ID. 

Note the `{}` sign next to the `Text` label, showing that this value can be set dynamically, using [Mustache templating](https://mustache.github.io/), so you could go with something like `Joining meeting {{msg.call.dtmf}}`.

Feel free to further personalize the experience by selecting a [`Voice Name`](https://developer.nexmo.com/voice/voice-api/guides/text-to-speech#voice-names) or by making use of [SSML tags](https://developer.nexmo.com/voice/voice-api/guides/customizing-tts)

#### `conversation`

We're using the *`conversation`* action to create a standard conference, so the only parameter we have to set is `Name {}`. Using the conversation action with the same name reuses the same persisted Conversation, so it's handy to name it after the meeting ID, referencing `{{msg.call.dtmf}}` The first person to call the virtual number assigned to the conversation creates it. 

![conference conversation node](/content/blog/build-a-conference-call-with-node-red/conference-conversation-node.png "conference conversation node")

In the future, you might want to take this a step further and create a moderated Conversation with selective audio controls. Check out the [NCCO reference](https://developer.nexmo.com/voice/voice-api/ncco-reference#conversation) to find out more.

Once you're done with this path, it should look similar to this:

![conference input url](/content/blog/build-a-conference-call-with-node-red/conference-input-url.gif "conference input url")

## Create a Nexmo Voice Application

Some of Nexmo’s APIs, including the Voice API, use Nexmo Applications to hold security and config information needed to connect to Nexmo endpoints. 

In the Nexmo Node-RED palette, several nodes have the capability to create these applications: *`getrecording`*, *`earmuff`*, *`mute`*, *`hangup`*, *`transfer`*, *`createcall`*, *`playaudio`*, *`playtts`* and *`playdtmf`*.

Drag any of these nodes into your workspace, then double-click on it to open up the node properties.

Next to the `Nexmo Credentials`, select "Add new nexmovoiceapp..." from the drop-down menu and click the edit button. Fill in the details below and click `Create New Application`.

| KEY          | DESCRIPTION                                                                                                 |
| ------------ | ----------------------------------------------------------------------------------------------------------- |
| `Name`       | Choose a name for your Voice Application, for example `Conference Call`.                                    |
| `API Key`    | Your Nexmo API key, shown in your [account overview](https://dashboard.nexmo.com/getting-started-guide).    |
| `API Secret` | Your Nexmo API secret, shown in your [account overview](https://dashboard.nexmo.com/getting-started-guide). |
| `Answer URL` | YOUR_URL/answer, you'll be hosting a Nexmo Call Control Object (NCCO) here. - more about this later on.     |
| `Event URL`  | YOUR_URL/event, you'll need to reference this when setting up the event handler.                            |

Node-RED will then create a new Nexmo Application on your account and fill in the App ID and Private Key fields for you to save. After this step, feel free to delete the Nexmo node you used, as a `nexmovoiceapp` config node has been created, and that contains all the Nexmo credentials this flow needs.

![conference create voice app](/content/blog/build-a-conference-call-with-node-red/conference-create-voiceapp.png "conference create voice app")

## Set Up a Number to Call

Next, you'll have to link your virtual number to this application.

Find the Voice Application you've just created in your Nexmo Dashboard by navigating to *Voice* > *[Your Applications](https://dashboard.nexmo.com/voice/your-applications)*.

Click on the name of this application, then under the *Numbers* tab click on the **Link** button next to the virtual number you've rented earlier.

In case the number you'd like to use is already linked to another app, click on **Manage number** and configure it to forward incoming calls to your app.

![conference link number](/content/blog/build-a-conference-call-with-node-red/congerence-link-number.png "conference link number")

*Bonus tip:* Use a *`comment`* node to take note of the Nexmo number linked to your application, this way you always have it handy.

## Handle Your Call Events

If you'd like to receive events about the progress of your call, you can also set up an event webhook.

Connect an `http` input node to an `http response` node, as well as to a `debug` node, so that you can view your call events in the debug area.

In the `http` input node, select `POST` as a `Method` and fill in the `URL` field with `/event`.

The `http response` node should have `200` set as `Status code`, but don't worry about it; this is the default value as well.

![conference final flow](/content/blog/build-a-conference-call-with-node-red/conference-final-flow.png "conference final flow")

## Try it Out!

And that's a wrap! Get a friend or more and take it for a spin! Don't forget to take a peek in the debug area to follow your call events. Enjoy!

## Where Next?

### Resources:

* [Conversation NCCO Reference](https://developer.nexmo.com/voice/voice-api/ncco-reference#conversation)
* [Input NCCO Reference](https://developer.nexmo.com/voice/voice-api/ncco-reference#input)
* [Get Started with ngrok in Node-RED](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/)
* [Voice API Reference](https://developer.nexmo.com/voice/voice-api/overview)

### Try another tutorial:

* [Verify Phone Numbers with Node-RED](https://www.nexmo.com/blog/2019/09/25/verify-phone-numbers-with-node-red-dr)
* [How to Stream Audio into a Call with Node-RED](https://www.nexmo.com/blog/2019/07/15/stream-audio-node-red-dr)
* [How to Make Text-to-Speech Phone Calls with Node-RED](https://www.nexmo.com/blog/2019/06/14/make-text-to-speech-phone-calls-node-red-dr/)
* [How to Receive Phone Calls with Node-RED](https://www.nexmo.com/blog/2019/05/09/receive-phone-calls-node-red-dr/)
* [How to Send SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/17/send-sms-messages-node-red-dr/)
* [How to Receive SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/24/receive-sms-messages-node-red-dr/)