---
title: Create a Personal Twitch with Vonage Video API and Web Components
description: By integrating the Client SDK UI Web Components into the Vonage
  Video API Broadcast Sample App, the user can live stream themselves along with
  guests to an audience and interact via text chat.
thumbnail: /content/blog/create-a-personal-twitch-with-vonage-video-api-and-web-components/personal-twitch.png
author: dwanehemmings
published: true
published_at: 2021-12-15T10:24:41.091Z
updated_at: 2022-03-24T10:33:37.105Z
category: inspiration
tags:
  - video
  - javascript
  - twitch
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
*Post has been updated to include the Vonage Video API March 2022 Release with an increase in simultaneous live interactive participants, low latency HLS broadcasts, and the new Vonage Experience Composer.*

To start, let’s define some things and set expectations. Twitch is a gigantic platform that allows people to broadcast and interact with viewers. From [Wikipedia](https://en.wikipedia.org/wiki/Twitch_(service)):
“As of February 2020, it had 3 million broadcasters monthly and 15 million daily active users, with 1.4 million average concurrent users.”

Building something of that scale takes way more than what can be learned in a single blog post. Instead, the scope of this post will be geared towards creating more of a “personal Twitch”. Less pop star stadium-sized concert and more local/independent artist in a coffee shop. A place where the person broadcasting can actually read the messages in the chat room.

So at its core, the final application will allow a host to broadcast themselves along with guests to an audience and interact with them via text chat. Plus, it’s an opportunity to show how you can integrate Web Components into an existing application to add additional functionality.

The aforementioned existing application is the [Broadcast Sample App](https://github.com/opentok/broadcast-sample-app) created to showcase the broadcasting capabilities of the Vonage Video API. To add a text chat, the [Client SDK UI Web Components](https://github.com/nexmo-community/clientsdk-ui-js) will be used.

## Broadcasting Video

The Vonage Video API offers two ways to share video sessions with audiences.

[Live interactive video broadcasts](https://tokbox.com/developer/guides/broadcast/live-interactive-video/) - This option has presenters (host and guest) as well as viewers connected to the video session. Presenters are publishing and subscribing to each other's audio and video streams while the viewers are just subscribing to the presenters’ individual streams. (Note: Viewers can be allowed to publish their streams since they are already connected to the session.) Since everyone is subscribing to everyone else’s stream, the latency is lower, but there is an upper limit to the number of participants based on the number of publishing streams. That limit is 15,000 simultaneous live interactive participants. There’s a handy table in the docs to help determine the number of viewers possible.

[Live streaming broadcasts](https://tokbox.com/developer/guides/broadcast/live-streaming/) - The presenters are still publishing and subscribing to each other's streams, but there is a combined single broadcast stream that the viewers consume. Merging the streams will add some latency for the viewer. Both HLS and RTMP streams are available to broadcast. The latest release introduces a low latency HLS broadcast option that greatly reduces the latency to around 4 to 6 seconds. This option is closer to how Twitch, YouTube, Facebook, and others handle live streams. There is also the new HLS DVR option that allows viewers to pause and resume live broadcasts.

The Vonage Video API broadcast sample can do both, but we will focus on the live streaming broadcasts option here for our personal Twitch application.

## Text Chat

What’s a Twitch live stream without a chat? To add that functionality, the [Client SDK UI Web Components](https://github.com/nexmo-community/clientsdk-ui-js) will be used. More specifically, the `vc-messages`, `vc-text-input`, and `vc-typing-indicator` elements will be integrated.

## Combining The Two

Adding Web Components to an existing application you didn’t create can involve taking a few more considerations than if it were a new project or one that you are currently building. Here are some things I went through when adding a chat to the Broadcast sample app.

Does the existing application even have room for the addition of the Web Components? Depending on the layout, some rearranging may be required. It helps to plan out ahead of time what you want the final outcome to look like and then dive into the code to see what needs to be moved around. Luckily, the Broadcast sample app’s layout wasn’t too complex. Just had to make the video section a little more narrow to create some room for the chat interface. This involved mostly CSS.

To more seamlessly integrate the chat into the application, you can [style the Web Components](https://learn.vonage.com/blog/2021/10/18/styling-web-components/) to match other UI elements.

We just covered fitting the Web Components into the user interface of the application, but what about fitting in with the user experience? What things do the Web Components need to function and are they already available in the application?

For example, the chat requires a username so that everyone knows who typed what message. It wouldn’t be a great experience if after logging into an application with a username and password, the user would again have to enter their username to join the chat. The scope of the Broadcast sample app did involve logging in, so I just added an input field for the user to add the username they would like to use in chat.

The Client SDK UI Web Components also need to know the Conversation Id so that it can send and display the messages in the right chat. The Broadcast sample app uses parameters in the URL to pass some information about the stream, I just added another one for the Conversation Id so that everyone joins the same chat.

One more thing. Have you ever gone to a page on Twitch where there is a live stream and the video was playing, but the volume was muted? Well, that is because of the [Autoplay policy](https://developer.chrome.com/blog/autoplay/) of many browsers. To be in line with the policy, I muted the broadcast video stream by default and added a button to toggle it off and on.

## The Final Product

If you would like to see the application created in action for yourself, you can remix the [Glitch project](https://glitch.com/edit/#!/remix/personal-twitch-demo?path=README.md%3A1%3A0). By running a setup script and entering a couple of API Keys and Secrets, you too can have your own personal Twitch.

## What's Next?

Keep a lookout for an upcoming blog post where we incorporate the new Vonage Experience Composer. Think of it as a way to screen capture your whole application (video streams, User Interface, chat, and all) that can be then used for recordings and/or broadcasting.

As always, if you have any questions or comments, feel free to connect with us in our [community Slack channel](https://developer.vonage.com/slack).
