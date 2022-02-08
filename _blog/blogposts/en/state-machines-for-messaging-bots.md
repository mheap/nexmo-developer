---
title: State Machines for WhatsApp Messaging Bots with Node.js
description: Learn how to create a persistent state to build a Node.js state
  machine in a WhatsApp messaging bot server
thumbnail: /content/blog/state-machines-for-whatsapp-messaging-bots-with-node-js/state-machine_1200x600-1.png
author: garann-means
published: true
published_at: 2021-09-02T12:06:26.603Z
updated_at: 2021-08-23T11:56:56.437Z
category: tutorial
tags:
  - messages-api
  - whatsapp
  - javascript
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
In a typical web server, you don't have to think much about state. A user sends you a request and you provide a response. It's not necessary for the application to guide itself through a path of choices and actions; the end user does that. However, a bot works differently.

Although an end-user initiates a conversation with a bot, the bot needs to define the path from there, asking questions of the user to inform them of the potential next steps. When the bot is not just answering questions, but instead walking an end-user through a series of steps, that's what's known as a state machine.

Implementing a state machine as a messaging bot is a little bit tricky because messaging bots don't organically have any concept of state. By default, a message sent to a server you control comes in without a session, state, or any other information about a big picture the individual message might be a part of. But really all that means is you'll need to manually store the last state of a "session" between your server and a given phone number. In actuality, a web application has to do the same thing. Platforms and libraries just routinely do the work for us. 

## Prerequisites

Our bot server will use one of those traditional web servers in a non-traditional way. To follow along with this example you'll need:

