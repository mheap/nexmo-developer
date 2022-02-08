---
title: MultiTrack Call Transcription with Split Recording
description: Build a node.js app with the Nexmo Voice API to connect multiple
  parties and record the conversation via split recording, one participant in
  each channel.
thumbnail: /content/blog/multitrack-call-transcription-split-recording-voice-dr/MultiTrack-Call-Transcription_1200x675.jpg
author: mheap
published: true
published_at: 2018-12-03T17:01:49.000Z
updated_at: 2021-05-10T02:16:17.507Z
category: tutorial
tags:
  - javascript
  - voice-api
comments: true
redirect: ""
canonical: ""
---
Back in April we announced that [split recording](https://www.nexmo.com/blog/2018/04/17/dual-channel-transcription-split-recording-dr/) was available as part of the Nexmo Voice API. Split recording allows you to record a conversation in stereo, one participant in each channel. This makes common use cases such as transcription much easier to handle.

However, there was one downside to split recording - if you have more than two participants then the first participant would be in channel 0 and everyone else would be in channel 1, which means that we lose the ability to transcribe what everyone said individually.

What if I told you that Nexmo now supports not one, not two, but three(!) separate channels in a recording? Would that make you happy? How about if I told you we could support four? Five? We’re pleased to announce that available immediately, Nexmo supports up to 32 channels in every single recording. You read that correctly - we can provide 32 separate channels of audio, each containing a single participant for you to process however you like.

Just like last time, we’re going to walk through a simple use case together. In this scenario, Alice needs to discuss a work project with Bob and Charlie, and they’ve all agreed that it’d be a good idea to record the call. To achieve this, Alice has created a small Node.js application that uses Nexmo to connect her to Bob and Charlie and record the conversation.

> All of the code in this post is [available on Github](https://github.com/nexmo-community/multitrack-recording-google-transcription).

## Bootstrapping Your Application

The first thing we need to do is create a new application and install all of our dependencies. To do this, we’ll use `npm` to initialise a project and install `express` and `body-parser` to handle our HTTP requests, and `dotenv` to handle our application configuration. We’ll also need to install the `nexmo` client so that we can access our call recording once we receive a notification that it’s available and `@google-cloud/speech` to transcribe the audio .

```
npm init -y
npm install express body-parser dotenv nexmo @google-cloud/speech --save
```

Once you've installed all of your dependencies, you’ll need to create an application and rent a number that people can call. 

<sign-up number></sign-up>

Nexmo sends HTTP requests to your application whenever an event occurs within your application. This could be when a call starts ringing, when it’s answered or when a call recording is available, just to name a few. To do this Nexmo needs to be able to reach your application, which is difficult when the application is running locally on your laptop. To expose your local application via the internet, you can use a tool called [ngrok](https://ngrok.com/). For more information you can read our [introduction to ngrok](/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) blog post.

Expose your server now by running `ngrok http 3000`. You should see some text that looks similar to `http://2afec62c.ngrok.io -> localhost:3000`. The first section is your ngrok URL, and is what you need for the rest of this post.

We’re finally ready to create a Nexmo application and link a number to it. You’ll need to replace `http://2afec62c.ngrok.io` with your own ngrok URL in these examples:

```
# Create an application
nexmo app:create "MultiTranscription" http://2afec62c.ngrok.io/webhooks/answer http://2afec62c.ngrok.io/webhooks/event --keyfile private.key
# Application created: aaaaaaaa-bbbb-cccc-dddd-0123456789ab <- Make a note of this, you'll need it later

# Purchase a number
nexmo number:buy --country_code GB
# Number purchased: 442079460005 <- You'll need this too

# Link our number to our application
nexmo link:app NUMBER APPLICATION_ID
```

If you now make a call to the number that you purchased, Nexmo will make a request to `http://[id].ngrok.io/webhooks/answer` to find out how to handle the call. As we haven’t built that application yet, the call will fail.

## Handling an Inbound Call

Let’s build our application to handle inbound calls. 

Create the `index.js` file and enter the code shown below. This `require`s all of our dependencies, configures the Nexmo client and creates a new `express` instance:

```
require("dotenv").config();

const express = require("express");
const bodyParser = require("body-parser");
const Nexmo = require("nexmo");

const nexmo = new Nexmo({
    apiKey: "not_used", // Voice applications don't use the API key or secret
    apiSecret: "not_used", 
    applicationId: process.env.NEXMO_APPLICATION_ID,
    privateKey: process.env.NEXMO_PRIVATE_KEY_PATH
});

const app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
```

Next, we need to create our `/webhooks/answer` endpoint which will return an [NCCO](https://developer.nexmo.com/voice/voice-api/ncco-reference) and tell Nexmo how to handle our call. In our NCCO we use two `connect` actions to automatically dial Bob and Charlie’s phone numbers and add them to the conversation, and a `record` action that will tell Nexmo to record the call.

The `record` action is where the magic happens. We tell Nexmo to split the audio into separate channels by setting `split: conversation` and that the audio should be split into three channels by setting `channels: 3`.

```
app.get('/webhooks/answer', (req, res) => {
    return res.json([
        {
            action: 'connect',
            endpoint: [{
                type: 'phone',
                number: process.env.BOB_PHONE_NUMBER
            }]
        },
        {
            action: 'connect',
            endpoint: [{
                type: 'phone',
                number: process.env.CHARLIE_PHONE_NUMBER
            }]
        },
        {
            "action": "record",
            "eventUrl": [`${req.protocol}://${req.get('host')}/webhooks/recording`],
            "split": "conversation",
            "channels": 3,
            "format": "wav"
        }
    ]);
});
```

We’ll need to provide Bob’s and Charlie’s phone numbers for this to work, but let’s finish creating our endpoints before we configure our application.

Create the `/webhooks/event` endpoint which will be informed when [events](https://developer.nexmo.com/voice/voice-api/webhook-reference#event-webhook) are triggered on the call. For now, all we’re going to do is log the parameters we received and acknowledge that we received it by sending back a `204` response.

```
app.post('/webhooks/event', (req, res) => {
    console.log(req.body);
    return res.status(204).send("");
});
```

Finally, we need to implement our`/webhooks/recording` endpoint. This URL was defined in our NCCO in the `record` action and will be notified when a recording is available. We’ll automatically transcribe the audio later, but for now let’s log the request parameters so that we can see what’s available.

```
app.post('/webhooks/recording', (req, res) => {
    transcribeRecording(req.body);
    return res.status(204).send("");
});

