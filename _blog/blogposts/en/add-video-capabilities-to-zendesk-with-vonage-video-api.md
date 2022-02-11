---
title: Add Video Capabilities to Zendesk With Vonage Video API
description: Add video, screen sharing, and recording functionality to Zendesk
  by using Vonage Video API so that you can offer a richer customer experience.
thumbnail: /content/blog/add-video-capabilities-to-zendesk-with-vonage-video-api/Blog_Zendesk_VideoAPI_1200x600.png
author: javier-molina-sanz
published: true
published_at: 2020-09-08T13:27:09.000Z
updated_at: 2021-05-11T16:00:33.444Z
category: tutorial
tags:
  - video-api
  - zendesk
comments: true
redirect: ""
canonical: ""
---
In this tutorial, we're going to add video, screen sharing and recording functionality to Zendesk by using Vonage Video API so that you can offer a richer customer experience. 

You may be thinking that this is not for you as you don't use Zendesk, but, in fact, there are many other ticketing systems where you could apply these takeaways. If that didn't convince you, let us show you how to programmatically handle recordings and upload them to a Zendesk ticket so both parties can download it.

## The Scenario

* The customer would like to discuss an outstanding ticket with the support engineer. She requests a video call with the Support engineer by hitting the `Discuss Live with Javier` button and waits for him to join.

![A customer is requesting a call with the support agen](/content/blog/add-video-capabilities-to-zendesk-with-vonage-video-api/request_call_with_agent.gif)

\- The ticket is updated with an internal comment, so the support engineer is notified that the ticket's requester would like to have a video session.
 


![Agent receives a notification that the customer requests a call](/content/blog/add-video-capabilities-to-zendesk-with-vonage-video-api/ticketupdated.png)

* The support engineer joins the session, they go through the ticket (not much to discuss in this particular case 😂). They decide to record the call, and once the recording is stopped, it gets uploaded in the form of a ticket comment so both participants can download it.

![A recording of a video call between client and support engineer](/content/blog/add-video-capabilities-to-zendesk-with-vonage-video-api/recording.gif)

If this got your attention, please follow along.

## Architecture

To give a high overview of this integration's architecture, we would like to share the following diagram with you: 


![](/content/blog/add-video-capabilities-to-zendesk-with-vonage-video-api/architecture.png)

On one side, the end-customer is requesting a video call with the support engineer via the Zendesk Request Page. The server will handle the request and will update the ticket to get the Agent's attention. On the other side, the Agent using Zendesk will join the same session to discuss live.

## Prerequisites

Before we get started, you will need the following: 

