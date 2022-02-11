---
title: Build a Family Stand Up App with Vonage
description: A tutorial on how to use the Vonage Messages API to write an app
  that sends an SMS to family members asking for a weekly "Stand Up" report from
  them on Glitch.
thumbnail: /content/blog/build-a-family-stand-up-app-with-nexmo-messages-and-dispatch-api-dr/Blog_Family-Stand-Up-App_1200x600.png
author: laurenlee
published: true
published_at: 2019-09-18T19:23:25.000Z
updated_at: 2021-05-11T09:25:16.981Z
category: tutorial
tags:
  - glitch
  - dispatch-api
  - messages-api
comments: true
redirect: ""
canonical: ""
---
## Introduction

The Daily Stand Up: a brief meeting many Agile software engineering teams employ as a way to update teammates on an individual’s progress and/or surface any blocking issues. Each day, everyone stands in a circle and answers the same three questions:                   

1. What did I do yesterday?
2. What will I do today?
3. Do I see any blockers or impediments that prevent me from meeting my and/or the team’s goal?   

This is pretty much an industry standard. But my DevRel team here at Vonage is distributed. Meaning that because we all live all over the globe, it’s impossible for us all to be in the same room each day to stand in a circle and report out our day-to-day progress, blockers, and goals. So instead, we use a chat-bot within Slack to individually share our reports that all get funneled into one communal #standup channel for the whole team to view. 

![Slack stand up](/content/blog/build-a-family-stand-up-app-with-vonage/slackstandup.png "Slack stand up")

This method of remotely reporting our individual updates works pretty well for our team. We can each send in our update at the beginning of our workday and we can view the rest of the team’s updates all in one consolidated place.

## From Work to Family

Not only is my work team distributed throughout the world, but my family members are as well. I live in Seattle, my parents are in Chicago, and my brother lives in Florida. So I thought it might be fun to apply this whole “Stand Up” idea to my family as well!  

I could use Vonage’s Messages & Dispatch APIs and have everyone report their weekly highs and lows into one consolidated place for us each to view whenever’s convenient for each of us. 

## Prerequisites

