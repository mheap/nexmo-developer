---
title: Stream Audio into a Phone Call with Node.js
description: In this blog post you will learn how to play an audio file into an
  active call programmatically, using the Vonage Voice API and Node.js.
thumbnail: /content/blog/stream-audio-into-a-phone-call-with-node-js/Stream-Audio-into-a-Phone-Call-with-Node.js.png
author: marklewin
published: true
published_at: 2019-01-30T13:56:29.000Z
updated_at: 2021-05-12T02:34:23.365Z
category: tutorial
tags:
  - javascript
  - voice-api
comments: true
redirect: ""
canonical: ""
---
When you have your customer on a voice call, you have her undivided attention. Why not use that opportunity to tell her the latest news about your company, relay an inspiring message from your CEO, or even just play her your latest advertising jingle?

In this blog post, you will learn how to play an audio file into an active call programmatically, using the Vonage Voice API and Node.js. 

## Before you Begin

To work through this example you'll need Node.js. If you don't already have it installed, download it from the [Node.js website](https://nodejs.org/en/).

<sign-up number></sign-up>

You can provision a number in the Developer Dashboard, but we'll talk you through using the [Vonage CLI](https://github.com/Vonage/vonage-cli) to rent a number, create a voice application and then link your number to it.

Finally, you'll want the source code, which is available [on GitHub](https://github.com/nexmo-community/voice-stream-audio-node). [Clone the repository](https://help.github.com/articles/cloning-a-repository/) and `cd` into the application's root directory.

## Installing the Vonage CLI

Install the Vonage CLI globally using the following command:

```bash
npm install @vonage/cli -g
```

Then, configure the CLI with your Vonage API key and secret, which you will find in the [Developer Dashboard](https://dashboard.nexmo.com):

```bash
vonage config:set --apiKey=VONAGE_API_KEY --apiSecret=VONAGE_API_SECRET
```

Replace the `VONAGE_API_KEY` and `VONAGE_API_SECRET` with your own details to authenticate the CLI.

## Renting a Vonage Number

You need a number to make calls from. Rent one by executing the following command, replacing the country code as appropriate. For example, if you are in the USA, replace `GB` with `US`:

```bash
vonage numbers:search US
vonage numbers:buy [NUMBER] [COUNTRYCODE]
```

Make a note of the telephone number that the command returns.

## Creating the Voice Application

To use the Voice API, you must create a [Voice API application](https://developer.nexmo.com/concepts/guides/applications). This is not the same thing as the web application you are building. It is merely a container for the configuration and security information you need to connect to Vonage's APIs.

Create an application using the CLI and make a note of the application ID it returns:

```bash
 vonage apps:create "Play audio app"  --voice_answer_url=http://example.com/answer  --voice_event_url=http://example.com/event
```

Note that the `apps:create` command shown uses a few parameters. These are to set the webhook endpoints and generate your private key to authenticate your application.

The Vonage APIs need to know your webhook endpoints so that they can make requests to them when there is an incoming call or an event that your application should know about. You can safely leave these as `example.com` because we will specify the webhooks programmatically.

## Initialize the Dependencies

The application has the following external dependencies:

* `dotenv` - a module that allows us to easily configure the application using a `.env` file
* `express` - a lightweight web framework
* `body-parser` - middleware to handle `POST` requests
* `vonage` - the [REST client library for Node.js](https://github.com/Vonage/vonage-node-sdk)

These dependencies are configured in `package.json`. Run `npm install` to install them to the `node_modules` subdirectory.

## Make your Application Available on the Public Internet

We need to expose our application to the Internet so that Vonage's servers can access our webhooks. We recommend using [ngrok](https://ngrok.io) for this. 

Follow the instructions in [this blog post](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) to install and run ngrok on port 3000. For example:

```bash
ngrok http 3000
```

ngrok will give you a temporary URL such as `https://914288e7.ngrok.io`. Make a note of it.

Leave ngrok running while you are using the application, otherwise, the URLs will change and you will need to reconfigure it.

## Configure the Environment

Copy `example.env` to `.env` and enter the details you have harvested from the above steps:

```
VONAGE_API_KEY= Your Vonage API key
VONAGE_API_SECRET= Your Vonage API secret
VONAGE_APPLICATION_ID= The Voice API application ID
VONAGE_APPLICATION_PRIVATE_KEY_PATH=private.key
VONAGE_NUMBER= The number you rented from Vonage
TO_NUMBER= The number you want the application to call
BASE_URL= The Ngrok temporary URL
```

Then, change the path to the audio file in the `answer.json` package to match your ngrok hostname:

```json
...
    {
        "action": "stream",
        "streamUrl": [
            "http://914288e7.ngrok.io/audio/silence.mp3"
        ]
    }
]
```

You are now ready to see the application in action!

## Run the Application

Launch the application by executing the following command:

```javascript
node server.js
```

Visit `http://localhost:3000/call` in your browser. This makes a `GET` request to the `/call` endpoint in your application and causes it to ring the `TO_NUMBER` in `.env`. 

You will hear a message, followed by some music that plays for 20 seconds, and then the call disconnects.

## How It Works

All the logic happens in `server.js`.

### Instantiating the Vonage Client

The application first reads the settings you configured in `.env` into environment variables and uses them to instantiate the Vonage REST API client library for Node.js:

```javascript
const TO_NUMBER = process.env.TO_NUMBER
const VONAGE_NUMBER = process.env.VONAGE_NUMBER
const BASE_URL = process.env.BASE_URL

const VONAGE_API_KEY = process.env.VONAGE_API_KEY
const VONAGE_API_SECRET = process.env.VONAGE_API_SECRET
const VONAGE_APPLICATION_ID = process.env.VONAGE_APPLICATION_ID
const VONAGE_APPLICATION_PRIVATE_KEY_PATH = process.env.VONAGE_APPLICATION_PRIVATE_KEY_PATH

const vonage = new Vonage({
  apiKey: VONAGE_API_KEY,
  apiSecret: VONAGE_API_SECRET,
  applicationId: VONAGE_APPLICATION_ID,
  privateKey: VONAGE_APPLICATION_PRIVATE_KEY_PATH
})
```

### Serving the Audio Files and NCCO

We use two audio files in this application. One is for the music that we play to the caller. The other is a silent MP3 file. You can only play audio into an existing call, so it's important that we keep the call open otherwise it will disconnect before you have a chance to do anything with it. The silent MP3 file keeps the call open.

The welcome message and silent MP3 are defined in a [Call Control Object (NCCO)](https://developer.vonage.com/voice/voice-api/ncco-reference). The NCCO is an array of JSON objects that represents the actions that occur within the call. Our `answer.json` NCCO tells the application to read some text and then stream a silent MP3:

```json
[
    {
        "action": "talk",
        "text": "<speak>Please hold to listen to some music<break time='1s' /></speak>",
        "voiceName": "Russell"
    },
    {
        "action": "stream",
        "streamUrl": [
            "http://914288e7.ngrok.io/audio/silence.mp3"
        ]
    }
]
```

This is one way of streaming audio into a call. But the focus of this post is how to do it *programmatically*.

These resources are served from the application's `public` directory as follows:

```javascript
// Serve contents of public folder in the /audio path
app.use('/audio', express.static(path.join(__dirname, 'public')))

const answer_url = BASE_URL + '/audio/answer.json'
const audio_url = BASE_URL + '/audio/music.mp3'
const event_url = BASE_URL + `/webhooks/events`
```

### Making the Outbound Call

When we make a `GET` request to the `/call` route, the application uses the `vonage` client library's `calls.create()` method to make an outbound call to the `TO_NUMBER` configured in `.env`. When the call is answered, it responds with the actions defined in the `answer.json` NCCO and starts listening to Voice API events on the `/webhooks/events` webhook handler:

```javascript
app.get('/call', makeOutboundCall)

const makeOutboundCall = (req, res) => {
  console.log('Making the outbound call...')

  vonage.calls.create({
    to: [{
      type: 'phone',
      number: TO_NUMBER
    }],
    from: {
      type: 'phone',
      number: VONAGE_NUMBER
    },
    answer_url: [answer_url],
    event_url: event_url
  })
}
```

### Playing Audio into the Call

In the event webhook, we check the call `status`. If it is  `answered`, then we retrieve the call ID so that we can play the audio into the correct call and stop playing the audio after 20 seconds. After the audio is stopped, we use the `vonage.calls.update()` method to replace the existing NCCO `action` with a new one: `hangup`, which disconnects the call:

```javascript
app.post('/webhooks/events', (req, res) => {
  if (req.body.status == 'answered') {

    const call_uuid = req.body.uuid

    // Play audio into call
    start_stream(call_uuid)

    // Disconnect the call after 20 secs
    setTimeout(() => {
      stop_stream(call_uuid)
      vonage.calls.update(call_uuid, { action: 'hangup' }, (req, res) => {
        console.log("Disconnecting...")
      });
    }, 20000)


  }
  res.status(200).end()
})
```

The `start_stream()` function uses the Vonage client library's `calls.stream.start()` method to programmatically play the specified audio file into the call:

```javascript
const start_stream = (call_uuid) => {
  console.log(`streaming ${audio_url} into ${call_uuid}`)
  vonage.calls.stream.start(call_uuid, { stream_url: [audio_url], loop: 0 }, (err, res) => {
    if (err) {
      console.error(err)
    }
    else {
      console.log(res)
    }
  })
}
```

The `stop_stream()` function calls `vonage.calls.stream.stop()` to stop playing the audio file:

```javascript
const stop_stream = (call_uuid) => {
  vonage.calls.stream.stop(call_uuid, (err, res) => {
    if (err) {
      console.error(err)
    }
    else {
      console.log(res)
    }
  })
}
```

## Conclusion

In this post, you learned how to play audio into an existing call and about some of the NCCO `action`s that govern the call flow. Feel free to experiment by substituting different audio files and NCCO `action`s. The following resources might help:

* [Voice API reference](https://developer.vonage.com/api/voice)
* [NCCO reference](https://developer.vonage.com/voice/voice-api/ncco-reference)
* [Using SSML in TTS](https://developer.vonage.com/voice/voice-api/guides/text-to-speech#ssml) (text-to-speech)
* The REST API [client library](https://github.com/Vonage/vonage-node-sdk) for Node.js