---
title: How to Send and Receive SMS Messages With Node.js and Express
description: An in-depth tutorial that demonstrates how to send SMS text
  messages and receive replies using the Vonage APIs, Node.js and the Express
  framework.
thumbnail: /content/blog/how-to-send-and-receive-sms-messages-with-node-js-and-express/node-js_express_sms_1200x600.png
author: laka
published: true
published_at: 2019-09-16T08:00:45.000Z
updated_at: 2021-07-29T22:16:33.119Z
category: tutorial
tags:
  - javascript
  - node
  - sms-api
comments: true
---
Vonage has a couple of APIs that allow you to send and receive a high volume of SMS messages anywhere in the world. Once you get your virtual phone number, you can use the APIs to manage outbound messages (“sending”) and inbound messages (“receiving”).  

In this article, you will learn how to send and receive SMS messages with [Node.js](https://nodejs.org/) and [Express](https://expressjs.com/).

We will first send an SMS with Node.js and the new [Vonage Messages API](https://developer.vonage.com/messages/overview).\
We'll then build a Webhook that can receive SMS messages using Express. We'll focus in this article on sending and receiving SMS messages. Still, if you want to send and receive messages with Facebook Messenger, Viber, or WhatsApp, you can do that as well with the [Messages API](https://developer.vonage.com/messages/overview).

You can extend the application we're building here to reply to incoming SMS messages or include more complex, interactive elements and give you a head start building autoresponders for your SMS needs.

The code for this tutorial can be found on [GitHub](https://github.com/nexmo-community/nexmo-sms-autoresponder-node/) & [Glitch](https://glitch.com/edit/#!/whispering-rebel-ixia).

## Prerequisites

Before you begin, make  sure you have:

* [Node.js](https://nodejs.org/en/download/) installed on your machine
* [ngrok](https://ngrok.com/) to make the code on our local machine accessible to the outside world
* The [Vonage CLI Beta](https://www.npmjs.com/package/@vonage/cli): `npm install -g @vonage/cli@beta`

<sign-up number></sign-up>

## Send an SMS Message With the Messages API

You may already be familiar with the Vonage [SMS API](https://developer.vonage.com/messaging/sms/overview), but one of our newer APIs can also send text messages—the [Vonage Messages API](https://developer.vonage.com/messages/overview). It is a multi-channel API that can send a message via different channels, such as SMS, Facebook Messenger, Viber, and WhatsApp. The API is in Beta right now, so we need to install the beta version of the Vonage Node.js SDK.

```
npm install @vonage/server-sdk@beta
```

While Vonage has two different APIs capable of sending and receiving SMS, you can only use one at a time because it will change the format of the webhooks you receive.
Make sure that the Messages API is set as the default under the *SMS settings* of [your account](https://dashboard.nexmo.com/settings).

![Set Messages API as the default API for sending SMS messages](/content/blog/how-to-send-and-receive-sms-messages-with-node-js-and-express/messages-as-default-sms.png "Set Messages API as the default API for sending SMS messages")

### Run ngrok

If you haven't used ngrok before, there is a [blog post](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) that explains how to use it. If you're familiar with ngrok, run it with `http` on the 3000 port.

```
ngrok http 3000
```

After ngrok runs, it will give you a random-looking URL that we'll use as the base for our Webhooks later on. Mine looks like this: `http://5b5c1bd0.ngrok.io`.

### Create a Messages-Enabled Vonage Application

To interact with the Messages API, we'll need to create a Vonage API application to authenticate our requests. Think of applications more like containers, metadata to group all your data on the Vonage platform. We'll [create one using the Vonage API Dashboard](https://dashboard.nexmo.com/applications/new). 

Give it a name and click on *Generate public and private key*.
You'll be prompted to save a keyfile to disk—the private key. It's usually a good call to keep it in your project folder, as you'll need it later.\
Applications work on a public / private key system, so when you create an application, a public key is generated and kept with Vonage, and a private key is generated, not kept with Vonage, and returned to you via the creation of the application. We'll use the private key to authenticate our library calls later on.

Next, you need to enable the *Messages* capability and provide an inbound URL and a status URL.\
Use the ngrok URL you got in the previous step and fill in the fields, appending `/webhooks/inbound` and `/webhooks/status`, for the respective fields. When a message reaches the Messages API, the data about it is sent to the *inbound URL*. When you send a message using the API, the data about the message status gets sent to the *status URL*.

Finally, link one or more of your virtual numbers to this application. Any messages received on these numbers will be passed along to your *inbound URL*.

![Create Messages enabled Vonage Application](/content/blog/how-to-send-and-receive-sms-messages-with-node-js-and-express/tutorial.gif "Create Messages enabled Vonage Application")

#### Initialize Dependencies

Create an `index.js` file and initialize the Vonage node library installed earlier in it.

```
touch index.js
```

```javascript
import Vonage from '@vonage/server-sdk'

const vonage = new Vonage({
  applicationId: VONAGE_APPLICATION_ID,
  privateKey: VONAGE_APPLICATION_PRIVATE_KEY_PATH
})
```

Replace the values in all caps with the application id for the Vonage application you created and the path to the private key you saved.

### Send the SMS Message

To send an SMS message with the Messages API, we'll use the `vonage.channel.send` method of the Vonage node library. This method accepts objects as parameters, with information about the recipient, sender, and content. They vary for the different channels, so you'll need to check the [API documentation](https://developer.nexmo.com/api/messages-olympus) for the other channels mentioned.

For SMS, the type of recipient and sender is `sms`, and the object has to contain a `number` property. The `content` object accepts a `type` of `text` and a text message. The callback returns an error and response object, and we'll log messages about the success or failure of the operation.

```javascript
const text = "👋Hello from Vonage";

vonage.channel.send(
  { "type": "sms", "number": TO_NUMBER },
  { "type": "sms", "number": "Vonage" },
  {
    "content": {
      "type": "text",
      "text": text
    }
  },
  (err, responseData) => {
    if (err) {
      console.log("Message failed with error:", err);
    } else {
      console.log(`Message ${responseData.message_uuid} sent successfully.`);
    }
  }
);
```

Replace `TO_NUMBER` with the destination phone number as a string, then run the code with:

```
node index.js
```

That's it; you've just sent an SMS message using the Vonage Messages API. You might notice that the Messages API is a bit more verbose in usage, yet it still needs just one method to send an SMS message.

## Receive SMS Messages

When a Vonage number receives an SMS message, Vonage will pass that message along to a predetermined Webhook. You've already set up the webhook URL when you created the Messages enabled Vonage application: `YOUR_NGROK_URL/webhooks/inbound`

### Create a Web Server

We'll create our webserver using `express` because it's one of the most popular and easy-to-use Node.js frameworks for this purpose. We'll also be looking at the request bodies for the inbound URL, so we'll need to install `express` from npm.

```
npm install express
```

Let's create a new file for this, call it `server.js`:

```
touch server.js
```

We'll create a basic `express` application that uses the JSON parser from `express` and sets the `urlencoded` option to `true`. Let's fill out the `server.js` file we created. We'll use port 3000 for the server to listen to, and we already have ngrok running on port 3000.

```javascript
import express from 'express'	 
  
const {	 
 json,	   
 urlencoded	 
} = express	 
  
const app = express()	 
  
app.use(json())	 
  
app.use(urlencoded({	 
 extended: true	 
}))	 
  
app.listen(3000, () => {	 
 console.log('Server listening at http://localhost:3000')	 
})
```

### Create Webhook for the Inbound URL

We're going to create a POST request handler for `/webhooks/inbound` for the inbound URL, and we'll log the request body to the console. Because Vonage has a retry mechanism, it will keep resending the message if the URL doesn't respond with `200 OK`, so we'll send back a `200` status.

```javascript
app.post('/webhooks/inbound', (req, res) => {
  console.log(req.body);

  res.status(200).end();
});
```

You can run the code with:

```
node server.js
```

### Try It Out

Now send an SMS message from your phone to your Vonage number. You should see the message being logged in the terminal window where you ran the code. It looks similar to this:

```bash
{
  message_uuid: 'ecb3f7ab-5f70-4de1-9003-1e59a7270782',
  to: { type: 'sms', number: '447401234567' },
  from: { type: 'sms', number: '447312277109' },
  timestamp: '2021-07-07T15:30:26.706Z',
  usage: { price: '0.0057', currency: 'EUR' },
  message: {
    content: { type: 'text', text: 'Chuck Norris can hear text messages.' },
    sms: { num_messages: '1' }
  },
  direction: 'inbound'
}
```

I hope it worked, and you've just learned how to send and receive SMS messages with the Vonage Messages API and Node.js.