---
title: Send SMS Messages with Node.js and Express using the Vonage SMS API
description: A step-by-step tutorial on how to send SMS messages with Node.js
  and Express using the Vonage SMS API and Node.js client library.
thumbnail: /content/blog/send-sms-messages-with-node-js-and-express-using-the-vonage-sms-api/send-sms_node-js.png
author: tomomi
published: true
published_at: 2016-10-19T16:53:39.000Z
updated_at: 2021-09-01T14:34:10.439Z
category: tutorial
tags:
  - node
  - express
  - sms-api
comments: true
redirect: ""
canonical: ""
---
The [Vonage SMS API](https://developer.vonage.com/messaging/sms/overview) allows you to send and receive a high volume of SMS messages anywhere in the world. Once you get your virtual phone number, you can use the API to manage outbound messages ("sending") and inbound messages (“receiving”). In this article, you will learn how to send SMS messages with Node.js and Express.

All the step-by-step articles I am going to post in this _Getting Started_ series are written from my experiences as a new employee at Nexmo! Whenever I try a new thing, technical or not, I tend to write down how I did it whether I succeed or fail. Working with Nexmo (now Vonage) APIs is not an exception - I have been writing down every step I took to work with each API from scratch. Now I am posting my notes with a bunch of screenshots to share with you, so I hope you find them helpful. So let’s walk through with me!

**View** **[the source code on GitHub](https://github.com/nexmo-community/send-sms-nodejs-express)**

### Prerequisites

Before starting this tutorial, make sure you have:

- the basic understanding of JavaScript and Node.js
- [Node.js](https://nodejs.org/en/) installed on your machine

<sign-up number></sign-up>

## Using the Vonage Server SDK for Node.js

First, run `npm init` in your project folder, then use npm to install `@vonage/server-sdk`, the Server SDK for Node.js in your working directory:

`$ npm install @vonage/server-sdk --save`

Add `"type": "module"` to your `package.json` file to be able to use [import](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import) statements.

Create a `.js` file, let’s call it `index.js`, and in the file, initialize a `Vonage` instance with your credentials. Find your API key and secret in your [Vonage Dashboard](https://dashboard.nexmo.com/).

```javascript
import Vonage from "@vonage/server-sdk";

const vonage = new Vonage({
	apiKey: VONAGE_API_KEY,
	apiSecret: VONAGE_API_SECRET,
});
```

There are also optional params you can use. Find out more in [the SMS API Reference](https://developer.vonage.com/api/sms?theme=dark).

## Send an SMS Message with Node.js and the Vonage SMS API

To send a message, use the `vonage.message.sendSms` function and pass your virtual number you are sending the message from, a recipient number, and the message to be sent.

Also, you can pass [optional params](https://developer.vonage.com/api/sms?theme=dark), and a callback.

Let's hard-code the phone number (which should start with a country code, e.g. "15105551234") and a message for now to try the API. Replace `YOUR_VIRTUAL_NUMBER` with one of your [Vonage numbers](https://dashboard.nexmo.com/your-numbers).

```javascript
vonage.message.sendSms(
	"YOUR_VIRTUAL_NUMBER",
	"15105551234",
	"yo",
	(err, responseData) => {
		if (err) {
			console.log(err);
		} else {
			if (responseData.messages[0]["status"] === "0") {
				console.dir(responseData);
			} else {
				console.log(
					`Message failed with error: ${responseData.messages[0]["error-text"]}`
				);
			}
		}
	}
);
```

Let's run this, and see if you get an SMS to your mobile phone.

`$ node index.js`

![SMS sent via Vonage on Android](/content/blog/how-to-send-sms-messages-with-node-js-and-express/screenshot-sms.png)

I hope it worked! You have learned how to send an SMS message with the Vonage Node.js SDK.

You can stop right here, or proceed to play with Express.js to be able to take the queries dynamically from POST requests!

### Building a Bare Minimal SMS App with Express.js

Let’s write a very simple app using [Express](https://expressjs.com/) to send an SMS.

Install Express as a dependency:

```bash
$ npm install express --save
```

In **index.js**, add the following code to start a server that listens on port 3000 for connections:

```javascript
import express from "express";

const { json, urlencoded } = express;

const app = express();

app.use(json());
app.use(
	urlencoded({
		extended: true,
	})
);

app.listen(3000, () => {
	console.log("Server listening at http://localhost:3000");
});
```

Now, wrap `vonage.message.sendSms()` with the Express `post` route method. Let’s set the `type` to `'unicode'` so you can send some emojis too! Also, print out the response in the callback.

```javascript
app.post('/send', (req, res) => {
    // Send SMS
    vonage.message.sendSms(YOUR_VIRTUAL_NUMBER, req.body.toNumber, req.body.message, {type: 'unicode'}, (err, responseData) => {
      if (err) {
          console.log(err);
      } else {
          if(responseData.messages[0]['status'] === "0") {
              console.dir(responseData);
          } else {
              console.log(`Message failed with error: ${responseData.messages[0]['error-text']}`);
          }
      }
  })
});
```

Now, you can try sending an SMS to any mobile phone number (including Google Voice numbers) using your app.

In this tutorial, we are not going to create the HTML with the form UI where a user can fill out a phone number and message (I will write a full tutorial including the front-end code in the future!), so let’s pretend we are sending data from a web interface by using [Postman](https://www.postman.com/) to make requests to your app. Postman is a good tool to have when you develop apps with REST APIs!

1. Launch Postman and Select **POST**, and enter _http://localhost:3000/send_.
2. At **Headers**, Set _Content-Type: application/json_

![Send a post request to your app using postman](/content/blog/how-to-send-sms-messages-with-node-js-and-express/postman-headers.png)

3. At **Body**, type a valid JSON with "toNumber" and its value (use your mobile phone number! To receive an SMS message!), also “message” and its value.

![Send a post request to your app using postman](/content/blog/how-to-send-sms-messages-with-node-js-and-express/postman-body.png)

4. Press the blue **Send** button

Once you made a successful POST request to your app, you will get a text message to your phone from the virtual number!

![SMS on Android](/content/blog/how-to-send-sms-messages-with-node-js-and-express/screencast-sms.gif)

Also, you will see the response printed in your terminal.

```shell
{
  'message-count': '1',
  messages: [
    {
      to: '15105551234',
      'message-id': '13000001EBFD617E',
      status: '0',
      'remaining-balance': '5.03151152',
      'message-price': '0.03330000',
      network: 'US_VIRTUAL_BANDWIDTH'
    }
  ]
}
```

You can view [the code sample](https://github.com/nexmo-community/send-sms-nodejs-express/blob/main/index.js) used in this tutorial on GitHub.

In the [next tutorial](https://learn.vonage.com/blog/2016/10/27/receive-sms-messages-node-js-express-dr/), you will learn how to receive SMS messages to your virtual number. Stay tuned!

## References

- [Vonage SMS REST API](https://developer.vonage.com/messaging/sms/overview)
- [Vonage SDK for Node.js](https://github.com/vonage/vonage-node-sdk)
- [ExpressJS](https://expressjs.com)
