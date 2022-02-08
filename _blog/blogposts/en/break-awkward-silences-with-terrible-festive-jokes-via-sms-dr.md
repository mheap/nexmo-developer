---
title: Break Awkward Silences with Terrible Festive Jokes via SMS
description: Learn how to use the SMS API to break awkward silences with
  terrible festive jokes.
thumbnail: /content/blog/break-awkward-silences-with-terrible-festive-jokes-via-sms-dr/Break-Awkward-Silences-With-Terrible-Festive-Jokes-Via-SMS.png
author: martyn
published: true
published_at: 2018-12-18T21:51:52.000Z
updated_at: 2021-04-19T13:14:30.229Z
category: tutorial
tags:
  - javascript
  - messages-api
  - node
comments: true
redirect: ""
canonical: ""
---
In this tutorial I'll show you how to build your own awkward silence breaker, in the form of an SMS app that will reply to you with terrible festive jokes and one-liners that you can throw out to the table, quickly breaking the tension.

Getting large groups of family members together at any time of year can sometimes get a little awkward. Like when Uncle Bill has been mixing his drinks, and he ultimately says something about cousin Roberta that leaves everyone uncomfortably munching on parsnips.

Awkward. Fire up your code editor and let's get started.

## Try Before You Build

My version of this app is live, so you can message it right now and see the results before we dig into the code.

- - -

**Send an SMS containing the word 'awkward' to `+44 7520619627` if you're in the UK, or `+1 201 844 9627` if you're in the US and bust out laughing at the genius lines you'll be sent in return... maybe.**

- - -

(The keen of eye will have already spotted that the last 4 digits of each of those numbers spell out X-M-A-S on a telephone keypad.)

One line didn't break the grim, grim silence? Okay, SMS the word 'more' in reply and get another line that might help.

## Building The App

The app we're going to build uses [Node.js](https://nodejs.org/en/), the [Koa framework](https://koajs.com/) (which is just a more modern implementation of Express), and the Vonage Messages API.

The code is available in a repository on the [Nexmo Community GitHub](https://glitch.com/edit/#!/nexmo-community-xmas-jokes-nodejs) account, and also in [remixable form on Glitch](https://glitch.com/edit/#!/remix/nexmo-community-xmas-jokes-nodejs).

### Prerequisites

* The V[onage command line interface](https://developer.vonage.com/application/vonage-cli) 
* A fresh SMS capable number
* Node.js version 8 or above
* A selection of terrible jokes and one-liners
* An awkward situation

<sign-up number></sign-up>

### Clone The Repository

In any directory clone a copy of the code from our [nexmo-community](https://github.com/nexmo-community/xmas-jokes-nodejs) repository on GitHub:

```bash
git clone git@github.com:nexmo-community/xmas-jokes-nodejs.git
```

Then change to the directory to access the code:

```bash
cd xmas-jokes-nodejs
```

Open this festive package of wonder up in your editor, and we'll get on with the configuration.

### Start It Up

To configure this app, it needs to be reachable from the outside world. Use [Ngrok](https://ngrok.com/) to expose port `3000` and note down the `https` URL you are given:

```bash
ngrok http 3000
```

If you haven't used [Ngrok](https://ngrok.com/) before, follow the guide in [this blog post](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) to get up and running.

### Configuration

The first piece to configure is the `.env.sample` file. Start by renaming it to `.env`.

Add all the following pieces of information:

```bash
NEXMO_API_KEY="" # from your account dashboard
NEXMO_API_SECRET="" # from your account dashboard
```

Next up is the application-specific detail. Set that up using the CLI. 

The app you have cloned has two endpoints in it:

* `/inbound` receives new SMS messages
* `/status` is a required URL for any Messages & Dispatch application, it receives read receipts and other information about the messages you send

```bash
vonage apps:create 
✔ Application Name … Xmas Jokes
✔ Select App Capabilities › Messages
✔ Create messages webhooks? … yes
✔ Inbound Message Webhook - URL … https://<your_ngrok_url>/inbound
✔ Inbound Message Webhook - Method › POST
✔ Status Webhook - URL … https://<your_ngrok_url>/status
✔ Status Webhook - Method › POST
✔ Allow use of data for AI training? Read data collection disclosure - https://help.nexmo.com/hc/en-us/articles/4401914566036 … yes
```

This command will set up a new Messages & Dispatch application on your account. It outputs the `Application ID` to the screen and will also create a private key in the directory you're currently in. Both are needed for the next step of the config:

```bash
NEXMO_APPLICATION_ID="" # The new App ID you just generated
NEXMO_APPLICATION_PRIVATE_KEY="./XmasJokes.key" # No need to change this unless you called your keyfile something different
```

Finally, add in your new SMS capable number:

```bash
NEXMO_FROM_NUMBER="" # If you have a Non-US number put it here, otherwise blank
NEXMO_FROM_NUMBER_US="" # If you have a US number, put it here, otherwise blank
```

With all those fields filled out you can save your `.env` and close it.

Now you need a number so you can receive calls. You can rent one by using the following command (replacing the country code with your code). For example, if you are in the USA, replace `GB` with `US`:

* ```bash
  vonage numbers:search US
  vonage numbers:buy [NUMBER] [COUNTRYCODE]
  ```

  Now link the number to your app:

  ```
  vonage apps:link --number=VONAGE_NUMBER APP_ID
  ```

That's it. Set up complete!

## Fire Up The Festive Cheer

Vonage now knows where everything is going and how to route new messages over to your application. There's only one thing left to do:

```bash
npm run dev
```

Once the server is running, ensure that your Ngrok connection is still up and running on the same URL you used in the callbacks and then SMS the word 'awkward' to your new number.

![Numbers in action](https://cl.ly/fe0c9506c334/Screen%20Recording%202018-12-18%20at%2005.00%20pm.gif)

## Where Next?

Your next steps are to deploy this app to a server. [Heroku](https://heroku.com) is an excellent choice for this and the app won't require any code changes to work there.

Remember, when you deploy the app elsewhere you will need to update the callbacks for the SMS number, and both the URLs for your Messages & Dispatch application.

The CLI commands you need to do this are:

```bash
vonage apps:update [APP_ID] --voice_event_url=http://example.com/webhooks/event --voice_answer_url=http://example.com/webhooks/answer
```

Then you're good to go.

## Do You Want It To Be Even Easier?

If you're looking for an even quicker route to playing with the code for this application, you can [remix it on Glitch](https://glitch.com/edit/#!/nexmo-community-xmas-jokes-nodejs) by clicking the button below:

<!-- Remix Button -->

<a href="https://glitch.com/edit/#!/remix/nexmo-community-xmas-jokes-nodejs">
  <img src="https://cdn.glitch.com/2bdfb3f8-05ef-4035-a06e-2043962a3a13%2Fremix%402x.png?1513093958726" alt="remix button" aria-label="remix" height="33" border="0">
</a>