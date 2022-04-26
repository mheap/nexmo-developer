---
title: Video Express Is Here and Why It Is Awesome!
description: The Vonage Video Express is here! Here are some advantages, code
  samples, demo application and other reasons to give it a try.
thumbnail: /content/blog/video-express-is-here-and-why-it's-awesome/video-express_1200x600.png
author: dwanehemmings
published: true
published_at: 2021-09-23T13:38:38.639Z
updated_at: 2021-09-23T13:38:38.678Z
category: release
tags:
  - javascript
  - video-api
  - video-express
comments: false
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
## Express Explanation

Vonage, with a decade of video development expertise, has created a simple high-level API called Video Express to accelerate the development and integration of multiparty video into web applications.

## Multiparty?

Let’s start by defining what multiparty means. This is when a video call has multiple participants that are both publishing their audio and video streams while simultaneously subscribing to everyone else’s streams.

Previously, it was quite common to have teams of people in the same room and then get on a video call with a team in another room.

![Graphic depicting 2 groups of people passing information back and forth via 2 streams](/content/blog/video-express-is-here-and-why-it-is-awesome/2teams-2streams.jpg "2 teams 2 streams")

As you may have experienced yourself lately, things are shifting towards individuals calling in from different locations.

![Graphic depicting 6 individuals passing information back and forth via 36 streams](/content/blog/video-express-is-here-and-why-it-is-awesome/6people-36streams.jpg "6 people 36 streams")

As you can see from the image above, it can quickly become a complex challenge to keep up with all the connections from the participants.

This is where [Video Express](https://tokbox.com/developer/video-express/) comes in. Maybe you are new to developing applications that integrate video or a seasoned developer that wants to focus on other things. Video Express helps remove the complexity PLUS optimizes for quality, CPU usage, and layout! That’s why it’s awesome!

Here is Video Express used in a vanilla JavaScript [Glitch project](https://glitch.com/edit/#!/remix/video-express-demo?path=README.md%3A1%3A0) you can view. Just input your API Key and Secret in the .env file and you will have your own working example. This is a bare-bones implementation to highlight Video Express.

## Removing complexity

See the comparison below of the starter code needed to create a video chat.

**Vonage Video API JavaScript Client SDK**

```javascript
const session = OT.initSession(this.apiKey, this.roomId); // Init session
session.on('sessionConnected', ...); // Handle session connected events
session.on('sessionDisconnected', ...); // Handle session end
session.on('streamCreated', ...); // Subscribe to newly published streams
session.on('streamDestroyed', ...); // Clean up on stream end
session.on('connectionCreated', ...); // Handle connection events (join)
session.on('connectionDestroyed', ...); // Handle disconnect events (leave)

// Build your own UI / Layout
// Active Speaker Detection
// Video / Audio Optimizations
const pub = OT.initPublisher(targetElement, options, (err) => console.error(err)); // Create a publisher
session.publish(pub, undefined, err => { // Try to publish media
 if (err) {
   reject(err);
 } else {
   resolve();
 }
});
```

**Vonage Video Express**

```javascript
const room = new VideoExpress.Room({ apiKey, sessionId, token, roomContainer: 'roomContainer’ });

room.join();
```

Video Express handles all the publishing and subscribing of all the participants of the video call. Just tell it the id of the HTML element (in this example, "roomContainer") to place the "Room" into, join and that’s it. Read our [documentation](https://tokbox.com/developer/video-express/) for more on what you can do.

## Quality Manager

![Graphic showing the larger video feed on the left with a higher resolution and more bitrate and a column of other smaller video feeds to the right with smaller resolution and bitrates.](/content/blog/video-express-is-here-and-why-it-is-awesome/qualitymanager.jpg "Quality Manager diagram")

To help create the best quality video call, Video Express will apply various methods automatically. These include maximizing tile sizes for visible video streams and pausing the ones that can’t be seen. It will also adjust resolution and frame rates depending on network conditions and CPU. By dynamically setting higher priorities on speakers and screen shares, the things that need the focus can achieve the best quality.

## Experience Manager

To create a great user experience, Video Express will optimize things on the client-side. For example, every participant after 10 is automatically muted to avoid very noisy rooms. When a displayed video gets smaller in size, a smaller stream is requested to help reduce the bandwidth needed for smooth playback.

Example of a raw, unoptimized video session

![Table showing the amount of bandwidth used for audio and video for 1 to 1, 10 videos, and 25 videos in unoptimized sessions](/content/blog/video-express-is-here-and-why-it-is-awesome/unoptimized-video-session.jpg "Table with data of an unoptimized multiparty video session")

Example of an optimized video session

![Table showing the amount of bandwidth used for audio and video for 1 to 1, 10 videos, and 25 videos in optimized sessions with as much as 80% lower bandwidth. ](/content/blog/video-express-is-here-and-why-it-is-awesome/optimized-video-session.jpg "Table with data of an optimized multiparty video session")

## Layout Manager

![Demonstrating the layout changes of colored blocks representing video feeds as they are being added and removed to the screen.](/content/blog/video-express-is-here-and-why-it-is-awesome/layoutmanager.gif "Layout Manager diagram")

Out of the box, Video Express will automatically adjust the layout of the streams based on screen size and the number of participants. Screen shares and the active speaker are given a higher priority or take up more space.

## Preview Publisher

Another feature that Video Express handles for you is allowing the user to preview their video and audio before joining the room. Here is some sample code:

```javascript
const previewPublisher = new VideoExpress.PreviewPublisher('previewContainer');
await previewPublisher.previewMedia({
  targetElement: 'previewContainer',
  publisherProperties: {
    resolution: '1280x720',
    audioBitrate: 15,
  },
});
```

## Screenshare

The final feature of Video Express that I want to point out is how screen sharing is handled.

```javascript
const startScreensharing = () => {
  room.startScreensharing("myScreenshare");
}

const stopScreensharing = () => {
  room.stopScreensharing();
}

screenshareStartBtn.addEventListener("click", startScreensharing, false);

screenshareStopBtn.addEventListener("click", stopScreensharing, false);
```

That's it! With these few lines of code, you can share your screen and Video Express will reconfigure the room's layout to make it the priority.

## Well...

Ready to build something amazing?!

Take a look at the [Video Express documentation](https://tokbox.com/developer/video-express/) for more details.

Play around with the [basic starter project](https://glitch.com/edit/#!/remix/video-express-demo?path=README.md%3A1%3A0).

Show us what you are working on and give us any feedback in our [Community Slack Channel](https://developer.vonage.com/slack).
