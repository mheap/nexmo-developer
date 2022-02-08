---
title: Translating SMS Messages Using Google Cloud’s Translation API
description: Find out how to create an inbound Vonage SMS webhook and translate
  the message into English using the Google Cloud Translation API
thumbnail: /content/blog/extending-nexmo-google-cloud-translation-api-dr/E_EN_Translate-SMS_1200x600.png
author: kellyjandrews
published: true
published_at: 2019-10-24T12:12:44.000Z
updated_at: 2021-05-13T12:49:58.488Z
category: tutorial
tags:
  - sms-api
  - google-cloud
comments: true
redirect: ""
canonical: ""
---
Text messaging has become a part of our daily lives.  We integrate it into multiple aspects like banking, alerts, marketing, and support. It has become simple to implement, and Vonage is no different.  

As a part of the Extend team here, integrating text messages with translation API's makes perfect sense. Translating incoming text messages can help break down communication barriers and help you reach a broader audience.

## Overview

In this post, I show you how to create an [inbound Vonage SMS](https://developer.vonage.com/messaging/sms/guides/inbound-sms) webhook and translate the message into English using the [Google Cloud Translation API](https://cloud.google.com/translate/).  

In order to get started, you will need the following items setup:

* [Google Cloud Account](https://console.cloud.google.com)
* [Vonage CLI installed](https://developer.vonage.com/application/vonage-cli)

<sign-up></sign-up> 

## Create Your Project

The setup for this example is minimal, and you only need a couple of packages to get going.

* [`@google-cloud/translate`](https://www.npmjs.com/package/@google-cloud/translate) - this is the official Cloud Translation SDK
* [`express`](https://www.npmjs.com/package/express) - web framework to serve the webhook
* [`dotenv`](https://www.npmjs.com/package/dotenv) - a package to load environment variables
* [`body-parser`](https://www.npmjs.com/package/body-parser) - middleware for Express to handle the incoming webhook object

Initialize the project and then install the above requirements using `npm` or `yarn`.

```bash
npm init && npm install @google-cloud/translate express dotenv body-parser
# or
yarn init && yarn add @google-cloud/translate express dotenv body-parser
```

Once installed, create an `index.js` and `.env` file.

```bash
touch index.js .env
```

Open up the `.env` file first, and copy and paste the following:

```
GOOGLE_APPLICATION_CREDENTIALS=./google_creds.json
TARGET_LANGUAGE='en'
```

Next, open the `index.js` file and put the following code inside:

```js
'use strict';
require('dotenv').config();

const express = require('express');
const bodyParser = require('body-parser');
const { Translate } = require('@google-cloud/translate');

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

You can learn more about installing `ngrok` with [this post](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/). After you have everything ready to go you can start ngrok using the following command to create your tunnel.

```bash
ngrok http 3000
```

Make a note of the `ngrok` address, as you will need that in a later step.

## Setting Up Google Cloud Translation API

Once you have the initial items set up, you can now add Google Cloud Translation API to your account. Follow [this link](https://console.cloud.google.com/apis/library/translate.googleapis.com) to enable the Translation API. Select a project, and then click the `Enable` button to activate the API on that project.

![Enable Google Cloud Translation API](https://www.nexmo.com/wp-content/uploads/2019/10/enable-translate-api.png "Enable Google Cloud Translation API")

It is recommended to create a [`service user`](https://console.cloud.google.com/iam-admin/serviceaccounts) that has access to the Translation API.  [Click here](https://console.cloud.google.com/iam-admin/serviceaccounts) and click `+ Create Service Account`.

![Add New Service Account](https://www.nexmo.com/wp-content/uploads/2019/10/add-service-account.png "Add New Service Account")

Give the account any name you'd like, and press the `Create` button. After the account is created, add the `Cloud Translation API User` role, and click `Continue`.

![Add Cloud Translation API User Role](https://www.nexmo.com/wp-content/uploads/2019/10/service-account-role.png "Add Cloud Translation API User Role")

You will need to create keys for this user. Go ahead and click the `+ Create Key` button, and then select `JSON` and click create. This will download a `JSON` file to your machine that you will need to use the account.  When that is completed, click `Done` to complete the creation process.

![Create Service Account Key](https://www.nexmo.com/wp-content/uploads/2019/10/create-account-key.png "Create Service Account Key")

![Create Service Account Key - Select Type](https://www.nexmo.com/wp-content/uploads/2019/10/create-account-key-type.png "Create Service Account Key  - Select Type")

Copy the credentials file into your project folder:

```bash
cp /path/to/file/project-name-id.json ./google_creds.json
```

The Google Cloud Translation API is now set up and ready to use.

Next, we can set up the phone number.

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

First, we need to build the webhook code. Vonage has a built-in feature for setting default SMS behaviour.  [In the settings panel](https://dashboard.nexmo.com/settings) you can change the default `HTTP` method used. Mine is set to `POST-JSON`. I would recommend using this setting if possible, however the code used in this example will handle all three options in case you are unable to modify this setting.

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

Using the `@google-cloud/translate` package is really straight forward. We first instantiate the `Translate` class, which will give us the `translate` method. This is called within the `translateText` method and uses the `text` field from the inbound SMS message object. The `target` input is any two-letter code for the [language to translate into](https://cloud.google.com/translate/docs/languages).

```js
const translationApi = new Translate();

function translateText(params) {
  const target = process.env.TARGET_LANGUAGE || 'en';

  translationApi.translate(params.text, target)
        .then(results => {
           console.log(`Original Text: ${params.text}`);
           console.log(`Translation: ${results[0]}`);
         })
         .catch(err => {
           console.log('error', err);
         });
}
```

Now you can test out the functionality by starting the server, and sending a text message to the number you purchased earlier.

```
node index.js
# Text "Hola" to your phone number

# expected response
Original Text: Hola
Translation: Hello
```

The Google Cloud Translation API does an amazing job at detecting the incoming language and processing the translation quickly. Have fun and try it out.

## Recap

The example above is just a small introduction to translation, but should be a good start to get you going. From here you can translate the inbound message, and then translate the outbound message into the correct language as well (future blog post, for sure).

For a completed version of this tutorial you can find it at <https://github.com/nexmo-community/sms-translate-google-js>.

If you want to learn more about the Extend projects we have, you can visit <https://developer.nexmo.com/extend> to learn more.