1. [Node.js](https://nodejs.org/en/download/) installed and some [basic JavaScript knowledge](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/First_steps) 
2. A Zendesk account with administrator rights 
3. [The Zendesk App Tools (ZAT)](https://developer.zendesk.com/apps/docs/developer-guide/zat) installed 
4. An [Amazon S3 account](http://aws.amazon.com/s3)

<sign-up></sign-up>

## Zendesk Agent

To begin with Zendesk applications, you can follow their [Build Your First Support App](https://develop.zendesk.com/hc/en-us/articles/360001074788-Build-your-first-Support-app-Part-1-Laying-the-groundwork) tutorial. Move into your project directory and run the following command.

```console
zat new
```

You will be prompted with some information such as the name of your application; we will call it *Zendesk Video App*. It will also ask for your email and some other parameters that won't affect functionality. Once the command gets executed, you will see that the application is created. We're going to make a folder for our server as well. The final project structure looks like this.

```code
|--Application
    |-- Server
        |-- server.js
    |-- Zendesk Video App
        |-- manifest.json
        |-- Assets
          |-- iframe.html
          |-- index.css
          |-- index.jss
```

Our application will be made up of a frame embedded into the Zendesk interface, and it will have a video chat area with several actions available. Let's edit the `iframe.html` file by adding some simple button elements which will allow the Agent to have a video call with the customer inside of the ticket. You can copy-paste the following code into your `iframe.html`: 

```html
 <!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/combine/npm/@zendeskgarden/css-bedrock@7.0.21,npm/@zendeskgarden/css-utilities@4.3.0">
  <link href="main.css" rel="stylesheet">
</head>
<body>
  

  <div id="content"></div>
  <button id="initiatesession" class="button" onclick="initializeSession()">Initiate Session</button>
  <button id="startPublishingVideoId"  class="button" onclick="startPublishingVideo()">Turn on Video </button>
  <button id="startPublishingScreenId" class="button" onclick="startPublishingScreen()">Share Screen</button>
  <button id="handleRecording" class="button" onclick="handleRecording()">Start Recording</button>
  
  <div id="videos" >
      
    <div id="publisher" ></div>
    <div id="subscriber" ></div>
 
  </div>
    
  <script id="requester-template" type="text/x-handlebars-template">

  </script>

  <script src="https://cdn.jsdelivr.net/npm/handlebars@4.3.3/dist/handlebars.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/jquery@3.4.1/dist/jquery.min.js"></script>
  <script src="https://static.zdassets.com/zendesk_app_framework_sdk/2.0/zaf_sdk.min.js"></script>
  <script src="https://static.opentok.com/v2/js/opentok.min.js"></script>
  <script src="index.js"></script>
</body>
</html>
```

We will add some basic CSS for the buttons as well.

```css
.button {
  background-color: #008CBA;;
  border: none;
  color: black;
  padding: 15px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  margin: 4px 2px;
  cursor: pointer;
  border-radius: 12px;
}
```

Now, edit the `main.js` file instantiating a ZAF client. The ZAF client lets your app communicate with the host Zendesk product. You can use the client in your apps to listen for events, get or set properties, or invoke actions. In this case, we're interested in the details about the ticket we're working on. In particular, ticket ID and requester ID. Once the promise is fulfilled, we can send a request to our server to get the API key, session ID, and a token for this ticket. All the session generation logic will come from our server. We'll get to that later on.

```javascript
$(function() {
let client = ZAFClient.init();
client.invoke('resize', { width: '100%', height: '79vh'  });
videos.style.display = 'none';

client.get(['ticket.id', 'ticket.requester.id']).then(data => {
let user_id = data['ticket.requester.id']
let  ticket_id = data['ticket.id'];

    fetch(SERVER_BASE_URL + '/room/' + user_id + "-" + ticket_id).then(res => {
    return res.json()
      }).then(res => {
        apiKey = res.apiKey;
        sessionId = res.sessionId;
        token = res.token;
      }).catch(handleError);

  });

});
```

Now that we've got these values, we can let the Agent choose when to initiate the video session.  We will define an `initializeSession` function that will be triggered once the Agent clicks on the `Initiate session` button. We will set the publisher container display to block to make it visible (as it’s initially set to none). We will start the session by instantiating a session object, and then we initialize the publisher.

```javascript
let initializeSession = () => {
  session = OT.initSession(apiKey, sessionId);

  // Create a publisher
  publisher = OT.initPublisher('publisher', {
    insertMode: 'replace',
    publishVideo: false,
  }, handleError);

  // Connect to the session
  session.connect(token, error => {
    // If the connection is successful, initialize a publisher and publish to the session
    if (error) {
      handleError(error);
    } else {
    session.publish(publisher)
    document.getElementById("initiatesession").style.display = "none"
    }
  });
}
```

We'll also create some listeners for [events](https://tokbox.com/developer/sdks/js/reference/Session.html#events) that are dispatched by the session object. We'll leverage the `archiveStarted` and `archiveSopped` events to control our application's state, i.e., to know whether we're publishing the video or it's turned off if we're recording.

We will display a different value in the HTML buttons, depending on the state. For example, once we receive the `archiveStarted`, we'll want our button to read "Stop Archive" rather than "Start Archive" as the Archive/Recording is already initiated. 
At the top of our code, we've defined some state variables (`archiving`, `video`, and `screen`) that will change based on these events.

We will also want to subscribe to a stream as soon as it's created, so we will listen for the `streamCreated` event.

```javascript
session.on('archiveStarted', event => {
            archiveID = event.id;
            archiving = true
            document.getElementById('handleRecording').innerHTML = 'Stop Archive';
            console.log('ARCHIVE STARTED ' + archiveID);
  });  

session.on('archiveStopped',  event => {
            archiveID = event.id;
            archiving = false
            document.getElementById('handleRecording').innerHTML = 'Start Archive';
            console.log('ARCHIVE STOPED ' + archiveID);
  });  

session.on("streamPropertyChanged", event => {
             video = event.newValue
             video ? document.getElementById("startPublishingVideoId").innerHTML = 'Turn Video off' : document.getElementById("startPublishingVideoId").innerHTML = 'Turn on Video';
            });

  session.on('streamCreated', event => {
    console.log('stream created' + event.stream)
    session.subscribe(event.stream, 'subscriber', {
      insertMode: 'append',

    }, handleError);
  });
```

The `handleError` function we're passing as a callback is a function that throws an alert if an error happens while listening for events on the session.

```javascript
let handleError = (error) => {
  if (error) {
    alert(error.message);
  }
}
```

We can create a `handleRecording` function that will determine whether we're already recording or not. This will allow us to trigger a different function depending on the state.

```javascript
let handleRecording = () => {
  archiving ? stopArchive() : startArchive();
}
```

The `StartArchive` function will make a POST request to our server's `archive/start` route. We need to pass our `sessionId` so that our server knows which session is triggering the recording. You will see later in the tutorial that we refer to the recording and storing of the session. Do not get confused; it's the same concept, but we use the term "archive" internally :)

```javascript
let startArchive = () => {
  console.log('start');
  fetch(SERVER_BASE_URL +'/archive/start', {
    method: 'post',
    headers: {
      'Content-type': 'application/json'
    },
    body: JSON.stringify({
      'sessionId': sessionId
    })
  })
  .then((response) => {
    return response.json();
  })
  .then((data) => {
    console.log('data from server when starting archiving', data)
  })
  .catch(error => console.log('errror starting archive', error))
}
```

As for the `StopArchive` function, it's pretty much the same as `StartArchive`. But, in this case, we need to pass the `archiveID` that comes from the `archiveStarted` event.

```javascript
let stopArchive = () => {
  console.log('archiveID' + archiveID);
  fetch(SERVER_BASE_URL + '/archive/' + archiveID + '/stop', {
    method: 'post',
    headers: {
      'Content-type': 'application/json'
    }
  })
  .then((response) => {
    return response.json()
  })
  .then((data) => {
    console.log('data from server when stopping archiving', data)
  })
  .catch(error => console.log('errror stopping archive', error))
}
```

Now we need to add support for screen sharing streams. We're going to create a function that will check if we're sharing our screen already and if not, it will create a new publisher. This function will act as a toggler for the screen share stream in conjunction with some events, just like we did for the archiving.

We're going check if the browser supports Screen Sharing by calling the `OT.checkScreenSharingCapability` method. We explain more about screen sharing support in [the documentation about checkScreenSharingCapability callback](https://tokbox.com/developer/sdks/js/reference/OT.html#checkScreenSharingCapability). For some older browser versions, you may need to install an extension, but we will assume that both participants will be using a recent browser for the sake of simplicity.

Note that the events we're listening to in this case are dispatched by the publisher object rather than the session object. Refer to the [StreamEvent](https://tokbox.com/developer/sdks/js/reference/StreamEvent.html) for more information.

```javascript
const startPublishingScreen = () => {
  if (screenSharing === true) {
    session.unpublish(screenPublisher)
  } else {
    OT.checkScreenSharingCapability(response => {
      if (!response.supported || response.extensionRegistered === false) {
        alert('Screen share is not supported in this browser')
      } else {
        screenPublisher = OT.initPublisher('screen', {
          videoSource: 'screen'
        }, error => {
          if (error) {
            console.log(error)
          } else {
            session.publish(screenPublisher, handleError)
              .on("streamCreated", event => {
                if (event.stream.videoType === 'screen') {
                  screenSharing = true;
                  document.getElementById("startPublishingScreenId").innerHTML = 'stop screenShare'
                }
              })
              .on("streamDestroyed", event => {
                if (event.stream.videoType === 'screen') {
                  screenSharing = false
                  document.getElementById("startPublishingScreenId").innerHTML = 'start screenShare'
                }
              })
          }
        })
      }

    })
  }
}
```

## Customer Side

Now that we've got our agent side up and running, we need to think about adding Video capability to the customer's side. The main purpose of this post is to get the end customer (ticket requester) and the support agent (ticket assignee) connected.

To do that, we're going to follow [customizing your help center theme guide](https://support.zendesk.com/hc/en-us/articles/203664326-Customizing-your-Help-Center-theme-Guide-Professional-and-Enterprise-) so that we can gain access to the ticket requester's page code and build a richer customer experience in the Help Center.

In this case, we're interested in customizing the `Requests page`, that is, the lists of requests or tickets assigned to a specific user. As explained in the article linked above, the HTML for the Help Center is contained in editable templates. We're going to be editing the `requests_page.hbs` file. The code is going to be very similar to the JavaScript code in the `main.js` file.

First of all, we're going to import the Opentok library. This will download the latest version of the JS SDK.

```html
<script src="https://static.opentok.com/v2/js/opentok.min.js"></script>
```

We're adding some basic markup that will contain the publisher and the subscriber video as well as some buttons that will handle the functionality of our application. You will have noticed that we have `{{assignee.avatar_url}}`. That's a template language called `Curlybars` that will allow us to interact with Help Center Data in the context of Zendsk ticket.

In this example, we are displaying a picture of the ticket assignee on the button that will initiate the video call. The aim is to offer a close experience to the customer. Also, to keep it simple at first, we will be hiding all the buttons but the one that initiates the call. We'll do that by setting the display property of our HTML elements to `none`.

```html
<div>
<button class="button" onclick="initializeSession()" style="position:relative"> 
  <img src={{assignee.avatar_url}} />
  <span class="tooltiptext">Discuss live with {{assignee.name}}</span>
</button>
</div>
    
    <button id="startPublishingVideoId" class="button" onclick="toggleVideo()" style="display:none">Turn Video off</button>
    
    <button id="handleRecording" class="button" onclick="handleRecording()" style="display:none>Start video recording</button>
    
    <button id="startPublishingScreenId" class="button" onclick="startPublishingScreen()" style="display:none">Share your screen</button>

<div id="videos">
    <div id="publisher"></div>
    <div id="subscriber"></div>
</div>
```

We're going to define some variables that we'll be using throughout the code. As we did for the Agent's side, we will be working with some state variables (`video`, `archiving`, and `screenSharing`). We will also define the endpoint of our server.

```javascript
let sessionId;
let publisher;
let archiveId;
let screenSharing = false;
let archiving = false;
let video = true;
const SERVER_BASE_URL = 'SERVER_BASE_URL';
```

We're defining a simple error handler function that we will use to alert the user in the event of an error. The only goal of defining this as a separate function is to clean up our code a little bit.

```javascript
const handleError = (error) => {
  if (error) {
    alert(error.message);
  }
}
```

We're fetching `apiKey`, `sessionId`, and `token` from our server.

```javascript
fetch(SERVER_BASE_URL + '/room/' + {{request.requester.id}} + '-' +{{request.id}}).then(res => {
  return res.json()
}).then(res => {
  apiKey = res.apiKey;
  sessionId = res.sessionId;
  token = res.token;
}).catch(handleError);
```

Then, add the following `initializeSession` function, which will be triggered once the customer decides to request a video call with the support agent. We will show the buttons that were hidden at first, then we're first instantiating a session object and creating a publisher. Lastly, we're trying to connect to the session. If the connection is successful, we will try to publish to the session, as explained previously.

```javascript
const initializeSession = () => {
  document.getElementById('startPublishingVideoId').style.display = "block";
  document.getElementById('handleRecording').style.display = "block";
  document.getElementById('startPublishingScreenId').style.display = "block";
  videos.style.display = 'block';
  session = OT.initSession(apiKey, sessionId);

  publisher = OT.initPublisher('publisher', {
    insertMode: 'append',
    width: '100%',
    height: '100%',
  }, handleError);

  session.connect(token, error => {

    if (error) {
      handleError(error);
    } else {
      session.publish(publisher, handleError);
    }
  });

  session.on('streamCreated', (event) => {
    session.subscribe(event.stream, 'subscriber', {
      insertMode: 'append',
      width: '100%',
      height: '100%'
    }, handleError);
  });

  session.on('archiveStarted', event => {
    archiveID = event.id;
    archiving = true
    document.getElementById('handleRecording').innerHTML = 'Stop Archive';
    console.log('ARCHIVE STARTED ' + archiveID);
  });

  session.on('archiveStopped', event => {
    archiveID = event.id;
    archiving = false
    document.getElementById('handleRecording').innerHTML = 'Start Archive';
    console.log('ARCHIVE STOPED ' + archiveID);
  });

  session.on("streamPropertyChanged", event => {
    console.log(event.newValue)
    video = event.newValue
    video ? document.getElementById("startPublishingVideoId").innerHTML = 'Turn Video off' : document.getElementById("startPublishingVideoId").innerHTML = 'Turn Video on';
  });

  session.on('streamCreated', event => {
    session.subscribe(event.stream, 'subscriber', {
      insertMode: 'append',
    }, handleError);
  });
}
```

We're going to leverage ternary operators to decide whether we need to turn the video on or off. The same logic applies to determine if we're going to call the function to start the recording or to stop it.

```javascript
const toggleVideo = () => {
video ? publisher.publishVideo(false) : publisher.publishVideo(true)
}

const handleRecording = () => {
  archiving ? stopArchive() : startArchive();
}
```

The `startArchive()` and `startArchive()` functions look exactly the same as in the `main.js`, so we'll omit them for the sake of simplicity. You may also want to just give the option to initiate recordings to the support agent and not to the end customer, but this is totally up to you. To make it more fun, we'll allow both to initiate and stop recordings as both of them will be able to retrieve the recording after the call.

## Server

Our server-side will be composed of several routes to handle the requests coming from either the Agent or the support engineer.

Let's import the modules that we're going to be using for our application and define some environment variables.

`apiKey` and `apiSecret` are the Video API credentials found in your [dashboard](https://tokbox.com/account/), the `remoteUri` makes reference to the Zendesk endpoint of your organization in the form of https://xxxxxx.zendesk.com/. For the Zendesk authentication, check out their "[How can I authenticate API requests](https://support.zendesk.com/hc/en-us/articles/115000510267-How-can-I-authenticate-API-requests-)" article as they support different authentication methods; we used username and token. 

As for the authentication with AWS, there are several [supported methods](https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-credentials-node.html), but we also decided to go for environment variables. Note that in this case, The SDK automatically detects AWS credentials set as variables in your environment and uses them for SDK requests, eliminating the need to manage credentials in your application. That's why we're no reading the variables from our `.env` file.

```javascript
const fs = require('fs');
const bodyParser = require('body-parser')
const express = require('express');
const path = require('path');
const app = express();
const _ = require('lodash');
const request = require ('request')
const ZD = require('node-zendesk');
const cors = require('cors');
const dotenv = require('dotenv')

dotenv.config();

const apiKey = process.env.apiKey
const  apiSecret = process.env.apiSecret
const AWS = require('aws-sdk');
const remoteUri = process.env.remoteUri

const client = ZD.createClient({
  username:  process.env.username,
  token:     process.env.token,
  remoteUri: process.env.remoteUri
});

const OpenTok = require('opentok');
const opentok = new OpenTok(apiKey, apiSecret);
app.use(cors());
app.use(bodyParser.json()); 
app.use(bodyParser.urlencoded({
  extended: true
}));
let ticketId
const app = express()
init()
```

Add this to your `index.js` file.

```javascript
const init = () => {
app.listen(8080,  () => {
console.log('You\'re app is now ready at http://localhost:8080/');
}
```

The route that handles session and tokens creation is going to check if there's a session already created to discuss this ticket, and if not, it will create one. In case you're not familiar with the concept of [token](https://tokbox.com/developer/guides/create-token/) for the Video API, it is like a key to the room (session).

You would want to have a more secure solution, but we decided to do some basic validation here to keep it simple. In this case, we're receiving a `name` parameter in the following format `XXXXXX-YYYYY`.  Do you Remember those fetch calls that we made in both parts (Agent and Customer)? It's coming from there. 

We will only generate a session and a token if the requester ID of the ticket matches the second part of our `:name` parameter received. We're going to use a Zendesk package to perform the validation. As an example, if we receive `1222-1234`, we will check via Zendesk API if indeed ticket 1234 was requested by user 1222.  If not, we will return an HTTP 404.

 You will also see that there's some validation around the referer and the origin of the request. That's a quick hack done to update the ticket only if the request comes from the customer, and let the support engineer know that the ticket requester would like to have a video session. 

```javascript
app.get('/room/:name', (req, res) => {
  if (!req.params.name) {
    res.status(402).end()
  }
  let roomName = req.params.name;
  let sessionId;
  let requesterId = roomName.split("-")[0]
  ticketId = roomName.split("-")[1]

  checkIfValid(ticketId, req).then(response => {

      if (response && response.toString() === requesterId) {

        if (req.headers.origin === endpoint && req.headers.referer.split("/")[3] === "hc") {
          updateTicket(ticketId)
        }

        if (roomToSessionIdDictionary[roomName]) {
          sessionId = roomToSessionIdDictionary[roomName];
          token = opentok.generateToken(sessionId);
          res.setHeader('Content-Type', 'application/json');
          res.send({
            apiKey: apiKey,
            sessionId: sessionId,
            token: token
          });
        } else {
          giveMeSession().then(session => {
              roomToSessionIdDictionary[roomName] = session.sessionId;
              token = opentok.generateToken(session.sessionId);
              res.setHeader('Content-Type', 'application/json');
              res.send({
                apiKey: apiKey,
                sessionId: session.sessionId,
                token: token
              });

            })
            .catch(e => res.status(500).send({
              error: 'createSession error:' + e
            }))
        }
      } else {
        res.status(404).end()
      }
    })
    .catch((e) => {
      res.status(404).end()
    })

})
```

In a real-world application, you would probably need to store the session IDs in your database and check if a session has already been created for this ticket. However, we decided to simply use a dictionary that stores session IDs associated with a room name for this tutorial. Bear in mind that this will be reset once you restart your server.

```javascript
let roomToSessionIdDictionary = {};

// returns the room name, given a session ID that was associated with it
const findRoomFromSessionId = sessionId => {
  return _.findKey(roomToSessionIdDictionary,  value => { return value === sessionId; });
}
```

As we mentioned, we will create a session only if there's no session associated with the room name received. We're wrapping the callback-based method in a promise that will return a session object.

```javascript
const giveMeSession = ()=>{
  return new Promise((resolve, reject) => {
        opentok.createSession({ mediaMode: 'routed' }, (err, session) => {
          if (err) {
            console.log('[Opentok - createRoutedSession] - Err', err);
            reject(err);
          }
          resolve(session);
        });
      })
    }
```

We've also wrapped in a promise the Zendesk check that allows us to query the ticket ID that we have received so we can determine whether the request is legitimate or not.

```javascript
const checkIfValid = (ticketId, res) => {
  return new Promise(
    (resolve, reject) => {
      client.tickets.show(ticketId, function(err, request, result){
        if (err) reject(err);
        resolve(result.requester_id);

      })
   }
 );
};
```

If the request is valid and comes from the Customer side (not from the Agent), update the ticket so that the support engineer is notified about someone waiting for a video session.

```javascript
const updateTicket = (ticketId) => {
let notification  = 'The requester of the ticket would like to talk to you.'
 client.tickets.update(ticketId, {"ticket":{comment:{"body": notification, "public": false}}}, (err, req, res) => {
  if(!err){console.log('Ticket updated')                  
  }}
)}
```

We're defining the routes to start and stop archive. Note that the route to stop the archiving also takes the session ID. This is, so our servers know which session ID you're trying to stop the recording for.

```javascript
app.post('/archive/start',  (req, res) => {
  var json = req.body;
  var sessionId = json.sessionId;
  opentok.startArchive(sessionId, { name: 'testSession' },  (err, archive) => {
    if (err) {
      console.error(err);
      res.status(500).send({ error: 'startArchive error:' + err });
      return;
    }
    res.setHeader('Content-Type', 'application/json');
    res.send(archive);
  });
});

app.post('/archive/:archiveId/stop',  (req, res) => {
  opentok.stopArchive(archiveId, function (err, archive) {
    if (err) {
      console.error('error in stopArchive');
      console.error(err);
      res.status(500).send({ error: 'stopArchive error:' + err });
      return;
    }
    res.setHeader('Content-Type', 'application/json');
    res.send(archive);
  });
});
```

If you run your server, expose it with [ngrok](https://ngrok.com/), and configure the ngrok URL as `SERVER_BASE_URL` in both front ends (Customer and Agent side). You now have a video session, well done!

Okay, that was cool, but let's go one step further! Wouldn't it be great if we could also dynamically handle the call recording and upload it to Zendesk so both the support engineer and customer could retrieve it at their best convenience? Let's do that!

![Excited](/content/blog/add-video-capabilities-to-zendesk-with-vonage-video-api/giphy.gif)

## Handling Recordings

First, we have to let the Video API know where we want our video recording uploaded. As we're going to use an AWS S3 endpoint, you can follow our [Using S3 storage with Vonage Video API archiving](https://tokbox.com/developer/guides/archiving/using-s3.html) guide. Once configured, if you have a video session and you initiate and stop a recording, it will be automatically uploaded to your S3 bucket.

All archives are saved to a subdirectory of your S3 bucket that has your OpenTok API key as its name, and each archive is saved to a subdirectory of that, with the archive ID as its name. The archive file is `archive.mp4`.

For example, consider an archive with the following API key and ID:

* API key -- 123456
* Archive ID -- ab0baa3d-2539-43a6-be42-b41ff1488af3

The file for this archive is uploaded to the following directory your S3 bucket:

123456/ab0baa3d-2539-43a6-be42-b41ff1488af3/archive.mp4  

Next, we need to know when the archive has been uploaded to our S3 bucket so we can retrieve it. We're going to configure a route in our server to listen to archive-related events. The Video API platform will send you a webhook to your previously-configured callback URL when an archive's status changes. 

Go to your dashboard, hit on the project you're using, and configure your server URL to `https://YOUR_SERVER_URL/events`. As explained in the [archiving guide](https://tokbox.com/developer/guides/archiving/), the video API platform will send you an available status once the archive is available for download from the S3 bucket. We'll listen to that event on our server and download it. All of the logic is going to be handled on the server-side (`server.js` file). 

```javascript
app.post('/events',  (req, res) => {
  res.send('OK')
  if(req.body.status === 'uploaded'){
  let key = apiKey + "/" + req.body.id + "/archive.mp4"
  downloadVideo(req.body.id + ".mp4", key)
  }
})
```

Remember to configure your server URL in your Video API account. Otherwise, you won't receive these webhooks on your server. It should look something like the following:

![Callback URL](/content/blog/add-video-capabilities-to-zendesk-with-vonage-video-api/videocallback.png)

We will pass two variables to the `downloadVideo` function; one is the name that we want our archive to be downloaded with, and the other one is the Key, so our S3 bucket knows what recording we're trying to retrieve.

The request will stream the returned data directly to a Node.js Stream object by calling the `createReadStream` method on the request. Calling `createReadStream` returns the raw HTTP stream managed by the request. The raw data stream can then be piped into a Node.js Stream object. We should now be able to download the recordings dynamically once uploaded to our bucket.

```javascript
const downloadVideo = (name, key) => {
  var fileStream = fs.createWriteStream(name);
  s3 = new AWS.S3();
  var s3Stream = s3.getObject({Bucket: process.env.BucketName, Key: key}).createReadStream();
  s3Stream.on('error', (err) => {
  console.error(err);
  });

  s3Stream.pipe(fileStream).on('error', (err) => {
      // capture any errors that occur when writing data to the file
      console.error('File Stream:', err);
  }).on('close', () => {
      console.log('Done.');
      getToken(name)
  });
}
```

You will have noticed that we're calling a `getToken` function once we're done downloading the file. That's due to the process of uploading a file to Zendesk. You could do whatever you want with the file at this point, as it's already downloaded. However, to complete our post, let's upload the recording to the Zendesk ticket so both participants can watch the recording after the call.

We first need to get a token, and then we need to update the ticket passing this token. We'll do the second part in a separate function called `uploadVideo`.

```javascript
const getToken = (archiveName) => {
  client.attachments.upload(__dirname + '/' + archiveName , {binary: false, filename: archiveName}, (err, req, result) => {
    if (err) {
      console.log("error:", err);
    }
    console.log("token:", result.upload.token);
    uploadVideo(result.upload.token, ticketId)
  })
}
```

```javascript
const uploadVideo = (token, ticketId) =>{
  let ticket = {
  "ticket":{"comment": { "body": "This is the recording of the call", "public": true, "uploads":[token]},
  }};
  client.tickets.update(ticketId,ticket, (err, req, res) => {
    if(!err){
      console.log('ticket updated with the video recording')
    }
  })
}
```

Check out the [demo](https://github.com/javiermolsanz/blogOpenhack/blob/master/index.md#demo) to get a better idea of how all this works. Adapt this tutorial to suit your needs, leave your customers highly satisfied and true advocates of the support experience.

Find the code for this project in the [vonage-zendesk-integration](https://github.com/nexmo-community/vonage-zendesk-integration) GitHub repo.

What will you build next? Let us know!