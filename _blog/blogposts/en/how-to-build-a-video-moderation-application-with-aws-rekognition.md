---
title: How to Build a Video Moderation Application with AWS Rekognition
description: Learn how to implement a Video Moderation application using Vonage
  Video API and AWS Rekognition
thumbnail: /content/blog/how-to-build-a-video-moderation-application-with-aws-rekognition/blog_video-api_moderation_1200x600.png
author: enrico-portolan
published: true
published_at: 2021-05-27T09:37:54.007Z
updated_at: 2021-05-25T15:34:21.374Z
category: tutorial
tags:
  - video-api
  - aws
  - moderation
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
In education and events spaces particularly, adding an active moderation on participants' videos can be very useful, as it makes it possible to block inappropriate content from others. The application we build with this tutorial will also enable you to save data during the call and run post-call analysis on detection performances. 

In this blog post, we will implement a Video Moderation application using [Vonage Video API](https://www.vonage.com/communications-apis/video/) and [AWS Rekognition](https://aws.amazon.com/rekognition/).
The application will moderate the video published by Camera and Screen sharing for each of the publishers into the session. If the application detects inappropriate content, it will mute the video from the offending publisher and send a notification to all the participants. 

Want to jump ahead? You can find the code for this tutorial on [GitHub](https://github.com/nexmo-se/video-api-aws-moderation) and the video tutorial and demo on [Youtube](https://www.youtube.com/watch?v=TfORVVbC2-U)

<youtube id="TfORVVbC2-U"></youtube>

## Prerequisites

1. A Vonage Video API account. If you don't have one already, you can create an account in the [Video Dashboard](https://tokbox.com/account/#/)
2. An [AWS account](https://aws.amazon.com)

## Project Architecture

![Schema showing project architecture](/content/blog/how-to-build-a-video-moderation-application-with-aws-rekognition/image1.png "Schema showing project architecture")

The application backend is implemented using AWS Serverless components such as AWS Lambda, AWS API Gateway, AWS DynamoDB and AWS Rekognition service.

The backend is contained in the src/functions folder. There are two main functions:

* `api/room.js`: handles the room creation in DynamoDB and assigns Vonage Video API sessionId to the specific room name  
* `api/moderation.js`: receives the base64 image from the client, sends the image to the AWS Rekognition service and sends back the result to the client

The room function receives a parameter called `roomName`. Based on the `roomName`, it checks if the room exists. If so, it sends back the `sessionId` related to the existing room and the token to join the room. If not, it creates a new `sessionId`, saves it in DynamoDB and sends back the credentials (sessionId and token).

The moderation function receives the images from the client-side camera or screen share. Before sending the image to the AWS Rekognition server, the function decodes them into base64 format. 

```javascript
const AWS = require("aws-sdk");
const Rekognition = new AWS.Rekognition();
const config = require("../config.json");

function detectModerationLabels(imageBuffer) {
  var params = {
    Image: {
      Bytes: imageBuffer,
    },
    MinConfidence: Number(config.AWS_REKOGNITION_MIN_CONFIDENCE),
  };
  return Rekognition.detectModerationLabels(params).promise();
}
```

Then, it calls the `detectModerationLabels` function. The `detectModerationLabels` function gives back the objects detected and the confidence. If no objects are identified, the function returns an empty array. Otherwise, the function returns an array with the identified object to the client-side. 

### Client Side

The client-side application is a React Single Page Application. The entry point of the project is the `src/client/index.js` file. The index file imports the App file, which contains the Routes and Component definition.

### Pages

The routes are defined in the App.js file. The code uses the `react-router-dom` module to declare the routes. There are two main routes:

* Waiting Room: The user can set up their microphone and camera settings and run a pre-call test on this page. Then, they can join the video call.
* Video Room: The user can connect to the session, publish their stream, and subscribe to each stream inside the room.

The key thing to note on the Video Room page is the custom hook: `useModeration` (hooks/useModeration). The `useModeration` hook sends every second a screenshot of the camera (or the screen) to the moderation API function.  

For live streaming, it’s ideal to have a process to periodically extract frames and use image-based Rekognition API for analysis. This allows you to get the detection response asynchronously and also allows you to extend your AI/ML process in the future (most of the machine learning models are based on image).
Hence, sending a screenshot every second is a good compromise between live content detection and CPU/Bandwidth usage of the client using the video application. To get the screenshot of the stream, the application uses the [getImgData](https://tokbox.com/developer/sdks/js/reference/Publisher.html#getImgData) function provided by the Video SDK. 

```javascript
useInterval(
    () => {
      if (
        currentPublisher &&
        !currentPublisher.isLoading() &&
        currentPublisher.stream &&
        currentPublisher.stream.hasVideo &&
        isModerationActive
      ) {
        sendImage(currentPublisher.getImgData()).then((res) => {
          if (res && res.error) {
            return;
          }
          if (res && res.data && res.data.labels && res.data.labels.length) {
            setModerationLabels(parseModerationLabels(res.data.labels));
            setWarnOpenSnackbar(true);
            setCameraIsInappropriate(res.data.innapropriate);
          }
        });
      }
    },
    isIntervalRunning ? intervalDelay : null
  );
```

If the moderation function detects inappropriate content, the `useModeration` hook shows a warning snackbar to the current publisher and disables their webcam or screen for a defined period of time (for example, 10 seconds). The hook also sends a signal to the other participants telling them that the publisher's video has been disabled because of inappropriate content. 

## Conclusion

This post demonstrates how to integrate a content moderation API, AWS Rekognition, into the Vonage Video API.
How the application reacts to inappropriate content is completely customizable based on your use case—it can mute the audio/video of the Publisher, or even forcefully disconnect the user and ban them from joining the session again.  

For more details on how you can moderate content using Vonage Video API, have a look at this [article](https://learn.vonage.com/blog/2020/11/12/ban-the-trolls-adding-moderation-to-the-video-api/). 

Resources: <https://github.com/nexmo-se/video-api-aws-moderation>