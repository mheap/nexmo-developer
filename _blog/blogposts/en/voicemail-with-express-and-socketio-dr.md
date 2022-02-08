---
title: Create Custom Voicemail with Node.js, Express and Socket.io
description: Nexmo's Voice API lets you record a call, and with the help of
  Express and Socket.io you can deliver that recording to your own custom
  voicemail interface
thumbnail: /content/blog/voicemail-with-express-and-socketio-dr/custom-voicemail-nodejs.png
author: garann-means
published: true
published_at: 2019-04-02T09:00:11.000Z
updated_at: 2021-05-13T17:16:43.202Z
category: tutorial
tags:
  - voice-api
  - javascript
  - web-sockets
comments: true
redirect: ""
canonical: ""
---

The most pleasant user experiences you've ever had have probably not been using (or, worse, setting up) your voicemail. My voicemail, for example, is fine except that before playing the message it reads every digit of the date, time, and phone number from whence it came as slowly as possible. Some people don't like receiving any voicemail _at all_ and might prefer to only give the option to a few trusted contacts. 

Writing your own custom voicemail will probably take longer than calling your phone provider, setting a PIN, and recording your name. However, the tradeoff is complete control over how you interact with the system. By renting a Nexmo virtual number and associating that with your voicemail, you can even have a dedicated, separate entry point to the system. That means no longer have to triage messages from recruiters offering you a tenth of your current salary to move to another country for a three-month contract.

## Outline

