---
title: Getting Started with Ngrok in Node-RED
description: Ngrok is a great way to expose your development environment to the
  world. In this tutorial, see how this can be done for Node-RED without a
  terminal.
thumbnail: /content/blog/ngrok-in-node-red-dr/ngrok-featured.png
author: julia
published: true
published_at: 2019-07-03T15:34:57.000Z
updated_at: 2021-04-20T10:26:22.047Z
category: tutorial
tags:
  - ngrok
  - node-red
comments: true
redirect: ""
canonical: ""
---
If you've been getting your feet wet in the world of Nexmo APIs, chances are that you've come across webhooks. That's great! They are a perfect way to get notified about events like incoming SMS, delivery receipts and a variety of voice call events. There's a catch though. When building webhook consumers, you need a publicly accessible URL to configure the API service with. Without exposing your server to the internet, there is no way of receiving messages on your webhooks. If you're developing on localhost, this is where [Ngrok](https://ngrok.com/) comes into play.

## What Is Ngrok and Why Would You Use It?

Ngrok is a cross-platform application that exposes your local server to a unique *ngrok.io* subdomain over secure tunnels. By default, it creates both HTTP and HTTPS endpoints, making it useful for testing integrations with third-party services or APIs that require valid SSL/TLS domains. 

Another option would be deploying your code to a remote server. Although using these kinds of services is getting easier all the time, there's usually some cost and time commitment involved. Also, re-deploying your code every couple of minutes while debugging might get slightly frustrating.

Exposing your local server to the internet with ngrok only takes one command in your terminal, once you've installed it on your local machine. Read [Aaron's blog post](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) to find out more about this option.

![An image showing the output of an ngrok tunnel in the Terminal](/content/blog/getting-started-with-ngrok-in-node-red/ngrok-terminal.png)

In case you'd rather not leave your Node-RED editor, you could use the [**`ngrok`** node](https://flows.nodered.org/node/node-red-contrib-ngrok) for the same functionality.

![An image showing Ngrok layout in NodeRed](/content/blog/getting-started-with-ngrok-in-node-red/ngrok-nodered.png)

After you specify the port that Node-RED listens on (usually 1880), the ngrok client initiates a secure connection to the ngrok server and then anyone can make requests to your local server through the ngrok tunnel address.

- - -

**Security Concerns**

