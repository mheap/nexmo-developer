---
title: Create a webhook server
description: In this step you learn how to create a suitable webhook server that supports an app to app call.
---

# Create a webhook server

When an inbound call is received, Vonage makes a request to a publicly accessible URL of your choice - we call this the `answer_url`. You need to create a webhook server that is capable of receiving this request and returning an [NCCO](/voice/voice-api/ncco-reference) containing a `connect` action that will forward the call to another [User](/conversation/concepts/user). You do this by extracting the destination user from the `to` query parameter and returning it in your response.

## New project

Create a new project directory in a destination of your choice and change into it:

``` bash
mkdir app-to-app-js
cd app-to-app-js
```

Inside the folder, initialize a new Node.js project by running this command:

``` bash
npm init -y
```

## Add dependencies

Next, install the required dependencies:

``` bash
npm install express localtunnel --save
```

Also, install the Client SDK - you will use this later, when building the client application:

``` bash
npm install nexmo-client --save
```

## Create the server file

Inside your project folder, create a file named `server.js` and add the code as shown below - please make sure to replace `SUBDOMAIN` with an actual value. The value used will become part of the URLs you will set as webhooks in the next step.

``` javascript
'use strict';

const subdomain = 'SUBDOMAIN';

const express = require('express')
const app = express();
app.use(express.json());

app.get('/voice/answer', (req, res) => {
  console.log('NCCO request:');
  console.log(`  - caller: ${req.query.from}`);
  console.log(`  - callee: ${req.query.to}`);
  console.log('---');
  var ncco = [{"action": "talk", "text": "No destination user - hanging up"}];
  var username = req.query.to;
  if (username) {
    ncco = [
      {
        "action": "talk",
        "text": "Connecting you to " + username
      },
      {
        "action": "connect",
        "endpoint": [
          {
            "type": "app",
            "user": username
          }
        ]
      }
    ]
  }
  res.json(ncco);
});

app.all('/voice/event', (req, res) => {
  console.log('EVENT:');
  console.dir(req.body);
  console.log('---');
  res.sendStatus(200);
});

if(subdomain == "SUBDOMAIN") {
  console.log('\n\t🚨🚨🚨 Please change the SUBDOMAIN value');
  return false;
}
app.listen(3000);

const localtunnel = require('localtunnel');
(async () => {
  const tunnel = await localtunnel({ 
      subdomain: subdomain, 
      port: 3000
    });
  console.log(`App available at: ${tunnel.url}`);
})();
```

> **NOTE:** Please remember to replace `SUBDOMAIN` with a random string of your choice, containing lowercase letters, numbers, underscores or dashes.

There are 2 parts in the server code above:

### The Express server

The first part creates an `Express` server and makes it available locally on port `3000`. The server exposes 2 paths:

1. `/voice/answer` is the `answer_url` we mentioned above. It sends back a `JSON` response containing the user that will be receiving the call. 
   
    Notice, that the `username` is extracted from the `req.query.to` parameter that Vonage is sending as part of the request. The dynamically built NCCO then forwards the in-app call to the receiving user using a `connect` action.

2. The second one, `/voice/event`, you will set as destination for Vonage to notify you of everything happening during the in-app call - we call this the `event_url`.


### The `localtunnel`  integration

The second part of the server code above, exposes the `Express` server so it will be accessible by the Vonage servers.

> **NOTE:** `localtunnel` is a JavaScript library that exposes your localhost to the world for painless testing and sharing! No need to mess with DNS or deploy to have others test out your changes.


## Start the server

You can now start the server by running, in the terminal, the following command:

``` bash
node server.js
```

A notice will be displayed telling you the server is now available:

```
App available at: https://SUBDOMAIN.loca.lt
```

Please keep the terminal window handy as you will need the URL in the next step.
