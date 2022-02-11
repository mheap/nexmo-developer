---
title: How to Record Audio from Incoming Calls with Node.js
description: In this tutorial, you'll learn how to use the Nexmo Voice API to
  record audio files from phone calls with a Node.js web application.
thumbnail: /content/blog/how-to-record-audio-from-phone-call-node-js-dr/voice-record-call-node.png
author: tomomi
published: true
published_at: 2017-02-06T14:00:17.000Z
updated_at: 2021-05-17T13:46:14.992Z
category: tutorial
tags:
  - voice-api
  - node
comments: true
redirect: ""
canonical: ""
---
*This is the third tutorial in the “Getting Started with Nexmo and Node.js” series, which followed our Getting Started series on SMS APIs. See links to prior tutorials in these series at the bottom of the post.*

In the previous tutorial, you created a voice application and learned how to receive a text-to-voice call using the Nexmo Voice API and the Node.js client library. In this tutorial, you will extend the app to record a message from a caller.

View the source code **[record-call.js](https://github.com/nexmo-community/nexmo-node-quickstart/blob/master/voice/record-call.js)** GitHub

<sign-up number></sign-up>

## Defining a Nexmo Call Control Object to Record Incoming Calls

The previous tutorial walked through creating webhook endpoint URLs and associating them with a voice application to [receive incoming calls](https://www.nexmo.com/blog/2017/01/26/handle-inbound-text-speech-phone-call-node-js-dr/). In this tutorial, you will modify the [NCCO](https://docs.nexmo.com/voice/voice-api/ncco-reference) to record audio. If you have not completed the previous tutorial yet, follow that one first.

To begin, run **[ngrok](https://ngrok.com/)**:

```bash
$ ngrok http 4002
```

You are going to use the forwarding URLs, which look like `https://db95720f.ngrok.io`, as your temporary webhook endpoints during development.

Update your Nexmo application with the ngrok URLs. (You can skip this part if you resume using the same ngrok or your server URL):

```bash
$ nexmo app:update YOUR_NEXMO_APPLICATION_ID "My Voice App" https://db95720f.ngrok.io/answer https://db95720f.ngrok.io/event
```

Now, let’s modify your webhook code.

Edit the NCCO in the HTTP GET route to handle the requests for `/answer`:

```javascript
app.get('/answer', function (req, res) {

const ncco = [
{
'action': 'talk',
'voiceName': 'Jennifer',
'text': 'Please leave your name and quick message after the tone, then press #.'
},
{
'action': 'record',
'eventUrl': ['https://db95720f.ngrok.io/record'],
'endOnSilence': '3',
'endOnKey' : '#',
'beepStart': 'true'
},
{
'action': 'talk',
'voiceName': 'Jennifer',
'text': 'Thank you for your message. Ciao!'
}
];
res.json(ncco);
});
```

Notice the `eventUrl` in the NCCO. This is where the information about the recording is sent. You can reuse the generic `/event` route you have created for the application, or create an another POST route:

```javascript
app.post('/record', (req, res) => {
console.log(req.body);
res.status(204).end();
});
```

Run the script, and try calling your Nexmo phone number. If everything is working, you should hear a greeting from "Jennifer" followed by a beep. Leave a message and press # on your keypad.

By default, the recorded audio is saved in MP3 format and stored by Nexmo for 30 days.

When a recording is completed, the event returns the information, including the audio file URL, `recording_uuid`:

```json
{ start_time: '2017-01-19T00:34:48Z',
recording_url: 'https://api.nexmo.com/v1/files/486fadc7-2abb-4f56-985e-fb83102acb82',
size: 19181,
recording_uuid: '33e0c756-5405-44d9-b869-197e55e780f0',
end_time: '2017-01-19T00:34:53Z',
conversation_uuid: 'de783420-379c-409e-8c73-1ea1e6b2a38e' }
```

Next, you will retrieve the recording from the `recording_url`.

## Retrieving the Voicemail Message

Let’s modify the `/record` route to download the audio file as soon as the recording is completed.

Install the Nexmo Node.js library via npm. You will need version 1.2.0 of the library to be able to use the `save` feature, so upgrade if you are using an older version.

Include the `nexmo` module and then initialize with your credentials, the App ID, and the private key you generated with the CLI tool for [the previous tutorial](https://www.nexmo.com/blog/2017/01/12/make-outbound-text-speech-phone-call-node-js-dr/):

```javascript
const Nexmo = require('nexmo');
const appId = 'c6b78717-db0c-4b8b-9723-ee91400137cf'; // Use your own App ID!
const privateKey = require('fs').readFileSync(__dirname + '/private.key');

const nexmo = new Nexmo({
apiKey: NEXMO_API_KEY,
apiSecret: NEXMO_API_SECRET,
applicationId: appId,
privateKey: privateKey
});
```

As explained earlier, when a voice message is recorded, the specified webhook is triggered and it returns the info with the `recording_url`. You can fetch the MP3 audio file from this URL. Please note that the recorded file ID is *not* the same as other `uuid`s!

Let’s modify the `/record` route and use the `files.save` method to download the file to your disk:

```javascript
app.post('/record', (req, res) => {
let audioURL = req.body.recording_url;
let audioFile = audioURL.split('/').pop() + '.mp3';

nexmo.files.save(audioURL, audioFile, (err, response) => {
if(response) {console.log('The audio is downloaded successfully!');}
});
res.status(204).end();
});
```

Run the script and call your Nexmo phone number to record your message! After the call, you will see an audio file downloaded in the same directory! Yay!

![Nexmo Voice API - audio file download](/content/blog/how-to-record-audio-from-incoming-calls-with-node-js/audio-downloaded.png)

<youtube id="ahPkl3kmcjU"></youtube>

## Learn More

Here are some resources you can use to dive deeper into Nexmo APIs and Node.js.

### API References and Tools

* [Application API](https://docs.nexmo.com/tools/application-api)
* [Voice API](https://docs.nexmo.com/voice/voice-api)
* [Record calls and conversations](https://docs.nexmo.com/voice/voice-api/recordings)
* [Nexmo REST client for Node.js](https://github.com/Nexmo/nexmo-node)

### Nexmo Getting Started Guide for Node.js

* [How to Send SMS Messages with Node.js and Express](https://learn.vonage.com/blog/2016/10/19/how-to-send-sms-messages-with-node-js-and-express-dr/)
* [How to Receive SMS Messages with Node.js and Express](https://learn.vonage.com/blog/2016/10/27/receive-sms-messages-node-js-express-dr/)
* [How to Receive an SMS Delivery Receipt from a Mobile Carrier with Node.js](https://learn.vonage.com/blog/2016/11/23/getting-a-sms-delivery-receipt-from-a-mobile-carrier-with-node-js-dr/)
* [How to Make a Text-to-Speech Call with Node.js](https://learn.vonage.com/blog/2017/01/12/make-outbound-text-speech-phone-call-node-js-dr/)
* [How to Receive a Call with Node.js](https://learn.vonage.com/blog/2017/01/26/handle-inbound-text-speech-phone-call-node-js-dr/)