---
title: Moderate Audio in an App With the Vonage Video API and AWS Transcribe
description: Build an audio-moderated video application with the Vonage Video
  API and AWS Transcribe
thumbnail: /content/blog/moderate-audio-in-an-app-with-the-vonage-video-api-and-aws-transcribe/aws-audio-moderation_videoapi.png
author: enrico-portolan
published: true
published_at: 2022-03-11T09:42:48.712Z
updated_at: 2022-03-10T00:11:43.887Z
category: tutorial
tags:
  - video-api
  - AWS
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
This is the second part of my series of blog posts about Video Moderation. The first is focused on video moderation; you can have a look [here](https://learn.vonage.com/blog/2021/05/27/how-to-build-a-video-moderation-application-with-aws-rekognition/).

In education and events spaces particularly, adding an active moderation on participants' audio can be very useful, as it makes it possible to block inappropriate content from others. 

The application we build with this tutorial will add audio moderation on the video streams created using Vonage Video API. 

In this blog post, we will implement a Video Moderation application using the [Vonage Video API](https://www.vonage.com/communications-apis/video/) and [AWS Transcribe](https://aws.amazon.com/transcribe/). The application will moderate the audio published by Camera for each of the publishers into the session. If the application detects inappropriate words, it will mute the audio from the offending publisher and send a notification to all the participants. 

### Prerequisites

1. A Vonage Video API account. If you don't have one already, you can create an account in the [Video Dashboard](<1. https://tokbox.com/account/#/>).
2. An AWS account: <https://aws.amazon.com>

### Project Architecture

![](https://lh3.googleusercontent.com/Kkbf1Jbr2tb-9_w5G6GoG5TEamJzrxO1FA1EYvoXdCVZM45kNkoXVHsvELxZBxNRcWP4yOOzq-ihkvtqmZf-OJxXVKOQ3jp4uCGxqz8EYJpoSMvJ1W7Ltp44MAfRcqCD71EpqjGm)

The application backend is implemented using AWS Serverless components such as AWS Lambda, AWS API Gateway, AWS DynamoDB, and AWS Transcribe service.

The backend side is mostly for video room credentials handling. The audio moderation is implemented on the client-side.

### Client-Side

The client-side application is a React Single Page Application. The entry point of the project is the `src/client/index.js` file. The index file imports the App file, which contains the Routes and Component definition.

### Pages

The routes are defined in the App.js file. The code uses the `react-router-dom` module to declare the routes. There are two main routes:

* Waiting Room: The user can set up their microphone and camera settings and run a pre-call test on this page. Then, they can join the video call.
* Video Room: The user can connect to the session, publish their stream, and subscribe to each stream inside the room.

The key thing to note on the Video Room page is the custom hook: useTranscribe (hooks/useTranscribe). The useTranscribe hook opens a WebSocket connection to the AWS Transcribe service and sends an encoded audio stream. The audio stream is taken from the Publisher object of Vonage Video API, encoded using PCM. 

```javascript
const audioSource = currentPublisher.getAudioSource();

const audioMediaStream = new MediaStream();

audioMediaStream.addTrack(audioSource);

micStream.current = new MicrophoneStream({ stream: audioMediaStream });

const encodedAudioStream = await audioStream(micStream.current);



const command = new StartStreamTranscriptionCommand({

      LanguageCode: 'en-US',

      // The encoding used for the input audio. The only valid value is pcm.

      MediaEncoding: 'pcm',

      MediaSampleRateHertz: 44100,

      AudioStream: encodedAudioStream,

      EnablePartialResultsStabilization: true,

      PartialResultsStability: 'high',

      VocabularyFilterName: 'ProfanityModerationList'

    });

    try {

      console.log('encodedAudioStream', encodedAudioStream);

      const response = await transcribeStreamingClient.current.send(command);
```

The AWS Transcribe service receives the audio stream and transcribes it to text. On the AWS Transcribe service, it’s possible to add custom vocabularies to filter unwanted words. 

For this example, I created a vocabulary with several profanity words. If any word is detected, the service will add the \`\*\*\*\` character. On the client-side, if the transcription contains the `\*\*\*’ character, the useTranscribe hook will mute the local audio of the stream. It will also show a warning message to the user and send a notification to all the users connected to the room.

### Conclusion

This post demonstrates how to integrate a content moderation API, AWS Transcribe, into the Vonage Video API. 

How the application reacts to inappropriate content is completely customizable based on your use case— it can mute the audio/video of the Publisher, or even forcefully disconnect the user and ban them from joining the session again. 

### Resources

The first article of the series of posts about Video Moderation is [How to Build a Video Moderation Application with AWS Rekognition] (https://learn.vonage.com/blog/2021/05/27/how-to-build-a-video-moderation-application-with-aws-rekognition/).

For more details on how you can moderate content using Vonage Video API, have a look at ["Ban the Trolls! Adding Moderation to the Video API"](https://learn.vonage.com/blog/2020/11/12/ban-the-trolls-adding-moderation-to-the-video-api/). 

The GitHub repo can be found [here](https://github.com/nexmo-se/video-api-aws-moderation).

Make sure to join our community by [following us on Twitter](https://twitter.com/VonageDev) and [joining our Slack channel](https://developer.vonage.com/community/slack). 

Thanks for reading!
