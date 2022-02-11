---
title: "Vonage Video API Version 2.18: What’s New and How You Can Use It"
description: The Vonage Video API team have released OpenTok Video Client SDK
  v2.18. This post is an overview of the new features and how you can use them.
thumbnail: /content/blog/opentok-version-2-18-whats-new-and-how-you-can-use-it/Blog_SDK-Updates_1200x600-1.png
author: manik
published: true
published_at: 2020-09-03T13:16:58.000Z
updated_at: 2021-05-11T16:51:52.334Z
category: release
tags:
  - video-api
comments: true
redirect: ""
canonical: ""
---

The Vonage Video API team recently released a new version of the Vonage Video Client SDK - v2.18 (formerly TokBox OpenTok). This post is an overview of the new features and how you can use them. I will cover the launch of our latest Linux SDK, IP Proxy feature, updates to WebRTC stats, improvements to security, and more!

## Linux SDK

I am happy to share that we have added full support for Vonage Video Linux SDK for X86_64 on Debian 10. This new SDK has a C API with the same primitives as our other Video Client SDKs.

The Linux SDK unlocks many new use cases ranging from native desktop applications to IP camera-based streaming. Although we're not adding support for other reference architectures and flavors of Linux at this time, we'll be providing the unsupported SDK builds on the [Vonage Video Developer Center](https://tokbox.com/developer/).

You can find the samples on our GitHub and the full API documentation on the developer center.

## IP Proxy

To support use cases where end users are only able to add specific IPs and domains to their allowlist, we're releasing the IP Proxy API which will allow applications to route all of the Vonage Video HTTPS & WS traffic through their reverse proxy server.

To add it to your application, check out the sample code below: 

### JavaScript
```javascript
OT.setProxyUrl('https://mycustomproxy.com');
```

### Swift
```swift
  let settings = OTSessionSettings()
  settings.proxyUrl = "https://mycustomproxy.com"
  let session = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self, settings: settings)
```

### Java
```java
Session session = new Session.Builder(context, apiKey, sessionId).setProxyUrl("https://mycustomproxy.com").build();
```
<h3>C#</h3>
```csharp
var session = new Session(context, apiKey, sessionId, proxyUrl: "https://mycustomproxy.com")
```

### C
```c
otc_session_settings* otc_settings = otc_session_settings_new();
otc_session_settings_set_proxy_url(otc_settings, "https://mycustomproxy.com");
otc_session* session = otc_session_new_ex(apiKey, sessionId, &sessionCb, otc_settings);
```

In the example above, we're hard coding the `proxyUrl`, however, in production use cases, we recommend fetching the `proxyUrl` from your application server just as you fetch the credentials to connect the session. This approach will allow you to change the `proxyUrl` at runtime as needed.

You can find the detailed [documentation and guides](https://tokbox.com/developer/guides/ip-proxy/) in the Vonage Video Developer Center. Please note that this feature is available as an add-on. 

## getRtcStatsReport

As we continue to see more and more use cases with our Video API and WebRTC, we want to equip our developers with full WebRTC statistics to allow independent media connection quality analysis.

I am happy to share that with the Vonage Video JS SDK 2.18.0 you can now collect the raw, untransformed WebRTC statistics as the browser transmits them. These statistics will allow you to discover metrics such as how long it takes to encode a frame so you can use it to assess the impact on the CPU.

```javascript
// Get the raw stats from the publisher in a relayed session.
async function collectStats() {
  try {
    const pubStats = await publisher.getRtcStatsReport();

    // Print publisher raw stats on the console.
    pubStats.forEach(({ subscriberId, connectionId, rtcStatsReport }) => {
      console.log(`Raw stats for subscriber ${subscriberId} with connectionId ${connectionId}`);
      rtcStatsReport.forEach(console.log);
    });
  } catch(err) {
    console.log(err);
  }
}

// Get the raw stats from the publisher in a routed session.
async function collectStats() {
  try {
    const pubStats = await publisher.getRtcStatsReport();

    // Print publisher raw stats on the console.
    pubStats.forEach(({ rtcStatsReport }) => {
      rtcStatsReport.forEach(console.log);
    });
  } catch(err) {
    console.log(err);
  }
}

// Get the raw stats from the subscriber.
async function collectStats() {
  try {
    const subStats = await subscriber.getRtcStatsReport();

    // Print subscriber raw stats on the console.
    subStats.forEach(console.log);
  } catch (error) {
    console.log(err);
  }
}
```

## Android SDK Camera Capturing & Releasing APIs

In the previous release v2.17.0, we added several improvements to our Android SDK to make it more stable than the previous versions. With those improvements, we received some requests from our developers to add new APIs that allow them to directly release the camera and recapture it.

To add more control to the SDK, we've added an API to do just that via onStop and onRestart methods.

```java
class PublisherKit {
    // ...

    /**
     * This method will release any resource tied to the publisher.
     * It will stop capturing and then it will release the camera.
     * Please note that after calling this method if you plan to reuse the publisher again
     * you need to call onRestart
     */
    public void onStop() {
    }

    public void onRestart() {
    }
}
```


## Scalable Video HD Layer for Windows SDK

[Scalable Video](https://tokbox.com/developer/guides/scalable-video/) was first released back with the Vonage Video Windows SDK 2.14, which improves video quality in multi-party sessions.

Today, we're releasing improvements to our Windows SDK to intelligently stream HD resolution when using Scalable Video (where available).

## Security For Our SDKs

We address the WebRTC vulnerability in the SCTP with security patches for iOS, Android, and Windows SDKs.

We're improving this further by adding other additional layers of protection with 2.18.0. In addition to the client releases, we also upgraded our servers to block any data channels before the WebRTC vulnerability was made public.
 
## Getting Started With the New Features
The 2.18.0 release is already available to [Vonage Video API](https://www.vonage.com/communications-apis/video/) customers running on the standard environment, and we plan on releasing it to the Enterprise Environment in early October.

To learn more and access developer tutorials, please visit [Vonage Video Developer Center](https://tokbox.com/developer/). 

