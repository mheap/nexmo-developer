---
title: "Extending Nexmo: Streaming Transcription Comparison"
description: A breakdown and comparison of the four leading cloud providers
  streaming audio transcription APIs and how they can be used with Nexmo.
thumbnail: /content/blog/extending-nexmo-streaming-transcription-dr/E_Extending-Nexmo_Steaming-Transcript_1200x600.jpg
author: kellyjandrews
published: true
published_at: 2019-09-10T11:00:12.000Z
updated_at: 2021-05-10T14:41:29.589Z
category: tutorial
tags:
  - streaming-transcription
comments: true
redirect: ""
canonical: ""
---

In the world of communication, words are vital, and getting the right ones is incredibly important. Transcriptions of voice calls can help businesses understand emerging trends in content from sales and support phone calls.

Transcription is the process of taking audio conversations and turning them into written words.  In the past, this was handled by humans listening to a recording and typing out the words manually.  This practice still exists today. There are now automated services that have emerged, allowing software developers to send audio files to services for a more immediate result.

This work alone can provide incredible insights, but I'm focused specifically on streaming transcriptions where real-time information can provide another level of detail to your sales and support team.

## Overview

This post is a comparison and overview of the four leading cloud provider's streaming transcription services: [Amazon Transcribe](https://aws.amazon.com/transcribe/),  [Azure Cognitive Speech Service](https://azure.microsoft.com/en-us/services/cognitive-services/speech-to-text/), [Google Cloud Speech-to-Text](https://cloud.google.com/speech-to-text/), and [IBM Watson Speech-to-Text](https://www.ibm.com/watson/services/speech-to-text/).

