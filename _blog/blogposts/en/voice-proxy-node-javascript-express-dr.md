---
title: Proxy Voice Calls Anonymously with Express
description: In this tutorial, we'll learn how to create an anonymous voice
  proxy using Vonage Voice APIs, Nodejs, JavaScript and the Express framework.
  Protect your users' privacy by concealing their telephone numbers.
thumbnail: /content/blog/voice-proxy-node-javascript-express-dr/anonymous-voice-proxy-featured-image.png
author: aaron
published: true
published_at: 2018-05-22T14:53:51.000Z
updated_at: 2021-05-20T10:14:52.037Z
category: tutorial
tags:
  - node
  - voice-api
comments: true
redirect: ""
canonical: ""
---
We've all been there: you've gotten out of your cab and a few minutes later you realise you've left your umbrella behind. Alternatively, you're starving, staring out the window whenever you hear a car drive by, wondering where the food delivery you ordered an hour ago is.

![Girl waiting on delivery](/content/blog/proxy-voice-calls-anonymously-with-express/waiting-on-delivery.gif)

Perhaps it's the other way around. Maybe you're making a delivery and you need some directions to the address.

In all these situations you're going to need to call the other person, but you don't want to be giving your phone number out to strangers. So instead you can use [a virtual number](https://www.vonage.com/communications-apis/phone-numbers/) that connects the two parties but is only usable for the duration of the current transaction.

## Renting a Virtual Number

In this tutorial, we're going to use [the Vonage CLI](https://github.com/Vonage/vonage-cli) to rent our virtual number, but you can also manage your numbers and voice applications via [the Vonage dashboard](https://dashboard.nexmo.com/buy-numbers) if you'd prefer to use a GUI. If you haven't done so already, you can [install the Vonage CLI via npm/yarn](https://github.com/Vonage/vonage-cli#install-and-run-from-source). Full instructions are in the [Github repository](https://github.com/Vonage/vonage-cli).

At the time of writing, you can rent virtual numbers in 85 different countries. I'm going to use GB (Great Britain) in my example; you can see a [complete list of countries and prices on our pricing page](https://www.vonage.com/communications-apis/pricing/?icid=nexmo_rd).

```sh
vonage numbers:search GB
vonage numbers:buy [NUMBER] [COUNTRYCODE]
```

## Creating Our Voice Proxy Server

At the moment if you attempt to call the virtual number we just rented, nothing happens.

![Man on the phone](/content/blog/proxy-voice-calls-anonymously-with-express/on-the-phone.gif)

We have to associate the virtual number with an application. You can link multiple numbers to the same voice application, allowing you to have multiple numbers—even in different countries—all powered by a single backend.

In this example, we're going to create our backend with Node and Express and deploy it on [Glitch](https://glitch.com/). You can [view the code on Github](https://github.com/nexmo-community/anonymous-voice-proxy-glitch-server) or [remix it directly on Glitch](https://glitch.com/edit/#!/remix/jungle-pigeon).

[![Remix on Glitch](https://cdn.glitch.com/2703baf2-b643-4da7-ab91-7ee2a2d00b5b%2Fremix-button.svg)](https://glitch.com/edit/#!/remix/jungle-pigeon)

Our Express server has a single endpoint, which looks like this:

```javascript
    app.get("/", (request, response) => {
        response.json([
            {
                "action": "connect",
                "eventUrl": [`${process.env.EVENTS_URL}`],
                "from": `${process.env.FROM_NUMBER}`,
                "endpoint": [
                    {
                        "type": "phone",
                        "number": `${process.env.TO_NUMBER}`
                    }
                ]
            }
        ])
    })
```

The route defined above returns an [NCCO (Call Control Object)](https://developer.vonage.com/voice/voice-api/ncco-reference), a JSON file that is used to provide instructions to the Vonage API when someone answers an inbound or outbound call. An NCCO can contain many different types of actions. You can [view the available actions in our developer docs](https://developer.vonage.com/voice/voice-api/ncco-reference).

Our proxy server requires a single action [`connect`](https://developer.vonage.com/voice/voice-api/ncco-reference#connect). With this, we can proxy our incoming call to a range of different endpoints: another phone number, a WebSocket, or even a SIP URI. In the example above we connect to another phone number.

One of the requirements of the `connect` action is that the `process.env.FROM_NUMBER` *must* be a Vonage Virtual Number. This virtual number is what your call recipient sees. You can use the same virtual number you rented above, that way your caller and callee see the same virtual number, keeping their numbers private.

When you [remix the app](https://glitch.com/edit/#!/remix/jungle-pigeon), you need to configure the `FROM_NUMBER` and `TO_NUMBER` in your Glitch `.env`  file. These numbers need to be in the [E.164 format](https://en.wikipedia.org/wiki/E.164). We're not using the `EVENTS_URL` in this example, but if you're interested in how you can track analytics about your voice calls, then you should watch our webinar ["Inbound Voice Call Campaign Tracking with Vonage Virtual Numbers and Mixpanel"](https://www.youtube.com/watch?v=gm-XUvUwgyc) or [read the accompanying blog post](https://learn.vonage.com/blog/2017/08/03/inbound-voice-call-campaign-tracking-dr/).

## Linking Our Virtual Number to Our Proxy Server

To link our virtual number to our proxy server on Glitch we first need to create a [Vonage Voice Application](https://developer.vonage.com/application/overview). You can [create a voice application and link it to your number using the Vonage dashboard](https://dashboard.nexmo.com/voice/create-application), or via [the Vonage CLI](https://github.com/Vonage/vonage-cli).

```sh
     vonage apps:create "Application name"  --voice_answer_url=<GLITCH_URL> --voice_event_url=<EVENTS_URL> 
     vonage apps:link --number=<NUMBER> <APP_ID>
```

The [Application Overview](https://developer.vonage.com/application/overview) and the [Vonage CLI README](https://github.com/Vonage/vonage-cli#readme) contain more information on `apps:create` and the expected arguments.

## Where to Next?

Read the "[private voice communication](https://developer.vonage.com/use-cases/private-voice-communication)" tutorial for a more in-depth example. For an example of [the proxy server in Kotlin, watch my webinar](https://www.youtube.com/watch?v=pHf9Df3Ns2U). Alternatively, for more information on what else you can do with [Vonage Voice APIs](https://www.vonage.com/communications-apis/voice/?icmp=hibox_voiceapi_novalue) view our [example use cases](https://www.vonage.com/communications-apis/programmable-solutions/) or read [the developer documentation](https://developer.vonage.com/voice/voice-api/overview).