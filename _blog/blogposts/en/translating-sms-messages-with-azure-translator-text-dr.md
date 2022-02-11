---
title: Translating SMS Messages With Azure Translator Text
description: How to create a Vonage inbound SMS webhook and translate the
  message into English using the Azure Translator Text.
thumbnail: /content/blog/translating-sms-messages-with-azure-translator-text-dr/TW_Translate-SMS_1200x675.png
author: kellyjandrews
published: true
published_at: 2019-11-25T17:37:06.000Z
updated_at: 2021-05-21T09:18:37.622Z
category: tutorial
tags:
  - azure
  - sms-api
comments: true
redirect: ""
canonical: ""
---
In my previous posts, I showed how you can translate text messages with the [Google Translation API](https://learn.vonage.com/blog/2019/10/24/extending-nexmo-google-cloud-translation-api-dr/), [AWS Translate](https://www.nexmo.com/blog/2019/11/04/translating-sms-messages-with-aws-translate-dr). and [IBM Watson Language Translator](https://learn.vonage.com/blog/2019/11/04/translating-sms-messages-with-aws-translate-dr/).

## Overview

In this post, I show you how to create a [Vonage inbound SMS](https://developer.vonage.com/messaging/sms/guides/inbound-sms) webhook and translate the message into English using the [Azure Translator Text](https://azure.microsoft.com/en-us/services/cognitive-services/translator/).  

In order to get started, you will need the following items set up:

* [Azure](https://azure.microsoft.com/en-us/)
* [Vonage CLI installed](https://developer.vonage.com/application/vonage-cli)

  <sign-up></sign-up>

## Create Your Project

You will only need a couple of packages to get things going.

* [`@azure/ms-rest-js`](https://www.npmjs.com/package/@azure/ms-rest-js)—this is the Azure SDK and will assist with the credentials
* [`@azure/cognitiveservices-translatortext`](https://www.npmjs.com/package/@azure/cognitiveservices-translatortext)—this is the Azure Translator Text SDK
* [`express`](https://www.npmjs.com/package/express)—web framework to serve the webhook
* [`dotenv`](https://www.npmjs.com/package/dotenv)—a package to load environment variables
* [`body-parser`](https://www.npmjs.com/package/body-parser)—middleware for Express to handle the incoming webhook object

Initialize the project and then install the above requirements using `npm` or `yarn`.

```bash
npm init && npm install @azure/ms-rest-js @azure/cognitiveservices-translatortext express dotenv body-parser
# or
yarn init && yarn add @azure/ms-rest-js @azure/cognitiveservices-translatortext express dotenv body-parser
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
const CognitiveServicesCredentials = require("@azure/ms-rest-js");
const { TranslatorTextClient } = require("@azure/cognitiveservices-translatortext");

const app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

const server = app.listen(3000, () => {
  console.log(`Express server listening on port ${server.address().port} in ${app.settings.env} mode`);
});
```

This will set up the server to run the example.

### Installing ngrok

Publicly available webhooks are required so that Vonage can communicate with the application to receive incoming SMS messages. You could push your code up to a publicly available server, or you can use [`ngrok`](https://ngrok.com) to allow for public traffic to reach your local application.

You can learn more about installing `ngrok` with [this post](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/). After you have everything ready to go you can start ngrok using the following command to create your tunnel.

```bash
ngrok http 3000
```

Make a note of the `ngrok` address, as you will need that in a later step.

## Setting Up Azure Translator Text

Next, you can set up the Azure Translator Text service in the Azure portal. Start by opening the portal and clicking `Create New Resource`.

![Azure Portal Home Page](https://www.nexmo.com/wp-content/uploads/2019/11/home_page_add_resource.png "Azure Portal Home Page")

On the next screen do a search for `Translator Text` and click on the result to be taken to the Translator Text info page.  Click `Create` to start the process.

![Translator Text Create Resource Screen](https://www.nexmo.com/wp-content/uploads/2019/11/create_translator_text.png "Translator Text Create Resource Screen")

Fill out the name, select `Pay As You Go` and the resource group, and then click `Create` at the bottom of the page.

![Translator Text Create Resource Details](https://www.nexmo.com/wp-content/uploads/2019/11/translator_text_details.png "Translator Text Create Resource Details")

The creation process takes a few moments, so relax for a bit until that completes.

Open up the `.env` file first, and copy and paste the following:

```
TEXT_TRANSLATION_SUBSCRIPTION_KEY=
TEXT_TRANSLATION_ENDPOINT=https://api.cognitive.microsofttranslator.com/translate
```

Grab the key and endpoint from the quick start page and update the `.env` file with that information.

During my trials, I attempted to use the services endpoint presented in the dashboard but didn't have any luck getting it to work correctly.  The URL above is the global endpoint that will work if you run into the same troubles.

![Translator Text Resource Quickstart](https://www.nexmo.com/wp-content/uploads/2019/11/translate_quickstart.png "Translator Text Resource Quickstart")

## Setting Up Vonage Inbound SMS Messages

This example requires a phone number from Vonage to receive inbound messages. We can do this by using the [Vonage CLI](https://developer.vonage.com/application/vonage-cli) right from your terminal.

### Purchase a Virtual Phone Number

First, purchase a number directly from Vonage (feel free to use a different [ISO 3166 alpha-2](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes) country code as needed).

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

Although the actual route to use in the application isn't set up, you will name it `/message`. The phone number needs to be linked to this route so inbound messages know where to go. Get the `ngrok` hostname from the previous setup and use it here:

```bash
vonage number:update 12017621343 US --url=https://my-ngrok-hostname/message
```

Now the Vonage webhook is set up to route inbound SMS messages.  

## Finish the Application

The only step now is to create the Express route and functions to handle the incoming SMS message and the translations.

### Build the Webhook

We can set up the route handler first.  Vonage allows the  setting of a default SMS webhook behavior.  [In the settings panel](https://dashboard.nexmo.com/settings) you can change the default `HTTP` method used. Mine is set to `POST-JSON`, and I recommend using this setting. If you are unable to modify your setting, the code used here will handle all three options.

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

This handler will be passed directly to the `/message` route.  If the incoming message HTTP method is `POST`, the handler uses `req.body`, and uses `req.query` for the `GET` option. It then checks the inbound payload ensuring it has the correct info, then sends the object to the `translateText` method to display the translation.

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

In the previous step, we call `translateText`. This step will create that method.

You will initially get your credentials by using `CognitiveServicesCredentials.ApiKeyCredentials`. This will need to be passed as the first parameter to the `TranslatorTextClient` constructor.

After creating the `client`, use the `translate` method to translate the text.  The first argument is an array of languages you wish to translate the text into—allowing you to translate into multiple languages.  The service will automatically detect the incoming language if it can. The second argument is an array of objects for the text you want to translate.

```js
function translateText(params) {
  const creds = new CognitiveServicesCredentials.ApiKeyCredentials({ inHeader: { 'Ocp-Apim-Subscription-Key': process.env.TEXT_TRANSLATION_SUBSCRIPTION_KEY } });
  const client = new TranslatorTextClient(creds, process.env.TEXT_TRANSLATION_ENDPOINT);

  client.translator
    .translate(["en"], [{text:params.text}])
    .then(result => {
      console.log(`Original Text: ${params.text}`);
      console.log(`Translation: ${result[0].translations[0].text}`)
    })
    .catch(err => {
      console.error("error:", err);
    });
}
```

Now you can test out the functionality by starting the server and sending a text message to the number you purchased earlier.

```shell
node index.js
# Text "Hola" to your phone number

# expected response
Original Text: Hola
Translation: Hello
```

The Azure Translator Text full response object has a lot of details as well, so you can change the response to include `console.dir(translationResult, {depth: null})` to see the full payload.  

## Recap

Azure Translator Text is a great tool to translate your inbound messages from Vonage. This example only scratches the surface but should be a good start. You can venture off in several directions from here using this as a jumping point. Let me know what ideas you have for using these two services together.

You can find a completed version of this tutorial at <https://github.com/nexmo-community/sms-azure-translate-js>.

If you want to learn more about the Extend projects we have, you can visit <https://developer.vonage.com/extend> to learn more.