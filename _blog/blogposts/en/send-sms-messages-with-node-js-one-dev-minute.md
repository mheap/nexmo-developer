---
title: Send SMS Messages with Node.js | One Dev Minute
description: In this quick walkthrough, you'll learn how to send SMS messages
  with the Vonage Messages API and Node.js.
thumbnail: /content/blog/send-sms-messages-with-node-js-one-dev-minute/send-sms.png
author: amanda-cavallaro
published: true
published_at: 2022-06-21T08:02:17.720Z
updated_at: 2022-06-21T08:02:17.735Z
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

In this quick walkthrough, Amanda Cavallaro will show you how to send SMS messages with the Vonage Messages API and Node.js.

<youtube id="zN09k8zqrk4"></youtube>

## Transcript

Let's send SMS messages using Node.js with the Vonage Messages API.

Before we get started, make sure you have:

* created the Vonage account.
* installed Node.js, and the Vonage CLI beta.

From the Vonage dashboard, click on "Settings" on the menu on the left. Make sure that the Messages API is set as default under the SMS settings, and then click "Save". 

Create an application and click on "Generate the public and private key". A file will be downloaded. We'll use it in a second.

Create a project folder, change the directory inside of it and open your favorite code editor. 
Add the private key you downloaded to the project root. 
Install the Vonage server SDK dependency and create an `index.js` file. 

Initialize a new Vonage object instance. 
Add the application ID and the private key. They can be found on your Vonage dashboard. 

Declare a variable containing the text which will be sent via SMS and another variable that will hold the phone number we will send a text. 

It's time to use the Messages API to send an SMS. We'll use the `vonage.channel.send` method of the Vonage Node library. 

To send an SMS we will specify a type for their recipient and sender: SMS.

The first field will contain the recipient, and the second the sender.

For the content, we will specify a type of text and the text field that will contain our text message.

The callback returns an error and the response object will log messages about the success or failure of the operation.

And finally, you can run the code `node index.js` from your terminal.

You'll receive the SMS message on the phone number specified.You can learn further from the links below.

## Links

[Read the written version of the tutorial](https://developer.vonage.com/blog/2019/09/16/how-to-send-and-receive-sms-messages-with-node-js-and-express-dr)

[Reference the code on GitHub](https://github.com/nexmo-community/nexmo-sms-autoresponder-node/)

[Reference the code on Glitch](https://glitch.com/edit/#!/whispering-rebel-ixia)

[Join the Vonage Developer Community Slack](https://developer.vonage.com/community/slack)