By running this node, you will be exposing your Node-RED install to the public internet, therefore you are strongly advised to [set an admin password](https://nodered.org/docs/security) on the editor. 

- - -

## Setting up Ngrok in Node-RED

### Install the `node-red-contrib-ngrok` Package

First, you'll need to install the ngrok node. To do so, open up *Manage palette* from the hamburger menu in your Node-RED editor, search for the `node-red-contrib-ngrok` package and click install. After restarting your editor, the **`ngrok`** node should appear in the node palette.

![Image showing managing the palette in NodeRed](/content/blog/getting-started-with-ngrok-in-node-red/ngrok-manage-palette.png)



### Configure Ngrok

The `ngrok` node takes the strings **on** or **off** as input to start/stop the tunnel, and outputs the ngrok host address as the msg.payload.

The easiest way to set this up is to wire two `inject` nodes as the `ngrok` node's input, one with the payload of the string **on** and the other with **off**. For easier use, you could also set the `Name` of these nodes accordingly in the node properties, so that it's clear what functionality they have.
Next, to display the host address in the debug sidebar, connect a `debug` node after `ngrok`.

As the last step before hitting **deploy**, open up the `ngrok` node properties and specify the port number. In the case of Node-RED, the default value is `1880`. The default ngrok Region is the US but you can also set it to Europe or Asia. You can also add your authtoken for your ngrok account if you have one. Don't worry if you don't, just skip this step for now. The node will warn that it is not fully configured but this is not an issue.

![An image of NodeRed showing how to set various properties for Ngrok](/content/blog/getting-started-with-ngrok-in-node-red/ngrok-node-properties.png)

You're all set! Once you hit deploy and click on the **on** `inject` node's button, navigate to the URL displayed in the debug area to find your Node-RED editor at a public address.

This tunnel will live for 8 hours and your editor is now publicly available on the internet. After 8 hours you'll need to restart your tunnel and you will be provided with another randomly generated ngrok subdomain.
It's a great way to quickly share local demo or proof of concept applications as well, but don't forget that anyone who knows the URL will be able to modify your flow. Therefore you are strongly advised to [set an admin password](https://nodered.org/docs/security) on the editor.

### Extra Steps

Although your ngrok tunnel is up and running and everything you've done so far doesn't require you to have a ngrok account, it might still be worth [creating one](https://dashboard.ngrok.com/get-started).

If you choose to sign up for a free account, you can then authenticate with ngrok in the `ngrok` node by providing your `authtoken` and your tunnel will no longer be limited to 8 hours. The subdomain name will still be randomly generated, but it will remain the same. Get your `authtoken` from <https://dashboard.ngrok.com/auth> and paste it into your `ngrok` node properties.

![An Ngrok display showing how to retrieve your AuthToken](/content/blog/getting-started-with-ngrok-in-node-red/ngrok-authtoken.png)

The package comes with 1 online ngrok process, 4 tunnels/ngrok process and 40 connections/minute. It's a great solution for quick demos and simple tunnelling needs.

You can also check out their paid \[subscription plans](https://dashboard.ngrok.com/billing/plan) if you're looking for even more features, including custom subdomains, reserved hostnames, IP whitelisting, an increased number of processes/tunnels/connections etc.

## Useful Ngrok Features

### Dashboard

This web interface running locally on your machine, normally on \[port 4040](http://127.0.0.1:4040/), provides valuable insight into your tunnel. You can easily inspect the status of your tunnel, details about requests you've made through it and the responses received, including all header content. Make sure you have a good look at everything under the *inspect* tab, as this can be invaluable when debugging API interactions.

![An image showing the Ngrok dashboard](/content/blog/getting-started-with-ngrok-in-node-red/ngrok-dashoard.png)



### Replay requests

The best part about the dashboard? You can **replay** requests or replay them **with modifications**. For example, if you have a flow that captures inbound messages from the Nexmo SMS API, rather than having to send yet another SMS to trigger the webhook, you can simply replay the last inbound SMS request. That's powerful! 

![A gif showing how to trigger webhooks in Ngrok](/content/blog/getting-started-with-ngrok-in-node-red/replay-ngrok.png)



## Where Next?

In this tutorial you've learned how to expose your local server to the internet with the power of Node-RED. Want to see it in action? Pick one of our Node-RED tutorials and carry on! 

If you've followed along with this one, you already have a tunnel running, so feel free to skip the *Exposing your local server to the internet* part. 

* \[Sending Group Notifications with Google Sheets and Node-RED](https://learn.vonage.com/blog/2020/03/06/sms-notifications-google-sheets-nodered-dr)
* \[How to Build an IVR using Node-RED and the Nexmo APIs](https://learn.vonage.com/blog/2020/01/08/interactive-voice-response-node-red-dr)
* \[Build Your Own Voicemail With Node-RED and the Nexmo Voice API](https://learn.vonage.com/blog/2019/11/14/build-voicemail-node-red-voice-api-dr)
* \[Forward a Call via a Voice Proxy with Node-RED](https://learn.vonage.com/blog/2019/10/17/forward-call-via-voice-proxy-node-red-dr)
* \[Build a Conference Call with Node-RED](https://learn.vonage.com/blog/2019/10/07/conference-call-node-red-dr)
* \[Verify Phone Numbers with Node-RED](https://learn.vonage.com/blog/2019/09/25/verify-phone-numbers-with-node-red-dr)
* \[How to Make Text-to-Speech Phone Calls with Node-RED](https://learn.vonage.com/blog/2019/06/14/make-text-to-speech-phone-calls-node-red-dr/)
* \[How to Receive Phone Calls with Node-RED](https://learn.vonage.com/blog/2019/05/09/receive-phone-calls-node-red-dr/)
* \[How to Send SMS Messages with Node-RED](https://learn.vonage.com/blog/2019/04/17/send-sms-messages-node-red-dr/)
* \[How to Receive SMS Messages with Node-RED](https://learn.vonage.com/blog/2019/04/24/receive-sms-messages-node-red-dr/)

### More About Ngrok

* \[How it works](https://ngrok.com/product)
* \[Docs](https://ngrok.com/docs)