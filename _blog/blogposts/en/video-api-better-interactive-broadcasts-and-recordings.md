---
title: "Video API: Making Interactive Broadcasts and Recordings Better for You"
description: Vonage multiparty video reaches 5,000 live interactive
  participants, improving interactive broadcast quality, layouts and recording
thumbnail: /content/blog/video-api-better-interactive-broadcasts-and-recordings/videoapi_updates_1200x600-1-.png
author: jon-montana
published: true
published_at: 2021-05-11T08:11:10.597Z
updated_at: 2022-02-23T13:37:22.648Z
category: release
tags:
  - video-api
  - release
  - multiparty
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
*March 2022 Update: Tripling interactive participants to 15,000, introducing Experience Composer and LL-HLS.*

Vonage multiparty video reaches ~~5,000~~ – now 15,000 – live interactive participants, improving interactive broadcast quality, layouts and recording

We continue to work hard on improving interactive broadcasts with even more participant streams (now with up to 15,000 REAL TIME participants!), a brand new Experience Composer, low-latency live streaming, full HD broadcasts, as well as improvements to on-screen layouts and overall video quality of interactive broadcasts and recordings.

The Vonage Video API has long offered the ability to [compose video layouts for broadcasting and recording](https://www.vonage.com/communications-apis/video/features/interactive-broadcast/) in real-time as the video conversation occurs and streaming to an unlimited number of viewers with live streaming and to social platforms, like Facebook Live or Twitch.tv. Of all the exciting differentiating features we are adding this year, the Experience Composer - released in Beta - is the biggest game changer, enabling our customers to compose not just the video streams, but the entire surround experience, their built-for-purpose application UX, as well. Jump directly to [Experience Composer](#experience-composer).

## Broadcast Interactive

Virtual events companies grew like mushrooms last year as organizations needed smart ways to securely connect people with events and enable them to take part, whether in person or virtually. A virtual event typically combines a live stream with audience participation. This interactive element helps maximize opportunities for member engagement and meeting attendance, whether members are attending in person or online.

2020 demonstrated that anyone could benefit from attending a virtual event. Remote events, when done thoughtfully, can be very effective. The purpose-built experience allows for specialized stage environments with text-based audience interactions like Q&A and voting, while the breakout rooms allow for networking and open exchange of ideas.

The move to virtual services during the last two years has necessitated rapid digital transformation. Virtual town halls became one of the trademark features of corporate and civic organizations attempting to stay in touch with their people.

*“With Vonage’s Video API, we are able to keep users within our ecosystem, allowing us to ensure that both local authority employees and members of the public can join meetings, communicate, and view secure and easily accessible information from any device.” - Steven Garratt, CIVICA Modern.Gov.*

## These Times, They Call for... *More*

As with the rest of our lives, the global pandemic impacted our use of video, be it broadcasting or recording. As more of your customers are joining video sessions, these sessions got longer with more participants and with various devices - the recordings and broadcasts needed to keep up, too! The world our platform was initially designed for has changed, and we threw ourselves into identifying the features most needed to keep up.

### More Interactive Participants with WebRTC

In a [live interactive video broadcast](https://www.tokbox.com/developer/guides/broadcast/live-interactive-video/), a large number of clients can communicate in real time by publishing and subscribing to each others' streams in the session. The latest platform update increased the number of live interactive participants supported in a video broadcast session, up to 15,000 - depending on the number of active publishers in the session.

For example, when there are 1 or 2 published streams in the session, up to 15,000 participants can view both of these published streams in real-time as interactive broadcast participants. When there are 3 published streams in the session, up to 12,000 participants can view all published streams, and so on. With an interactive broadcast, the Vonage Video Router will forward all publisher streams to any of the subscribing participants, allowing applications to be independently dynamic about how the video is presented to each of the subscribing participants. Please reference the [developer guide](https://tokbox.com/developer/guides/broadcast/live-interactive-video/) to learn more about  the number of live interactive broadcast participants that can subscribe to all the publishers of the session.

Learn more about the new limits and how to build your app to support interactive broadcasts in our [Live interactive broadcasts developer guide](https://www.tokbox.com/developer/guides/broadcast/live-interactive-video/).

### More In-Sync Live Participants with Low Latency HLS

With an already large capacity of 15,000 real-time viewers via WebRTC, Video API can take your video sessions to ever-greater audiences with a single composed stream,  leveraging HTTP Live Streaming (HLS), and beyond to eyeballs on Facebook Live, Twitch and YouTube Live.

However, live streaming can be useful for more than just getting to more eyeballs! One advantage of streaming is, while limiting flexibility compared to multiple streams, a single stream can be used to reach viewers on restricted networks or older devices. The downside of live streaming compared to the real-time video is that streaming audiences experience the event with a slight delay, but this does not make them passive participants. Live audiences make for highly engaged chat participants, engage in polls and even ask questions. And with the introduction of Low Latency HLS in Vonage Video API, the gap between live and interactive is narrowing down to a blink (from something like a sigh, or two). [Learn more](https://learn.vonage.com/blog/2020/05/14/broadcast-video-chat-with-javascript-and-vonage-dr/) about broadcasting video Chat.

Low Latency HLS (LL-HLS) is an addition to the Apple HLS standard (and not a new streaming protocol) enabling latencies down to 4-6 sec, compared to standard HLS latencies in the order of 15-30 sec.

The low latency addition is supported natively by iOS devices and is also backward compatible with standard HLS players, meaning that the new manifest files are produced so that players that do not support LL-HLS can ignore the new standard and just play the files as standard HLS.

### <a name="interactive-live">Interactive vs Live, what’s the difference?</a>

A quick overview of the two methods Vonage Video API employs for broadcasting.

|                | WebRTC, or Interactive Broadcasts                                                                                                                                                                                                                                                     | HLS and LL-HLS Live Broadcasts                                                                                                                                                                                                                                                                                                                    |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Latency        | Presenters interact with audiences and other presenters by subscribing to each other's real-time media and signaling with sub-second latency (for chat, polls, etc.)                                                                                                                  | Presenters' composed media stream reaches audiences close to real-time. 1) With NewLow-Latency HLS (LL-HLS) the delay is down to 4-6 seconds, barely noticeable for chat and Q&A sync 2) HLS streaming creates latency of around 15+ seconds. Real-time signaling may still be deployed for chat, polls and other interactive application elements |
| Capacity       | Video API currently supports any number of on-screen presenters and up to 15,000 audience participants - depending on the number of active publishers in the session ([learn more](https://tokbox.com/developer/guides/broadcast/live-interactive-video/) about interactive capacity) | This type of broadcast allows the event to reach an unlimited number of viewers at low latency and stream directly to social platforms such as Facebook Live, YTlive, Twitch and others via RTMP                                                                                                                                                   |
| Implementation | Easy to implement with the standard Video API calls; your application controls the look and feel, no extra composition steps needed                                                                                                                                                   | Requires [stream composition](https://tokbox.com/developer/guides/broadcast/live-streaming/) to transmit the desired broadcast experience                                                                                                                                                                                                          |
| Flexibility    | Easy to bring an audience member "on stage" - just enable them to publish their video and audio streams!                                                                                                                                                                              | Requires additional coding to bring audience members "on stage" by switching the HLS participants to WebRTC mode                                                                                                                                                                                                                                   |
| Reach          | WebRTC is available on all modern browsers as well as on native clients for all major platforms. More on [WebRTC browser support](https://bloggeek.me/webrtc-browser-support/).                                                                                                       | Greater compatibility across browsers and better video performance over restricted networks and on older devices. More on [HLS browser support](https://developer.mozilla.org/en-US/docs/Web/Guide/Audio_and_video_delivery/Live_streaming_web_audio_and_video#video_streaming_file_formats).                                                      |

### <a name="experience-composer">More Power to Compose the Experience</a>

Our customers have always built personalized experience applications using the Video API. These applications often enable rich user and customer experiences for the participants which go beyond the basic media streams and encompass web native components, custom layouts, custom application look & feel, chat widgets, emojis, whiteboards etc. This trend has become more prevalent due to the pandemic as more and more in-person experiences such as learning, conferences, meetups and events have moved online.

Experience Composer enables developers to programmatically capture personalized experiences offered by their applications and provides them with a composite media stream which can be broadcast or recorded for a more immersive on-demand viewing experience.

Imagine a distributed group of scientists or product designers unveiling a new idea using simulations, voting tools, chat and whiteboards – in addition to videos of the presenters – and wanting to easily share all of these elements with tens of thousands of engaged audience members or preserve the live event, just as it happened, for posterity. Vonage Experience Composer does that.

Application experiences captured by the Experience Composer include video backgrounds and overlays, like watermarks, real time audience interaction, chats, emojis, whiteboard or any other programmed application user interfaces. To get started with the Experience Composer, please reference the [developer guide](https://tokbox.com/developer/guides/experience-composer) to video composition.

### Full HD Interactive Broadcast

To give your events the big screen appeal, we are adding Full HD (1080p) support within the Vonage Video API clients, letting you broadcast the highest resolution available today to any device that supports it, in both relayed and routed sessions, and few to many live broadcast sessions.\
The support for 1080p is being optimized through the use of simulcast so that multiple layers of video can be published and routed to clients based on the bandwidths that they have available to them.

### Play, Pause and Resume HLS Streams

As an enhancement to standard HLS broadcasts, we are enabling DVR functionality that allows participants to pause, resume and rewind the live HLS broadcasts when enabled.\
The feature is compatible with all HLS players and will provide a 2 hour rewind history for broadcasts.
*It should be noted that the DVR feature can only be enabled on standard HLS streams and is not available when LL-HLS is active.*

### More Video and Audio Participant in Composed Views

In a recent platform update, we increased the maximum number of video and audio streams viewable in [a composed recording](https://tokbox.com/developer/guides/archiving/#individual-stream-and-composed-archives) or a [composed live streaming broadcast](https://tokbox.com/developer/guides/broadcast/live-streaming/) for all customers. To accommodate more video participants and video streams in the composed layout, we increased the maximum number of supported video streams from 9 to 16. Similarly, we increased the number of audio-only participants from 9 to 50 total participants in recordings and broadcasts.

For example, our Best Fit layout type will automatically increase to a 4x4 grid layout, and customers have the option of customizing it to display up to 16 video streams. For audio, the first 50 audio streams published to the session will be included in the recordings and broadcasts.

> Developer Guide: Learn the best practices of [broadcasting interactive sessions via HLS and/or RTMP streams](https://learn.vonage.com/blog/2020/09/22/dynamic-layouts-in-hls-rmtp-broadcasts-with-the-video-api-dr/).

### Longer Recordings With Better Sound Quality

The [Vonage Video Recording API](https://tokbox.com/developer/guides/archiving/) has been updated to double the maximum video recording time to 240min so users can record longer meetings and video sessions. Automatic recording sessions will restart recording at 4hr length files. Additionally, audio in the recorded files and broadcasts is now recorded at a higher bitrate, MP4 files encoded with AAC at 128kbps, allowing higher fidelity audio to benefit application use cases.

### Enhanced Screen Share Layouts and Stream Prioritization

The Video API allows users the flexibility to [customize the video layout](https://tokbox.com/developer/guides/archiving/layout-control.html) and even dynamically change the video layout while [recording](https://tokbox.com/developer/guides/archiving/layout-control.html#changing-layout-type) or [broadcasting](https://tokbox.com/developer/guides/broadcast/live-streaming/#changing-layout-type).

The new [Screen Share Layouts](https://tokbox.com/developer/guides/archive-broadcast-layout/#screen-sharing-layouts) prioritize screenshare streams so that the user’s presentation or content share always takes precedence in the recording or broadcast. Customers can use this feature and [Layout Stream Prioritization Rules](https://tokbox.com/developer/guides/archive-broadcast-layout/#stream-prioritization-rules) to make sure presentations, screen shares, and selected streams get priority in recordings and broadcasts.

![ Picture-in-Picture, Vertical Presentation and Horizontal Presentation Layouts](/content/blog/video-api-better-interactive-broadcasts-and-recordings/screenshot-2021-05-10-at-22.33.29.png " Picture-in-Picture, Vertical Presentation and Horizontal Presentation Layouts")

> Developer Guide: Learn how to build a [JS application for multiple screen share streams](https://learn.vonage.com/blog/2021/03/11/share-screens-together-with-your-friends-and-co-workers/).

### Portrait Layout

As people adapt to their remote environments, we also saw the need to support vertical compositions suitable for mobile devices in portrait orientation. To that end, we added support for portrait layout resolutions, portrait SD (480x640) and portrait HD (720x1280) for both recording and interactive broadcasting. Our predefined layouts have been optimized for these portrait orientations to adapt automatically for mobile orientation views.

![Portrait Layout](/content/blog/video-api-better-interactive-broadcasts-and-recordings/vertical-composing.png "Portrait Layout")

### Cloud Recording and Broadcast Quality

Lastly, we also updated our video platform with a number of optimizations at our real-time cloud composition servers to improve video synchronization and resilience of real-time composed recordings and broadcasts under poor network conditions. These improvements ensure that sessions are recorded or live streamed properly, even when publishers find themselves in adverse network conditions. (Learn more about our work on quality improvements and a [comparative benchmark VS our top competitors](https://www.vonage.com/about-us/vonage-stories/video-quality-webrtc-live-interactions-post-covid1/)).

## Privacy, Please

When it comes to video broadcasts and recordings, privacy and security related features may be required. Vonage Video API already comes with always-on encryption and other features designed to protect users' information. With [encryption](https://tokbox.com/developer/guides/archiving/opentok-encryption.html), customers can ensure that their recorded data can be stored securely to maintain user privacy and comply with regulations, like GDPR. Learn more about Vonage [Video API privacy architecture](https://www.vonage.com/communications-apis/video/video-api-privacy-architecture/) and how it protects your users and your content.

## Getting Started

We are very excited to put the power of improved broadcasting and recording into the hands of our customers to ensure they can keep up with today’s communications demands. The features are already available in the [Vonage Video API](https://tokbox.com/account/) Standard and Enterprise environments so customers can gain immediate access to these improved capabilities.

If you liked this Video API update, check out our new [Video Express](https://learn.vonage.com/blog/2021/09/23/video-express-is-here-and-why-it%E2%80%99s-awesome/), and why it’s awesome!
