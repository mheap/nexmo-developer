---
title: Create a webhook server
description: In this step you learn how to create a suitable webhook server that supports an inbound call from a PSTN phone to a web app.
---

# Create a webhook server

When an inbound call is received, Vonage makes a request to a publicly accessible URL of your choice - we call this the `answer_url`. You need to create a webhook server that is capable of receiving this request and returning an NCCO containing a `connect` action that will forward the call to the PSTN phone number. You do this by extracting the destination number from the `to` query parameter and returning it in your response.

## New project

Create a new project directory in a destination of your choice and change into it:

``` bash
mkdir vonage-app-to-phone-tutorial
cd vonage-app-to-phone-tutorial
```

Inside the folder, create a blank project by running this command:

``` bash
npm init -y
```

## Add dependencies

Next, install the required dependencies:

``` bash
npm install express localtunnel --save
```

Also, install the Client SDK - you'll use this later when building the client:

``` bash
npm install nexmo-client --save
```

## Create the server file

Inside your project folder, create a file named `server.js` and add the code as shown below - please make sure to replace `subdomain-of-your-choosing` with an actual value:

``` javascript
'use strict';
const express = require('express')
const app = express();
app.use(express.json());

app.get('/voice/answer', (req, res) => {
  console.log('NCCO request:');
  console.log(`  - caller: ${req.query.from}\n  - callee: ${req.query.to}`);
  console.log('---');
  res.json([ 
    { 
      "action": "talk", 
      "text": "Please wait while we connect you."
    },
    { 
      "action": "connect", 
      "endpoint": [ 
        { "type": "phone", "number": req.query.to } 
      ]
    }
  ]);
});

app.all('/voice/event', (req, res) => {
  console.log('VOICE EVENT:');
  console.dir(req.body);
  console.log('---');
  res.sendStatus(200);
});

app.listen(3000);


const localtunnel = require('localtunnel');
(async () => {
  const tunnel = await localtunnel({ 
      subdomain: 'subdomain-of-your-choosing', 
      port: 3000
    });
  console.log(`App available at: ${tunnel.url}`);
})();
```

Please remember to replace `subdomain-of-your-choosing` with an actual value.


There are 2 parts in the above server code:


### The Express server

The first part creates an `Express` server and makes it available locally on port `3000`. The server exposes 2 paths:

1. `/voice/answer` is the `answer_url` we mentioned above. It sends back a `JSON` response containing the destination number for the call. 
   
    Notice, that the `number` is extracted from the `req.query.to` parameter that Vonage is sending as part of the request. The dynamically built NCCO then forwards the call to the destination phone using a `connect` action.

2. The second one, `/voice/event`, you will set as destination for Vonage to notify you of everything happening in your all - - we call this the `event_url`.


### The `localtunnel`  integration

The second part of the server code above, exposes the `Express` server to will be accessible by the Vonage server.

`localtunnel` is a JavaScript library that exposes your localhost to the world for easy testing and sharing! No need to mess with DNS or deploy just to have others test out your changes.


## Start the server

You can now start the server by running, in the terminal, the following command:

``` bash
node server.js
```

A notice will be displayed telling you the server is now available:

```
App available at: https://subdomain-of-your-choosing.loca.lt
```

Please keep the terminal window handy as you will need the URL in the next step.
