---
title: Messaging Everywhere With Node.js
description: See how useful WhatsApp, Viber, and Facebook Messenger chat can be
  with the Vonage Messages API Sandbox, then start adding it to production
  alongside SMS.
thumbnail: /content/blog/messaging-everywhere-with-node-dr/Blog_Node-js_Messaging_1200x600.png
author: garann-means
published: true
published_at: 2020-05-27T14:35:10.000Z
updated_at: 2021-05-05T13:08:32.257Z
category: tutorial
tags:
  - node
  - messages-api
  - sms-api
comments: true
redirect: ""
canonical: ""
---
The Vonage [Messages API Sandbox](https://developer.nexmo.com/messages/concepts/messages-api-sandbox) is great for trying out communication channels your organization may not have already. Once you see how useful WhatsApp, Viber, and Facebook Messenger chat can be you might be inspired to start adding it to production.

There are slight differences between the sandbox and the regular [Vonage Messages API](https://developer.nexmo.com/messages/overview). There are also slight differences between the individual channels. In this example, you'll create a server to send messages from any channel, from the sandbox or production. You can also [remix the code on Glitch](https://glitch.com/~vonage-multi-messenger) to get started testing things in the sandbox then moving to production more quickly.

## Prerequisites

You don't need much more than Node.js and the [Nexmo Node SDK](https://www.npmjs.com/package/nexmo) for this code. However, you'll need a correctly configured application for it to work. We'll go through that in detail, so for now, create a new project directory and be sure it has:

- Node and npm
- The beta Nexmo Node.js SDK
- [Express.js](https://expressjs.com/)
- [body-parser](https://www.npmjs.com/package/body-parser)
- [dotenv](https://www.npmjs.com/package/dotenv)

From the command line, you can run `npm init` to prepare your project. Then you can install the packages with:

```text
> npm install nexmo@beta express body-parser dotenv -s
```

<sign-up></sign-up>

## Get Set Up

Before you begin to code, go to your [Vonage Developer Dashboard](https://dashboard.nexmo.com/). First, create a new application and make sure to assign one of your phone numbers to it. This is a good time to create a `.env` file in your project directory. You can create some variables and paste your new Application ID and private key directly into the file:

```bash
API_KEY=""
API_SECRET=""
SMS_NUM=""
WHATSAPP_NUM=""
VIBER_ID=""
FB_ID=""
APP_ID="12a34b5c-6789-0d12-34e5-6fa789bcde0f"
PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
xxxxxx... etc."
```

You can find your `API_KEY` and `API_SECRET` on the [Getting Started](https://dashboard.nexmo.com/) page in your dashboard. The `SMS_NUM` is the number you assigned to your application. `WHATSAPP_NUM`, `VIBER_ID`, AND `FB_ID` can be found on the [Messages API Sandbox](https://dashboard.nexmo.com/messages/sandbox) page, in the example cURL commands for the respective channels. This example assumes you're using the sandbox for all three and don't already have your own accounts.

Now create a `server.js` file so you can get started coding. The code in this example uses Glitch's default Express server setup, which is pretty straight-forward. You'll require Express and the body-parser middleware, and configure your server to serve static pages from the `/public` directory. You can add a few endpoints to serve a static landing page and provide webhook endpoints for your application. At the end of the file you can start the server:

```javascript
const express = require("express");
const app = express();
const bodyParser = require('body-parser');

app.use(express.static('public'));
app.use(bodyParser.json());

// https://expressjs.com/en/starter/basic-routing.html
app.get("/", (request, response) => {
  response.sendFile(__dirname + "/views/index.html");
});

app.post('/answer', function(req, res) {
  // this is where contacts could send you new communication info
  res.status(204).end();
});

// this endpoint receives information about events in the app
app.post('/event', function(req, res) {
  res.status(204).end();
});

// TODO: Add some messaging logic here!

// listen for requests :)
const listener = app.listen(process.env.PORT, () => {
  console.log("Your app is listening on port " + listener.address().port);
});
```

## Create Two Clients

Because you can't send SMS messages from the Vonage Messages Sandbox API, you'll want two clients if your app allows communication via SMS as well as other messaging channels. You can add both below your `/event` listener function:

```javascript
// create Nexmo clients
const Nexmo = require('nexmo');

// this client uses your real SMS, WhatsApp, Viber, and Messenger accounts
const nexmo = new Nexmo({
  apiKey: process.env.API_KEY,
  apiSecret: process.env.API_SECRET,
  applicationId: process.env.APP_ID,
  privateKey: process.env.PRIVATE_KEY 
});
// this client uses the Message API Sandbox, for testing only
const sandbox = new Nexmo({
  apiKey: process.env.API_KEY,
  apiSecret: process.env.API_SECRET,
  applicationId: process.env.APP_ID,
  privateKey: process.env.PRIVATE_KEY 
}, {
  apiHost: 'messages-sandbox.nexmo.com'
});

// add channels to this array to use a production account
// in this example, only SMS is a "real" channel, the rest use the sandbox
const prodChannels = ['SMS'];
```

First you'll require the `nexmo` package to use the SDK. Then you can create two nearly-identical clients. The only difference between them is that the `sandbox` client uses a specific Messages Sandbox `apiHost` key: `messages-sandbox.nexmo.com`. 

To switch channels from sandbox to production in one place, you can store the production channels in an array. We'll check this array in the next step to determine which client we should be using. 

## Handle Client-Side Requests

Next, you can set up your server to handle requests from a form on the front-end. This form will allow you to select a contact or user, the channel to message them on, and some text to send to them. The example code stores an array of users and their contact details in `.data/contacts`. You should provide your whitelisted numbers and accounts in the format:

```javascript
module.exports = [
  {
    id: 1, 
    name: 'Template McTemplateypants',
    sms: '441234567890',
    viber: '441234567890',
    whatsapp: '441234567890',
    messenger: '1234567890123456'
  }
];
```

After requiring your data file, you can handle POST requests to `/send`. You'll get the `contact`, `method`, and `message` from the request body, and use the contact ID to find the corresponding user object. You'll set the default client to be `sandbox`, then check whether `method` is in your array of production channels and change the client to `nexmo` if it is.

You'll build _to_ and _from_ objects in separate functions and pass them, along with the `message`, to the client's `channel.send` method. That method will return an error if there was a problem, and some data about the message sent. Don't forget to send a response back to the client to close the request.

The last thing to add to the server are the `getFrom` and `getTo` functions. These make sure the _to_ and _from_ objects are structured correctly for the channel selected:

```javascript
const users = require('./.data/contacts');

// handle the form submission from the client
app.post("/send", function(req, res) {
  var contact = req.body.contact;
  var user = users.find(u => u.id == contact);
  var method = req.body.method;
  var message = req.body.message;
  var client = sandbox;
  
  if (prodChannels.includes(method)) {
    client = nexmo;
  }
  
  client.channel.send(getTo(user, method), getFrom(method), {
    content: {
      type: 'text',
      text: message
    }
  }, (e, data) => {
    if (e) {
      console.error(e);
    }
    console.log(data);
  });
  
  res.send({data: 'sent'});
});

function getFrom(method) {
  if (method == 'SMS') {
    return { "type": 'sms', "number": process.env.SMS_NUM };
  }
  if (method == 'WhatsApp') {
    return { "type": 'whatsapp', "number": process.env.WHATSAPP_NUM };
  }
  if (method == 'Viber') {
    return { "type": 'viber_service_msg', "id": process.env.VIBER_ID };
  }
  if (method == 'FB') {
    return { "type": 'messenger', "id": process.env.FB_ID };
  }
}

function getTo(user, method) {
  if (method == 'SMS') {
    return { "type": 'sms', "number": user.sms };
  }
  if (method == 'WhatsApp') {
    return { "type": 'whatsapp', "number": user.whatsapp };
  }
  if (method == 'Viber') {
    return { "type": 'viber_service_msg', "number": user.viber };
  }
  if (method == 'FB') {
    return { "type": 'messenger', "id": user.messenger };
  }
}
```

## Build a UI

You'll need some kind of interface to send your messages. This example uses a minimal form on the client-side. The example values are hard-coded and match up with the objects the example has in `.data/contacts.js`. You could take it a step further and populate the options dynamically, depending on how much data you have:

```html
    <form>
      <label>Contact:
        <select id="contact">
          <option value="1">Angie</option>
          <option value="2">Benji</option>
          <option value="3">CJ</option>
          <option value="4">Digby</option>
        </select>
      </label>
      <label>Method:
        <select id="method">
          <option>SMS</option>
          <option>WhatsApp</option>
          <option>Viber</option>
          <option value="FB">Facebook Messenger</option>
        </select>
      </label>
      <section>
        <label for="message">Message:</label>
        <textarea id="message"></textarea>
        <button>Send</button>
      </section>
    </form>
```

The script to submit the form responds to the click of a generic button. It gets the values in the form and builds a request body with them, submitting it to your `/send` endpoint. Once it gets any data back, it blanks out the form:

```javascript
    <script>
      const contact = document.querySelector('#contact');
      const method = document.querySelector('#method');
      const message = document.querySelector('#message');

      document.querySelector('button').onclick = function(e) {
        let body = JSON.stringify({
            contact: contact.value,
            method: method.value,
            message: message.value
          });

        fetch('/send', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: body
        })
        .then(response => response.json())
        .then(data => {
          contact.value = '';
          method.value = '';
          message.value = '';
        });
        return false;
      };
    </script>
```

## Send Some Messages

With the device or devices of your whitelisted accounts and SMS numbers handy, you can try sending some messages via your form. Once you've verified it worked, you can adapt this code to set up testing with the Vonage Messages API Sandbox for your application's logic.