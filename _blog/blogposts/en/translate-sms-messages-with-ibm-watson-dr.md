---
title: Translate SMS Messages With IBM Watson and Vonage
description: Learn how to create an inbound Vonage SMS webhook and translate the
  message into English using the IBM Watson Language Translator
thumbnail: /content/blog/translate-sms-messages-with-ibm-watson-dr/Blog_Translate-SMS-Messages_1200x600.png
author: kellyjandrews
published: true
published_at: 2019-11-12T15:18:17.000Z
updated_at: 2021-05-11T12:26:46.887Z
category: tutorial
tags:
  - sms-api
  - ibm-watson
comments: true
redirect: ""
canonical: ""
---
In my previous posts, I showed how you can translate text messages with the [Google Translation API](https://learn.vonage.com/blog/2019/10/24/extending-nexmo-google-cloud-translation-api-dr/) and [AWS Translate](https://learn.vonage.com/blog/2019/11/04/translating-sms-messages-with-aws-translate-dr/).

## Overview

In this post, I show you how to create an [inbound Vonage SMS](https://developer.vonage.com/messaging/sms/guides/inbound-sms) webhook and translate the message into English using the [IBM Watson Language Translator](https://www.ibm.com/watson/services/language-translator/).  

In order to get started, you will need the following items setup:

* [IBM Cloud](https://cloud.ibm.com/login)
* [Vonage CLI installed](https://developer.vonage.com/application/vonage-cli)

<sign-up></sign-up>

## Create Your Project

The setup for this example is minimal, and you only need a couple of packages to get going.

* [`ibm-watson`](https://www.npmjs.com/package/ibm-watson) - this is the official IBM Watson SDK
* [`express`](https://www.npmjs.com/package/express) - web framework to serve the webhook
* [`dotenv`](https://www.npmjs.com/package/dotenv) - a package to load environment variables
* [`body-parser`](https://www.npmjs.com/package/body-parser) - middleware for Express to handle the incoming webhook object

Initialize the project and then install the above requirements using `npm` or `yarn`.

```bash
npm init && npm install ibm-watson express dotenv body-parser
# or
yarn init && yarn add ibm-watson express dotenv body-parser
```

Once installed, create an `index.js` and `.env` file.

```bash
touch index.js .env
```

Next, open the `index.js` file and put the following code inside:

```js
'use strict';
require('dotenv').config();

const express = require('express');
const bodyParser = require('body-parser');
const LanguageTranslatorV3 = require('ibm-watson/language-translator/v3');
const { IamAuthenticator } = require('ibm-watson/auth');

const app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

const server = app.listen(3000, () => {
  console.log(`Express server listening on port ${server.address().port} in ${app.settings.env} mode`);
});
```

This will set up the server to run the example.

### Installing Ngrok

Webhooks need to be publicly available so that the Vonage service can reach the application when incoming SMS messages are received. You could push your code up to a publicly available server, or you can use [`ngrok`](https://ngrok.com) to allow for public traffic to reach your local application.

You can learn more about installing `ngrok` with [this post](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr). After you have everything ready to go you can start ngrok using the following command to create your tunnel.

```bash
ngrok http 3000
```

Make a note of the `ngrok` address, as you will need that in a later step.

## Setting Up IBM Watson Language Translator

Once you have the initial items set up, you can add IBM Watson Language Translator to your account and get the credentials required to run the example. Follow [this link](https://cloud.ibm.com/catalog/services/language-translator) to enable the Language Translator API. Select a project, and then click the `Enable` button to activate the API on that project.

![Create Language Translator Service](/content/blog/translate-sms-messages-with-ibm-watson-and-vonage/create_language_translator_service.png "Create Language Translator Service")

Once created you will be presented with a Getting Started tutorial. In the left nav, click `Manage` to locate following screen:

![IBM Watson Language Translator Manage Screen](https://www.nexmo.com/wp-content/uploads/2019/11/language_translator_keys.png "IBM Watson Language Translator Manage Screen")

Open up the `.env` file first, and copy and paste the following:

```
TRANSLATE_IAM_APIKEY=
TRANSLATE_URL=
```

Using the Copy the `API Key` and `URL` found on the IBM Watson Translation Manage page, fill in the `.env` file details, save and continue on to create the Vonage phone number.

## Setting Up Vonage Inbound SMS Messages

This example requires a phone number from Vonage to receive inbound messages. We can do this by using the [Vonage CLI](https://developer.vonage.com/application/vonage-cli) right from a terminal.

### Purchase a Virtual Phone Number

The first step will be to purchase a number (feel free to use a different [ISO 3166 alpha-2](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes) country code as needed).

```bash
vonage numbers:search US

 Country Number      Type       Cost Features  
 ─────── ─────────── ────────── ──── ───────── 
 US      12017621343 mobile-lvn 0.90 VOICE,SMS 
 US      12017782770 mobile-lvn 0.90 VOICE,SMS 
 US      12018011956 mobile-lvn 0.90 VOICE,SMS 
 US      12018099074 mobile-lvn 0.90 VOICE,SMS 
 US      12018099756 mobile-lvn 0.90 VOICE,SMS 

vonage numbers:buy 12017621343 US
```

Although the actual route to use in the application isn't set up, you will name it `/message`. The phone number needs to be linked to this route so inbound messages know where to go. Get the `ngrok` host name from the previous setup and use it here:

```bash
vonage number:update 12017621343 US --url=https://my-ngrok-hostname/message
```

Now we have the webhook setup as a place for inbound SMS messages to be routed.  

## Finish the Application

All that is left for this tutorial is creating the Express route to handle the incoming data and a couple of small functions to actually perform the translation.

### Build the Webhook

First, we need to build the webhook code. Vonage has a built in feature for setting default SMS behaviour.  [In the settings panel](https://dashboard.nexmo.com/settings) you can change the default `HTTP` method used. Mine is set to `POST-JSON`. I would recommend using this setting if possible, however the code used in this example will handle all three options in case you are unable to modify this setting.

![Default Vonage SMS HTTP Method](https://www.nexmo.com/wp-content/uploads/2019/10/default-sms-settings.png "Default Vonage SMS HTTP Method")

Open up the `index.js` file, and at the bottom, paste the following code:

```js
// Reading the inbound SMS messages
const handleRoute = (req, res) => {

  let params = req.body;

  if (req.method === "GET") {
    params = req.query
  }

  if (!params.to || !params.msisdn) {
    res.status(400).send({'error': 'This is not a valid inbound SMS message!'});
  } else {
    translateText(params);
    res.status(200).end();
  }

};
```

The above snippet is the method we will pass into the routes.  If the incoming message is using `POST` it will use `req.body`, and it will use `req.query` for the `GET` option. As long as the inbound payload is properly set up, the object will be sent along to the `translateText` method to display the translation.

Now you can add the route and proper `HTTP` methods to the application.

```js
app.route('/message')
  .get(handleRoute)
  .post(handleRoute)
  .all((req, res) => res.status(405).send());
```

The above code will create the `GET` and `POST` methods to handle either from the inbound SMS webhook message.  If any other method is used, a `405 - Method Not Allowed` response will be returned.

The webhook is ready to go and the final piece is the actual translations.

### Translation Method

In the previous step we call `translateText`. This step will create that method.

Using the `ibm-watson` package we first instantiate the `LanguageTranslatorV3` class, which will give us the `translate` method. This is called within the `translateText` method and uses the `text` field from the inbound SMS message object. The `modelId` input is any two-letter code for the [language to translate into](https://cloud.ibm.com/docs/services/language-translator?topic=language-translator-translation-models).

```js
const languageTranslator = new LanguageTranslatorV3({
  version: '2017-09-21',
  authenticator: new IamAuthenticator({
    apikey: process.env.TRANSLATE_IAM_APIKEY,
  }),
  url: process.env.TRANSLATE_URL,
});

function translateText(params) {
  const translateParams = {
    text: params.text,
    modelId: 'en-es',
  };

  languageTranslator.translate(translateParams)
    .then(data => {
      console.log(`Original Text ${params.text}`);
      console.dir(`Translation ${data.result.translations[0].translation}`)
    })
    .catch(err => {
      console.log('error:', err);
    });
}
```

Now you can test out the functionality by starting the server, and sending a text message to the number you purchased earlier.

```shell
node index.js
# Text "Hola" to your phone number

# expected response
Original Text: Hola
Translation: Hello
```

The IBM Watson Language Translator full response object has a lot of details as well, so you could change the response to include `console.dir(translationResult, {depth: null})` to see the full payload.  

## Recap

The example above is just a small introduction to translation using the IBM Watson Translation service. From here you can translate the inbound message, and then translate the outbound message into the correct language as well (future blog post, for sure).

You can find a completed version of this tutorial on the [Vonage Community GitHub](https://github.com/nexmo-community/sms-translate-ibm-js).

If you want to learn more about the Extend projects we have, you can visit <https://developer.vonage.com/extend>.