---
title: Building a JavaScript Hotline with OpenTok and Node.js
description: OpenTok makes it quick to get started with video chat between two
  participants. With some queueing in Node.js you can create a JavaScript
  hotline in no time
thumbnail: /content/blog/javascript-hotline-with-opentok-and-nodejs-dr/Building-a-JavaScript-Hotline-with-OpenTok-and-Node.js.png
author: garann-means
published: true
published_at: 2019-07-05T12:07:42.000Z
updated_at: 2021-04-27T14:01:43.924Z
category: tutorial
tags:
  - javascript
  - video-api
comments: true
redirect: ""
canonical: ""
---
Once upon a time, when people had questions about JavaScript they went to IRC (Internet Relay Chat) to find someone to answer them. IRC is a very old technology in Internet years, though. Many JavaScript developers these days may not even have an IRC client, or ever have used one. Most, on the other hand, are very familiar with video chat.

[OpenTok](https://tokbox.com/developer/guides/basics/) already makes it quick to get started with a [simple video chat](https://tokbox.com/developer/quickstart/) between two participants. With a little queueing logic added, you can have a hotline for JavaScript questions, or anything else, in no time.

To make your hotline even friendlier you can build the project on [Glitch](https://glitch.com/). This means less setup for you. It also makes your hotline even _more_ helpful by providing the complete project for others to remix for their own hotlines. 

## Getting Started on Glitch

If you want to skip to a working project you can remix the [JavaScript hotline project on Glitch](https://glitch.com/edit/#!/javascript-hotline) right away. Otherwise, in just a few steps you can code your own hotline from scratch. To begin, create a new project on Glitch, choosing the `hello-express` template. 

To provide video chat with OpenTok, `opentok` is actually the only additional package you need.  Adding the option to get a text when someone needs a question answered will make the hotline more able to cope with variations in user volume, though. To support that you can also install `body-parser` to receive form input and `nexmo` to send your texts:

```text
pnpm install opentok body-parser nexmo -s
```

You can repurpose the example `server.js`, `index.html`, and `client.js` files already in your Glitch project. That means your setup is pretty much done.

## Supplying Environment Variables

Your `.env` file will look a bit like this:

```bash
OPENTOK_API_KEY="12345678"
OPENTOK_SECRET="12a3b4c567d89e0f1234567890ab12345678c901"
NEXMO_API_KEY="12ab3456"
NEXMO_API_SECRET="123AbcdefghIJklM"
FROM_PHONE="441234567890"
```

To provide real values for those variables, you'll need developer accounts on both OpenTok and Nexmo. You'll also need an OpenTok project and a Nexmo virtual number.

Within your [OpenTok account dashboard](https://tokbox.com/account), create a new project for your hotline with the "OpenTok API" project type. After giving it a name and selecting a video codec (VP8 should be fine), you'll see its API key and secret. You can paste those into `OPENTOK_API_KEY` and `OPENTOK_SECRET`, respectively. 

Your Nexmo credentials, which you can paste into `NEXMO_API_KEY` and `NEXMO_API_SECRET`, should be visible on the the "Getting Started" page of your [Nexmo Dashboard](https://dashboard.nexmo.com/). You can use any phone number from "[Your Numbers](https://dashboard.nexmo.com/your-numbers" without configuration for `FROM_PHONE`, since you'll be texting from the number but not receiving texts or calls.

## Setting Up the Server

Your server already includes some initialization, a view route for the application root, and a listener that starts the server. You can modify the initialization section a bit to also use the `body-parser` middleware:

```javascript
const express = require('express');
const bodyParser = require('body-parser');
const app = express();
app.use(express.static('public'));
app.use(bodyParser.json());
```

Below that block you can add new OpenTok and Nexmo objects initialized with the values from `.env`, and two empty arrays. `waiting` is for the session IDs of chats waiting for a helper to answer a question, and `helpers` is the phone numbers of people who've offered help during downtimes when no one had a question.

```javascript
const OpenTok = require('opentok');
const opentok = new OpenTok(process.env.OPENTOK_API_KEY, process.env.OPENTOK_SECRET);

const Nexmo = require('nexmo');
const nexmo = new Nexmo({
  apiKey: process.env.NEXMO_API_KEY,
  apiSecret: process.env.NEXMO_API_SECRET
});

var waiting = [];
var helpers = [];
```

In the rest of the file, between the default route and the listener, you can declare the other routes. Below them you'll need a function to text someone who's offered to answer questions:

```javascript
app.get('/', function(request, response) {
  response.sendFile(__dirname + '/views/index.html');
});

app.get('/ask', function(request, response) {});

app.get('/answer', function(request, response) {});

app.get('/answer/:sessionId', function(request, response) {});

app.post('/text', function(request, response) {});

function textHelper(sessionId) {}

const listener = app.listen(process.env.PORT, function() {
  console.log('Your app is listening on port ' + listener.address().port);
});
```

## Adding Participants to Ask and Answer

The most basic function of the hotline application is to connect a person asking a question with someone offering to answer one. The most direct way to accomplish this is to create a video chat session when someone declares they want to ask something. Then you can add the next available person wanting to answer as a second participant. You could create a more robust way of handling these active sessions using a data store, but for testing purposes an array should be fine. 

When someone has a question you can create a new OpenTok session and store its ID in the `waiting` array. Then you can respond with the new ID, the application's OpenTok API key, and a token identifying that specific client:

```javascript
app.get('/ask', function(request, response) {
  opentok.createSession(function(err, session) {
    let sessionId = session.sessionId;
    waiting.push(sessionId);
    
    response.send({
      apiKey: process.env.OPENTOK_API_KEY,
      sessionId: sessionId,
      token: opentok.generateToken(sessionId)
    });
    
    if (helpers.length) {
      textHelper(sessionId);
    }
  });
});
```

> You can see that the `/ask` route, as a final step, checks the length of the `helpers` array. If it finds items in it, it calls the `textHelper` function. We'll discuss `textHelper` separately below, but if you want to simplify your hotline by only connecting people currently using your app you can remove that entire conditional.

Now when someone offers to answer a question, you can send a similar response object with values for the first session in the `waiting` queue. If it's empty, you can send a response indicating to the client that there's no one asking for help at the moment:

```javascript
app.get('/answer', function(request, response) {
  if (waiting.length) {
    let sessionId = waiting.shift();
    response.send({
      apiKey: process.env.OPENTOK_API_KEY,
      sessionId: sessionId,
      token: opentok.generateToken(sessionId)
    });
  } else {
    response.send({
      wait: true
    });
  }
});
```

## Texting a Helper When Someone Asks a Question

It complicates our existing workflow a tiny bit, but allowing potential helpers to provide their phone number and receive a text when a new question session is ready lets the hotline cope better with slow periods. 

Saving someone's phone number is only a few lines of code. The `/text` endpoint receives the phone number in its request body and can then add it to a `helpers` queue. It then returns an "OK" status:

```javascript
app.post('/text', function(request, response) {
  let phone = request.body.phone;
  helpers.push(phone);
  response.sendStatus(200);
});
```

We can now make use of the helper's stored phone number in the `textHelper` function that gets called by the `/ask` route. The function gets the first phone number from `helpers` and texts it a link to a specific video chat session:

```javascript
function textHelper(sessionId) {
  let phone = helpers.shift();
  
  nexmo.message.sendSms(
    process.env.FROM_PHONE,
    phone,
    'JavaScript question for you! Caller is waiting at: https://' + process.env.PROJECT_DOMAIN + '.glitch.me/?id=' + sessionId
  );
}
```

If someone follows a session link texted to them the client can request credentials to join that specific session from the server. The application can safely remove the session from the `waiting` queue once it's actually requested:

```javascript
app.get('/answer/:sessionId', function(request, response) {
  let sessionId = request.params.sessionId;
  let index = waiting.indexOf(sessionId);
  waiting.splice(index, 1);
  response.send({
    apiKey: process.env.OPENTOK_API_KEY,
    sessionId: sessionId,
    token: opentok.generateToken(sessionId)
  });
});
```

## Adding an Interface

For testing it's simplest to keep all your HTML on one page. The example `index.html` already imports `client.js`. Above that script tag, you'll also want to import the OpenTok client library from OpenTok's servers:

```html
<script src="https://static.opentok.com/v2/js/opentok.min.js"></script>
```

You can replace the contents of the `<body>` tag with three blocks: buttons to kick off the process of asking or answering, a pseudoform to collect phone numbers of people who'd like to receive a text, and the targets for your video elements:

```html
    <div id="buttons">
      <a href="/ask" class="bigbutton" id="askBtn">Ask a Question</a>
      <a href="/answer" class="bigbutton" id="answerBtn">Answer a Question</a> 
    </div>
    
    <div id="addNumber">
      No one has a question right now. Want a text when someone does?
      <label>Phone number (e.g. 441234123456):
        <input type="tel" id="phoneNumber" name="phoneNumber" />
      </label>
      <button id="phoneBtn">Text me!</button>
    </div>
    
    <div id="videos">
      <div id="subscriber"></div>
      <div id="publisher"></div>
    </div>
```

> We won't get into the CSS in this tutorial, but at minimum you probably want to hide the `#addNumber` and `#videos` elements when the page first loads. You can add that and any other styling to the existing stylesheet at `style.css`.

## Doing the Client-Side Setup

The first thing you want your client script to do is see if there's an `id` parameter in the URL. This indicates someone followed a link in a text to join an ongoing chat session. If there is, you can immediately fetch the credentials necessary to join from the `/answer/:sessionId` endpoint on the server. The handling of the server response happens in one of two functions, `initializeSession` or `handleError`, both of which we'll cover in a minute:

```javascript
let params = new URLSearchParams(window.location.search);
let ongoingId = params.get('id');
if (ongoingId) {
  fetch('/answer/' + ongoingId).then(function fetch(res) {
    return res.json();
  }).then(function fetchJson(json) {
    initializeSession(json.apiKey, json.sessionId, json.token);
  }).catch(function catchErr(error) {
    handleError(error);
  });
}
```

Having covered the less common case where someone wants to join a specific session, you can set up the scripting you'll use for handling actions in the interface. This is also a good place to define `handleError`. If you like, this function can be much more involved than its current form, where it just sends the error to the console. After that you can select top-level elements that will receive dynamic functionality. If the buttons you've selected exist you can assign them click handlers:

```javascript
function handleError(error) {
  if (error) {
    console.error(error);
  }
}

var askBtn = document.querySelector('#askBtn');
var answerBtn = document.querySelector('#answerBtn');
var addPhone = document.querySelector('#addNumber');
var phoneBtn = document.querySelector('#phoneBtn');

if (askBtn) askBtn.onclick = askQuestion;
if (answerBtn) answerBtn.onclick = answerQuestion;
if (phoneBtn) phoneBtn.onclick = addPhoneNumber;
```

## Initializing a Session

The process of initializing a question and answer session begins by clicking the Ask or Answer buttons. The handlers for those buttons, `askQuestion` and `answerQuestion`, are nearly identical. They first suppress the link's default action, then fetch chat credentials from the appropriate endpoint on the server. If it's possible to create or join a session, `initializeSession` gets called with their credentials. In the case of `answerQuestion`, if no one is asking a question the helper instead sees the option to provide their phone number:

```javascript
function askQuestion(e) {
  e.preventDefault();
  fetch('/ask').then(function fetch(res) {
    return res.json();
  }).then(function fetchJson(json) {
    initializeSession(json.apiKey, json.sessionId, json.token);
  }).catch(function catchErr(error) {
    handleError(error);
  });
}

function answerQuestion(e) {
  e.preventDefault();
  fetch('/answer').then(function fetch(res) {
    return res.json();
  }).then(function fetchJson(json) {
    if (json.wait) {
      addPhone.style.display = 'block';
      return;
    }
    
    initializeSession(json.apiKey, json.sessionId, json.token);
  }).catch(function catchErr(error) {
    handleError(error);
  });
}
```

The `initializeSession` function may be the most complex logic in the entire application. Amazingly, the OpenTok API is actually simplifying the logic needed. It takes care of coordinating between the chat session listeners and the DOM elements so that lower-level tasks like creating a `<video>` element and assigning its source happen behind the scenes.

The function first creates an instance of the session by supplying the OpenTok API the API key and session ID. 

> Static methods in the client-side OpenTok API are available under the `OT` variable. You can ignore any editor complaints about `OT` not being defined. However, for a more robust app it would be best to do some error checking and verify that `OT` _is_ in fact defined. Conversely, you don't want to define `OT` too much by assigning anything else in your code to that variable, unless you change the default API object name first.

The first handler you need is for the `streamCreated` event. When a stream gets created on the current session, it will appear in the element with the ID `subscriber`. You can also add a handler to notify the client if they're disconnected from the session.

Next, define some properties for the publisher's video feed. The client is always the publisher from its own perspective. Their video will be 100% size and be appended to the `publisher` element. 

With the minimum event handlers and configuration in place, you can connect to the session, adding the publisher feed to the client:

```javascript
function initializeSession(apiKey, sessionId, token) {
  var session = OT.initSession(apiKey, sessionId);

  // Subscribe to a newly created stream
  session.on('streamCreated', function streamCreated(event) {
    var subscriberOptions = {
      insertMode: 'append',
      width: '100%',
      height: '100%'
    };
    session.subscribe(event.stream, 'subscriber', subscriberOptions, handleError);
  });

  session.on('sessionDisconnected', function sessionDisconnected(event) {
    console.log('You were disconnected from the session.', event.reason);
  });

  // initialize the publisher
  var publisherOptions = {
    insertMode: 'append',
    width: '100%',
    height: '100%'
  };
  var publisher = OT.initPublisher('publisher', publisherOptions, handleError);

  // Connect to the session
  session.connect(token, function callback(error) {
    if (error) {
      handleError(error);
    } else {
      // If the connection is successful, publish the publisher to the session
      session.publish(publisher, handleError);
    }
  });
}
```

## Saving a Phone Number

At this point, you should have a working hotline. If someone clicks the Ask a Question button, and someone else comes along shortly after and clicks Answer a Question, the two parties should find themselves video chatting and, hopefully, be able to solve all their JavaScript riddles. The only thing left to add is the ability to send a phone number to text in the event that there are no questions at the moment but one comes up later. 

The `addPhoneNumber` handler is, like the button handlers, just suppressing the default event and then doing a fetch. In this case, you'll `POST` data to the server, setting the `Content-Type` to `application/json` and stringifying the value of the `#phoneNumber` field. If that succeeds, you'll hide the phone number input field again:

```javascript
function addPhoneNumber(e) {
  e.preventDefault();
  fetch('/text', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({phone: document.querySelector('#phoneNumber').value})
  }).then(() => {
    addPhone.style.display = 'none';
  }).catch(function catchErr(error) {
    handleError(error);
  });
}
```

## Next Steps

There are lots of different features you could add to your hotline, and lots of different hotlines you could create. It might be nice for users to see how many people are waiting with questions or answers, and it would add robustness to have the ability to reconnect to a session that dropped. 

Since you're already using the Nexmo API, you might like to add the option to do a simple [voice chat](https://developer.nexmo.com/voice/voice-api/overview). And since you're already using OpenTok, you could definitely consider adding features like [screen sharing](https://tokbox.com/developer/guides/screen-sharing/js/) or the option to [archive](https://tokbox.com/developer/guides/archiving/) common questions.

You can read more about what you can do with OpenTok on the [TokBox Developer Center](https://tokbox.com/developer/), and you can view and remix the code for this example on Glitch:

<div class="glitch-embed-wrap" style="height: 420px; width: 100%;">
  <iframe
    allow="geolocation; microphone; camera; midi; vr; encrypted-media"
    src="https://glitch.com/embed/#!/embed/javascript-hotline?path=public/client.js&previewSize=0"
    alt="javascript-hotline on Glitch"
    style="height: 100%; width: 100%; border: 0;">
  </iframe>
</div>