---
title: Auto Zoom and Center Published Video Calls with Vonage Video API
description: Learn how to automatically focus faces in video calls using the
  Vonage Video API and machine learning libraries.
thumbnail: /content/blog/auto-zoom-and-center-published-video-calls-with-vonage-video-api/auto-zoom-center.png
author: iu-jie-lim
published: true
published_at: 2022-07-14T11:56:48.724Z
updated_at: 2022-07-14T11:56:50.414Z
category: tutorial
tags:
  - video-api
  - ai
  - node
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
## Introduction

In a video call meeting, sometimes it is hard to feel a connection with others compared to a face-to-face meeting. This is because we are unable to closely monitor others’ emotions, feelings, and body language throughout a video call. Furthermore, people always keep some distance between themselves and the webcam. This makes it harder for the presenter to respond to the audience immediately.

Therefore, the use of Vonage ml-transformers and media-processor libraries to zoom in on the caller’s face during a video call has been introduced. This is a great function that can provide extra care during a medical consultant session. The ml-transformers can detect the patient’s face while a media-processor can be used to focus on the patient's face during the consultation session. So now doctors can have a deeper diagnosis by clearly monitoring patients' facial reactions and some facial body language or even sick signals like a pale or swollen face throughout the call.

This article is going to show you how to integrate Vonage Video API with Vonage ml-transformers and media-processor libraries to create a video call that will automatically zoom and center the publisher.

## Prerequisites

1. A Vonage Video API account. If you don’t have one already, you can create an account in the [Video Dashboard](https://www.tokbox.com/account/user/signup).
2. Node.js version >= 16.8
3. Vite.js version >= 2.9

## Join a session

To join a video call session, you need a session ID, JWT, and API key. You may generate a session id and a token under the project’s “Create Session ID” and “Generate Token” sections of your Vonage Video API account. 

Then, use that information to initialize and connect to the generated session by calling `initSession` and `connect`. Do remember to add the [Vonage Video API library](https://static.opentok.com/v2/js/opentok.min.js) to your HTML file. For more Vonage Video API library information, visit [Vonage Video API Client SDKs](https://tokbox.com/developer/sdks/js/).

```
session = OT.initSession(apiKey, sessionId);

 // Connect to the session

 await session.connect(token, function(error) {

   // If the connection is successful, publish to the session
   if (error) {
     console.log("SESSION CONNECT ERROR", error);
     handleError(error);
   } else {
     console.log("SESSION CONNECT SUCCESS");
     initializeStream();
     layout.layout();
   }
 });
```

You may want to add `streamCreated`, `streamDestroyed`, and `streamPropertyChanged` event listeners for the session since you might need to do some layout changes on the browser to have a better layout appearance during your video call.

`StreamCreated` event is triggered if another user (AKA subscriber) joins the same session. On the other hand, the `streamDestroyed` event informs you that a subscriber has left the session. While the `streamPropertyChange` event tells you that the video property, such as video dimension, audio state, or, video state of the subscriber has been changed.

## ML transformers

The [@vonage/ml-transformers](https://www.npmjs.com/package/@vonage/ml-transformers) library consists of multiple functions - for example, the face mesh, face detection, background blur effect, virtual background replacement, etc.

This tutorial will demonstrate how to use the ml-transformers library to detect the publisher's face. 

First, initialize mediaPipeHelper with the “face_detection” model. Then send the webcam image to the mediaPipeHelper periodically using `mediaPipeHelper.send(image)`.

Once the library completes the detection process, it will pass the result to the listener function that was created during initialization. In this case, the listener function receives the face detection result and passes the result to the web worker for post-processing.

```
    import { isSupported, MediapipeHelper } from '@vonage/ml-transformers';

    const mediaPipeHelper = new MediapipeHelper();

    mediaPipeHelper.initialize({
     mediaPipeModelConfigArray: [{modelType: "face_detection", options: {
         selfieMode: false,
         minDetectionConfidence: 0.5,
         model: 'short'
       },
       listener: (results) => {
          if (results && results.detections.length !== 0) {
            worker.postMessage({
              operation: "faceDetectionResult",
              result: results.detections[0].boundingBox
            });
          }
       }}]
    });
```

The result is a bounding box that contains information on the detected face dimension which has been converted into normalized dimensions. The actual value can be obtained by multiplying the result with video dimensions, e.g. `faceWidth = resultWidth * videoWidth`.

Cropped dimension is applied to zoom the video. Typically, the cropped dimension needs to be adjusted to the detected face dimension with a reasonable margin to include some background around the face. The new calculated dimensions will then be used to crop the video during stream transformation.

## Media processor

Traditionally, an intermediary, such as the `<canvas>` element, is needed to manipulate the video. In contrast, an insertable stream allows the developers to process video/audio streams directly, such as resizing video, adding virtual background, or voice effects. The [@vonage/media-processor](https://www.npmjs.com/package/@vonage/media-processor) library makes use of the insertable streams in the background to manipulate a video stream.

The library can process a bunch of transform functions during stream manipulation. In this case, only one transform function is needed to generate a new video stream with the desired dimensions.

First, initialize and set the media processor with a transform function by calling the media processor `setTransformers` function. This transform function will generate a new videoFrame with the dimension calculated earlier. Now the new videoFrame can be used to publish in your video call.

```
   import { MediaProcessor } from '@vonage/media-processor';

    mediaProcessor = new MediaProcessor();
    let transformers = [];
    transformers.push({transform});
    mediaProcessor.setTransformers(transformers);
 
    function transform(videoFrame, controller) {
       const cropVideo = new VideoFrame(videoFrame, {
           visibleRect: {
               x: visibleRectDimension.visibleRectX,
               y: visibleRectDimension.visibleRectY,
               width: visibleRectDimension.visibleRectWidth,
               height: visibleRectDimension.visibleRectHeight
           },
           alpha: 'discard'
       });

       videoFrame.close();
       controller.enqueue(cropVideo);
    }
```

## Publish Stream

After executing all the steps above, you should be able to generate a video that focuses on the publisher’s face. Next, you need to publish the video to the session so that all the users in the same session are visible to the video stream. 

To publish the video, you should create a publisher object using the generated video track, followed by calling `publish` to publish the publisher object to the session. Refer to [the documentation](https://tokbox.com/developer/sdks/js/reference/Publisher.html) for details on how to customize the publisher. 

```
    let publisher = OT.initPublisher('croppedVideo', {
        insertMode: 'append',
        videoSource: videoTracks[0]

    }, handleError);
    session.publish(publisher, handleError);
```

## Conclusion

Now you are ready to publish a face-focused video in a video call! Hopefully, you get the idea of how a face-focused video can be quickly created using the ml-transformers and media-processor libraries.

Further details and code samples are available on our [GitHub repo](https://github.com/nexmo-se/zoom-and-center-publisher).

If you have any questions, join our [Community Slack](https://developer.vonage.com/community/slack) or send us a message on [Twitter](https://twitter.com/VonageDev).
