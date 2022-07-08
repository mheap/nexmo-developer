---
title: Call Control Objects (NCCOs) | One Dev Minute
description: Welcome to One Dev Minute! The goal of this video series is to
  share knowledge in a bite-sized manner. Let's learn about Call Control
  Objects.
thumbnail: /content/blog/call-control-objects-nccos-one-dev-minute/thumbnail-and-assets-for-one-dev-minute-1-.png
author: amanda-cavallaro
published: true
published_at: 2021-10-20T10:51:18.158Z
updated_at: 2021-10-07T20:55:54.833Z
category: tutorial
tags:
  - voice-api
  - javascript
  - nodejs
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Welcome to [One Dev Minute](https://www.youtube.com/playlist?list=PLWYngsniPr_mwb65DDl3Kr6xeh6l7_pVY)! This series is hosted on the [Vonage Dev YouTube channel](https://www.youtube.com/vonagedev). The goal of this video series is to share knowledge in a bite-sized manner. 

In this video, Amanda Cavallaro, our Developer Advocate, talks about the Call Control Objects, which are a set of actions that instruct Vonage how to control the call to your Vonage application. For instance, you can connect a call, send synthesized speech using talk, stream audio, or record a call.


<youtube id="26rm0MP2up0"></youtube>

## Transcript

A Call Control Object - or an NCCO - is a set of instructions that a voice call will follow.

An NCCO is composed of one or more actions. Their order is important, as it describes the flow of the call. Options are used to customize an action. A Call Control Object is represented by a JSON array.

In this example, we can see a connect action with the options to make a call from a given number to an endpoint of type phone with a number.

This second example is similar to the first one, but instead, it makes a call from a given phone number to an endpoint of type app, connecting to a client app, and we are also sending updates from the event URL. 

You can join multiple calls into one conversation conference call.
In this example, you can see one action talk with a descriptive text showing you’re joining a conference. It's followed by an action that creates the conversation for the conference call.

We can also leverage speech recognition. Here’s a code snippet that shows how to handle a user's input.

We can accept Dual Tone Multi Frequency (DTMF), speech, or both.

You can learn further from the links below.

## Links

More resources related to NCCO:

[NCCO Guide](https://developer.vonage.com/voice/voice-api/guides/ncco)

[NCCO Reference](https://developer.vonage.com/voice/voice-api/ncco-reference)

[NCCO Examples Collection](https://learn.vonage.com/blog/2019/10/25/introducing-the-ncco-examples-collection-dr/)

[Call Flow](https://developer.vonage.com/voice/voice-api/guides/call-flow)


Join the [Vonage Developer Community Slack](https://developer.nexmo.com/community/slack)
