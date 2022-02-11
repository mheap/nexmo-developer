---
title: Forward Nexmo SMS to Slack using Express and Node
description: Using Node and Express, we’ll look at how we can automatically
  notify a Slack channel whenever a virtual number from Nexmo receives a text
  message.
thumbnail: /content/blog/forward-nexmo-sms-to-slack-using-express-and-node-dr/E_SMS-to-Slack_1200x600.jpg
author: dotun
published: true
published_at: 2020-01-01T09:00:24.000Z
updated_at: 2021-05-18T11:07:58.834Z
category: tutorial
tags:
  - sms-api
  - node
  - slack
comments: true
spotlight: true
redirect: ""
canonical: ""
---
## Introduction

Nexmo’s virtual numbers allow you to send or receive text messages and phone calls, which can serve as a means for effectively communicating with your users or customers.

In this tutorial using Node and Express, we’ll be looking at how we can automatically notify a Slack channel whenever a virtual number from Nexmo receives a text message. The notification will contain the content of the text message that was received. This can be very useful as it means we’ll always be notified when we receive a text message, and the Slack channel can function as a central place for tracking inbound text messages. 

## Prerequisites

* [Node.js](https://nodejs.org/)
* [ngrok](https://ngrok.com/) which allows you to expose your local webserver to the internet. To learn more about how to set up your local environment with ngrok, you can check out the docs [here](https://ngrok.com/docs). 
* [Slack](https://slack.com/)

<sign-up number></sign-up>

## Install Node Dependencies

In the root of your project’s directory, run the following command to create a `package.json` file. 

```bash
npm init
```

This will prompt you with a series of questions for you to answer; the default works fine for this tutorial. To install all our project’s dependencies, run the following command:

```bash
npm install express body-parser slack-notify
```

* [express](https://expressjs.com/) is a Node web application framework. 
* [body-parser](https://www.npmjs.com/package/body-parser) is an express middleware for parsing incoming request bodies.
* [slack-notify](https://www.npmjs.com/package/slack-notify) is a Node wrapper around the [Slack Webhook API](https://api.slack.com/incoming-webhooks) which makes it easy to send notifications to Slack from your application. 

Next, run the following command to create an `index.js` file at the root of your project’s directory:

```bash
touch index.js
```

Add the following code to the file we just created: 

```javascript
const express = require('express');
const app = express();
const bodyParser = require('body-parser')
const port = 3000;

app.use(bodyParser.json());

app.use(bodyParser.urlencoded({extended: true}));

app.listen(port, () => {
    console.log(`Listening on ${port}`);
})
```

This creates an express application with a web server that listens on port 3000. We’ve also instructed the application to make use of the JSON parser from the `body-parser` package we installed earlier and set the `urlencoded` option to true. Let’s add a command for running this server. 

In the `package.json` file, add the following code to the `scripts` section:

```javascript
"scripts": {
    "start": "node index.js"
  },
```

We can now run the app by using the following command

```bash
npm run start
```

## Creating Incoming Webhooks on Slack

To be able to send messages to Slack, we need to create an incoming webhook URL. To get started, head over to [Slack](https://api.slack.com/apps?new_app=1) and create an app if you don’t already have one. 

![Creating a Slack App](/content/blog/forward-nexmo-sms-to-slack-using-express-and-node/createslackapp.png)

Select a name for your app and associate it with the workspace you’d like to send notifications to. Once you’ve created the app, you’ll be presented with a screen similar to the one below:

![Build an App for Slack](/content/blog/forward-nexmo-sms-to-slack-using-express-and-node/buildingappsforslack.png)

Select the incoming webhooks tab and click the `Activate incoming webhooks` toggle to switch it on. Next, click the `Add New Webhook to Workspace` button. Select the channel you’d like to post notifications to and then click `allow` to authorize the app. You’ll be redirected back to the settings page with a new Webhook URL created for you.

![Defining the Webhook URL](/content/blog/forward-nexmo-sms-to-slack-using-express-and-node/webhookurl.png)

Take note of the Webhook URL as we’ll be needing it shortly. 

## Create Webhook for Inbound Messages

We need to define a `route` in our application where Nexmo will make a `POST` request to whenever our virtual number receives a text message. This `route` will be responsible for triggering the slack notifications. Before we create the `route`, we need to `require` the `slack-notify` package we installed earlier. 

Add the following code to the `index.js` file under the `require` section :

```javascript
const webhookUrl = 'https://hooks.slack.com/services/xxxx/xxx';
const slack = require('slack-notify')(webhookUrl)
```

Replace `webhookUrl` with the Webhook URL that Slack generated for you in the previous section. 

![Console output showing the webhook response](/content/blog/forward-nexmo-sms-to-slack-using-express-and-node/console.png)

Whenever we receive an inbound message, Nexmo will send a payload that looks like the screenshot above. The `text` key contains the content of the message that was received. 

Let’s add the route now. Edit the `index.js` file with the following code:

```javascript
app.post("/webhooks/inbound-message", (req, res) => {
    const { text } = req.body
    slack.alert({
        text: 'New SMS message',
        fields: {
            'Message' : text
        }
    });
    res.status(200).end();
})
```

The `text` key from the request body will contain the content of the message that was received. 
Using destructuring, we assign the `text` key to a `text` const and in turn, trigger the notification to be sent to Slack using the `alert()` method. You can find the different methods `slack-notify` support [here](https://www.npmjs.com/package/slack-notify).

The final structure of the `index.js` file should look like this: 

```javascript
const express = require('express');
const app = express();
const bodyParser = require('body-parser')
const port = 3000;
const webhookUrl = 'https://hooks.slack.com/services/xxxx/xxx';
const slack = require('slack-notify')(webhookUrl)

app.use(bodyParser.json());

app.use(bodyParser.urlencoded({extended: true}));

app.post("/webhooks/inbound-message", (req, res) => {
    const { text } = req.body
    slack.alert({
        text: 'New SMS message',
        fields: {
            'Message' : text
        }
    });
    res.status(200).end();
})

app.listen(port, () => {
    console.log(`Listening on ${port}`);
})
```

## Setting up ngrok

To make our application publicly accessible over the web, we’ll need to set up ngrok. You can learn how to set up ngrok [here](https://ngrok.com/docs#getting-started-expose). Since our application is currently running on port 3000, all we need to do is run the following command:

```bash
ngrok http 3000
```

You should see a screen similar to the one below:

![Screenshot showing example of Ngrok running](/content/blog/forward-nexmo-sms-to-slack-using-express-and-node/ngrokscreenshot.png)

Copy the first Forwarding URL as we’ll be making use of it shortly in our Nexmo account. 

## Add Webhook Inbound URL to Nexmo

Under the `Numbers` section in your Nexmo Dashboard, click the gear icon for the number you’d like to receive Slack notifications. If you don’t have any virtual numbers, you will have to purchase one. 

![Screenshot showing the Nexmo dashboard with a list of your numbers](/content/blog/forward-nexmo-sms-to-slack-using-express-and-node/yournumbers.png)

You’ll be prompted with a modal similar to the one below:

![Screenshot showing how to configure your Webhook URLS](/content/blog/forward-nexmo-sms-to-slack-using-express-and-node/configurewebhook.png)

Configure the Inbound Webhook URL with the `ngrok` URL we noted earlier. (http://1e389185.ngrok.io/webhooks/inbound-message)

## Testing

To test that our application works as expected, restart your node server and send a message from your phone to your Nexmo Number. 

![Screenshot showing an example text message received](/content/blog/forward-nexmo-sms-to-slack-using-express-and-node/textmessage.png)

Check your Slack Channel, and you should see the notification.

![Screenshot showing Slack bot receiving the SMS](/content/blog/forward-nexmo-sms-to-slack-using-express-and-node/slackmessage.png)

## Conclusion

In this tutorial, we’ve seen how we can receive Slack Notifications using Nexmo. This tutorial can serve as a great starting guide for building applications with Nexmo and Slack. You can find the repo to this tutorial [here](https://github.com/Dotunj/nexmo-slack-notification).