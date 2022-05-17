---
title: Receive SMS Messages With Node.js and Express | One Dev Minute
description: "In this quick walkthrough, you'll learn how to receive SMS
  messages with the Vonage Messages API, Express and Node.js."
thumbnail: /content/blog/receive-sms-messages-with-node-js-and-express-one-dev-minute/receive.png
author: amanda-cavallaro
published: true
published_at: 2022-05-17T13:22:33.889Z
updated_at: 2022-05-17T13:22:35.141Z
category: tutorial
tags:
  - javascript
  - node
  - messages-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Welcome to [One Dev Minute](https://www.youtube.com/playlist?list=PLWYngsniPr_mwb65DDl3Kr6xeh6l7_pVY)! This series is hosted on the [Vonage Dev YouTube channel](https://www.youtube.com/vonagedev). The goal of this video series is to share knowledge in a bite-sized manner.

In this quick walkthrough, Amanda Cavallaro will show you how to receive SMS messages with the Vonage Messages API, Express and Node.js.

<youtube id="JmC4y2ycF6c"></youtube>

## Transcript

Let's receive messages using Node.js, Express and the Vonage Messages API.

Before we get started, make sure you have:

* created a Vonage account,
* installed Node.js, installed Ngrok, and the Vonage CLI globally.

Create a folder, change the directory inside of it, install Express, and the Vonage server SDK beta.
Create a new file called `server.js`, and open it in your favorite code editor.

We'll create an Express application that makes use of the JSON parser and the URL encoded modules. 

We'll use port 3000 for the server to listen to. Now we are going to create a post request handler for the webhook inbound for the inbound URL, and will log the request body to the console. 

You can run the code by running `node server.js` in one terminal tab and on another terminal tab you can run: `ngrok http 3000`. 

From the Vonage dashboard, click on "Settings" on the menu on the left. Make sure that the messages API is set as default under the SMS settings, and then click "Save". 

Go to the Vonage dashboard and click to create a new application. Give it a name, scroll down to capabilities and toggle "Messages" on the right. 

Go back to your terminal tab and copy the HTTPS URL that was generated for us to use in ngrok.

For the inbound URL we are going to paste the URL and append `/webhooks/inbound,` which is the route that we have set up in our code. 

Scroll down and click to generate a new application. Link a phone number. If you don't already have one, you have to buy it on the menu on the left.

To see it in action, you can send a message from your phone to your virtual phone number. You should see a message being logged in the terminal window.

You can learn further from the links below

## Links

[Read the written version of the tutorial](https://developer.vonage.com/blog/2019/09/16/how-to-send-and-receive-sms-messages-with-node-js-and-express-dr)

[Reference the code on GitHub](https://github.com/nexmo-community/nexmo-sms-autoresponder-node/)

[Reference the code on Glitch](https://glitch.com/edit/#!/whispering-rebel-ixia)

[Join the Vonage Developer Community Slack](https://developer.vonage.com/community/slack)
