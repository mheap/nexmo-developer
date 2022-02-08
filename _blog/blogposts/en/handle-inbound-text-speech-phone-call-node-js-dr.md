---
title: How to Handle Inbound Phone Calls with Node.js
description: Learn how to handle inbound phone calls and respond to them with a
  text-to-speech synthesized voice using the Nexmo Voice API w/ Node.js &
  Express.
thumbnail: /content/blog/handle-inbound-text-speech-phone-call-node-js-dr/voice-receive-node.png
author: tomomi
published: true
published_at: 2017-01-26T14:00:49.000Z
updated_at: 2021-05-17T13:23:14.383Z
category: tutorial
tags:
  - voice-api
  - node
comments: true
redirect: ""
canonical: ""
---
*This is the second of a two-part Voice API tutorial on making and receiving phone calls with Node.js. It continues the “Getting Started with Nexmo and Node.js” series, which followed our Getting Started series on SMS APIs. See links to prior tutorials in these series at the bottom of the post.*

In Part 1 of this tutorial, I showed how to create and secure an application and learned [how to make an outbound text-to-voice call using the Voice API](https://learn.vonage.com/blog/2017/01/12/make-outbound-text-speech-phone-call-node-js-dr/) with the Node.js client library. In this tutorial, you will learn how to receive inbound calls by implementing a webhook.

View [the source code on GitHub](https://github.com/nexmo-community/nexmo-node-quickstart/blob/master/voice/receive-call-webhook.js).

<sign-up number></sign-up>

## Using Nexmo Application

In this tutorial, you will use the same *application* that was created in the previous tutorial to receive a voice call. You also will update the application with webhook endpoint URLs. If you haven’t reviewed the first tutorial, ["How to Make an Outbound Text-to-Speech Call with Node.js"](https://learn.vonage.com/blog/2017/01/12/make-outbound-text-speech-phone-call-node-js-dr/), refer to the section, *Creating a Nexmo Application and Generating a Private Key* to create an application.

When a user calls the Nexmo virtual phone number associated with your voice application, Nexmo retrieves the [Nexmo Call Control Objects](https://docs.nexmo.com/voice/voice-api/ncco-reference) (NCCO) from your `answer_url` webhook endpoint, and answers the call with a synthesized voice that reads the text you have specified in the NCCO.

![Accepting incoming calls](/content/blog/how-to-handle-inbound-phone-calls-with-node-js/voice-accept-call-diagram.png)

*Diagram 1: Using The Voice API to receive a call to your Nexmo virtual number*

Nexmo also sends status information to another webhook endpoint defined by `event_url`. The event is triggered when the user’s handset is ringing (`ringing`), when the call is answered (`answered`), etc. You can find all the events in the [API Reference documentation](https://docs.nexmo.com/voice/voice-api/api-reference#call_retrieve).

## Defining Webhook Endpoints

In order to accept an incoming call to your Nexmo virtual phone number, you need to associate your voice application with webhook endpoint URLs.

Just as a previous tutorial showed how to use [ngrok](https://ngrok.com/) to [receive SMS messages](https://learn.vonage.com/blog/2016/10/27/receive-sms-messages-node-js-express-dr/), let’s use ngrok to expose your webhook endpoint on your local machine as a public URL.

Run ngrok with a port number of your choice (let’s make it 4001 for now):

```bash
$ ngrok http 4001
```

Your local server (localhost:4001) now has a forwarding URL, something like `https://97855482.ngrok.io` that can be used as your webhook endpoint during development.

## Writing WebHook Endpoints with Express

Let's handle the POST requests with [Express](https://expressjs.com/). You will also need to install body-parser.

```bash
$ npm install express body-parser --save
```

Create a .js file, instantiate express, and listen to the server to port 4001. Because you have set your ngrok to expose `localhost:4001`, you must stick with the same port.

```javascript
'use strict'
const app = require('express')();
const bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
const server = app.listen(process.env.PORT || 4001, () => {
console.log('Express server listening on port %d in %s mode', server.address().port, app.settings.env);
});
```

Let’s define the endpoint for the Answer URL as `/answer` and the Event URL as `/event`.

Create an HTTP GET route to handle the requests for `/answer` to retrieve your NCCO:

```javascript
app.get('/answer', function (req, res) {
const ncco = [
{
action: 'talk',
voiceName: 'Jennifer',
text: 'Hello, thank you for calling. This is Jennifer from Nexmo. Ciao.'
}
];
res.json(ncco);
});
```

Define your text to be read by a synthesized voice in JSON (or JavaScript object, in this case). You can customize the audio with [optional params](https://docs.nexmo.com/voice/voice-api/ncco-reference), such as `voiceName`, which you can choose from varieties of voices for a language, gender, and accent.

The endpoint for the `event_url` needs to be POST, so let’s define `/event`:

```javascript
app.post('/event', function (req, res) {
console.log(req.body);
res.status(204).end();
});
```

You don’t need to actually return anything if you just want to monitor the status in a terminal.

## Updating Nexmo Application with WebHook URLs

Nexmo applications contain configuration information you need to connect to the Voice API endpoints. Previously, we used placeholders for both the Answer URL and the Event URL. Now you are going to use the Nexmo CLI to update the application information with the webhook endpoints you just defined.

You need the Application ID to update the information. You can get it from the `make-call.js` in the previous tutorial, or use the `app:list` command:

```bash
$ nexmo app:list
```

The CLI should return a list of each app ID and an app name. Now, use the correct app ID to update the application with the webhook URLs:

```bash
$ nexmo app:update c6b78717-db0c-4b8b-9723-ee91400137cf "My Voice App" https://97855482.ngrok.io/answer https://97855482.ngrok.io/event
```

### Associating the Info with Your Virtual Number

Finally, you need to associate your application with the virtual number you rent from Nexmo. Let’s use the Nexmo CLI again. Use the command `nexmo link:app` followed by the phone number, which must start with a country code and then the app ID. So, the command should look like this:

```
$ nexmo link:app 12015556649 c6b78717-db0c-4b8b-9723-ee91400137cf
```

When the linking is successful, the CLI returns with the message, "Number updated".

## Testing Your Voice Application

Let's make a phone call to see if your application works! Call your virtual number from your physical phone. If everything works, you should hear the message you have defined in your NCCO.

Also, see your terminal to check the status of your call.

<youtube id="vuI82175gzo"></youtube>


In the next tutorial, you will learn how to record calls as audio files, so stay tuned!

## Learn More

Here are some resources you can use to dive deeper into Nexmo APIs and Node.js.

### API References and Tools

* [Application API](https://docs.nexmo.com/tools/application-api)
* [Voice API](https://docs.nexmo.com/voice/voice-api)
* [Accept Inbound Calls](https://docs.nexmo.com/voice/voice-api/inbound-calls)
* [Nexmo REST client for Node.js](https://github.com/Nexmo/nexmo-node)

### Nexmo Getting Started Guide for Node.js

* [How to Send SMS Messages with Node.js and Express](https://learn.vonage.com/blog/2016/10/19/how-to-send-sms-messages-with-node-js-and-express-dr/)
* [How to Receive SMS Messages with Node.js and Express](https://learn.vonage.com/blog/2016/10/27/receive-sms-messages-node-js-express-dr/)
* [How to Receive an SMS Delivery Receipt from a Mobile Carrier with Node.js](https://learn.vonage.com/blog/2016/11/23/getting-a-sms-delivery-receipt-from-a-mobile-carrier-with-node-js-dr/)
* [How to Make a Text-to-Speech Call with Node.js](https://learn.vonage.com/blog/2017/01/12/make-outbound-text-speech-phone-call-node-js-dr/)