* [Node](https://nodejs.org/en/) and [Express](https://expressjs.com/) installed
* A [SQLite](https://www.sqlite.org/index.html) database [installed and configured](https://github.com/mapbox/node-sqlite3)
* A Vonage Developer account

<sign-up></sign-up>

The code we'll be looking at is part of a larger [WhatsApp bot example project](https://vonage-whatsapp-bot.glitch.me/) on Glitch. You can also copy and paste from there, or remix it to start with a functional app.

## Server Endpoints

All instructions and requests from end-users are routed through just one endpoint on our server. It's up to our server to parse them and determine what to do next. Incoming messages will be POST requests containing the message itself and its metadata. We can use Express to handle them, then forward specific types onto other handlers later. 

First, we'll set up an Express server in `server.js`, configuring it to parse the body of incoming requests and server static pages. We can also define our states. I've used explanatory property names mapped to integers to avoid having to do string comparisons. There'll be plenty of those later!

```javascript
const fs = require('fs');
const express = require('express');
const app = express();

app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static('public'));

const states = {
  waiting: 0,
  getUsername: 1,
  getEmail: 2,
  getAddress: 3,
  confirmPayment: 4
};

// CONFIGURE DATABASE

// APP CODE

const listener = app.listen(process.env.PORT, () => {
  console.log("Your app is listening on port " + listener.address().port);
});
```

Because the Vonage API provides two webhooks, there are two endpoints in the server. But in this example, only one will actually do anything. To keep things tidy, the `/status` endpoint just acknowledges any requests it receives. The `/inbound` endpoint is where the work of the app truly begins. 

Before the `/inbound` endpoint, we create a Vonage instance we can use to send replies. The example uses the Vonage Message API Sandbox, which requires setting the `apiHost`. 

```javascript
// APP CODE

// this endpoint receives information about events in the app
app.post('/status', function(req, res) {
  res.status(204).end();
});

const Vonage = require('@vonage/server-sdk');
const vonage = new Vonage({
  apiKey: process.env.API_KEY,
  apiSecret: process.env.API_SECRET,
  applicationId: process.env.APP_ID,
  privateKey: __dirname + '/.data/private.key'
},{
  apiHost: 'https://messages-sandbox.nexmo.com/'
});

app.post('/inbound', function(req, res) {});
app.post('/signup', function(req, res) {});
function setUsername(phone, username) {}
```

Before fleshing out the inbound message handler and other functions, we'll configure the other pieces we need.

## Configuring the Webhooks

To send messages back and forth between a personal messaging app account and the server, you need to configure the Vonage Messages API. Messages sent to a Vonage-owned account or one you've registered with a Vonage application will be forwarded to the endpoint you specify. There are two ways to do this, depending on whether or not you're using the Messages API Sandbox. 

If you're using the Sandbox, you won't need to create an application to try out messaging. You can configure your webhooks from the Sandbox page itself. Just supply an endpoint to handle incoming messages and one to handle status messages on your publicly accessible server.

![Specifying webhook endpoints in the Messages API Sandbox](/content/blog/state-machines-for-messaging-bots/screen-shot-2021-08-23-at-16.21.19.png)

If you own a number for messaging, you can configure the webhooks within your application. When creating the application, scroll down to Capabilities and toggle "Messages" on. This reveals the fields where you can specify the webhook endpoints. 

![Setting webhook endpoints in a Vonage application](/content/blog/state-machines-for-messaging-bots/screen-shot-2021-08-23-at-16.19.53.png)

## Setting Up a Data Store

The state you store can be simple or complex, depending on your needs. In addition to the state of the server's interaction with a given user, you may want to store information you'd keep in a session variable in a traditional web server. However, sometimes that information is stored in the session to avoid having to keep looking it up in the database, so there may be little benefit. Additional information in your state database is probably best used for additional context relevant to the current state. 

First, we'll create the database itself, then add a state table. This example won't be complex. Instead of containing multiple columns for different pieces of information a given state could potentially need, we'll just use a catch-all column called `memo`:

```javascript
// CONFIGURE DATABASE

const dbFile = './.data/sqlite.db';
var exists = fs.existsSync(dbFile);
const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database(dbFile);

db.serialize(function(){
  if (!exists) {
    db.run('CREATE TABLE State (phone NUMERIC UNIQUE, state NUMERIC, memo TEXT)')
    db.run('CREATE TABLE Users (phone NUMERIC UNIQUE, username TEXT, email TEXT, address TEXT)');
  } 
});
```

We're also creating a `Users` table, because the stateful process in this example will be user registration.

## Checking the State

Now, when we receive an inbound message, we're prepared to check whether our bot is in the middle of a stateful process with the sender. We won't look at the contents of the message until we check the state database and determine what state we're expecting. Assuming it's possible to exit a stateful process, you might choose to check whether the user wants to do that before going to the database. But most processes, once begun, need some cleanup if they're canceled, so it's equally likely you'll want to check the database anyway.

The main thing we need from the request body will be the phone number of the sender. We can use that to query the state database and, if we find that the number has a state, call a function it corresponds to. If not, we can pass the whole message to a `parseIncoming` function that will look for new instructions.

```javascript
app.post('/inbound', function(req, res) {
  let phone = req.body.from.number;
  let message = req.body.message.content;
  
  db.get('SELECT * FROM State WHERE (phone = $phone)', {
    $phone: phone
  }, function(error, userState) {
    
    switch(userState.state) {
      case states.getUsername:
        setUsername(phone, message.text);
        break;
      case states.getEmail:
        setEmail(phone, message.text, true);
        break;
      case states.getAddress:
        setAddress(phone, message.text, true);
        break;
      case states.confirmPayment:
        completeBuy(phone, message.text);
        break;
      default:
        parseIncoming(phone, message);
    }
    
  });
  
  res.status(204).end();  
});
```

## Updating the State

Assuming we're continuing through the process, the next state will be determined by the current state. Initially, of course, there won't be one. The user has to enter into a stateful process somehow. For most of the states available in the example, that way is by signing up. 

The pattern in the `/signup` endpoint is half of the one most of the other steps of the signup process will follow. It sends a message to the phone number found in the request body (in this case, coming from a web form instead of a message), prompting the user to complete the next step. It then creates a new state database row to mark the user's place in the process. In subsequent steps, that will be an update:

```javascript
app.post('/signup', function(req, res) {
  let phone = req.body.number;
  
  vonage.channel.send(
    { type: 'whatsapp', number: phone },
    { type: 'whatsapp', number: process.env.WHATSAPP_NUM },
    { content: {
      type: 'text',
      text: 'Welcome to Nice Cool Shoes! What should we call you?'
    }}, (e, data) => {
      if (e) {
        console.error(e);
      } else {
        db.run('INSERT INTO State (phone, state) VALUES ($phone, $state)', {
          $phone: parseInt(phone),
          $state: states.getUsername
        }, (err) => {
          if (err) {
            console.error(err);
          }
        });
      }
    }
  );
  
  res.send({});

});
```

The next function in the process, `setUsername` shows a complete state transition. Because the previous step sent a prompt, it's assumed the next message that comes back is the response. Therefore the message text is inserted into the `Users` table as the new user's username. Once that's done, the rest is like the `/signup` endpoint. The server sends the next prompt and updates the `State` table:

```javascript
function setUsername(phone, username) {
  
  db.run('INSERT INTO Users (phone, username) VALUES ($phone, $username)', {
    $phone: parseInt(phone),
    $username: username
  }, (err, row) => {
    if (err) {
      console.error(err);
    }
  });
  
  vonage.channel.send(
    { type: 'whatsapp', number: phone },
    { type: 'whatsapp', number: process.env.WHATSAPP_NUM },
    { content: {
      type: 'text',
      text: 'Nice to meet you, ' + username + '! What\'s your email address?'
    }}, (e, data) => {
      if (e) {
        console.error(e);
      } else {
        db.run('UPDATE State SET state = $state WHERE phone = $phone', {
          $phone: parseInt(phone),
          $state: states.getEmail
        }, (err, row) => {
          if (err) {
            console.error(err);
          }
        });
      }
    }
  );  
  
}
```

## Next Steps

If your bot is mostly answering questions, your need for a state machine may be limited and hard-coding a few functions may be the most sensible thing to do. But you may have noticed that workflows like the user signup in the example are using slightly different information for the same tasks at each step. By abstracting the common elements into a single function and providing a more detailed array of states, you can have the server move the process along in a less manual way. For our example, an expanded definition of a state could include:

* column name to update
* next prompt
* next state

You could add more information, like table names, to make it handle states in multiple different processes.

There are all kinds of interesting ways you can structure a messaging bot. Check out the [Vonage Messages API documentation](https://developer.nexmo.com/messages/overview) to learn more about features and use cases that may be helpful to your project.
