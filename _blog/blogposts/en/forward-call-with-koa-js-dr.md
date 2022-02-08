---
title: Forward a Call Via Voice Proxy With Koa.js
description: Receive inbound calls and forward them to individuals without
  revealing their numbers using Vonage's Voice API and a Koa.js server.
thumbnail: /content/blog/forward-call-with-koa-js-dr/Forward-a-call-via-voice-proxy-with-Koa.js.png
author: garann-means
published: true
published_at: 2019-02-05T10:08:57.000Z
updated_at: 2021-05-12T02:48:02.192Z
category: tutorial
tags:
  - voice-api
comments: true
redirect: ""
canonical: ""
---
It's easy to [have an automated voice answer](https://learn.vonage.com/blog/2017/01/26/handle-inbound-text-speech-phone-call-node-js-dr/) when people call your [Vonage virtual number](https://developer.vonage.com/numbers/guides/number-management), but there are times you'll want to forward those calls on to a real person. With a minimal configuration and one webhook on a [Koa.js](https://koajs.com/) server, you can pass inbound calls to any number you choose.

## Set Up Ngrok and the Vonage CLI

To begin, you'll need to do some setup of Vonage, your application, and ngrok (or another way to host your endpoints). If you've followed [our other blog posts](https://learn.vonage.com/), you may have these things and be able to skip to the next section. If not, read on!

You can use ngrok to expose an endpoint on your local machine, rather than pushing your code to a publicly accessible server, for ease of development. Download it from [ngrok.io](https://ngrok.io) and follow the setup instructions. In a new terminal window, start ngrok on port 3000:

```
ngrok http 3000
```

Keep that terminal window open so you can copy the ngrok URLs you've been assigned later in the tutorial.

Next you'll need to install the [Vonage CLI](https://github.com/Vonage/vonage-cli) from npm. Installing it globally will be useful so you have a consistent version across your projects and don't have to keep track of the path to the utility:

```
npm install @vonage/cli -g
```

Unless you'll be using a different developer account for each project you create, you can set up the CLI by providing the credentials from [your dashboard](https://dashboard.nexmo.com) globally (which is the default):

```
vonage config:set <api_key> <api_secret>
```

## Create Your App

Create a directory for your new application and perform any initialization you might want to do. This example uses Koa.js for a server, so the basics provided by `npm init` should be enough. Because you'll be storing some variables in a `.env` file, it's also a good time to remember to install [dotenv](https://www.npmjs.com/package/dotenv):

```
npm install dotenv --save
```

Let's create the `.env` file now, with a small template for the variables the application will need:

```
APP_ID=
FROM_NUMBER=
TO_NUMBER=
```

Create a new application using the Vonage CLI, supplying a name that will distinguish it in your dashboard and the ngrok endpoints you'll code in the next section. This is where you need to swap in your own ngrok https URL:

```
vonage apps:create "Forward a call"  --voice_answer_url=https://04d37918.ngrok.io/answer --voice_event_url=https://04d37918.ngrok.io/event
```

As long as this command is successful, you'll receive an Application ID, which you can paste into your `.env` file for safekeeping.

## Koa Server

Now you're ready to create your server. You'll need to install Koa.js and two middleware packages, [`koa-body`](https://www.npmjs.com/package/koa-body) and [`koa-router`](https://www.npmjs.com/package/koa-router):

```text
npm install koa koa-body koa-router --save
```

Your server will import `dotenv` to give you access to the variables in `.env`, as well as Koa and its middleware. It will create a new Koa application, wire up the middleware, then finally listen on port 3000 (the port we supplied to ngrok):

```javascript
require('dotenv').config();

const Koa = require('koa');
const router = require('koa-router')();
const koaBody = require('koa-body');
const app = new Koa();

app.use(koaBody());

router.get('/answer',() => {});
router.post('/event',() => {});

app.use(router.routes()).listen(3000);
```

Your server has two routes, one which will answer inbound calls, and one which will log events. The second is simpler, so let's flesh that out first. The handler will do two things: log the contents of the request to the console, and return an [HTTP 204](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/204) status:

```javascript
router.post('/event', async context => {
  console.log(context.request.body);
  context.status = 204;
});
```

You also need to provide a handler for the `/answer` endpoint. If you've worked with Vonage's API before, this may look very straightforward. We want to create a [Call Control Object (NCCO)](https://developer.vonage.com/voice/voice-api/ncco-reference) and return that as a JSON object. There are several properties we need on this object:

* the [action](https://developer.vonage.com/voice/voice-api/ncco-reference#ncco-actions), which is "connect" (that is, we want to *connect* our caller to another endpoint)
* an array of `eventUrl`s, the only member of which will be our logging endpoint
* the from number, which is not the inbound caller's number but a Vonage virtual number through which we will proxy
* an [endpoint](https://developer.vonage.com/voice/voice-api/ncco-reference#endpoint-types-and-values) definition whose type is "phone" and whose number is the number we want to forward the call to

The code itself is minimal. Notice we're using `process.env` to get the variables in your `.env` file, so you can keep phone numbers you may not want shared private. You don't have to provide a URL for `eventUrl` unless you want to use a different event handler for this NCCO than for the application as a whole:

```javascript
router.get('/answer', async context => {
  const ncco = [
    {
      action: 'connect',
      eventUrl: [],
      from: process.env.FROM_NUMBER,
      endpoint: [
        {
          type: 'phone',
          number: process.env.TO_NUMBER
        }
      ]
    }
  ];
  context.body = ncco;
});
```

## Renting a Number

Your server is almost ready to go, but you'll need to supply phone number values in `.env` in order to test it. You can [rent a number within your Vonage dashboard](https://dashboard.nexmo.com/buy-numbers), or use the command line:

```
vonage numbers:search GB
```

You'll get a list of available numbers, all in [E.164](https://en.wikipedia.org/wiki/E.164) format, which you'll always use when interacting with the Vonage API. If the country code at the beginning of the numbers listed doesn't match your own, change "GB" to your [country](https://datahub.io/core/country-list) and run the command again. Once you find a number you like, you can rent it via the CLI:

```
vonage numbers:buy 442079460005
```

After confirming the number is rented, you can add it to your `.env` file along with your own number, or another number you'd like to forward calls to:

```
APP_ID=308494d1-06c6-4d47-9ba8-70488d946846
FROM_NUMBER=442079460005
TO_NUMBER=447700900003
```

You also want to associate the number you've rented with your application, which is done from the command line. You supply one argument: the new number.

```
vonage apps:link --number=442079460005 APP_ID
```

## Test Your Application

You're all set! Make sure ngrok is still running (if it's not you'll need to restart it and update the endpoint URLs in your app) and start your server with:

```
node index.js
```

Now if someone calls your virtual number, it should ring your phone. In the console, you'll see details about each step of the process. If you want to take your application further, you can use that information in the `/events` endpoint to see if calls have been answered and do things like play a message or try forwarding to a backup number.