function transcribeRecording(params) {
    console.log(params);
}

app.listen(3000, () => console.log(`Listening`))
```

At this point there’s only one thing left to do - populate our `.env` file to provide the information that our application needs. You’ll need your `application_id`, as well as some phone numbers for Bob and Charlie to help you test. Create a `.env` file and add the following, making sure to replace the application ID and phone numbers with your own values:

```
NEXMO_APPLICATION_ID="aaaaaaaa-bbbb-cccc-dddd-0123456789ab"
NEXMO_PRIVATE_KEY_PATH="./private.key"

BOB_PHONE_NUMBER="442079460000"
CHARLIE_PHONE_NUMBER="442079460001"

GOOGLE_APPLICATION_CREDENTIALS="./google_creds.json"
```

*Make sure to add the Google credentials line, even though we haven't created that file yet. We'll create it in the next section*

Once you’ve done this you can test your application by running `node index.js` and then calling the Nexmo number you purchased. It should automatically call the two numbers that you added to the `.env` file and once everyone hangs up, your `/webhooks/recording` endpoint should receive a recording URL.

## Connecting to Google

We’re going to use Google’s Speech-To-Text service to transcribe our call recording. To get started with that, you’ll need to [generate Google Cloud credentials](https://cloud.google.com/docs/authentication/getting-started#creating-a-service-account) in the Google console. Download the JSON file they provide, rename it to `google_creds.json` and place it alongside `index.js`. This is the file that the Google SDK will try and read to fetch your authentication credentials.

To transcribe our audio data, we’re going to connect to the Google Speech API, passing in the expected language, the number of channels in the recording and the audio stream itself. Update your `transcribeRecording` method to contain the following code:

```
function transcribeRecording(params) {
    const client = new speech.SpeechClient();

    const config = {
        encoding: `LINEAR16`,
        languageCode: params.language,
        audioChannelCount: params.channelCount,
        enableSeparateRecognitionPerChannel: true,
    };

    const request = {
        config: config,
        audio: {
            content: params.audio.toString('base64'),
        }
    };

    return client.recognize(request);
}
```

This returns a `promise` from the Google Cloud speech SDK which will resolve when the transcription is available. Before we can use the speech SDK, we need to require it so add the following to your `require` section at the top of your file:

```
const speech = require('@google-cloud/speech').v1p1beta1;
```

At this point we’re ready to transcribe our audio. The final step is to fetch the recording from Nexmo when we receive a request to `/webhooks/recording` and feed the audio in to Google’s transcription service. To do this, we use the `nexmo.files.get` method and pass the audio returned in to our `transcribeRecording` method:

```
app.post('/webhooks/recording', (req, res) => {
    nexmo.files.get(req.body.recording_url, (err, audio) => {
        if (err) { console.log(err); return; }

        transcribeRecording({
            "language": "en-US",
            "channelCount": 3,
            "audio": audio,
        }).then((data) => {
            const response = data[0];
            const transcription = response.results
                .map(
                    result =>
                    ` Channel Tag: ` +
                    result.channelTag +
                    ` ` +
                    result.alternatives[0].transcript
                )
                .join('n');
            console.log(`Transcription: n${transcription}`);
        });
    });
    return res.status(204).send("");
});
```

As well as passing the audio as a parameter, we tell our `transcribeRecording` method that there are `3` channels in the audio and that we want to transcribe using the `en-US` language model. Once the promise is resolved by the Google speech SDK, we read the results and output a transcription of the conversation, including which channel the audio came from.

If you call your Nexmo number now, you'll be connected to both Bob and Charlie. Once the call is done, hang up and wait for Nexmo to send you a recording webhook. Once it arrives, we send that audio off to Google and the transcription will appear in the console. This is how it looks for me:

```
Transcription:
Channel Tag: 1 this is channel one
Channel Tag: 2 and this is channel two
Channel Tag: 3 and a test from channel three
Channel Tag: 1 great
```

## Conclusion

We've just built a conference calling system with automatic transcription in just 76 lines of code. Not only does it automatically transcribe the call, but it transcribes each channel separately, allowing you to know who said what on the call. For more information about the options available when recording a call, you can view the `record action` in our [NCCO reference](https://developer.nexmo.com/voice/voice-api/ncco-reference#record), or see an [example implementation of the NCCO required](https://developer.nexmo.com/voice/voice-api/building-blocks/record-a-call-with-split-audio) in multiple languages.