In this example, you'll write your new voicemail system with [Express.js](https://expressjs.com/) and [Socket.io](https://socket.io/), two well-established tools that may be familiar to you if you write JavaScript. To start, you'll need to create a directory for your application and run `npm init -y` to initialize it. Alternately, you can [download all the code from GitHub](https://github.com/nexmo-community/voicemail-express-socketio).

To prevent anyone else checking your voicemail or using your voicemail system as their answering service, for development you can use [Ngrok](https://ngrok.com/) to expose your localhost at a URL only you know. Install Ngrok, if you don't have it already, and start a tunnel using `ngrok http 3000`. Copy the URL it generates, which should look something like `http://93be423e.ngrok.io`.

## Creating Your Application

<sign-up number></sign-up>

In the root of your directory, add a `.env` file. You can take your Ngrok URL and paste it in as the first environment variable, calling it `URL`. You can also add placeholders for your `API_KEY`, `API_SECRET`, `APP_ID`, and `PRIVATE_KEY`. This should leave `.env` looking like this:

```bash
URL="http://93be423e.ngrok.io"
API_KEY=""
API_SECRET=""
APP_ID=""
PRIVATE_KEY=""
```

You can get the values you need to populate the remaining variables from your [Nexmo dashboard](https://dashboard.nexmo.com/). You'll find the API key and secret on the [Getting Started](https://dashboard.nexmo.com/getting-started-guide) page, then you can go to the "[Create an application](https://dashboard.nexmo.com/voice/create-application)" page in the Voice submenu to register your new voicemail app.

Substitute the Ngrok URL you generated for "http://example.com" in the Event and Answer URLs, and click "Generate public/private key pair" to download a private key for the app.

Save the private key to the root of your application directory and supply the filename as the value for `PRIVATE_KEY` in `.env`.

When you click the "Create application" button back in your dashboard, you'll get an Application ID you can set as the value of `APP_ID`. With that, your `.env` should be populated.

If you have a Nexmo virtual number you'd like to use already, you can link it to your application in the "Numbers" tab. If not, you'll also find a button there to "[Buy more numbers](https://dashboard.nexmo.com/buy-numbers)". Search for a number you like, rent it, and then return to link it to your application. Now by default calls to that number will be directed to the endpoint you defined as your Answer URL.

There are several dependencies you'll need to install for this project from npm:

- Express
- Socket.io
- [the Nexmo Node SDK](https://www.npmjs.com/package/nexmo)
- [`body-parser`](https://www.npmjs.com/package/body-parser)
- [`dotenv`](https://www.npmjs.com/package/dotenv)

In my project, I've also installed [`unique-names-generator`](https://www.npmjs.com/package/unique-names-generator) to generate the filenames for individual voicemail recordings. You can choose any generator you like, or a different strategy altogether.

With your dependencies installed, create a new file called `index.js` to define your server.

## Server Setup

It's possible to write a voicemail service with minimal logic by leaning heavily on the default behaviors of the packages you installed above. To initialize your server, require the packages you'll be using, instantiate a new server and websocket connection, and create a new Nexmo object populated with the variables you set in `.env`. 

Set up Express to serve static assets from the `/public` directory and to use the `body-parser` middleware. For now, you can add the signatures for your routes without their bodies. At the end of the file, tell your server to listen on port 3000:

```javascript
require('dotenv').config();

const express = require('express');
const app = express();
const http = require('http').Server(app);
const io = require('socket.io')(http);

const bodyParser = require('body-parser');
const uniqueName = require('unique-names-generator');

const Nexmo = require('nexmo');
const nexmo = new Nexmo({
  apiKey: process.env.API_KEY,
  apiSecret: process.env.API_SECRET,
  applicationId: process.env.APP_ID,
  privateKey: __dirname + '/' + process.env.PRIVATE_KEY
});

app.use(express.static('public'));
app.use(bodyParser.json());

app.get('/answer', (req, res) => {});

app.post('/event', (req, res) => {});

app.post('/voicemail', (req, res) => {});

http.listen(3000);
```

## Nexmo, Take a Message

Now it's time to dive into the heart of the functionality Nexmo will provide, the Nexmo Call Control Object (NCCO). When you created your application you defined the Answer URL as `[your Ngrok URL]/answer`, and you've just created a stub function to listen on that route. Within it, you'll define an NCCO that will do three things:

1. [Greet](https://developer.nexmo.com/voice/voice-api/ncco-reference#talk) the person calling and instruct them when to begin and how to end their message.
2. [Record the call](https://developer.nexmo.com/voice/voice-api/ncco-reference#record), stopping when the caller presses `#`, and send information about the recording to `[your Ngrok URL]/voicemail`.
3. Say goodbye, acknowledging the end of the message.

You can send that NCCO as your response from Express. Nexmo will do the rest, storing the recording and sending its details on to your `/voicemail` route:

```javascript
app.get('/answer', (req, res) => {
  const ncco = [
    {
      action: 'talk',
      voiceName: 'Ivy',
      text: 'Please record your message for Garann after the beep. Press # to end.'
    },
    {
      action: 'record',
      eventUrl: [process.env.URL + '/voicemail'],
      endOnKey: '#',
      beepStart: true
    },
    {
      action: 'talk',
      voiceName: 'Ivy',
      text: 'Thank you, goodbye.'
    }
  ];
  res.send(ncco);
});
```

> Don't forget to customize your greeting, or at minimum change the name!

Nexmo applications also have an `/event` endpoint. A minimal voicemail application won't need to do anything with it, but it's still nice to define it so you don't get 404s:

```javascript
app.post('/event', (req, res) => {
  res.status(204);
});
```

There's a lot of [interesting data](https://developer.nexmo.com/voice/voice-api/code-snippets/download-a-recording) sent to your endpoint when a new recording is made. You can use as much or as little in your user interface as you want. I'm going to keep my example pretty simple, focusing mostly on the audio recording itself. If you want to do the same, generate a unique filename for your audio, and use the `save` function of the Nexmo Files object to save it in your `public` directory. If that succeeds, emit an event called `voicemail` that will signal the client a new message is available, sending as data both the filename of the recording and its start time:

```javascript
app.post('/voicemail', (req, res) => {
  let filename = uniqueName.uniqueNamesGenerator() + '.mp3';
  let path = __dirname + '/public/' + filename;
  nexmo.files.save(req.body.recording_url, path, (err, response) => {
    if (err) {
      res.status(500);
      return console.error(err);
    }
    io.emit('voicemail', {
      date: req.body.start_time,
      file: filename
    });
  });
});
```

## Adding a User Interface

With your server done, you can move into your `public` directory and create an `index.html` file for your client. If you like, you can add a CSS file at `/public/css/style.css` to make it more user-friendly. Start by adding some basic HTML to your HTML file:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
      <meta charset="utf-8" />
      <link href="css/style.css" rel="stylesheet">
      <title>Voicemail</title>
  </head>
  <body>
  </body>
  <script src="/socket.io/socket.io.js"></script>
  <script>
  </script>
</html>
```

> You'll notice that you're importing a script from a location that doesn't exist in your file directory, but as long as your server's running that won't be an issue. Socket.io helpfully serves its own client JavaScript at that location.

The `body` of your page will contain two elements: an `audio` element to play your messages, and a `table` to display data about them. Feel free to use simpler markup than a table if you don't want to show very much data or aren't interested in giving your voicemail system that retro look:

```html
  <body>

    <audio>
      Sorry, your browser does not support this audio.
    </audio>

    <table class="voicemails">
      <thead>
        <tr><th colspan="3">New Voicemails</th></tr>
        <tr>
          <th>Date</th>
          <th></th>
          <th></th>
        </tr>
      </thead>
      <tbody id="vm_rows">

      </tbody>
    </table>

  </body>
```

## Client-side JavaScript

With all the default markup defined, you can fill out the empty `script` tag at the bottom of the page. You'll provide three main things:

1. Some DOM references you won't want to keep looking up.
2. A `document`-level click handler to catch any button clicks that occur in newly-added table rows.
3. Your socket connection and a listener looking for `voicemail` events.

First, add the constants and stub out the listeners:

```html
  <script>
    const rows = document.querySelector('#vm_rows');
    const audio = document.querySelector('audio');

    document.onclick = function(e) {};

    const socket = io();
    socket.on('voicemail', vm => {});
  </script>
```

Event bubbling is a handy feature of the DOM you can use to listen for clicks on any buttons you may add to your table. Within your click handler, sort your buttons by their `className` and perform the appropriate action for each type. I'm using two buttons, Play and Delete. 

Delete only deletes the message from the UI, but in a more robust application it would be wise to also ask the server to delete the audio file associated with the message, to avoid storing too much data. Play is doing the more interesting work, getting the filename of the audio file from the button clicked and setting it as the source of the `audio` element. Once the source has been set, it plays the audio:

```javascript
    document.onclick = function(e) {
      let el = e.target;
      
      if (el.className === 'play_btn') {
        audio.src = el.value;
        audio.play();
      }
      
      if (el.className === 'del_btn') {
        el.closest('tr').remove();
      }
    };
```

To make this work, you'll need to add the messages and their buttons to the table, and that will happen in the socket listener. When a new `voicemail` event is emitted, the client will receive the data defined on the server. Take those values and interpolate them into a template literal, appending it to the `innerHTML` of your table body. Show any data you've decided to pass back in the appropriate table cell, and provide the filename of your recording as the value of your Play button:

```javascript
    socket.on('voicemail', vm => {
      rows.innerHTML += `<tr>
          <td>${vm.date}</td>
          <td><button class="play_btn" value="${vm.file}">Play</button></td>
          <td><button class="del_btn">Delete</button></td>
        </tr>`;
    });
```

## Test It Out

To get your server running, just run `node index.js` in your terminal from the root of your directory. Open a browser window to your Ngrok URL and your UI should appear. If you call the phone number associated with your Nexmo application, you'll hear the greeting you provided, and once you record your message it should appear in your HTML page. Now you have a voicemail system you can tweak to suit your exact preferences, and you'll never have to sit through the interminable reading out of digits again!