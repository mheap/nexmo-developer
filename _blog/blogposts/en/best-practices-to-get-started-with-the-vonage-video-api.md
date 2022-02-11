---
title: Best Practices to Get Started With Vonage Video
description: "Best practices we recommend for consideration, before you start
  building your feature-rich video application powered by Vonage Video API. "
thumbnail: /content/blog/best-practices-to-get-started-with-vonage-video/best-practices-videoapi_1200x627.png
author: simon-jones
published: true
published_at: 2021-05-24T15:41:01.908Z
updated_at: 2021-05-25T09:00:00.000Z
category: inspiration
tags:
  - video-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
This document describes some of the best practices we recommend for consideration before you start building your feature-rich video application powered by Vonage Video API.

[Visit our website](https://www.vonage.com/communications-apis/video) to set up your new account; it’s free and your account will automatically be credited ten US dollars ($10).

## Where to get more help?

Very detailed developer documentation on the Vonage Video API is publicly available on our [Video API Developer Site](https://tokbox.com/developer).

Here you will find all the details you need for basically any question you might have, sample codes, release notes. There is also a great section called “[Get answers to your Video API questions](https://support.tokbox.com/hc/en-us)”.

To help us better assist you, please send us your feedback via email at: [support@tokbox.com](mailto:support@tokbox.com)

## Video Platform

Vonage video uses webRTC for audio-video communications and consists of client libraries for web, IOS and Android, as well as server SDKs and REST API. More information can be found here <https://tokbox.com/developer/guides/basics/#opentok-platform>.

Key Terms:

* Video API does not have a concept of username or log in - they need to be created by the application. The platform uses tokens for authorisation.
* Session: A session is a logical group of connections and streams.  Connections within the same session can exchange messages. Think of a session as the “room” where participants can interact with each other. Sessions should not be reused as it makes troubleshooting difficult and your implementation potentially less secure.
* Connection: is an endpoint that participates in a session and is capable of sending and receiving messages.  A connection has presence, it is either connected and can receive messages, or it’s disconnected. 
* Stream: media stream between two connections. This means that actual bytes containing media are being exchanged. 
* Publisher: clients publishing stream.
* Subscriber: clients receiving stream.

## Environment

When designing a video application, consider having two environments; one for testing and one for production. To test simple items, you can also use our playground or you can use the Opentok command line.

1. Create a project key for lab and production
2. Link to opentok CLI - https://www.npmjs.com/package/opentok-cli
3. Link to playground - https://tokbox.com/developer/tools/playground_doc/

For Enterprise server customers, it is important to note that newly added API keys will be using the Standard environment by default. If you need to switch an API key’s environment from Standard to Enterprise, you can do so on our account portal. 

The Enterprise JS SDK is available at <https://enterprise.opentok.com/v2/js/opentok.min.js>. 

For more info, visit <https://tokbox.com/developer/enterprise/content/enterprise-overview.html>.

### API key/secret, Tokens and Session IDs

* API Key and Secret

  * Keep secret/key private by NOT exposing them to public repositories.
  * Do NOT save secret/key in client libraries/compiled mobile SDKs.
  * Use HTTPS only to make REST calls.
* Session ID

  * Always generate a new `sessionId` for every new session created.  
  * Sessions’ quality scores and data are indexed by `sessionId`. If there are multiple conversations per `sessionId`, it will be difficult to debug using Vonage’s inspector tool as reused `sessionIds` tend to report lower aggregate quality scores than the actual call quality experienced by end-users.
* Tokens

  * Your server that generates tokens must be placed behind a secured/authenticated endpoint
  * Always generate new tokens for each participant
  * Do not store or reuse tokens. 
  * By default, tokens expire after 24 hours, this is checked at connection time. Adjust the expiration as needed, depending on your use case and application. 
  * Add additional information to tokens (using the data parameter) such as usernames or other information that can identify participants, but NEVER use personal information. 
  * Set roles when applicable such as moderator, publisher and subscriber.
  * More information about tokens can be found at <https://tokbox.com/developer/guides/create-token/>.

## Media Server and Media Modes

* **Relayed** - this media mode does not use Vonage media servers. Before deciding whether to use relayed mode or not, be sure to check the following:

  * That recording is not needed
  * One-to-one and 3-party sessions only
  * Where direct media between participants is preferred
  * End-to-end media encryption is required

Note that media quality will not be managed in relayed mode since media is exchanged between clients. Therefore, setting the subscriber's frame rate and/or resolution will not work. See <https://tokbox.com/developer/guides/scalable-video/> for more information.

* **Routed** - this media mode uses Vonage media servers. Before deciding whether to use routed mode or not, be sure to check the following:

  * Three or more participants
  * May have a need to archive
  * Needs media quality control (audio fallback and video recovery)
  * May have a need to use SIP interconnect
  * May have a need to use interactive or live streaming broadcast

More information about media modes can be found at: <https://tokbox.com/developer/guides/create-session/>.

* **Audio Fallback** - In routed mode, Vonage SDK automatically falls back to audio-only mode if the bandwidth is too low to support video calls. However, if you want to override this behaviour this is possible by using [getStats()](https://tokbox.com/developer/sdks/js/reference/Subscriber.html#getStats) method to get real-time statistics about upload/download bandwidth, packet loss, frame rate etc. Based on this information you can estimate the quality and make some decisions, for example, cut-off video at a higher bandwidth level instead of showing low-quality video etc.
* **getStats Method** - in addition to implementing the custom audio fallback mentioned above, [getStats()](https://tokbox.com/developer/sdks/js/reference/Subscriber.html#getStats) polling can be used to capture information about the quality of the connection to display real-time information to the user as well as for troubleshooting purposes.

See the following example: <https://github.com/nexmo-se/opentok-get-stats>

* **Vonage Inspector Tool** - The inspector can be used to understand the media performance during the session, as well as which codecs, modes (relayed or routed), events and advanced features were used during the call.
  See <https://tokbox.com/developer/tools/inspector_doc/>

## Broadcast

* **Interactive** - this type of broadcast allows clients to interact with each other by subscribing to each other's stream. Important to note that this type of broadcast can only support up to 5,000 subscribers; anything above that will generate an error message. Below are things to consider when using this broadcast:

  * Contact support and have them enable simulcast. Visit <https://support.tokbox.com/hc/en-us/articles/360029733831-TokBox-Scalable-Video-Simulcast-FAQ> to learn more about Simulcast. By default Simulcast is set to heuristic in all API keys, this means that Simulcast will only kick in after the third connection joins the call (this is done to avoid Simulcast in one-to-one calls). Important to note that the first two connections won’t use Simulcast if it is set to heuristic.
  * Allow no more than five publishers. Keep in mind that the maximum number of subscribers will be impacted when streams increase. Broadcasts with 2 publishers support up to 5,000 subscribers
  * Suppress connection events, see <https://tokbox.com/developer/guides/broadcast/live-interactive-video/#suppressing-connection-events>
  * See <https://tokbox.com/developer/guides/broadcast/live-interactive-video/>for more information
* **Live Streaming** - this type of broadcast allows for more than 5,000 subscribers to subscribe to streams. There are two types of protocols available to broadcast video, RTMP (Real Time Messaging Protocol) and HLS (HTTP Live Streaming). Regardless of which one you choose, limit the number of publishers to five for a better experience.

### HLS vs RTMP

* HLS supports an unlimited number of subscribers where RTMP is limited by the RTMP delivery platform
* HLS is delayed by 15-20 seconds where RTMP, from Vonage’s platform, is delayed by five seconds; this does not include the delay from RTMP delivery platform however as they too will induce delay based on how they process video.
* HLS playback is not supported on all browsers but there are plugins that you can use such as flowplayer. *Playback allows users to go back, video scrubbing (rewind/fast forward) if you will, from the beginning of the live stream then back to the current live stream.*
* HLS/RTMP has a max duration of two hours. If the broadcast needs to go longer, change the max duration property (max is 10 hours).
* HLS/RTMP stream automatically stops sixty seconds after the last client disconnects from the session

To learn more about live streaming such as layouts, max duration and how to start/stop the live stream, visit <https://tokbox.com/developer/guides/broadcast/live-streaming/>.

## User Interface/Experience

* In general, it is recommended to read and follow the [UI Customization documentation (Web, iOS, Android, Windows)](https://tokbox.com/developer/guides/customize-ui/js/) and follow the sections that are relevant to your application.
* **Pre-call Test** - add a pre-call test where users’ device and connection will be subject to network and hardware test prior to joining a session. Remember to generate new `sessionIDs` for every test and let the test run for at least 30 seconds for more accurate results.

  * The general [Vonage Precall Test Tool](https://tokbox.com/developer/tools/precall) can be used by you and your customers for generic connectivity tests to the Video API
  * If you would like to integrate your own PreCall test and gather all the test data, there are several resources available to do so:

    * [iOS and Android Github Samples](https://github.com/opentok/opentok-network-test)
    * [Javascript Network Test Package](https://github.com/opentok/opentok-network-test-js)
  * You can also check how a Precall test can be embedded in a complete application by checking our [Live Meeting Demo](https://opentokdemo.tokbox.com/) and inspecting the [relevant source code](https://github.com/opentok/opentok-rtc/blob/master/web/js/precallController.js) of that demo to check how you can build it.
* Publishing/Subscribing video streams - include handlers

  * Completion Handlers can give you feedback when you try to connect, publish, subscribe or send signals to a video API session. They are described here:

    * [Javascript Exception Handling](https://tokbox.com/developer/guides/exception-handling/js/)
    * [iOS Exception Handling](https://tokbox.com/developer/sdks/ios/reference/Protocols/OTSessionDelegate.html)
    * [Android Exception Handling](https://tokbox.com/developer/sdks/android/reference/)
  * You can also listen for exception events on the OT object, which will throw exception events for more general errors that are described under [Exception Events](https://tokbox.com/developer/sdks/js/reference/ExceptionEvent.html)
  * When the connection has been established, you would usually publish audio and video and also subscribe to other participants' streams. When managing the Publishers and Subscribers in regards to UI, you can make use of the respective events of the publisher and subscriber instances, which can help you display useful information to users when specific events or exceptions occur. Publisher and Subscriber events can be different and are described here:

    * [Publisher Events (JS)](https://tokbox.com/developer/sdks/js/reference/Publisher.html#events)
    * [Subscriber Events (JS)](https://tokbox.com/developer/sdks/js/reference/Subscriber.html#events)
    * For Android and iOS, please see “Exception Handling” above
* **Audio Fallback** - our media server constantly checks network conditions and if it detects an issue with end users’ connection, it will automatically drop the video and continue with audio-only, if packet loss is greater than 15%; and, an event gets sent when this happens (eg. for iOS: [subscriberVideoDisabled:reason:](https://tokbox.com/developer/sdks/ios/reference/Protocols/OTSubscriberKitDelegate.html#//api/name/subscriberVideoDisabled:reason) and [subscriberVideoEnabled:reason:)](https://tokbox.com/developer/sdks/ios/reference/Protocols/OTSubscriberKitDelegate.html#//api/name/subscriberVideoEnabled:reason). It is recommended that such an event is displayed on the UI alerting impacted users that the quality of their connection dropped, switching to audio-only. The threshold to switch to audio-only is not configurable, more information can be found in these examples:

  * [Video Disabled Warning](https://tokbox.com/developer/sdks/js/reference/Subscriber.html#event:videoDisableWarning)
  * [Video Disabled Reason](https://tokbox.com/developer/sdks/ios/reference/Protocols/OTSubscriberKitDelegate.html#//api/name/subscriberVideoDisabled:reason:)
  * [Video Enabled Reason](https://tokbox.com/developer/sdks/ios/reference/Protocols/OTSubscriberKitDelegate.html#//api/name/subscriberVideoEnabled:reason:)

Audio fallback is enabled by default, however it can be disabled with the audioFallbackEnabled parameter. [See here](https://tokbox.com/developer/sdks/js/reference/OT.html).

* **Reconnecting to session** - when a participant suddenly drops from a session due to network-related issues, it will attempt to reconnect back to the session. For a better user experience, it is recommended that such events are captured and properly displayed to the UI letting the user know that it is attempting to reconnect back to the session. More information can be found [here](https://tokbox.com/developer/guides/connect-session/js/#automatic_reconnection).
* **Active speaker** - for an audio-only session, try adding an audio level meter so that participants can have a visual of who the current active speaker/s is/are. For video, try changing the layout where the active speaker gets more screen real estate. You can use the audioLevelUpdated event that gets sent periodically to make UI adjustments, more information can be found here <https://tokbox.com/developer/guides/customize-ui/js/ >
* **Loudness detector** - It is good practice to implement a loudness detector to identify when a given user who is muted is trying to speak. In this case, the [audioLevelUpdated](https://tokbox.com/developer/sdks/js/reference/AudioLevelUpdatedEvent.html) event will fire with audioLevel set to 0. Therefore, it’s necessary to use an AudioContext to avoid this situation. For reference, follow this [blog post](https://vonagedev.medium.com/how-to-create-a-loudness-detector-using-vonage-video-api-8dbcf93595a8).
* **Report Issue API** - <https://tokbox.com/developer/guides/debugging/js/#report-issue>. This allows the end consumer of the application to trigger a unique issue ID from the client-side. Our customer can store this issue ID and that can be used when raising a ticket with support. The issue Id will help to identify the unique connection ID that reported the problem and focus the investigation from support.

## Features

* **Chat (text messaging)** - you can send messages using Vonage’s signalling, <https://tokbox.com/developer/sdks/js/reference/Session.html#signal>, but note that messages are not persistent on Vonage’s video platform. When adding text messaging functionality, keep in mind that some users may arrive/join a session after text messages were sent; latecomers will be unable to view messages that were sent. Additionally, should you decide to record a session, text messages will not be saved. To solve this problem, we recommend using the Nexmo client SDK (see the sample code, nexmo in-app messaging, at the end of this document.
* **Archiving** - there are two types of offerings when it comes to recording, composed and individual streams. Below talks about the difference between the two and things to consider

  * Composed

    * Can record up to 16 streams. Alternatively, we allow up to 50 audio-only streams
    * Single MP4 file containing all media streams
    * Customizable layout - <https://tokbox.com/developer/guides/archiving/layout-control.html>
    * Can be started automatically (240 minutes max. If the recording is not stopped, it will start archiving to a new file)
    * It is possible to prioritize certain streams to be included in the recording by assigning different layout classes. For example, screen-share streams  - <https://tokbox.com/developer/guides/archive-broadcast-layout/#stream-prioritization-rules>
  * Individual Stream

    * Can record up to 50 streams
    * Multiple individual streams/files saved in a zip folder
    * Intended for use with a post-processing tool to produce customized content
    * Cannot be started automatically
* **Storing archives** - Vonage will keep copies of archives for 72 hours if uploading fails, if cloud storage has not been configured or if the disable option for storage fallback is not selected. Keep in mind that should you decide to not enable upload fallback and uploading fails for whatever reason, that archives will be not recoverable.

  * AWS S3: Visit this site <https://tokbox.com/developer/guides/archiving/using-s3.html> for instructions on how to upload archive files to AWS.
  * Azure: Visit this site <https://tokbox.com/developer/guides/archiving/using-azure.html> for instructions on how to upload archive files to Azure.

### Archiving FAQs:

* Are archives encrypted? 

  * No. But one can add an encryption feature for archives. To learn more, visit <https://tokbox.com/developer/guides/archiving/opentok-encryption.html>
* Can you record just the audio or just the video?

  * Yes. Using REST, set the `hasVideo`/`hasAudio` to `true` or `false` - <https://tokbox.com/developer/rest/#start_archive>
* Can I name the archive so that I can identify them by name?

  * Yes. Using REST, set the name to the desired identifier `<String>` - <https://tokbox.com/developer/rest/#start_archive>
* How can I check archives’ status?

  * Use the archive inspector. A great article written by one of our support engineers can be found here <https://support.tokbox.com/hc/en-us/articles/360029733871-Archiving-FAQ>
* Can I record certain streams from a session? 

  * No. All streams will be recorded and one will not have the ability to pick which streams he/she wants to be archived.

Important note on Safari browser when using archive - *To include video from streams published from Safari clients, you must use a [Safari OpenTok project](https://tokbox.com/developer/sdks/js/safari/). Otherwise, streams published from Safari show up as audio-only.*

* **Screen-share** - hide the publisher that sharing its screen to avoid the hallway mirror effect.

  * ContentHint: motion, detail, etc: This flag can and should be set after 2.20.

## Quality, Performance, and Compatibility

* **Devices** - for multi-party sessions, try to limit the number of participants as more participants require more processing power.

See below the number of participants that we recommend:

* Mobile = 4 (Engineering official statement supported up to 8 MAX)
* Laptop = 10
* Desktop = 15
* For **bandwidth requirements** please see: [What is the minimum bandwidth requirement to use OpenTok?](https://support.tokbox.com/hc/en-us/articles/360029732311-What-is-the-minimum-bandwidth-requirement-to-use-OpenTok-)
* **Proxy** - if users can only access the internet through a proxy, make sure that it is a “transparent” proxy or it must be configured in the browser for HTTPS connection as 
  webRTC does not work well on proxies requiring authentication. Check out our network check flow - <https://tokbox.com/developer/guides/restricted-networks/>
* **Firewall** - at minimum, below are the ports and domains that need to be included on firewalls’ rules:

  * TCP 443
  * FQDN: tokbox.com
  * FQDN: opentok.com
  * STUN/TURN: 3478

If allowed, try opening the following range: UDP 1025 - 65535. This range covers port ranges that will provide users the best experience possible. This will also eliminate the need for TURN; not relaying media through such network elements decreases latency.

* **Codec** - link to codec compatibility <https://tokbox.com/developer/guides/codecs/>. Vonage supports VP9, VP8 and H.264 codecs; however, VP9 is only available on relayed media mode on sessions where ALL participants are using Chrome.

Difference between VP8 and H.264:

* VP8 is a software codec, more mature and can handle lower bitrates. 

Additionally, it supports scalable/simulcast video.

* H.264 is available as software or hardware depending on the device. It does not support scalable video or simulcast.

By default, the codec is set to VP8. If you need to change the assigned codec for a particular project key, log in to your portal to make the change.

## Session Monitoring

* Visit our dev page - <https://tokbox.com/developer/guides/session-monitoring/>
* Session monitoring allows you to register a webhook URL.
* Use this feature to monitor sessions and streams - an example of this is limiting the number of participants in a session, this is often used alongside forceDisconnect function for JS - <https://tokbox.com/developer/guides/moderation/js/#force_disconnect>. Moderator can also call an action to the server and have it do a REST call to force disconnect - <https://tokbox.com/developer/guides/moderation/rest/>
* Can be used to track usage (for better usage tracking, use Advance Insights - <https://tokbox.com/developer/guides/insights/#obtaining-session-data-advanced-insights->).

## Addons

It is possible now for Enterprise customers to purchase (or remove) add-ons with a single click. Refer to [this presentation](https://docs.google.com/presentation/d/16Q9XRznFLs5rl2DZFYt5Nwl1ibKj_j_y-9XQZ5C3VSc/edit#slide=id.gafa078777f_0_18) slide for the list of add-ons that can be configured via the self-service tool.

* SIP Interconnect

  * Get Started: <https://tokbox.com/developer/guides/sip/>
  * How to build a Phone Dial-in via SIP Interconnect: <https://learn.vonage.com/blog/2019/04/23/connecting-webrtc-and-pstn-with-opentok-and-nexmo-dr>
* Configurable TURN

  * Get Started: <https://tokbox.com/developer/guides/configurable-turn-servers/>
* IP Proxy

  * Get Started: https://tokbox.com/developer/guides/ip-proxy/
  * How to host on AWS: <https://support.tokbox.com/hc/en-us/articles/360046878351-How-to-install-and-configure-a-test-Proxy-Server-in-AWS>
* Regional Media Zones

  * Datasheet: <https://tokbox.com/pdf/datasheet-regional_media_zones.pdf>
* China Relay

  * What is it?: <https://support.tokbox.com/hc/en-us/articles/360029413612-What-is-China-Relay->
  * How does it work: <https://support.tokbox.com/hc/en-us/articles/360029732451-How-does-China-relay-work->
  * Why is it necessary?: <https://support.tokbox.com/hc/en-us/articles/360029411992-Why-is-China-relay-necessary->
* IP Whitelisting

  * <https://support.tokbox.com/hc/en-us/articles/360029732031-Can-I-get-a-list-of-the-IP-ranges-of-TokBox-servers->
* AES-256 Encryption

## Security and Privacy

Vonage Video API can be customized to meet the highest security standards. Our platform is GDPR compliant and we are HIPAA compliant. For European customers, we are offering extended addons that make it possible to comply with additional local certifications and standards, such as KBV certification (Germany) or other privacy laws that aim for better data ownership & protection (Europe-wide).

You can find more about GDPR here: <https://www.vonage.com/communications-apis/platform/gdpr/>

The Vonage Privacy Policy can be found here: <https://www.vonage.com/legal/privacy-policy/>

We are also listing all our sub-processors here: <https://www.vonage.com/communications-apis/platform/gdpr/sub-processors/>

In addition, a Data Processing Addendum (DPA) can be found and self-signed on the GDPR page.

On request and under NDA, we can provide further reports such as SOC2 and External Pen Tests that prove the high-security standards of our Video platform.

## Links to sample codes:

* Precall test

  * Vonage Precall Test Site: <https://tokbox.com/developer/tools/precall/>
  * Git Repository: 

    * iOS and Android:<https://github.com/opentok/opentok-network-test>
    * Javascript: <https://github.com/opentok/opentok-network-test-js>
* Session Monitoring

  * Call Queuing: <https://github.com/opentok/opentok-video-call-center>
* Vonage text chat - <https://github.com/opentok/accelerator-textchat-js>, <https://github.com/nexmo-community/stream-video-with-textchat>
* Vonage In-app Messaging - <https://github.com/nexmo-community/video-messaging-app>
* Interactive/Live Streaming Broadcast - <https://github.com/opentok/broadcast-sample-app/>
* Post-processing tool sample code for processing individual stream archive - <https://github.com/opentok/archiving-composer>
* Tutoring / Proctoring E-Learning Samples: <https://github.com/opentok/opentok-elearning-samples>
* Advanced Insights Dashboard Sample: <https://github.com/opentok/insights-dashboard-sample>

## Calculating monthly usage / Video API tiered pricing

* [How do I estimate my OpenTok monthly usage](https://support.tokbox.com/hc/en-us/articles/360029732691-How-do-I-estimate-my-OpenTok-monthly-usage-)
* [Video API Pricing](https://www.vonage.com/communications-apis/video/pricing/?icmp=l3nav_pricing_novalue)