To work through this tutorial, you will need a Vonage account.
You can sign up now for *free* and receive free credit to get started if you don't already have an account.
In addition, if you want to skip to a working project you can remix the [Family Stand Up App](https://glitch.com/~family-standup-app) right away in Glitch. Otherwise, in just a few steps you can create your own from scratch!

<sign-up></sign-up>

## How to Build the App

### Create a Vonage Account

If you haven’t done so already, create a Vonage account for free, and as an added bonus, your account will be credited with 2 euros to begin using your new application. Head over to [Vonage](https://dashboard.nexmo.com/sign-up?utm_source=DEV_REL&utm_medium=glitch&utm_campaign=https://glitch.com/~family-standup-app) and go through the signup steps. Once you have finished you will be in your Vonage dashboard. 

### Purchase a Vonage Phone Number

* From the Vonage Dashboard, click on the `Numbers` menu item on the left-hand side.
* Click the `Buy Numbers` option and you’ll be directed to a page where you can choose a country, features, type, and four digits you would like the number to have.


  ![buy numbers](/content/blog/build-a-family-stand-up-app-with-vonage/buy-numbers.png "buy numbers")
* Select the country that you are currently in so the call is local. For features, select `Voice` and for type, either mobile or landline will work just fine.
* Click `Search` to see a list of phone numbers available.
* Select a number by clicking the orange `Buy` button, and clicking the orange `Buy` button again once you’re in the confirmation prompt.
  You now own a Vonage phone number! Your next step is to create an application.   

### Create a Vonage Messages and Dispatch Application

#### From the Nexmo CLI:

Enter the following command into the shell:   

```bash
nexmo app:create "Family Stand Up App" https://your_Glitch_URL.glitch.me/inbound https://your_Glitch_URL.glitch.me/status --keyfile=private.key --type=messages
```

* Be sure to replace `your_Glitch_URL` with your actual URL!   

#### From the [Vonage Dashboard](https://dashboard.nexmo.com/messages/applications/):

* From the left-hand menu, click on the `Messages and Dispatch` menu item.
* Select the `Create an application` option. You’ll be directed to a page where you can set up a new Vonage application.
* Complete the form with the following: 

  * `Application name` text field enter `Family Stand Up App` 
  * `Status URL` text field enter your Glitch URL: `https://[your Glitch URL].glitch.me/status`
  * `Inbound URL` text field enter your Glitch URL again: `https://[your Glitch URL].glitch.me/inbound`
* Once that is all in there, click the blue `Create Application` button. 
* Be sure to generate a public/private key pair and save it.
     

### Link Everything Together

You now have a Vonage number and a Messages and Dispatch application, all that is left to do is link the two together.

* Within your `Family Stand Up App` Messages application, select the `Numbers` tab next to `Settings`. 
* Click the `Link` button to the right of the phone number you’d like to connect to your application.   

Your new Vonage Messages is now linked to your new Vonage application, and with that last step, you are ready to build your application!

### Modify Default SMS Setting

In the Vonage Dashboard, underneath your name, select the `Settings` tab to update the `Default SMS Setting` so that any text received from any of your family members are linked to your Stand Up app.   

![default sms setting](/content/blog/build-a-family-stand-up-app-with-vonage/default-sms-setting.png "default sms setting")

## Create Your Express App on Glitch

### Edit the `package.json` File

To begin, navigate to glitch.com to create a new project and choose the `hello-express` template.

In the `package.json` file, select the `Add a package` dropdown to search for and add the following dependencies: `dotenv` and `node-schedule`.

![dependencies](/content/blog/build-a-family-stand-up-app-with-vonage/dependencies.png "dependencies")


We are going to use a Beta version of `Vonage` so manually type in this particular version: `^2.5.1-beta-1`. 

### Edit the `.env` File

In the `.env` file, fill in those Vonage specific credentials we just created in the Vonage Dashboard: 

```javascript
API_KEY=******
API_SECRET=******
APP_ID=******
PRIVATE_KEY_PATH=.data/private.key
NEXMO_NUMBER=****** 
```

Replace the API Key, API Secret, App ID, and your Vonage Number. To include the Private Key, select the `New File` toggle in the top left corner and name it `.data/private.key`. In that file, paste the private key you generated when you created your voice application. This file will become invisible within Glitch if you remix your code for security reasons.

### Edit the `server.js` File

#### Set Up Dependencies, Credentials, and Constant Variables

At the top of your `server.js` file, let’s set up our Express server, require our dependencies, and embed our Vonage credentials:  

```js
// server.js 
require('dotenv').config();
const express = require('express');
const app = express();
const Nexmo = require('nexmo')
const schedule = require('node-schedule');

// Vonage credentials 
const nexmo = new Nexmo({
  apiKey: process.env.API_KEY,
  apiSecret: process.env.API_SECRET,
  applicationId: process.env.APP_ID,
  privateKey: process.env.PRIVATE_KEY_PATH
});

// array of family members' numbers (be sure to change and include the numbers of your *own* family 
const familyNumbers = [18479623979, 18478402296]
// content of SMS (feel free to personalize!)
const standupText = "It's time for family stand up! What have you been up to this week? What were your highs? What were your lows?"
// Array of messages received 
let messages_received = [];
```

#### Use Node-Schedule to Send the Text Once a Week

[Node Schedule](https://www.npmjs.com/package/node-schedule) is a flexible job scheduler for Node.js. It allows you to schedule jobs (arbitrary functions) for execution at specific dates, with optional recurrence rules. We’ll use that `RecurrenceRule()` concept and have it sent out every Sunday at 5pm. It will then map through the array of family phone numbers and pass in the `standupText` variable.  

```javascript
// server.js 
// node-schedule will call the nexmoSend() function and send the text every Sunday at 5pm 
const rule = new schedule.RecurrenceRule();
rule.dayOfWeek = 0;
rule.hour = 17;
rule.minute = 0;
const scheduler = schedule.scheduleJob(rule, function(){
   // mapping through those numbers and sending them each a text with nexmo 
  familyNumbers.map(number => {
    nexmoSend(number, standupText); 
  });
});
```

#### Send the Weekly SMS Asking for a Stand Up Report

Let’s utilize Vonage and the `nexmo.channel.send()` function. We’ll pass in the `TO` and `FROM` numbers, the body of the message, and logic to handle errors. 

```javascript
// server.js 
// function to send text with Vonage Messages API 
const nexmoSend = (number, text) => { nexmo.channel.send(
  { "type": "sms", "number": number },
  { "type": "sms", "number": process.env.NEXMO_NUMBER },
  {
    "content": {
      "type": "text",
      "text": text
    }
  },
  (err, data) => { console.log("message_uuid: ", data.message_uuid); }
)};   
```

#### Receive the SMS Messages From Family Members

You now have the code to send out the Stand-Up SMS from your Vonage number. But what to do with your family’s responses? I chose to receive the messages and showcase them on the app’s frontend within Glitch. But the world is really your oyster here. You can choose to wait for all parties to reply and send a bundled message with all of them in one consolidated update. Or you could use a database like [MongoDB](https://www.mongodb.com/) and save the data to do something with it all later. 

![logging](/content/blog/build-a-family-stand-up-app-with-vonage/logging.png "logging")

For now, the solution I came up with was to push both the number it came from and the actual text of the message received into an array to then be sent to the app’s frontend. That way, the messages will become visible once a message has been received! 

![front end](/content/blog/build-a-family-stand-up-app-with-vonage/screenshot.png "front end")

```js
// server.js 
// function to receive message responses 
const handleInboundSms = (req, res) => {
  const params = Object.assign(req.query, req.body);

  messages_received.push({
    from: params.msisdn,
    standup_report: params.text
  });
  
  // send messages for family members to see on website 
  app.get('/', (req, res) => {
    res.send(messages_received);
  });
  
  // send OK status
  res.status(204).send();
}
```

#### Final Express Pieces

Lastly, let’s fill in the necessary Express components to get our app up and running. And for debugging purposes, we’ll be sure to log what port the app is listening to.  

```js
// server.js 
app
.route('/webhooks/inbound-sms')
.get(handleInboundSms)
.post(handleInboundSms)

const listener = app.listen(process.env.PORT, () => {
  console.log('Your express app is listening on port ' + listener.address().port);
});
```

## Getting Help

We love to hear from you so if you have questions, comments or find a bug in the project, let us know! You can either:

* Tweet at us! We're [@VonageDev on Twitter](https://twitter.com/VonageDev)
* Or [join the Vonage Community Slack](https://developer.nexmo.com/community/slack)

## Further Reading

* Check out the Developer Documentation at <https://developer.nexmo.com>