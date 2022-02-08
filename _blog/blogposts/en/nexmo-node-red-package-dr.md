---
title: Announcing the Nexmo Node-RED Package
description: The Nexmo Node-RED package enables you to create flows for
  autoresponders, phone call IVRs, phone number verification, and sending SMS to
  multiple recipients.
thumbnail: /content/blog/nexmo-node-red-package-dr/NodeRED-Flow.png
author: sammachin
published: true
published_at: 2019-02-21T17:16:35.000Z
updated_at: 2021-05-12T03:13:35.939Z
category: release
tags:
  - javascript
  - node-red
comments: true
redirect: ""
canonical: ""
---
We strive to make programmable communications available to as many people as possible, but until now if you wanted to build with the Nexmo API platform you really needed to write code. So, today we’re really excited to share something with you that will lower the barrier to entry.

[Node-RED](https://nodered.org) is an open source project enabling “flow-based programming for the Internet of Things.” While it has seen some good adoption in traditional IoT use cases such as sensor networks and smart homes, we think that the potential application is far wider. Flow-based programming lends itself very nicely to programmable communications because phones are just another “thing” connected to the Internet, so controlling the progress of a call or sending and receiving SMS are very similar to IoT activities.

## Introducing node-red-contrib-nexmo v3

We recently adopted the [Nexmo Node-RED package](https://flows.nodered.org/node/node-red-contrib-nexmo) that had been developed by the community. We've updated it to provide functionality (nodes) for all Nexmo products that are in general availability ([SMS](https://developer.nexmo.com/messaging/sms/overview), [Voice](https://developer.nexmo.com/voice/voice-api/overview), [Verify](https://developer.nexmo.com/verify/overview) and [Number Insight](https://developer.nexmo.com/number-insight/overview)) and have published version 3 of `node-red-contrib-nexmo` as a beta release.

You can now create flows for things such as sending SMS to multiple recipients, creating autoresponders, building phone call IVRs or running phone number verification (e.g. 2FA). The Nexmo Node-RED package is perfect for prototyping call flows, allowing you to rapidly make changes and visualise the sequence of events.

![Editing an IVR Flow](/content/blog/announcing-the-nexmo-node-red-package/edit_ivr.gif "Editing an IVR Flow")

## Benefit from the Node-RED Ecosystem

One of the great things about Node-RED is that there’s a thriving ecosystem of other nodes to connect to different services. If you want to combine Nexmo communications with Slack to get a notification of an SMS inquiry from a customer or use IBM Watson to run sentiment analysis on your voicemails, you can combine the nodes to create that. The possibilities are endless.

![Adding a Slack Node](/content/blog/announcing-the-nexmo-node-red-package/node-red-slack.gif "Trigger a Slack Message from an inbound SMS")

If you can’t find a node to do what you need then Node-RED also offers the capability to create a block of custom JavaScript within your flow, giving you lower-level access if you're comfortable with programming.

There are thousands of developers and builders working with Node-RED to create all kinds of interactions and you'll find plenty of sample flows in the [Node-RED Library](https://flows.nodered.org/?type=flow&num_pages=1). You can also see a number of [Nexmo Node-RED flows](https://flows.nodered.org/?term=nexmo&type=flow&num_pages=1), such as the ones shown above, and we'll be adding more.

## Get Started with Nexmo and Node-RED

If you’d like to get started with Node-RED you’ll need to install the runtime and editor. There are all sorts of ways to do this, either on your local machine, on a device like a Raspberry Pi, or a number of cloud-hosted options. You can read how to get started in the [offical Node-RED docs](https://nodered.org/#get-started). If you’re running on your local machine you will need to use a local tunnel solution such as [ngrok](https://ngrok.com/) to expose your Node-RED server to the Internet so that the Nexmo platform can send webhooks. Check out our [blog post on using ngrok](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) and you can also find an [ngrok package](https://flows.nodered.org/node/node-red-contrib-ngrok) for Node-RED in the catalog.

If you're new to Node-RED but have some experience with programming you'll find some helpful examples of how to solve common problems in the [Cookbook](https://cookbook.nodered.org/).

Finally, this 5-minute video shows you how to get started with the Nexmo Node-RED package and walks through creating your first voice application.

<center><iframe width="560" height="315" src="https://www.youtube.com/embed/cfdNm1xII2A" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></center>

## Useful Links

* [Node-RED](https://nodered.org)
* [Nexmo NodeRED on Github](https://github.com/nexmo/nexmo-nodered)
* [Nexmo YouTube Channel](https://www.youtube.com/channel/UCHQnbTiun_Wn7nDxkQavrYQ)
* [Nexmo Extend](https://developer.nexmo.com/extend)