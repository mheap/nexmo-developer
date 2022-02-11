---
title: How to Receive Phone Calls with Node-RED
description: In this tutorial, you'll learn about handling inbound calls using
  Node-RED and the Nexmo Voice API.
thumbnail: /content/blog/receive-phone-calls-node-red-dr/inbound-calls-node-red.png
author: julia
published: true
published_at: 2019-05-09T08:00:44.000Z
updated_at: 2021-05-13T20:28:08.345Z
category: tutorial
tags:
  - voice-api
  - javascript
  - text-to-speech
comments: true
redirect: ""
canonical: ""
---
*This is the third article in a series of "Getting Started with Nexmo and Node-RED" tutorials.*

In the [previous tutorials](https://www.nexmo.com/blog/tag/node-red/) you've learnt how to send and receive SMS messages programatically using the Nexmo SMS API and how to handle delivery receipts.

Next, you'll be moving on to the next chapter, exploring the Nexmo Voice API. 

By the end of this article, you'll have handled your first inbound call with Node-RED.

## Prerequisites

Before getting started, you’ll need a few things:

* [Node.js](https://nodejs.org/en/) and [Node-RED](https://nodered.org/docs/getting-started/installation) installed on your machine
* Optional: [ngrok](https://ngrok.com/download)—get up to speed with [Aaron's blog post](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/)

<sign-up number></sign-up>

### Getting Your Credentials

In order to interact with the Voice API, you'll need to make note of a couple of things. Once you've created a Nexmo account, go to the [dashboard](https://dashboard.nexmo.com) to find your API key and secret.

Next, you'll need a Voice enabled virtual number. Go to Numbers > [Buy numbers](https://dashboard.nexmo.com/buy-numbers) to get one.

### Setting Up Your Node-RED Editor

First, you’ll need to [install](https://nodered.org/docs/getting-started/installation) the runtime and editor. This could be done either on your local machine, on a Single Board Computer (eg Raspberry Pi), or a number of cloud-hosted options. This example will be using your local machine, so once you've installed Node-RED globally, just type the command below in your terminal to get started.

```bash
$ node-red
```

You can then access the Node-RED editor by pointing your browser at <http://localhost:1880>.

Once you have your editor open, you'll need to install the Nexmo nodes. You can do so under the *Manage palette* menu, by searching for the `node-red-contrib-nexmo` package and clicking install. 

![nexmo node red](/content/blog/how-to-receive-phone-calls-with-node-red/install-nexmo-nodered.gif)

Now you should see all of the Nexmo nodes appear on the left side of your screen, among the other default nodes.

## Handle an Inbound Phone Call with Node-RED

### Exposing Your Local Server to the Internet

First, you'll have to expose your local server to the internet, so that Nexmo can access it. If you’re running Node-RED on a public webserver instead of your local machine, you can skip this stage. 

Otherwise, a convenient way to do this is by using a tunneling service like [ngrok](https://ngrok.com).

[Download](https://ngrok.com/download) and install **ngrok**, then run it in the terminal to start a tunnel on port `1880`.

```bash
$ ./ngrok http 1880
```

Navigate to the URL displayed to find your Node-RED Editor.

![ngrok inbound call](/content/blog/how-to-receive-phone-calls-with-node-red/ngrok-inbound-call.png)

### Creating a Nexmo Application

In the previous SMS tutorials, you were able to configure a phone number directly with an endpoint; however, this is not always the case.

Some of Nexmo’s APIs, including the Voice API, use Nexmo Applications to hold security and config information needed to connect to Nexmo endpoints. 

In the Nexmo Node-RED palette, several nodes have the ability to create these applications: `getrecording`, `earmuff`, `mute`, `hangup`, `transfer`, `createcall`, `playaudio`, `playtts` and `playdtmf`.

Drag any of these nodes into your workspace, then double-click on it to open up the node editor.

Next to the `Nexmo Credentials`, select "Add new nexmovoiceapp..." from the drop-down menu and click the edit button. Fill in the details below and click `Create New Application`.

| KEY          | DESCRIPTION                                                                                                 |
| ------------ | ----------------------------------------------------------------------------------------------------------- |
| `Name`       | Choose a name for your Voice Application, for example `inbound call`.                                       |
| `API Key`    | Your Nexmo API key, shown in your [account overview](https://dashboard.nexmo.com/getting-started-guide).    |
| `API Secret` | Your Nexmo API secret, shown in your [account overview](https://dashboard.nexmo.com/getting-started-guide). |
| `Answer URL` | YOUR_URL/answer, you'll be hosting a Nexmo Call Control Object (NCCO) here. - more about this later on.     |
| `Event URL`  | YOUR_URL/event, you'll need to reference this when setting up the event handler.                            |

Node-RED will then create a new Nexmo Application on your account and fill in the App ID and Private Key fields for you to save. After this step, feel free to delete the Nexmo node you used, as a `nexmovoiceapp` config node has been created, and that contains all the Nexmo credentials this flow needs.

![Next step](/content/blog/how-to-receive-phone-calls-with-node-red/844c06b1-4af6-43e8-acfd-95c3a6a0189b.png)

Next, you'll have to link your virtual number to this application.

Find the Voice Application you've just created in your Nexmo Dashboard by navigating to *Voice* > *[Your Applications](https://dashboard.nexmo.com/voice/your-applications)*.

Click on the name of this application, then under the *Numbers* tab click on the **Link** button next to the virtual number you've rented earlier.

Alternatively, if the number you'd like to use is already linked to another app, click on **Manage number** and configure it to forward incoming calls to your app.

![link number](/content/blog/how-to-receive-phone-calls-with-node-red/link-number-voiceapp.png)

### Build the Nexmo Call Control Object (NCCO)

Nexmo calls are controlled using *Nexmo Call Control Objects*, also known as NCCOs. An NCCO defines a list of actions to be followed when a call is handled. There are lots of different actions available, find the corresponding nodes under the Nexmo palette in your Node-RED editor or check out the [NCCO Reference](https://developer.nexmo.com/api/voice/ncco) to find out more about them.

For this tutorial, you'll be using the `talk` action. 

Drag and drop the **`talk`** node into your workspace, then connect it to a **`voice webhook`** input node and a **`return NCCO`** output node. 

Next, in the **`voice webhook`** node, select `GET` as a method and type something like `/answer` in the answer URL field. 

Finally, go to the **`talk`** node properties and set the `Text{}` field to the message you'd like to be read out when the call is answered. Note the `{}` sign next to the `Text` label, indicating that this value can be set dynamically, using [Mustache templating](https://mustache.github.io/). You can also select a `Voice Name`, see the [Text to Speech Guide](https://developer.nexmo.com/voice/voice-api/guides/text-to-speech#voice-names) for the full list of options.

![Create tts ncco](/content/blog/how-to-receive-phone-calls-with-node-red/create-tts-ncco.gif)

### Setting Up a Handler for the Event URL

Connect a `http` input node to a `http response` node, as well as to a `debug` node, so that you can view your delivery receipt in the debug area.

In the **`http`** input node, select `POST` as a `Method` and fill in the `URL` field with something like `/event`.

The **`http response`** node should have `200` set as `Status code`, but don't worry about it, this is the default value as well.

Now hit **Deploy**, call your virtual number and follow the flow of your call in the debug sidebar.

![inbound call debug](/content/blog/how-to-receive-phone-calls-with-node-red/inbound-call-debug.png)

## Next Steps

In this tutorial, you've learnt how to play a text-to-speech message to a caller. In a quite similar manner, you could also play an audio file to them, or forward the call to a phone number. If you'd like to take it further, why not record the conversation or set up your custom voicemail? Stay tuned to find out how!

## Resources

* More about the [Voice API](https://developer.nexmo.com/voice/voice-api/overview)
* Check out the [NCCO Reference](https://developer.nexmo.com/voice/voice-api/ncco-reference) to learn about the many ways to control your call.
* [Text to Speech Guide](https://developer.nexmo.com/voice/voice-api/guides/text-to-speech#voice-names)
* [Announcing the Nexmo Node-RED Package](https://www.nexmo.com/blog/2019/02/21/nexmo-node-red-package-dr/)
* [How to Send SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/17/send-sms-messages-node-red-dr/)
* [How to Receive SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/24/receive-sms-messages-node-red-dr/)
* Have a closer look at [Node-RED](https://nodered.org/docs/)