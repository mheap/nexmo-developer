---
title: Forward a Call via a Voice Proxy with Node-RED
description: In this tutorial we'll learn how to make private phone calls by
  forwarding them using a voice proxy with the Nexmo Voice API and Node-RED.
thumbnail: /content/blog/forward-call-via-voice-proxy-node-red-dr/forward-call-featured.png
author: julia
published: true
published_at: 2019-10-17T08:09:37.000Z
updated_at: 2021-05-24T12:30:22.032Z
category: tutorial
tags:
  - node-red
comments: true
redirect: ""
canonical: ""
---
In this tutorial we'll be using the Nexmo Voice API to make private calls, by forwarding a call via a voice proxy, and as an additional bonus we're also going to add a recording feature to it at the end.

If you've ever wondered how you can contact your ride share driver, Airbnb host or courier without knowing their number, or you're simply interested in making private calls, follow along and find out how this is done!

## Dependencies

### Prerequisites

Before getting started, you’ll need a few things:

* [Node.js](https://nodejs.org/en/) and [Node-RED](https://nodered.org/docs/getting-started/installation) installed, if you're developing locally
* A way to expose your server to the internet. This either means you're running a hosted version of Node-RED, or using a tunnelling service like [ngrok](https://flows.nodered.org/node/node-red-contrib-ngrok) - get up to speed with this [Getting Started with Ngrok in Node-RED](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/) tutorial

<sign-up></sign-up>

### Getting Your Credentials

To use the Nexmo nodes in Node-RED you'll have to provide your credentials, so it's best to keep them handy. Go to your [dashboard](https://dashboard.nexmo.com) to find your API key and secret and make a note of them.

Next, you'll need a *Voice-enabled* virtual number. Go to Numbers > [Buy numbers](https://dashboard.nexmo.com/buy-numbers) to get one.

![Buy Number Nexmo Dashboard](/content/blog/forward-a-call-via-a-voice-proxy-with-node-red/buy-number-nexmo-dashboard-1-.gif "Buy Number Nexmo Dashboard")

### Setting Up Your Node-RED Editor

Access your Node-RED editor by pointing your browser at <http://localhost:1880>.

Once you have the editor open, you'll need to install the Nexmo nodes. You can do so under the *Manage palette* menu, by searching for the `node-red-contrib-nexmo` package and clicking install. 

Now you should see all of the Nexmo nodes appear on the left side of your screen - in your node palette, among other default nodes.

## Expose Your Local Server to the Internet

In case you're not using a hosted version of Node-RED, the Nexmo Voice API will need another way to access your webhook endpoints, so let's [make your local server accessible over the public internet](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/). If you’re running Node-RED on a public web server instead of your local machine, you're all set and ready to move on to the *[Create a Nexmo Voice Application](link_me)* step. 

A convenient way to do this is by using a tunneling service like [ngrok](https://ngrok.com), and there is a [node](https://flows.nodered.org/node/node-red-contrib-ngrok) for it that you can install directly from your editor.

Feel free to also check out our tutorial on [Getting Started with Ngrok in Node-RED](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/) to find out more.

Once you've installed the ngrok node and restarted your editor, the **`ngrok`** node should appear in you node palette. It takes the strings **on** or **off** as input to start/stop the tunnel, and outputs the ngrok host address as the *msg.payload*.

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

![ngrok path](/content/blog/forward-a-call-via-a-voice-proxy-with-node-red/ngrok-path.png "ngrok path")

As the last step before hitting **Deploy**, open up the **`ngrok`** node properties and specify the port number (`1880` for Node-RED) and the Region.

You can also add your authtoken for your ngrok account if you have one. Don't worry if you don't, just skip this step for now. The node will warn that it is not fully configured but this is not an issue.

![ngrok properties](/content/blog/forward-a-call-via-a-voice-proxy-with-node-red/ngrok-properties.png "ngrok properties")

Hit **Deploy** and click on the **on** **`inject`** node's button, then navigate to the URL displayed in the debug area (YOUR_URL for future reference) to find your Node-RED editor at a public address.

![ngrok node-red](/content/blog/forward-a-call-via-a-voice-proxy-with-node-red/ngrok-nodered-1.png "ngrok node-red")

## Create a Nexmo Voice Application

Some of Nexmo’s APIs, including the Voice API, use Nexmo Applications to hold security and config information needed to connect to Nexmo endpoints. 

In the Nexmo Node-RED palette, several nodes have the capability to create these applications: **`getrecording`**, **`earmuff`**, **`mute`**, **`hangup`**, **`transfer`**, **`createcall`**, **`playaudio`**, **`playtts`** and **`playdtmf`**.

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

![create voice app](/content/blog/forward-a-call-via-a-voice-proxy-with-node-red/conference-create-voiceapp.png "create voice app")

## Set Up a Number to Call

Next, you'll have to link your virtual number to this application.

Find the Voice Application you've just created in your Nexmo Dashboard by navigating to *Voice* > *[Your Applications](https://dashboard.nexmo.com/voice/your-applications)*.

Click on the name of this application, then under the *Numbers* tab click on the **Link** button next to the virtual number you've rented earlier.

In case the number you'd like to use is already linked to another app, click on **Manage number** and configure it to forward incoming calls to your app.

![link number](/content/blog/forward-a-call-via-a-voice-proxy-with-node-red/link-number.png "link number")

*Bonus tip:* Use a **`comment`** node to take note of the Nexmo number linked to your application, this way you always have it handy.

## Handle Inbound Calls

When you receive an inbound call, the Nexmo Voice API makes a `GET` request to an endpoint you define, `YOUR_URL/answer`, and expects a set of instructions on how to handle the call.

These instructions come in the form of a *Nexmo Call Control Object*, also known as NCCOs.
There are lots of different actions available, find the corresponding nodes under the Nexmo palette in your Node-RED editor or check out the [NCCO Reference](https://developer.nexmo.com/api/voice/ncco) to find out more about them.

For this tutorial we'll be using the `connect` action, so that when the inbound call is received, it gets connected to a new phone number we specify.

### Define the Webhook Endpoint for Inbound Calls

Add a *`voice webhook`* and a *`return ncco`* node to your workspace, and wire them together to define a webhook endpoint.

Next, open up the *`voice webhook`* node properties, select `GET` as a `Method` and type `/answer` in the `URL` field, then press *Deploy*.

![inbound webhook](/content/blog/forward-a-call-via-a-voice-proxy-with-node-red/inbound-webhook.png "inbound webhook")

Great! Now you have a webhook that returns an NCCO to Nexmo's API. At this point it doesn't contain any actions, so let's add one!

### Build the Nexmo Call Control Object

To forward the incoming call, we need to connect it to a new endpoint. To do so, we need a `connect` action.

Add a *`connect`* node in between the *`voice webhook`* and a *`return ncco`* nodes. This will add a connect action to the NCCO.

Open up the *`connect`* node editor, select `Phone` as an `Endpoint`and type in the number you'd lilke to call in the `Number {}` field.

Leave the `From {}` field empty for the Caller ID to appear as unknown, or fill it in with one of your Nexmo virtual numbers.

<img src="https://www.nexmo.com/wp-content/uploads/2019/10/forward-connect-node.png" alt="" width="" height="" class="alignnone size-full wp-image-30510" />

To find out more about the other parameters and the `connect` action, check out the [NCCO Reference](https://developer.nexmo.com/voice/voice-api/ncco-reference#connect). 

## Log Call Events

Finally, connect an `http in` node to an `http response` node, as well as to a `debug` node, so that you can view your call events in the debug area.

In the `http` input node, select `POST` as a `Method` and fill in the `URL` field with `/event`.

The `http response` node should have `200` set as `Status code`, but don't worry about it, this is the default value as well.

![forward flow](/content/blog/forward-a-call-via-a-voice-proxy-with-node-red/forward-flow.png "forward flow")

Now call your Nexmo number and follow your call events in the debug sidebar!

![forward call events](/content/blog/forward-a-call-via-a-voice-proxy-with-node-red/forward-call-events_.gif "forward call events")

## Add a Recording Feature

When making business phone calls, it's often helpful to have the option to also record them. So let's have a look at how we can transform the flow above to give us a recording of the conversation.

### Update the NCCO

First, we'll need a `record` action added to the Nexmo Call Control Object.

Recording starts when the record action is executed in the NCCO and finishes when the synchronous condition in the action is met. That is, `End On Silence`, `timeOut` or `endOnKey`.

If you do not set a synchronous condition, the Voice API immediately executes the next NCCO without recording.

In our use case, this means that we need to add a *`record`* node before the *`connect`* node, and no `End On Silence`, `Time Out` or `End On Key` values should be set. 

Go ahead and add a *`record`* node to your flow, between the *`voice webhook`* and *`connect`* nodes.

Open up its properties, fill in the `URL {}` field with something like `YOUR_URL/record`, select `POST` as a `Method` and pick a `Format` for the recording file - I'll go with `MP3`.  You could also tick `Beep Start` to have a clear indication of when exactly the recording starts.

![forwrad record node](/content/blog/forward-a-call-via-a-voice-proxy-with-node-red/forward-record-node.png "forwrad record node")

### Add Handler for the Recording eventURL

Next, we need to add a handler for the recording eventURL - `YOUR_URL/record`.
This way we receive the event on completion of recording, and then be able to download said recording to our machine.

Add an `http in` node and an `http response` node to your workspace and wire them together. Consider also adding a `debug` node to see what's coming through the recording eventURL.\
In the `http` input node, select `POST` as a `Method` and fill in the `URL` field with `/record`.

The `http response` node should have `200` set as `Status code`, but this is the default value as well.

![forward record event](/content/blog/forward-a-call-via-a-voice-proxy-with-node-red/forward-record-node.png "forward record event")

### Download Recording

Once the recording has completed, Nexmo sends us the recording URL in the recording event webhook . The last step is fetching the recording and downloading it.

For this step we'll need a *`getrecording`* node to fetch the recording audio from the supplied URL, and a *`file`* node to write it to a file on our machine.

Add a *`getrecording`* node after the `/record` *`http in`* node, then in its node properties select the voice application created earlier from the `Nexmo Credentials` drop-down and provide an absolute path as `Filename {}`.

![forward get recording](/content/blog/forward-a-call-via-a-voice-proxy-with-node-red/forward-getrecording.png "forward get recording")

And finally, add a *`file`* node after *`getrecording`*. In its node editor, make sure the *Create directory if it doesn't exist?* option is ticked and select either *overwrite* or *append to file* from the `Action` drop-down. Leave the `Filename` field empty, as this value will be passed in from the *`getrecording`* node, in `{{msg.filename}}`. 

![forward file node](/content/blog/forward-a-call-via-a-voice-proxy-with-node-red/forward-file-node.png "forward file node")

That's a wrap! Get a second device or have a friend call your Nexmo number, have a conversation and once you're done, the recording file will be waiting for you, already domnloaded to your machine. Enjoy!

![forward recording download](/content/blog/forward-a-call-via-a-voice-proxy-with-node-red/forward-recording-download_.gif "forward recording download")

## Where Next?

### Further Reading

* [Voice API Reference](https://developer.nexmo.com/voice/voice-api/overview)
* [Record NCCO Reference](https://developer.nexmo.com/voice/voice-api/ncco-reference#record)
* [Connect NCCO Reference](https://developer.nexmo.com/voice/voice-api/ncco-reference#connect)
* [Get Started with ngrok in Node-RED](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/)

### Try Another Tutorial

* [Build a Conference Call with Node-RED](https://www.nexmo.com/blog/2019/10/07/conference-call-node-red-dr)
* [Verify Phone Numbers with Node-RED](https://www.nexmo.com/blog/2019/09/25/verify-phone-numbers-with-node-red-dr)
* [How to Stream Audio into a Call with Node-RED](https://www.nexmo.com/blog/2019/07/15/stream-audio-node-red-dr)
* [How to Make Text-to-Speech Phone Calls with Node-RED](https://www.nexmo.com/blog/2019/06/14/make-text-to-speech-phone-calls-node-red-dr/)
* [How to Receive Phone Calls with Node-RED](https://www.nexmo.com/blog/2019/05/09/receive-phone-calls-node-red-dr/)
* [How to Send SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/17/send-sms-messages-node-red-dr/)
* [How to Receive SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/24/receive-sms-messages-node-red-dr/)