---
title: Build an Interactive Voice Response Menu using Node.js and Express
description: This tutorial shows you how to build interactive voice reponse
  menus for your application using Nexmo, Node.js and the Express framework.
thumbnail: /content/blog/build-interactive-voice-response-node-express-javascript-dr/ivr-menu-node-express.png
author: laka
published: true
published_at: 2019-04-08T08:00:29.000Z
updated_at: 2021-05-13T17:39:11.629Z
category: tutorial
tags:
  - voice-api
  - javascript
  - PBX
comments: true
redirect: ""
canonical: ""
---
We're going to build an interactive voice response menu, going through everything you need to know to set up a Node.js application that can receive inbound calls and capture user input entered via the keypad.

By following this tutorial you will end up with a simple application that can be extended to include more complex, interactive elements and give you a head start building interactive menus for your callers.

The code for this tutorial can be found on [GitHub](https://github.com/Nexmo/nexmo-node-code-snippets/blob/master/voice/ivr-menu.js).

## Prerequisites

<sign-up number></sign-up>

* [Node.js](https://nodejs.org/en/download/) installed on your machine
* [ngrok](https://ngrok.com/) in order to make the code on our local machine accessible to the outside world
* The [Nexmo CLI](https://developer.nexmo.com/tools): `npm install -g nexmo-cli`

## Setup

When Nexmo receives a call on a number you have rented, an HTTP request is made to a URL (a 'webhook', that you specify) that contains all of the information needed to receive and respond to the call. This is commonly called the *answer URL*.

Nexmo sends all the information about the call progress to a webhook URL you'll specify when you create a Nexmo Application, called the *event URL*.

When a user presses a number on their keypad, you can collect it via DTMF (*Dual Tone Multifrequency*). Whenever a DTMF input is collected from the user, this is sent to a different webhook URL in your app which you'll also have to specify.

So let's start writing this webhook server already! I'll use [express](https://expressjs.com/) as a web application framework, so I need to install it. I'll need to deal with JSON bodies, so I'll install `body-parser` as well. Run the following command inside the project folder in your terminal:

```bash
npm install express body-parser
```

Next up, in your main folder, create a new file called `index.js` and add a boilerplate `express` server, using `body-parser`, that listens on port 3000. For example:

```javascript
const app = require('express')()
const bodyParser = require('body-parser')

app.use(bodyParser.json())

app.listen(3000)
```

## Receiving a Phone Call

I need to create the *answer URL*, that is where Nexmo is going to make a `GET` request and it expects to receive a [Nexmo Call Control Object](https://developer.nexmo.com/api/voice/ncco), or NCCO for short. It's nothing really fancy, a JSON object with a set of pre-defined action objects.

We'll use the `talk` action to greet the caller and ask them to press a digit, setting the `bargeIn` option to `true` so that the user can enter a digit without waiting for the spoken message to finish.

Then, we'll add an `input` to the NCCO in order to capture the digit via DTMF. Set the `maxDigits` property to 1 and the `eventURL` to a handler on your server to receive and handle the input. To achieve all this, you can add the following code to your `index.js` file:

```javascript
app.get('/webhooks/answer', (req, res) => {
  const ncco = [{
      action: 'talk',
      bargeIn: true,
      text: 'Hello. Please enter a digit.'
    },
    {
      action: 'input',
      maxDigits: 1,
      eventUrl: [`${req.protocol}://${req.get('host')}/webhooks/dtmf`]
    }
  ]

  res.json(ncco)
})
```

## Handle the User Input

Let's add the code to handle incoming DTMF in `index.js`. Nexmo makes a `POST` request to our webhook, which we'll expose as an endpoint at `webhooks/dtmf`. When we receive the request we will create another `talk` action that inspects the request object and reads back the digits that the caller pressed:

```javascript
app.post('/webhooks/dtmf', (req, res) => {
  const ncco = [{
    action: 'talk',
    text: `You pressed ${req.body.dtmf}`
  }]

  res.json(ncco)
})
```

## Log Call Events

We'll need to create another `POST` route in the app to log all the call related events coming from Nexmo. Add the following code to your `index.js` file:

```javascript
app.post('/webhooks/events', (req, res) => {
  console.log(req.body)
  res.send(200);
})
```

For reference, your final `index.js` file should look something like [this one](https://github.com/Nexmo/nexmo-node-code-snippets/blob/master/voice/ivr-menu.js).

Now, you're set up and ready to run the code, you can do that by entering the following command in your terminal:

```bash
node index.js
```

This will start a server and route any traffic to `http://localhost:3000` through to your `index.js` file.

## Expose Your App With Ngrok

In order to allow Nexmo to make requests to your app, you need to expose the code running on your local machine to the world.

ngrok is our tool of choice for this, and we've provided a great [introduction to the tool](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) that you can read to get up to speed if you haven't used it before.

Once you have ngrok installed, run `ngrok http 3000` to expose your application to the internet. You’ll need to make a note of the `ngrok` URL that is generated as we’ll need to provide it to Nexmo in the next step (it’ll look something like `http://e83658ff.ngrok.io`). I'll refer to it later as `YOUR_NGROK_URL`.

## Buy a Number and Create an App

With the server running and available to the world, we now need to get a Nexmo phone number and link this code, that will be running locally, to it.

Let's start by purchasing a number via the Nexmo CLI:

```bash
nexmo number:buy  --country_code US
```

You can use a different country code if you want to. Make a note of the number you purchase, as we'll need it for the next step.

We now need to create a [Nexmo application](https://developer.nexmo.com/concepts/guides/applications), which is a container for all the settings required for your application. We need to specify the *answer URL* and the *event URL* so Nexmo can interact with the server we created.

Use the Nexmo CLI to create your application making sure you substitute `YOUR_NGROK_URL` with your own generated URL that ngrok gave you earlier:

```bash
nexmo app:create "IVR Menu" YOUR_NGROK_URL/webhooks/answer YOUR_NGROK_URL/webhooks/events
```

The response you'll get back will contain a huge private key output and, above that, an application ID. You can ignore the private key as it isn't necessary for handling inbound calls.

Make a note of the application ID (which looks like this: `aaaaaaaa-bbbb-cccc-dddd-abcdef123456`).

We have an application that is connected to the server and a Nexmo phone number, but the phone number isn't connected to the application.

So, we'll need to link the number we just bought to the application we just created. You can do that using the Nexmo CLI to issue the following command, replacing `YOUR_NEXMO_NUMBER` and `YOUR_APPLICATION_ID`:

```bash
nexmo link:app YOUR_NEXMO_NUMBER YOUR_APPLICATION_ID
```

That's everything needed to associate the code above with your Nexmo application and number. You can test it out by dialing the number you purchased and pressing a digit on your keypad!

## Conclusion

In about thirty lines of JavaScript, you now have an application that has an interactive voice response menu. How could you expand this from here?

If you want to learn more about what is possible with inbound voice calls, and how you can make them more complex by adding features such as recording audio or connecting callers to your mobile phone, you can learn more about these actions in the [NCCO reference](https://developer.nexmo.com/api/voice/ncco).

As always, if you have any questions about this post feel free to DM me on Twitter, I'm [@lakatos88](https://twitter.com/lakatos88). You can also email the Developer Relations team at Nexmo, [devrel@nexmo.com](mailto:devrel@nexmo.com), or [join the Nexmo community Slack channel](https://developer.nexmo.com/community/slack), where we’re waiting and ready to help.