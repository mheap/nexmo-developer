---
title: Build Your Own Voicemail With Node-RED and the Nexmo Voice API
description: Discover how to use Node-RED to build a voicemail service that
  automatically emails recordings of the messages to recipients using Nexmo's
  Voice API.
thumbnail: /content/blog/build-voicemail-node-red-voice-api-dr/voicemail-featured-image.png
author: julia
published: true
published_at: 2019-11-14T12:54:36.000Z
updated_at: 2021-05-24T12:48:58.915Z
category: tutorial
tags:
  - node-red
  - low-code
comments: true
redirect: ""
canonical: ""
---
I have been avoiding voicemail for most of my life. Most of the time for one simple reason—I could never quite get 100% of the message.

I would have considered myself lucky if they'd slurred out a number I could have called back, the voicemail had been empty-ish or they had gotten past their first name. In most cases though it would go something like this:  

*"Hi Julia, this is Ted, I'm with didn't_really_get_the_name . I’m sorry we haven’t been able to get back together on this – if you’re like me I’m sure you’re being pulled in many different directions and are real busy.  Do me a favour, though, and when you get this message, just call me back and leave a message with what you’ve decided to do about my proposal. Either way, it will be nice for me to know. Thanks in advance for that, and I’ll be waiting for your call.."* 

Ted... Mosby? Crilly? Maybe, Cassidy? We'll never know.  

Luckily, building your own voicemail in Node-RED is both faster and easier than deciphering those messages. Follow along to see how it works!

## What You're Going to Build

