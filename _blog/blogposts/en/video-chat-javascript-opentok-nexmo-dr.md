---
title: Build a Video Chat Application with OpenTok and Nexmo In App Messaging
description: Find out how to create a Video Chat Application with In-App
  Messaging in this tutorial using JavaScript, OpenTok and Nexmo APIs
thumbnail: /content/blog/video-chat-javascript-opentok-nexmo-dr/Video-Chat-Application-with-OpenTok-and-Nexmo-In-App-Messaging.png
author: manik
published: true
published_at: 2019-01-09T00:12:20.000Z
updated_at: 2021-05-11T09:59:08.880Z
category: tutorial
tags:
  - javascript
  - video-api
comments: true
redirect: ""
canonical: ""
---
In this blog post, we’re going to build a web application that allows users to video chat and send messages to each other using [OpenTok](https://tokbox.com/developer/) and [Nexmo In-App Messaging](https://developer.nexmo.com/stitch/in-app-messaging/overview).

To see the full code, please check out the following [repo](https://github.com/nexmo-community/video-messaging-app). You can also check out our [recent webinar](https://www.crowdcast.io/e/building-with-opentok-8) that covers the application.

## Prerequisites

<sign-up></sign-up>

* A [TokBox](https://tokbox.com/account/user/signup) account and the API Key and Secret from an API project
* [Node.js](https://nodejs.org/en/)
* [NPM](https://www.npmjs.com/)
* [Nexmo CLI](https://www.npmjs.com/package/nexmo-cli)
* [Browserify](https://www.npmjs.com/package/browserify)

## Structure of the App

Create a directory and name it whatever you’d like:

```sh
mkdir video-messaging-app
cd video-messaging-app
```

We’ll go ahead and create a few files and subfolders inside the directory using the following commands:

```sh
mkdir public public/js views
touch public/js/index.js views/index.ejs server.js config.js
```

Our project structure should now look like this:

```
video-messaging-app
├── package.json
├── package-lock.json
├── views
│   ├── index.ejs
├── public
│   ├── js
│       ├── index.js
├── config.js
├── server.js
```

### Dependencies

We’ll create an NPM project and install all of the dependencies required for the project:

```javascript
npm init -y // we use the -y flag to skip through the questions
npm install opentok @opentok/client nexmo nexmo-stitch express ejs
```

Now, let’s go ahead create our server by adding the server code to the `server.js` file.

```javascript
const OpenTok = require('opentok');
const Nexmo = require('nexmo');
const express = require('express');

const app = express();
app.use(express.static(`${__dirname}/public`));

app.get('/', (req, res) => {
 res.json({
   opentokApiKey: null,
   opentokSessionId: null,
   opentokToken: null,
   nexmoConversationId: null,
   nexmoJWT: null,
 });
});

const PORT  = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Running server on PORT: ${PORT}`));
```

Please note that we’ve created a server using [ExpressJS](https://expressjs.com/) and are returning empty credentials for both OpenTok and Nexmo. Don’t worry, we’ll generate the credentials in the next few steps, but before we do that let’s go ahead and create our Nexmo messaging application using the Nexmo CLI:

```javascript
nexmo app:create video-messaging-app https://example.com/answer https://example.com/event --keyfile=private.key
nexmo conversation:create display_name="Nexmo In-App Messaging"
nexmo user:create name="jamie"
nexmo member:add YOUR_CONVERSATION_ID action=invite channel='{"type":"app"}' user_id=USER_ID // make sure to replace the conversation ID and the user ID
```

Using the `app:create` command, we’ll get the application ID for our `video-messaging-app` along with a private key which will be added to the directory. Please note that we’ve set the answer and event urls to example urls, but we can change these later. Using the `conversation:create` command, we have also created a conversation called `Nexmo In-App Messaging`. This will result in a conversation ID which we will use later to connect to the conversation. The `user:create` command also allows creates a user tied to the application. Please note the name of this user because we will use it as a part of our JWT generation process.

We’ll now create an OpenTok API project using the TokBox dashboard so you can get access to the API Key and Secret.

Now, let’s open our `config.js` file so we can store our credentials:

```javascript
module.exports = {
 opentokApiKey: '',
 opentokApiSecret: '',
 nexmoApiKey: '',
 nexmoApiSecret: '',
 nexmoApplicationId: '',
 nexmoPrivateKey: '',
 nexmoConversationId: '',
};
```

Make sure to add the appropriate credentials to the `config.js` file

### Importing the config variables:

In our `server.js` file, let's go ahead and import the config variables so we can use these to instantiate `OpenTok` and `Nexmo` classes.

```javascript
const {
 opentokApiKey,
 opentokApiSecret,
 nexmoApiKey,
 nexmoApiSecret,
 nexmoApplicationId,
 nexmoPrivateKey,
 nexmoConversationId,
 } = require('./config');


const opentok = new OpenTok(opentokApiKey, opentokApiSecret);
const nexmo = new Nexmo({
 apiKey: nexmoApiKey,
 apiSecret: nexmoApiSecret,
 applicationId: nexmoApplicationId,
 privateKey: nexmoPrivateKey,
});
```

Now let’s go ahead and update the GET request path so we can return valid credentials:

```javascript
app.get('/', (req, res) => {
 opentok.createSession({
   mediaMode: 'routed'
 }, (error, session) => {
   if (error) {
     res.status(500).send('There was an error generating an OpenTok session');
   } else {
     const opentokSessionId = session.sessionId;
     const opentokToken = opentok.generateToken(opentokSessionId);
     const nexmoJWT = nexmo.generateJwt({
       exp: new Date().getTime() + 86400,
       acl: {
          "paths": {
            "/v1/users/**": {},
            "/v1/conversations/**": {},
            "/v1/sessions/**": {},
            "/v1/devices/**": {},
            "/v1/image/**": {},
            "/v3/media/**": {},
            "/v1/applications/**": {},
            "/v1/push/**": {},
            "/v1/knocking/**": {}
          }
       },
       sub: 'jamie' // this is the name we set when creating the user with the Nexmo CLI
     });
     res.json({
       opentokApiKey,
       opentokSessionId,
       opentokToken,
       nexmoConversationId,
       nexmoJWT,
     });
   }
 });
});
```

Using the code above, we’ll create the following each time someone visits the `/` path from their browser:

* OpenTok session ID
* OpenTok Token for the corresponding session ID
* JWT Token for our Nexmo application with the appropriate ACLs

Now that we’ve created a mechanism to get the credentials let’s go ahead and work on the client side of the application.

Open up the `index.js` file located in the `js` directory.

```javascript
const OT = require('@opentok/client');
const ConversationClient = require('nexmo-stitch');

const session = OT.initSession(opentokApiKey, opentokSessionId);
const publisher = OT.initPublisher('publisher');

session.on({
 streamCreated: (event) => {
   const subscriberClassName = `subscriber-${event.stream.streamId}`;
   const subscriber = document.createElement('div');
   subscriber.setAttribute('id', subscriberClassName);
   document.getElementById('subscribers').appendChild(subscriber);
   session.subscribe(event.stream, subscriberClassName);
  },
 streamDestroyed: (event) => {
   console.log(`Stream ${event.stream.name} ended because ${event.reason}.`);
  },
  sessionConnected: event => {
    session.publish(publisher);
  },
});

session.connect(opentokToken, (error) => {
 if (error) {
   console.log('error connecting to session');
 }
});
```

In the code above, we initialize an OpenTok [Session](https://tokbox.com/developer/sdks/js/reference/Session.html) by calling the `initSession` method on the `OT` object. We then create a publisher and set the following event listeners: `streamCreated`, `streamDestroyed`, and `sessionConnected`. These event listeners are used to subscribe to streams when a stream is created, print a message when a stream is destroyed, and publish to the session when we're connected. We then proceed to connect to the session using the token we generated on the server.

Now that we’ve added the code for a video chat let’s add In-App Messaging.

```javascript
class ChatApp {
  constructor() {
   this.messageTextarea = document.getElementById('messageTextarea');
   this.messageFeed = document.getElementById('messageFeed');
   this.sendButton = document.getElementById('send');
   this.loginForm = document.getElementById('login');
  }
}
```

The `ChatApp` class will be used to add our In-App messaging features. We will also grab the reference to a few DOM elements that we'll create in our `index.ejs` file.

Let's go ahead and add some helper methods to the `ChatApp` class for logging our events and errors to the console:

```javascript
  errorLogger(error) {
   console.log(`There was an error ${error}`);
 }

 eventLogger(event) {
   console.log(`This event happened: ${event}`);
 }
```

Moving on, we need to instantiate a `ConversationClient` and authenticate with the `nexmoJWT` token generated by our server:

```javascript
 joinConversation(userToken) {
   new ConversationClient({
     debug: false
   })
   .login(userToken)
   .then(app => {
     console.log('*** Logged into app', app)
     return app.getConversation(nexmoConversationId)
   })
   .then(this.setupConversationEvents.bind(this))
   .catch(this.errorLogger)
 }
```

Now that we have a reference to the conversation, let's go ahead and set up our conversation events:

```javascript
 setupConversationEvents(conversation) {
   console.log('*** Conversation Retrieved', conversation)
   console.log('*** Conversation Member', conversation.me)

   conversation.on('text', (sender, message) => {
     console.log('*** Message received', sender, message)
     const date = new Date(Date.parse(message.timestamp))
     const text = `${sender.user.name} @ ${date}: <b>${message.body.text}</b><br>`
     this.messageFeed.innerHTML = text + this.messageFeed.innerHTML
   });
   this.showConversationHistory(conversation);
 }
```

We can retrieve the conversation history by calling the `getEvents` method on the `conversation` object. Let's go ahead and create a helper method so we can display the chat history on the DOM. As you can see below, we're using the different `types` to distinguish between the events:

```javascript
  showConversationHistory(conversation) {
   conversation.getEvents().then((events) => {
     var eventsHistory = ""
      events.forEach((value, key) => {
       if (conversation.members.get(value.from)) {
         const date = new Date(Date.parse(value.timestamp))
         switch (value.type) {
           case 'text:seen':
             break;
           case 'text:delivered':
             break;
           case 'text':
             eventsHistory = `${conversation.members.get(value.from).user.name} @ ${date}: <b>${value.body.text}</b><br>` + eventsHistory
             break;
            case 'member:joined':
             eventsHistory = `${conversation.members.get(value.from).user.name} @ ${date}: <b>joined the conversation</b><br>` + eventsHistory
             break;
           case 'member:left':
             eventsHistory = `${conversation.members.get(value.from).user.name} @ ${date}: <b>left the conversation</b><br>` + eventsHistory
             break;
           case 'member:invited':
             eventsHistory = `${conversation.members.get(value.from).user.name} @ ${date}: <b>invited to the conversation</b><br>` + eventsHistory
             break;
            default:
             eventsHistory = `${conversation.members.get(value.from).user.name} @ ${date}: <b>unknown event</b><br>` + eventsHistory
         }
       }
     })
      this.messageFeed.innerHTML = eventsHistory + this.messageFeed.innerHTML
   })
 }
```

We should also set up some user events to know when the end user has triggered actions on the HTML page:

```javascript
 setupUserEvents() {
   this.sendButton.addEventListener('click', () => {
     this.conversation.sendText(this.messageTextarea.value).then(() => {
         this.eventLogger('text');
         this.messageTextarea.value = '';
     }).catch(this.errorLogger)
 })
 this.loginForm.addEventListener('submit', (event) => {
     event.preventDefault();
     document.getElementById('messages').style.display = 'block';
     document.getElementById('login').style.display = 'none';
     this.joinConversation(nexmoJWT);
  });
 }
```

Let's make sure to set call the `setupUserEvents()` method in our constructor:

```javascript
class ChatApp {
  constructor() {
   this.messageTextarea = document.getElementById('messageTextarea');
   this.messageFeed = document.getElementById('messageFeed');
   this.sendButton = document.getElementById('send');
   this.loginForm = document.getElementById('login');
   this.setupUserEvents();
  }
}
```

Let's recap what we did in the code above. We’ve created a class called `ChatApp` that creates a `ConversationClient` which we authenticate using the `nexmoJWT` token. We also set an event listener, `text`, on the conversation object to listen to any incoming messages. Please note that to retrieve older messages from the conversation, we use the `getEvents` method. We use some event listeners on the DOM to display information when things are changed.

Now that we’ve created the ChatApp class let’s go ahead and instantiate a ChatApp class when the onload event fires so we can use the DOM elements as needed.

```javascript
window.onload = () => {
 new ChatApp();
}
```

After completing our `index.js`, let's go ahead and add some information to our `index.ejs` file:

```xml
<!DOCTYPE html>
<html>
  <head>
    <style>
      #login,
      #messages {
        width: 80% ; height: 300px;
      }

      #messages {
        display: none
      }

      #conversations {
        display: none
      }
    </style>
    <script type="text/javascript">
      const opentokApiKey = '<%= opentokApiKey %>';
      const opentokSessionId = '<%= opentokSessionId %>';
      const opentokToken = '<%= opentokToken %>';
      const nexmoConversationId = '<%= nexmoConversationId %>';
      const nexmoJWT = '<%= nexmoJWT %>';
    </script>
    <script src="/js/bundle.js"></script>
  </head>

  <body>
    <form id="login">
      <h1>Login</h1>
      <input type="text" name="username" value="">
      <input type="submit" value="Login" />
    </form>

    <section id="messages">
      <button id="leave">Leave Conversation</button>
      <h1>Messages</h1>

      <div id="messageFeed"></div>

      <textarea id="messageTextarea"></textarea>
      <br>
      <button id="send">Send</button>
    </section>

    <section id="conversations">
      <h1>Conversations</h1>
    </section>
  </body>
</html>
```

The code above is rendered by our server when someone visits the `/` path. As you can see, we pass in our credentials which we use for the OpenTok Session and Nexmo Conversation Client.

Lastly, let's modify our server to render the `index.ejs` view with the right variables:

```javascript
  res.render('index.ejs', {
    opentokApiKey,
    opentokSessionId,
    opentokToken,
    nexmoConversationId,
    nexmoJWT,
  });
```

Now that we have everything set up, let's add a `start` script to our `package.json` file so we can easily start the server:

```javascript
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "browserify public/js/index.js -o public/js/bundle.js && node server.js"
  }
```

Run `npm start` in your terminal and run the application!

## Conclusion

In this blog, we've covered important OpenTok and Nexmo In-App Messaging concepts showcasing the ability to add live video and in-app messaging to web applications. To see the full code, please refer the following [repo](https://github.com/nexmo-community/video-messaging-app).