Using the [Nexmo Voice API and WebSockets](https://developer.nexmo.com/voice/voice-api/guides/websockets), I connected a voice call from my cell phone and streamed the audio to test the service.  During the process, I took a few notes regarding things like features, ease of use, accuracy, and costs.

## Accuracy

One of the more critical factors when selecting a transcription service is its accuracy.  Having incorrect information would cause any data to be untrusted.  

I tested each service using an `8kHz` sample rate using my cell phone. You can also use `16kHz`, but in some cases, it's actually less accurate. Using various phrases, I spoke at a relatively average rate of speech at a moderate volume.  The room was also quiet enough to remove background noises.

Every service transcribed the phrases I used with no issues, but some of it depended on how well I spoke. Unfortunately, any service struggles with lack of enunciation.  

Otherwise, you can feel reasonably confident with any one of these services to handle your transcriptions.

### "Stand clear of the doors."

+ IBM Watson Speech-to-Text - 90% (It couldn't get "stand" no matter how clear I spoke)
+ Azure Cognitive Speech Service - 100%
+ Google Cloud Speech-to-Text - 100%
+ Amazon Transcribe - 100%

### "Shake well before serving"

+ IBM Watson Speech-to-Text - 100%
+ Azure Cognitive Speech Service - 100%
+ Google Cloud Speech-to-Text - 100%
+ Amazon Transcribe - 100%

### "Peter Piper picked a peck of pickled peppers."

+ IBM Watson Speech-to-Text - 100%
+ Azure Cognitive Speech Service - 100%
+ Google Cloud Speech-to-Text - 100%
+ Amazon Transcribe - 100%


## Features

The feature sets for most of the services are very similar:

+ Uses Machine Learning for Accuracy
+ Custom models for optimization
+ Audio files and streaming
+ Contextual formatting for proper nouns
+ Punctuation support

### Language Support

[Google Cloud Speech-to-Text](https://cloud.google.com/speech-to-text/docs/languages) has far-and-away the highest number of supported languages at 120 and can auto-detect the language in most cases. The next closest language support is [Azure Cognitive Speech Service](https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/language-support) with 30 and [IBM Watson Speech-to-Text](https://cloud.ibm.com/docs/services/speech-to-text?topic=speech-to-text-models#modelsList) with 15. [Amazon Transcribe](https://docs.aws.amazon.com/transcribe/latest/dg/what-is-transcribe.html) is most restrictive with only 5 languages available for streaming transcription (more available for audio files).

## Ease of Use

Each provider has their unique path to success. All of them provide getting started guides in various formats. However, they tend to either be for sending an audio file or capturing microphone input. While microphone input is the streaming method we need to use with the Nexmo WebSocket, it comes with some additional front end code that was unnecessary.

### Google Cloud Speech-to-Text

The Google SDK was simple to implement by creating a `SpeechClient` with the provided SDK and the Google credentials file provided during the service account user.

The `SpeechClient` provides a method called `streamingRecognize` which provides events.

```js
const client = new speech.SpeechClient();

  let request ={
    config: {
      encoding: 'LINEAR16',
      sampleRateHertz: 8000,
      languageCode: 'en-US'
    },
    interimResults: false
  };

  const recognizeStream = client
  .streamingRecognize(request)
  .on('error', console.error)
  .on('data', data => {
    console.dir(data, {depth: null});
  });
```

Google's simplicity gets an advantage over other competitors. You can get up and running with little effort, and for me, that's a huge win.

[Google Cloud Speech-to-Text Documentation](https://cloud.google.com/speech-to-text/docs/)

### Azure/IBM

Both IBM and Azure provide language-specific SDKs and plenty of getting started documentation to get you going, but the API direct call is straightforward to implement. These services can both be used with just connecting to an API route with the  `wss://` protocol and providing a key.

#### Azure Cognitive Speech Service

```
wss://region.stt.speech.microsoft.com/speech/recognition/interactive/cognitiveservices/v1?format=simple&language=LANG_CODE
```

#### IBM Watson Speech-to-Text

```
wss://stream.watsonplatform.net/speech-to-text/api/v1/recognize?model=langage_model
```

There are some additional headers to be provided, but you can find the documentation for each service to be a beneficial resource.

+ [IBM Watson Speech-to-Text Documentation](https://cloud.ibm.com/apidocs/speech-to-text)
+ [Azure Cognitive Speech Service Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/)

### Amazon Transcribe

I have to admit, AWS was the hardest for me to implement.  The documentation had very few examples, and the SDK didn't seem to support streaming services at all.  When I first set out to build the Amazon Transcribe integration, HTTP/2 was the only protocol available and required signing every request sent to the server. Being a bit of a novice with AWS in general, this proved to be quite tricky for me.

Where this story makes a great turn around, is when Developer Relations lead, [Brandon West](https://twitter.com/bwest) stepped in, and wrote some sample code using a WebSocket connection and saved me.  The sample code made things much more accessible, but the general authorization process and call signing make Amazon Transcribe a bit harder to implement in general.

Here I used the `WebSocket` Node package and created a signed URL to create the connection.

```js
  let url = v4.createPresignedURL(
    'GET',
    `transcribestreaming.${process.env.AWS_REGION}.amazonaws.com:8443`,
    '/stream-transcription-websocket',
    'transcribe',
    crypto.createHash('sha256').update('', 'utf8').digest('hex'), {
        'key': process.env.AWS_ACCESS_KEY_ID,
        'secret': process.env.AWS_SECRET_ACCESS_KEY,
        'protocol': 'wss',
        'expires': 15,
        'region': process.env.AWS_REGION,
        'query': `language-code=${process.env.LANG_CODE}&media-encoding=pcm&sample-rate=${process.env.SAMPLE_RATE}`
    }
  );

  let socket = new WebSocket(url);
```

Amazon Transcribe is an excellent service, but if it's not something you are accustomed to, the learning curve can be a challenge.

[Amazon Transcribe Documentation](https://docs.aws.amazon.com/transcribe/latest/dg/what-is-transcribe.html)

## Cost

All of the service providers offer a lite or free tier to get you started.  The base cost is on the amount of audio time transcribed. The providers use different increments of time, so I normalized them in the table below to help you understand precisely the difference in costs.

|Provider|Free Tier|Cost|Normalized Cost|
|---|---|---|---|
|[Amazon Transcribe](https://aws.amazon.com/transcribe/pricing/)| 60 min/month for 12 months| $0.006/~10 seconds|$0.036/minute|
|[Azure Cognitive Speech Service](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/)|5 audio hours free per month|$1/audio hour|$0.016/minute|
|[Google Cloud Speech-to-Text](https://cloud.google.com/speech-to-text/pricing)|60 minutes free|$0.006/15 seconds|$0.024/minute|
|[IBM Watson Speech-to-Text](https://www.ibm.com/cloud/watson-speech-to-text/pricing)|500 Minutes per Month|$0.02/minute|$0.02/minute|


## Recap

Streaming transcription is a great way to provide insight in real-time.  Each of the four leading cloud providers has great offerings with reliable, accurate speech-to-text services. Using Nexmo as the audio stream is a great extension that allows for more in-depth communication experiences for your customers.  

I highly recommend Google Speech-to-text as a solid pick. The price is competitive, and the service is robust and reliable. It's easy to get set up and start using it immediately, which is a bonus.

If you would like to try out any or all of these services, the Nexmo Extend team has created example code to help you get started.

+ [Amazon Transcribe](https://github.com/nexmo-community/voice-aws-speechtotext-js)
+ [Azure Cognitive Speech Service](https://github.com/nexmo-community/voice-microsoft-speechtotext-py)
+ [Google Cloud Speech-to-Text](https://github.com/nexmo-community/voice-google-speechtotext-js)
+ [IBM Watson Speech-to-Text](https://github.com/nexmo-community/voice-watson-speechtotext-py)
