---
title: How to Stream Audio into a Call with Node-RED
description: Find out how to play an audio file to a caller, and how to stream
  audio into an outound call. All these with the power of Node-RED and the Nexmo
  Voice API.
thumbnail: /content/blog/stream-audio-node-red-dr/stream-audio-featured-image.png
author: julia
published: true
published_at: 2019-07-15T16:17:02.000Z
updated_at: 2021-04-28T08:14:07.379Z
category: tutorial
tags:
  - node-red
  - voice-api
comments: true
redirect: ""
canonical: ""
---
*This is the fifth article in a series of “Getting Started with Nexmo and Node-RED” tutorials.*

In the previous tutorials you've learnt about handling inbound calls and making outbound phone calls with the Nexmo Voice API.
For these examples we've used text-to-speech, but sometimes a more human approach is needed. It's always a nice touch to be greeted by a human voice when calling a business, instead of the all too well known friendly neighbourhood robot. Also, time flies by easier when quality music is playing while you are holding the line.

In this blog post we'll change it up a bit, and you'll find out how to stream audio into a call. By the end of it, you'll be able to play an audio file to a caller and you'll know how to stream audio to the recipient of an outbound call.

Get the flows from the Node-RED library below or follow along!

* [Stream Audio into an Outbound Call](https://flows.nodered.org/flow/12be7fb502cba62ef00ea9d06d5b8cef)
* [Play an Audio File to a Caller](https://flows.nodered.org/flow/24f972c23b92a120bde39a9b8163d872)

## Prerequisites

Before getting started, you’ll need a few things:

* [Node.js](https://nodejs.org/en/) and [Node-RED](https://nodered.org/docs/getting-started/installation) installed on your machine
* A way to expose your server to the internet. This either means you're running a hosted version of Node-RED, or in case you're developing locally, using a tunneling service like [ngrok](https://ngrok.com/download) - get up to speed with this [Getting Started with Ngrok in Node-RED](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/) tutorial
  <sign-up></sign-up> 

### Getting Your Credentials

In order to interact with the Voice API, you'll need to make note of a couple of things. Once you've created a Nexmo account, go to the [dashboard](https://dashboard.nexmo.com) to find your API key and secret.

Next, you'll need a Voice enabled virtual number. Go to Numbers > [Buy numbers](https://dashboard.nexmo.com/buy-numbers) to get one.

![Buy Number Dashboard](/content/blog/how-to-stream-audio-into-a-call-with-node-red/buy-number-nexmo-dashboard.png "Buy Number Dashboard")

### Setting Up Your Node-RED Editor

First, you’ll need to [install](https://nodered.org/docs/getting-started/installation) the runtime and editor. This could be done either on your local machine, on a Single Board Computer (eg Raspberry Pi), or a number of cloud-hosted options. This example will be using your local machine, so once you've installed Node-RED globally, just type the command below in your terminal to get started.

```bash
$ node-red
```

You can then access the Node-RED editor by pointing your browser at <http://localhost:1880>.

Once you have your editor open, you'll need to install the Nexmo nodes. You can do so under the *Manage palette* menu, by searching for the `node-red-contrib-nexmo` package and clicking install. 

![Install Node Red](/content/blog/how-to-stream-audio-into-a-call-with-node-red/install-nexmo-nodered.png "Install Node Red")

Now you should see all of the Nexmo nodes appear on the left side of your screen, among the other default nodes.

### Exposing Your Local Server to the Internet

Next you'll have to [expose your local server to the internet](https://www.nexmo.com/blog/2019/07/03/ngrok-in-node-red-dr/), so that Nexmo can access it. If you’re running Node-RED on a public webserver instead of your local machine, you can skip this stage. 

Otherwise, a convenient way to do this is by using a tunneling service like [ngrok](https://ngrok.com).

First, you'll need to install the ngrok node. To do so, open up *Manage palette* from the hamburger menu in your Node-RED editor, search for the `node-red-contrib-ngrok` package and click install. After restarting your editor, the **`ngrok`** node should appear in the node palette.

![ngrok manage palette](/content/blog/how-to-stream-audio-into-a-call-with-node-red/ngrok-manage-palette.png "ngrok manage palette")

The `ngrok` node takes the strings **on** or **off** as input to start/stop the tunnel, and outputs the ngrok host address as the *msg.payload*.

The easiest way to set this up is to wire two `inject` nodes as the **`ngrok`** node's input, one with the payload of the string **on** and the other with **off**. For easier use, you could also set the `Name` of these nodes accordingly in the node properties, so that it's clear what functionality they have.

Next, to display the host address in the debug sidebar, connect a `debug` node after **`ngrok`**.

As the last step before hitting **deploy**, open up the **`ngrok`** node properties and specify the port number. In case of Node-RED, the default value is `1880`. The default ngrok Region is US but you can also set it to Europe or Asia. You can also add your authtoken for your ngrok account if you have one. Don't worry if you don't, just skip this step for now. The node will warn that it is not fully configured but this is not an issue.


![ngrok properties](/content/blog/how-to-stream-audio-into-a-call-with-node-red/ngrok-node-properties-1.png "ngrok properties")

And you're all set! Once you hit deploy and click on the **on** `inject` node's button, navigate to the URL displayed in the debug area (YOUR_URL for future reference) to find your Node-RED editor at a public address.

![ngrok nodered](/content/blog/how-to-stream-audio-into-a-call-with-node-red/ngrok-nodered-1.png "ngrok nodered")

### Event Webhook

If you'd like to receive events about the progress of your call, you can also setup an event webhook.

Connect a `http` input node to a `http response` node, as well as to a `debug` node, so that you can view your call events in the debug area.

In the `http` input node, select `POST` as a `Method` - as this is the default method in your [ voice application settings](https://dashboard.nexmo.com/voice/your-applications),  and fill in the `URL` field with `/event`.

The `http response` node should have `200` set as `Status code`, but don't worry about it, this is the default value as well.

![event webhook](/content/blog/how-to-stream-audio-into-a-call-with-node-red/event-webhook-1.png "event webhook")

### Serving Up the Audio File

On to the audio file you'd like to play into the call. If you have it somewhere online, make sure it is in either MP3 or WAV format, take note of the URL where it's hosted and continue with the next step.

Another option is serving it up from your computer. To do this, connect in sequence an `http` input node, a `file in`, a `change` and an `http response` node.

In the `http` input node, select `GET` as a `Method` and fill in the `URL` field with something like `/filename.mp3`, so that you can find your audio file at *YOUR-URL/filename.mp3*.

Next, open up the `file in` node properties, provide the absolute local path to the audio file you're serving up in the `Filename` field and set the `Output` to `a single Buffer object`. This will read the contents of the file as a binary buffer.

You also need to specify what type of file you're serving up, and that's where the `change` node comes into play. Set `msg.headers` to `{}` and `msg.headers.content-type` to `audio/mp3`.

![serve up audio nodered](/content/blog/how-to-stream-audio-into-a-call-with-node-red/serve-up-audio-nodered-1.png "serve up audio nodered")

Now after hitting **Deploy**, point your browser at `YOUR_URL/filename.mp3` and you should hear your audio file playing.

### Creating a Nexmo Application

Some of Nexmo’s APIs, including the Voice API, use Nexmo Applications to hold security and config information needed to connect to Nexmo endpoints. 

In the Nexmo Node-RED palette, several nodes have the ability to create these applications: `getrecording`, `earmuff`, `mute`, `hangup`, `transfer`, `createcall`, `playaudio`, `playtts` and `playdtmf`.

Let's use the **`createcall`** node, which will also be able to make an outbound call using the NCCO you'll build next.

Once you have it in your workspace, double-click on the **`createcall`** node to open up the node editor.
Next to the `Nexmo Credentials`, select "Add new nexmovoiceapp..." from the drop-down menu and click the edit button. Fill in the details below and click `Create New Application`.

| KEY          | DESCRIPTION                                                                                                                                                                                                                                                                                                                                                                                                   |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Name`       | Choose a name for your Voice Application, for example `Stream audio`.                                                                                                                                                                                                                                                                                                                                         |
| `API Key`    | Your Nexmo API key, shown in your [account overview](https://dashboard.nexmo.com/getting-started-guide).                                                                                                                                                                                                                                                                                                      |
| `API Secret` | Your Nexmo API secret, shown in your [account overview](https://dashboard.nexmo.com/getting-started-guide).                                                                                                                                                                                                                                                                                                   |
| `Answer URL` | The URL that Nexmo makes a request to when handling [inbound calls](https://www.nexmo.com/blog/2019/05/09/receive-phone-calls-node-red-dr/). In case you're only interested in making an outbound call, just use http://example.com - you won't be needing it. Otherwise, set it to YOUR_URL/answer, you'll be hosting a Nexmo Call Control Object (NCCO) here. - more about this later on.                   |
| `Event URL`  | Nexmo will send call events (e.g. ringing, answered) to this URL. If you’d like to receive events about the progress of your call, make sure your server is exposed to the internet, then use `YOUR_URL/event` for this field. Otherwise, feel free to use http://example.com - this will respond with 200 OK. You could also override this eventURL for a specific `createCall` node in its node properties. |

Node-RED will then create a new Nexmo Application on your account and fill in the App ID and Private Key fields for you to save. Now you can find this application in your Nexmo Dashboard under *Voice* > *[Your Applications](https://dashboard.nexmo.com/voice/your-applications)*.

![create voice app example](/content/blog/how-to-stream-audio-into-a-call-with-node-red/create-voice-app-example-1.png "create voice app example")

## Playing an audio file to a caller

### Linking Your Virtual Number

Next you need to link your virtual number to the application created earlier by the **`createcall`** node.

Find the Voice Application you've just created in your Nexmo Dashboard by navigating to *Voice* > *[Your Applications](https://dashboard.nexmo.com/voice/your-applications)*.
Click on the name of this application, then under the *Numbers* tab click on the **Link** button next to the virtual number you've rented earlier.

![link number voice](/content/blog/how-to-stream-audio-into-a-call-with-node-red/link-number-voiceapp-1.png "link number voice")

### Building the Nexmo Call Control Object (NCCO)

Nexmo calls are controlled using *Nexmo Call Control Objects*, also known as NCCOs. An NCCO defines a list of actions to be followed when a call is handled. There are lots of different actions available, find the corresponding nodes under the Nexmo palette in your Node-RED editor or check out the [NCCO Reference](https://developer.nexmo.com/api/voice/ncco) to find out more about them.

When handling inbound calls, you need your NCCO hosted at an *Answer URL*, and for this tutorial, you'll be using the **`stream`** action. 

Drag and drop the **`stream`** node into your workspace, set the `Stream URL`, then connect it to a **`voice webhook`** input node and a **`return NCCO`** output node.

Next, in the **`voice webhook`** node, select `GET` as a method and type something like `/answer` in the answer URL field. 

![stream ncco answer url](/content/blog/how-to-stream-audio-into-a-call-with-node-red/stream-ncco-answer-url-1.png "stream ncco answer url")

Finally, go to the **`createcall`** node properties, select `URL` from the `Answer` drop-down, and fill in the field with `YOUR_URL/answer`.

Call your linked Nexmo number, lay back and enjoy! Your audio file will be waiting for you. 
Psst, you can also follow your call events in the debug sidebar!

## Streaming an Audio File into a Phone Call

### Building the Nexmo Call Control Object (NCCO)

After building the NCCO, this will be passed on to the `createcall` node, which will then be used to  make the outbound call. This `createcall` node takes 3 types of input for NCCO in the `Answer` field: `JSON`, `URL` or `msg.ncco`. Depending on which one you choose, there are 3 corresponding ways to build the NCCO, as follows. 

#### msg.ncco

Drag and drop the **`stream`** node into your workspace, double-click on it to open the node properties and set the `Stream URL {}` field to the link where your audio file is hosted -- `YOUR_URL/filename.mp3`. Note the `{}` sign next to the label, indicating that this value can be set dynamically, using [Mustache templating](https://mustache.github.io/). You can also set `Barge In`, `Loop`and `Level` values, although these are not required. See the [Stream section](https://developer.nexmo.com/voice/voice-api/ncco-reference#stream) of the NCCO reference to find out more.

Next, wire **`stream`** node's output into the **`createcall`** node, then under the **`createcall`** node properties select `msg.ncco` from the `Answer` drop-down menu.

![stream msg ncco](/content/blog/how-to-stream-audio-into-a-call-with-node-red/stream-msg-ncco-1.png "stream msg ncco")

#### JSON

If you'd rather write your NCCO as JSON, instead of using the action nodes, you can do so in the **`createcall`** node. Open the node properties and select `JSON` in the `Answer` field.
Expand the JSON editor and paste in  the snippet below:

```json
[
    {
        "action": "stream",
        "streamUrl": ["https://YOUR_URL/filename.mp3"]
    }
]
```

#### Answer URL

Alternatively, you can serve up the NCCO at an AnswerURL.
Drag and drop the **`stream`** node into your workspace, set the `Stream URL`, then connect it to a **`voice webhook`** input node and a **`return NCCO`** output node. 
Next, in the **`voice webhook`** node, select `GET` as a method and type `/answer` in the answer URL field. 

![stream ncco answer url](/content/blog/how-to-stream-audio-into-a-call-with-node-red/stream-ncco-answer-url-1-1-.png "stream ncco answer url")

Finally, go to the **`createcall`** node properties, select `URL` from the `Answer` drop-down, and fill in the field with `YOUR_URL/answer`.

### Making the Outbound Call

Next, let's have a closer look at the **`createcall`** node properties. To actually make the outbound call, you need to fill in a few more details. 

First, select `Phone` from the `Endpoint` drop-down menu. This will forward the call to a phone number, which you can specify in the text field next to the `Number{}` label.

Note the `{}` sign, which means that [Mustache templating](https://mustache.github.io/) is supported for these fields. You could hardcode a phone number in here, or pass it in dynamically using an **`inject`** node, and in this case, referencing it with `{{msg.payload}}`.

Moving on to the next step, set one of your [virtual numbers](https://dashboard.nexmo.com/your-numbers) as the `From{}` number.

![edit create call](/content/blog/how-to-stream-audio-into-a-call-with-node-red/edit-createcall-1.png "edit create call")

Add an **`inject`** node to set off the flow and wire it as an input for the path containing the **`createcall`** node. In its node properties, you can select `Number` from the `Payload` drop-down menu, and fill in the text field next to it with the phone number you wish to call in E.164 format. For example 447401234567. In this case, don't forget to reference this number using `{{msg.payload}}` in the **`createcall`** node properties as the value of `Number{}`.

To have a bit more insight into what's happening when you make the call, wire the **`createcall`**'s output into a **`debug`** node. 

Now hit **Deploy** and click the **`inject`** node's button - your phone should be ringing any second now! You can also follow the flow of your call in the debug sidebar if you've implemented an event webhook.

![stream outbound debug](/content/blog/how-to-stream-audio-into-a-call-with-node-red/stream-outbound-debug-1.png "stream outbound debug")

### Where Next?

* More about the [Voice API](https://developer.nexmo.com/voice/voice-api/overview)
* Check out the [NCCO Reference](https://developer.nexmo.com/voice/voice-api/ncco-reference) to learn about the many ways to control your call.
* [Stream Guide](https://developer.nexmo.com/voice/voice-api/ncco-reference#stream)
* [How to Make Text-to-Speech Phone Calls with Node-RED](https://www.nexmo.com/blog/2019/06/14/make-text-to-speech-phone-calls-node-red-dr/)
* [How to Receive Phone Calls with Node-RED](https://www.nexmo.com/blog/2019/05/09/receive-phone-calls-node-red-dr/)
* [Announcing the Nexmo Node-RED Package](https://www.nexmo.com/blog/2019/02/21/nexmo-node-red-package-dr/)
* [How to Send SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/17/send-sms-messages-node-red-dr/)
* [How to Receive SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/24/receive-sms-messages-node-red-dr/)
* Have a closer look at [Node-RED](https://nodered.org/docs/)