This tutorial is part of the *["Getting Started with Nexmo and Node-RED"](https://www.nexmo.com/blog/tag/node-red)* series.

These articles show you how to get started with Nexmo APIs like SMS, Voice and Verify, so feel free to refer back to them as you go, or in case you'd like to add another functionality.  

In this tutorial we'll be building a simple voicemail service that allows callers to reach your Nexmo number and leave a message.

The recorded voice message will then be fetched from the Nexmo servers and sent to your email address.

## Dependencies

### Prerequisites

Before getting started, you’ll need a few things:

* [Node.js](https://nodejs.org/en/) and [Node-RED](https://nodered.org/docs/getting-started/installation) installed, if you're developing locally
* A way to expose your server to the internet. This either means you're running a hosted version of Node-RED, or using a tunneling service like [ngrok](https://flows.nodered.org/node/node-red-contrib-ngrok) - get up to speed with this [Getting Started with Ngrok in Node-RED](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/) tutorial

<sign-up></sign-up>

### Getting Your Credentials

To use the Nexmo nodes in Node-RED you'll have to provide your credentials, so it's best to keep them handy. Go to your [dashboard](https://dashboard.nexmo.com) to find your API key and secret and make a note of them.

Next, you'll need a *Voice-enabled* virtual number. Go to Numbers > [Buy numbers](https://dashboard.nexmo.com/buy-numbers) to get one.

![buy number nexmo dashboard](/content/blog/build-your-own-voicemail-with-node-red-and-the-nexmo-voice-api/buy-number-nexmo-dashboard-2-.gif "buy number nexmo dashboard")

### Setting Up Your Node-RED Editor

Access your Node-RED editor by pointing your browser at <http://localhost:1880>.

Once you have the editor open, you'll need to install the [Nexmo nodes](https://flows.nodered.org/node/node-red-contrib-nexmo), the [Ngrok node](https://flows.nodered.org/node/node-red-contrib-ngrok)(if not using a hosted version of Node-RED) and the default [Email node](https://flows.nodered.org/node/node-red-node-email). You can do so under the *Manage palette* menu, by searching for the corresponding packages and clicking install:

* Nexmo: `node-red-contrib-nexmo`
* Ngrok: `node-red-contrib-ngrok`
* Email: `node-red-node-email` 

After restarting Node-RED, you should see all of these nodes appear on the left side of your screen - in your node palette, among other default nodes.

## Expose Your Local Server to the Internet

In case you're not using a hosted version of Node-RED, the Nexmo Voice API will need another way to access your webhook endpoints, so let's [make your local server accessible over the public internet](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/). If you’re running Node-RED on a public web server instead of your local machine, you're all set and ready to move on to the [*Create a Nexmo Voice Application*] step. 

A convenient way to do this is by using a tunneling service like [ngrok](https://ngrok.com), and there is a [node](https://flows.nodered.org/node/node-red-contrib-ngrok) for it that you've just added to your palette. 

It takes the strings **on** and **off** as input to start/stop the tunnel, and outputs the ngrok host address as the *msg.payload*. Check out our tutorial on [Getting Started with Ngrok in Node-RED](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/) to find out more.

*Import* from *Clipboard* the snippet below, or have a stab at building this path yourself.

```json
[
    {
        "id": "faed0f7.1e524f",
        "type": "inject",
        "z": "5b8bbfc3.1a9f18",
        "name": "",
        "topic": "",
        "payload": "on",
        "payloadType": "str",
        "repeat": "",
        "crontab": "",
        "once": false,
        "onceDelay": 0.1,
        "x": 190,
        "y": 100,
        "wires": [
            [
                "8a01baeb.6756d"
            ]
        ]
    },
    {
        "id": "11051fa9.75bd1",
        "type": "inject",
        "z": "5b8bbfc3.1a9f18",
        "name": "",
        "topic": "",
        "payload": "off",
        "payloadType": "str",
        "repeat": "",
        "crontab": "",
        "once": false,
        "onceDelay": 0.1,
        "x": 190,
        "y": 160,
        "wires": [
            [
                "8a01baeb.6756d"
            ]
        ]
    },
    {
        "id": "8a01baeb.6756d",
        "type": "ngrok",
        "z": "5b8bbfc3.1a9f18",
        "port": "1880",
        "creds": "5a9e2b8c.173a2c",
        "region": "ap",
        "subdomain": "",
        "name": "",
        "x": 400,
        "y": 140,
        "wires": [
            [
                "93fd5675.743c1"
            ]
        ]
    },
    {
        "id": "93fd5675.743c1",
        "type": "debug",
        "z": "5b8bbfc3.1a9f18",
        "name": "",
        "active": true,
        "tosidebar": true,
        "console": false,
        "tostatus": false,
        "complete": "false",
        "x": 620,
        "y": 140,
        "wires": []
    },
    {
        "id": "5a9e2b8c.173a2c",
        "type": "ngrokauth",
        "z": ""
    }
]
```

At this point, your editor should look similar to this:

![ngrok path](/content/blog/build-your-own-voicemail-with-node-red-and-the-nexmo-voice-api/ngrok-path-1-.png "ngrok path")

As the last step before hitting **Deploy**, open up the *`ngrok`* node properties and specify the port number (`1880` for Node-RED) and the Region.

You can also add your authtoken if you already have a ngrok account. Don't worry if you don't, just skip this step for now. The node will warn that it is not fully configured but this is not an issue.

![ngrok properties](/content/blog/build-your-own-voicemail-with-node-red-and-the-nexmo-voice-api/ngrok-properties-1-.png "ngrok properties")

Hit **Deploy** and click on the **on** *`inject`* node's button, then navigate to the URL displayed in the debug area (YOUR_URL for future reference) to find your Node-RED editor at a public address.

![ngrok node-red](/content/blog/build-your-own-voicemail-with-node-red-and-the-nexmo-voice-api/ngrok-nodered-1-.png "ngrok node-red")

## Create a Nexmo Voice Application

The Nexmo Voice API uses Nexmo Applications to hold security and config information needed to connect to Nexmo endpoints. 

In the Nexmo Node-RED palette, several nodes have the capability to create these applications: *`getrecording`*, *`earmuff`*, *`mute`*, *`hangup`*, *`transfer`*, *`createcall`*, *`playaudio`*, *`playtts`* and *`playdtmf`*.

Drag any of these nodes into your workspace, then double-click on it to open up the node properties.

Next to the `Nexmo Credentials`, select "Add new nexmovoiceapp..." from the drop-down menu and click the edit button. Fill in the details below and click *Create New Application*.

| KEY          | DESCRIPTION                                                                                                 |
| ------------ | ----------------------------------------------------------------------------------------------------------- |
| `Name`       | Choose a name for your Voice Application, for example "Nexmo Voice Application".                            |
| `API Key`    | Your Nexmo API key, shown in your [account overview](https://dashboard.nexmo.com/getting-started-guide).    |
| `API Secret` | Your Nexmo API secret, shown in your [account overview](https://dashboard.nexmo.com/getting-started-guide). |
| `Answer URL` | YOUR_URL/answer, you'll be hosting a Nexmo Call Control Object (NCCO) here. - more about this later on.     |
| `Event URL`  | YOUR_URL/event, you'll need to reference this when setting up the event handler.                            |

Node-RED will then create a new Nexmo Application on your account and fill in the App ID and Private Key fields. After this step, feel free to delete the Nexmo node you used, as a `nexmovoiceapp` config node has been created, and that contains all the Nexmo credentials this flow needs.

![create voice app](/content/blog/build-your-own-voicemail-with-node-red-and-the-nexmo-voice-api/create-voiceapp-1-.png "create voice app")

## Set Up a Number to Call

Next, you'll have to link your virtual number to this application.

Find the Voice Application you've just created in your Nexmo Dashboard by navigating to *Voice* > *[Your Applications](https://dashboard.nexmo.com/voice/your-applications)*.

Click on the name of this application, then under the *Numbers* tab click on the **Link** button next to the virtual number you've rented earlier.

In case the number you'd like to use is already linked to another app, click on **Manage number** and configure it to forward incoming calls to your app.

![link number](/content/blog/build-your-own-voicemail-with-node-red-and-the-nexmo-voice-api/link-number-1-.png "link number")

*Bonus tip:* Use a *`comment`* node to take note of the Nexmo number linked to your application, this way you always have it handy.

## Handle Inbound Calls

When you receive an inbound call to your virtual number, the Nexmo Voice API makes a `GET` request to an endpoint you define, `YOUR_URL/answer`, and expects a set of instructions on how to handle the call.

First, let's implement this endpoint.

### Define the Webhook Endpoint for Inbound Calls

Add a *`voice webhook`* and a *`return ncco`* node to your workspace, and wire them together to define a webhook endpoint.
Next, open up the *`voice webhook`* node properties, select `GET` as a `Method` and type `/answer` in the `URL` field, then press *Deploy*.

![inbound webhook](/content/blog/build-your-own-voicemail-with-node-red-and-the-nexmo-voice-api/inbound-webhook-1-.png "inbound webhook")

Great! Now you have a webhook that returns an NCCO to Nexmo's API. At this point it doesn't contain any instructions, so let's add some!

### Build the Nexmo Call Control Object (NCCO)

The instructions expected by the Nexmo API come in the form of a *Nexmo Call Control Object*, also known as NCCO.

There are lots of different actions available, find the corresponding nodes under the Nexmo palette in your Node-RED editor or check out the [NCCO Reference](https://developer.nexmo.com/api/voice/ncco) to find out more about them.

In this case, you'll probably want to greet the caller then start recording the message. To do this, you'll need to add a *`talk`* node followed by a *`record`* node.

Add them to your workspace, then connect them in between the *`voice webhook`* and *`return ncco`* nodes.

#### *`talk`*

Next, open up the *`talk`* node editor and set the `Text{}` field to the message you'd like to be read out to the caller. Eg. "Hi! You've reached X, please leave a message."

If you're feeling nostalgic about old school voicemails, you're all set. On the other hand, you could also personalize the experience by selecting a [`Voice Name`](https://developer.nexmo.com/voice/voice-api/guides/text-to-speech#voice-names) or by making use of [SSML tags](https://developer.nexmo.com/voice/voice-api/guides/customizing-tts), so that it sounds more like a person and less like a robot.

#### *`record`*

In the *`record`* node properties fill in the `URL {}` field with `YOUR_URL/record`. This is going to be the eventURL that Nexmo will return a set of parameters to, once the recording has completed.

If you glance over at the [NCCO Reference](https://developer.nexmo.com/voice/voice-api/ncco-reference#record) you'll soon realize that the calling number is not one of them.  

Fortunately, we can grab the caller's phone number from the answerURL and pass it as a query parameter.

Update the `URL {}` field to `YOUR_URL/record?from={{msg.call.from}}`. This way we'll be able to access the `from` value through the record eventURL by referencing `msg.req.query.from`.

Before moving on to the next step, make sure you've selected `POST` as a `Method`, `MP3` as a `Format` and that you've set a value for `End On Silence` (eg. 3). 

![voicemail record](/content/blog/build-your-own-voicemail-with-node-red-and-the-nexmo-voice-api/voicemail-record.png "voicemail record")

If you'd like to see the generated NCCO, go to `YOUR_URL/answer`. You'll see a set of actions, or "instructions", in JSON format that Nexmo will use to control the call flow.

Ready to take it a step further? Dial your Nexmo number to see it in action!

![voicemail NCCO](/content/blog/build-your-own-voicemail-with-node-red-and-the-nexmo-voice-api/voicemail-ncco.png "voicemail NCCO")

## Fetch Recording

At this point, the caller is greeted by a TTS message followed by a beep tone and their message gets recorded. The next step is to fetch the recording from the Nexmo servers.

### Record eventURL

First, let's define the record eventURL where we're expecting the recording parameters to be sent upon completion.

Add a *`http in`* node to your workspace, then connect a *`http response`* node, as well as to a *`debug`* node to it. This way you can start logging events in the debug area and gain a bit more insight into what is really going on.

Open up the *`http in`* node properties, select `POST` as a `Method` and fill in the `URL` field with `/record`.

The *`http response`* node should have `200` set as `Status code`, but don't worry about it, this is the default value as well.

Although the recording data is coming through as `msg.payload`, we still have the `from` value stored in `msg.req.query.from`. Make sure you select `complete msg object` in the *`debug`* node's editor as `Output`.

### Get Recording

To actually retrieve the recording, we'll be using the *`getrecording`* Nexmo node.\
Add one to your canvas, connect it to the `/record` *`http in`* node and open up its node editor.

You'll see two fields:

1. `Nexmo Credentials` - select the voice application you created earlier from the drop-down menu.
2. `Filename {}` - Notice the `{}` sign in the label, which means that this field supports [Mustache templating](https://mustache.github.io/) and the value can be set dynamically. This gives us the perfect opportunity to include the caller's number and a timestamp in the filename, so let's set it to `recordings/{{msg.req.query.from}}_{{msg.payload.timestamp}}.mp3`.  

![](/content/blog/build-your-own-voicemail-with-node-red-and-the-nexmo-voice-api/voicemail-getrecording.png)

Note, this node does not write the audio to disk, the filename field is there to set the value of msg.filename. Next, there are a couple different routes you can take: upload the audio to your own server, follow with a *`file`* node and download it to your computer, or use an *`e-mail`* node and send it to yourself.

## Send Recording to an Email Address

For this example we'll use the default Node-RED *`e-mail`* node, which sends the `msg.payload` as an email, with a subject of `msg.topic`.

In our case, `msg.payload` is a binary buffer (the recording) and it will be converted to an attachment. If you wish to add a body to your email set it as `msg.description` using a *`change`* node in the flow before the *`e-mail`* node.

The filename will be `msg.filename`, which we've already specified. 

Connect a *`change`* node into *`getrecording`*, followed by an *`e-mail`* node. You'll find both in your node palette, *`change`* under *function* and *`e-mail`* under *social*. 
Next, let's see how to configure them.

### *`change`*

Open up the *`change`* node properties and define two rules using the *set* operation.

First, let's set `msg.topic`, the subject of the email.

In the upper field replace `payload` with `topic`, then select `expression` type from the `to` drop-down, which uses the [JSONata](http://jsonata.org/) query and expression language. To include the caller's number in the email subject, fill in this field with something like `'Voicemail from ' & msg.req.query.from`.

Click on the **add** button to define a second rule. This time we'll be setting the value of `msg.description`, the email body. You could use an expression again, or just go with a simple string like "Hey, you've got voicemail!".

![voicemail change](/content/blog/build-your-own-voicemail-with-node-red-and-the-nexmo-voice-api/voicemail-change.png "voicemail change")

Press **Done** once you're finished, and let's move on to the *`e-mail`* node!

### *`e-mail`*

In the *`e-mail`* node editor there are three fields you need to fill in: `To` - the recipient email address, `Userid` and `Password` - your email login details.  

![voicemail email](/content/blog/build-your-own-voicemail-with-node-red-and-the-nexmo-voice-api/voicemail-email.png "voicemail email")

Once you're done, hit **Done** and **Deploy**. Your Voicemail is up and running!

## Log Call Events

One more thing before you go! It's quite useful to see your call events in the debug area and have a better understanding of what's really going on, so let's add an event webhook!  

Connect an *`http in`* node to an *`http response`* node, as well as to a *`debug`* node, so that you can view your call events in the debug area.

In the *`http in`* node, select `POST` as a `Method` and fill in the `URL` field with `/event`.

The *`http response`* node should have `200` set as `Status code`, but don't worry about it, this is the default value as well.

![voicemail flow](/content/blog/build-your-own-voicemail-with-node-red-and-the-nexmo-voice-api/voicemail-flow.png "voicemail flow")

Now call your Nexmo number and follow your call events in the debug sidebar!

## Try it Out!

Et voilà! You've built your own voicemail service and, hopefully, you'll never have to put up with another pesky voicemail again. Call your Nexmo number and an email will be headed your way shortly. 

![](/content/blog/build-your-own-voicemail-with-node-red-and-the-nexmo-voice-api/voicemail-email-in.png)

## Where Next?

### Further Reading

* [Voice API Reference](https://developer.nexmo.com/voice/voice-api/overview)
* [Record NCCO Reference](https://developer.nexmo.com/voice/voice-api/ncco-reference#record)
* [TTS Voice Names](https://developer.nexmo.com/voice/voice-api/guides/text-to-speech#voice-names)
* [Using SSML Tags](https://developer.nexmo.com/voice/voice-api/guides/customizing-tts)
* [Get Started with ngrok in Node-RED](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/)

### Try Another Tutorial

* [Forward a Call via a Voice Proxy with Node-RED](https://www.nexmo.com/blog/2019/10/17/forward-call-via-voice-proxy-node-red-dr)
* [Build a Conference Call with Node-RED](https://www.nexmo.com/blog/2019/10/07/conference-call-node-red-dr)
* [Verify Phone Numbers with Node-RED](https://www.nexmo.com/blog/2019/09/25/verify-phone-numbers-with-node-red-dr)
* [How to Stream Audio into a Call with Node-RED](https://www.nexmo.com/blog/2019/07/15/stream-audio-node-red-dr)
* [How to Make Text-to-Speech Phone Calls with Node-RED](https://www.nexmo.com/blog/2019/06/14/make-text-to-speech-phone-calls-node-red-dr/)
* [How to Receive Phone Calls with Node-RED](https://www.nexmo.com/blog/2019/05/09/receive-phone-calls-node-red-dr/)
* [How to Send SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/17/send-sms-messages-node-red-dr/)
* [How to Receive SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/24/receive-sms-messages-node-red-dr/)