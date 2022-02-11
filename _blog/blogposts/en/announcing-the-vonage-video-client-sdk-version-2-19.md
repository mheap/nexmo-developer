---
title: Announcing the Vonage Video Client SDK Version 2.19
description: The Vonage Video API team recently released a new version of the
  Vonage Video Client SDK  - v2.19 (formerly TokBox OpenTok). Checkout what's
  new.
thumbnail: /content/blog/announcing-the-vonage-video-client-sdk-version-2-19/videoapi_sdk-release_1200x600.png
author: product-manager-video-api
published: true
published_at: 2021-03-26T14:43:14.650Z
updated_at: 2021-03-26T14:16:55.972Z
category: release
tags:
  - video-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
## What’s New and How You Can Use It

The Vonage Video API team recently released a new version of the [Vonage Video Client SDK  - v2.19](https://tokbox.com/developer/sdks/js/release-notes.html) (formerly TokBox OpenTok). Below, you will find details about the new features and examples of how they might be used.

### Select Video Source

When we started the Vonage Video Platform, we were lucky if we had a built-in camera to use as a video source. When phones began shipping with both a front and rear-facing camera, we released the cycleVideo() API as a handy way to cycle between the front and rear-facing cameras without having to start and stop a publisher. Today, phones and tablets have many cameras, and applications such as SnapCam and Epoc Cam create virtual cameras on a user’s computer. 

With 2.19, we are introducing a way to specify a camera to use. You can now change between devices by calling [Publisher.setVideoSource()](https://tokbox.com/developer/sdks/js/reference/Publisher.html#setVideoSource) and specifying a device. Similarly, to obtain details about the publisher’s current video source, including device id, camera type, and media stream track, you can use [Publisher.getVideoSource().](https://tokbox.com/developer/sdks/js/reference/Publisher.html#getVideoSource) It is also now possible for an application to store and set a user’s last used camera settings!

This code adds a very simple video input selector so you can choose the camera you are capturing from:

```js
let p = OT.initPublisher('publisher');
let sources = document.getElementById("videoSources");

sources.onchange = () => {
  let selected = sources.options[sources.selectedIndex];
  p.setVideoSource(selected.value)
}

function addVideoSource(source) {
  let opt = document.createElement("option");
  opt.text = source.label;
  opt.value = source.deviceId;

  if (source.deviceId === p.getVideoSource().deviceId) {
    opt.selected = true;
  }

  sources.add(opt);
}

OT.getDevices((e, d) => {       
  for (let i = 0; i < d.length; i++) {
    if (d[i].kind === "videoInput") {
      addVideoSource(d[i])
    }    
  }
})
```

These new methods provide much more flexibility to choose exactly which camera sources will be supported by the application and dynamically allow source changes between multiple cameras or video sources the application chooses to support. 

### Audio Processing

Is there more to your audio streams than just people talking? A typical WebRTC implementation offers AudioProcessing capabilities that are tuned for processing conversational speech. In Vonage Video version 2.19 we introduce new capabilities to allow developers more control over audio in their applications. For applications looking to enable high-quality audio or music sources, a selection of audio processing functions can help achieve the best audio response for the application objectives. The 2.19 release helps developers tune their audio experience by separating audio processing functions into different Publisher controls.

Application developers can choose the audio processing techniques most important to their application by independently enabling or disabling the new options echoCancellation, autoGainControl and noiseSuppression in the OT.initPublisher() method, as described in this [SDK reference](https://tokbox.com/developer/sdks/js/reference/OT.html#initPublisher).

To add echo cancellation while allowing for loud noises such as a trumpet or drums, in the app you would enable the echoCancellation option while disabling noiseSuppression, as shown in the sample code below:

```js
OT.initPublisher('publisher', {
  echoCancellation: false,
  autoGainControl: true
  noiseSuppression: true
});
```

### Screen Sharing Picker for Electron

When requesting to share a user’s screen, many browsers provide a dialogue that allows the user to specify what they would like to share. 

Electron is a popular platform to build cross-platform web-based applications with, and many of our developers choose Electron to deploy their desktop applications. In fact, Electron is used by many desktop applications you already use such as Slack, WhatsApp, and Discord. 

We noticed the ability to select a specific window or tab missing from Electron, so we built it for you! Developers may now take advantage of the SDK’s built-in source picker when requesting screen sharing without any additional code.

![](/content/blog/announcing-the-vonage-video-client-sdk-version-2-19/pasted-image-0.png)

### ‘Custom’ Video Type in Native

[Custom Capture](https://www.nexmo.com/legacy-blog/2018/12/20/custom-video-streams-opentok-api-dr) allows developers to modify video streams coming from the camera or other sources with graphics, overlays, stickers, or filters. 2.19 expands special handling of these video types from the JavaScript SDK to iOS, Android, Windows and Linux. Adding the custom video type allows developers to treat video with overlays or effects differently than a standard camera or screen sharing source in their UI on Native applications and can be especially beneficial for applications using AR/VR or annotations. 

### iOS 14 Specific Enhancements

iOS 14 introduced [Compact Calls](https://support.apple.com/guide/iphone/answer-or-decline-incoming-calls-iph3c9947bf/14.0/ios/14.0), Compact VoIP, and [local networking privacy](https://developer.apple.com/videos/play/wwdc2020/10110/). 2.19 contains enhancements to gracefully support compact VoIP with CallKit. While on the topic of iOS changes, it is worth mentioning that all supported versions of the iOS SDK allow flexibility in deciding [how to handle local network privacy](https://support.tokbox.com/hc/en-us/articles/360051172612-Important-Changes-to-iOS-14-affecting-Relayed-sessions) by either gracefully promoting for network access or routing all traffic through our servers if the developer does not expect users to ever join from the same network.

### General Updates and Native SDK WebRTC Upgrade

2.19 includes further performance improvements related to the computation of audio level events as well as significant performance and stability improvements for the Native SDK set. Native SDK users should notice improved codec quality, efficiency, connection reliability, as well as additional statistics and quality metrics available with enhanced getStats reporting.

## Getting Started With the New Features

The 2.19.0 is already available to [Vonage Video API](https://www.vonage.com/communications-apis/video/) customers running on the standard environment and we plan on releasing it to the Enterprise Environment in early April.\
**\
To learn more and access developer tutorials, please visit [Vonage Video Developer Center](https://tokbox.com/developer/).**