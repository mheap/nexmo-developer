---
title: "OpenTok Version 2.16: What’s New and How You Can Use It"
description: Here's a look at OpenTok v2.16 updates, simulcast, and the unity
  samples in beta. Find out more about some of the great new features included
  and how you can use them.
thumbnail: /content/blog/opentok-v2-16-new-release/OpenTok-V2.16-Blog-1.png
author: manik
published: true
published_at: 2019-07-02T20:58:34.000Z
updated_at: 2021-04-27T12:19:12.281Z
category: release
tags:
  - video-api
comments: true
redirect: ""
canonical: ""
---
Just in time to unlock the new features of Safari version 12.1, we released OpenTok v2.16, the latest version of our OpenTok Client SDKs. We wanted to update you on some of the great new features included and how you can use them.

### Safari VP8 Video Codec Support

A key new feature of Safari v12.1 includes VP8 support on iOS and macOS!

In the last few updates, we have addressed some interoperability challenges. In OpenTok v2.12, we added Safari and H.264 codec support. However, in some cases VP8 and H.264 may not have been supported.

We then released version 2.15 and the getSupportedCodecs API to handle multiple video codecs in web and Android SDKs. With OpenTok.js v2.16 you no longer need to turn on the H.264 codec in your project, forcing everyone to use H.264 for video to work on Safari.

This is a huge step forward because the latest Safari and OpenTok updates allows for full interoperability between all browsers, including old Android devices that do not support H.264 encoding.

Make sure you have the latest iOS 12.2 and macOS 10.14.4, along with v2.16 of OpenTok.js to give it a try.

[![](https://www.nexmo.com/wp-content/uploads/2019/07/safari-V12-1.png)](https://www.nexmo.com/wp-content/uploads/2019/07/safari-V12-1.png)

### Safari Screen Sharing Support

[![](https://www.nexmo.com/wp-content/uploads/2019/07/Screen-Shot-2019-07-02-at-11.14.40-AM.png)](https://www.nexmo.com/wp-content/uploads/2019/07/Screen-Shot-2019-07-02-at-11.14.40-AM.png)

Safari 12.1 also adds experimental support for screen sharing. Here’s how:

Enable ScreenCapture in the Develop -> Experimental Features menu.

If you don’t have the Develop menu you will need to turn it on in the Advanced section of your Safari Preferences Panel.

Once you’ve enabled the feature, you can use the OpenTok screen sharing API in the same way you do with other browsers.

[![](https://www.nexmo.com/wp-content/uploads/2019/07/Screen-Shot-2019-07-02-at-11.14.18-AM.png)](https://www.nexmo.com/wp-content/uploads/2019/07/Screen-Shot-2019-07-02-at-11.14.18-AM.png)

### Safari Scalable Video Support

The latest Safari also supports simulcast, or scalable video. The release of OpenTok.js v2.16 also unlocks this feature for Safari, which was previously only available in Chrome on the web platform.

### What is Simulcast (Scalable Video)?

Simulcast delivers multiple layers of video with a diversity of encoded qualities directly from the publisher, which helps address the trade-off between video quality and subscriber capacity. Our smart media routing servers are able to adapt to what's best for each subscriber and their respective network or processing capacity. As a result, the remaining subscriber pool can remain independent and unaffected by the rest of subscriber conditions.

In non-scalable video streams, congestion control feedback affects the experience of all subscribers in the session, as the publisher generates a common quality for all subscribers, and it needs to fit the worst subscriber capabilities case.

In a broadcast topology, normal congestion control presents a “race to the bottom.” This means, for example, that a higher subscriber population can increase the risk of poor video quality for all participants, either due to network or device capability issues. For more details about scalable video and simulcast have a look at this support article.

You can find more details about other new WebRTC features in the Safari 12.1 release [here](https://webkit.org/blog/8672/on-the-road-to-webrtc-1-0-including-vp8/).

### Unity Samples - Beta

We’re also excited to share that with the 2.16 release, we’ve released [samples](https://github.com/opentok/opentok-unity-samples) on how to use OpenTok on iOS, Android, Windows, and MacOS with Unity3d in beta. We’d love for you to take them out for a spin.

For a full list of the features and fixes in our OpenTok Client SDKs have a look at the release notes.

*   [OpenTok iOS SDK release notes](https://tokbox.com/developer/sdks/ios/release-notes.html)
*   [OpenTok Android SDK release notes](https://tokbox.com/developer/sdks/android/release-notes.html)
*   [OpenTok Windows SDK release notes](https://tokbox.com/developer/sdks/windows/release-notes.html)
*   [OpenTok.js release notes](https://tokbox.com/developer/sdks/js/release-notes.html)