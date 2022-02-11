---
title: Announcing the Vonage Video Client SDK Version 2.20
description: " The Vonage Video API team recently released a new version of the
  Vonage Video Client SDK - v2.20 (formerly TokBox OpenTok))."
thumbnail: /content/blog/announcing-the-vonage-video-client-sdk-version-2-20/videoapi_sdk-release_1200x600.png
author: product-manager-video-api
published: true
published_at: 2021-07-30T11:48:44.145Z
updated_at: 2021-07-29T11:58:45.124Z
category: release
tags:
  - video-api
comments: false
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
## What’s New and How You Can Use It

The Vonage Video API team recently released a new version of the [Vonage Video Client SDK - v2.20](https://tokbox.com/developer/sdks/js/release-notes.html) (formerly TokBox OpenTok). Below, you will find details about the new features and examples of how they might be used.

### Screenshare Improvement: Content Hints

`contentHint` (available for Web and coming soon to Native SDKs) provides an additional level of improvement to video and screen sharing quality by helping the encoder prioritize either high frame rate for motion-rich content or high image quality to emphasize details. Content hints also help stabilize screen sharing bandwidth utilization and bandwidth estimation.

You can direct the browser to use one of the following encoding methods to better tailor rendering for the type of content:

- **Motion** — Best used when capturing motion is important, such as cars passing by or sports. Smooth motion will be prioritized over image clarity.
- **Detail** — Best used when trying to capture video details.  A crisp picture will be prioritized over video smoothness.
- **Text** — Use only for text or where pixel-perfect recreations are necessary. This creates full-resolution frames for all simulcast layers but may significantly impact framerate in poor networks. 
- **" "** — no hint is provided

To learn more about how to take advantage of content hints in your application, see the [setVideoContentHint Developer Reference](https://tokbox.com/developer/sdks/js/reference/Publisher.html#setVideoContentHint).


### Force Mute Participants (Beta)

For everyone who’s been wanting to give their meeting hosts the power to mute any participant at will - wait no more! 
 
- **forceMuteAll** - mute all publishers currently in a session. 
- **forceMuteStream** - mute a specific stream in the session

Learn more about moderating all clients or a publisher of a specific stream to mute their published audio in our guide to [moderating interactive video sessions](https://tokbox.com/developer/guides/moderation/js/#force_mute).


### Vonage Video API Support for Plan B and Unified Plan Session Discovery Protocols

Google is now in the final stages of [Unified Plan transition](https://webrtc.org/getting-started/unified-plan-transition-guide) — which brings Chrome browser in line with the webRTC draft spec for browser interop. Previously, Chrome browsers relied on Plan B as a temporary bridge to full browser interop.


Since rolling out the much-awaited Unified Plan earlier this year, [Google has announced](https://groups.google.com/u/1/g/discuss-webrtc/c/UBtZfawdIAA/m/-UVQQcubBQAJ?pli=1) that they will remove support for Plan-B from Chrome in August 2021.


In response to this change, [our platform has been transitioning Vonage Video clients in browsers to strictly use Unified Plan](https://support.tokbox.com/hc/en-us/articles/4402056584852-Vonage-Video-API-Support-for-Plan-B-and-Unified-Plan-Session-Discovery-Protocols). This transition is happening via a patch release to versions 2.18, 2.19, and 2.20 of the web SDK.

## Getting Started With the New Features

The 2.20.0 is already available to [Vonage Video API](https://tokbox.com/developer/) customers running on the Standard Environment, and we plan on releasing it to the Enterprise Environment in the coming weeks.

To learn more and access developer tutorials, please visit [Vonage Video Developer Center](https://tokbox.com/developer/).