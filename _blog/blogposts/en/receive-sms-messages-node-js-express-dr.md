---
title: Receive SMS Messages with Node.js, Express, and the Vonage SMS API
description: A step-by-step tutorial on how to receive SMS messages and write a
  webhook with Node.js and ExpressJS using the Vonage SMS API.
thumbnail: /content/blog/receive-sms-messages-with-node-js-express-and-the-vonage-sms-api/recieve-sms_node-js.png
author: tomomi
published: true
published_at: 2016-10-27T18:35:15.000Z
updated_at: 2021-09-07T17:55:12.114Z
category: tutorial
tags:
  - express
  - nodejs
  - sms-api
comments: true
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
> We've built this tutorial using the Vonage SMS API, Node.js, and Express

In the previous article, you set up your Vonage account and learned [how to send SMS messages with Node.js](https://learn.vonage.com/blog/2016/10/19/how-to-send-sms-messages-with-node-js-and-express-dr/). In this blog post, you will learn about receiving an inbound SMS by implementing a webhook endpoint in Node.js using [Express](http://expressjs.com/).

**View** **[the source code on GitHub](https://github.com/nexmo-community/receive-sms-node)**

## Defining a Webhook Endpoint

To receive an SMS message from Vonage, you need to associate a webhook endpoint (URL) with a virtual number you have rented from Vonage. [Inbound Messages](https://developer.vonage.com/messaging/sms/guides/inbound-sms) to that number are then sent to your webhook endpoint.

While developing the webhook endpoint, it is a pain to keep deploying your work in progress. To make your life easier, let’s use **[ngrok](https://ngrok.com/)** to expose your webhook endpoint on your local machine as a public URL!

### Using ngrok

First, download ngrok from <https://ngrok.com>. Once installed, run ngrok on terminal:

```bash
$ ngrok http 3000
```

![running ngrok](/content/blog/how-to-receive-sms-messages-with-node-js-and-express/ngrok.png "running ngrok")

Your local server (localhost:3000) now has an ngrok URL like `https://71f03962.ngrok.io` that can be used as your webhook endpoint during development. Also, notice the Web Interface URL—you can inspect, modify, and replay your requests here—more about this later!

### Setting the Webhook Endpoint With Vonage

Sign in to your Vonage account, go to [Settings](https://dashboard.nexmo.com/settings), and find the **SMS Settings** section.  

Vonage has two different APIs capable of sending and receiving SMS messages. You can only use one at a time because it will change the format of the webhooks you receive. This time, we're going with the `SMS API`, so make sure this is selected.  

Next, fill out the **Inbound SMS webhooks** field using the ngrok URL with a route—let’s call it "inbound". Enter `https://YOUR_NGROK_URL/inbound`, set the **HTTP Method** to `POST` then click on **Save changes**.

![setting your webhook endpoint](/content/blog/receive-sms-messages-with-node-js-express-and-the-vonage-sms-api/screenshot-2021-09-03-at-22.10.12.png "setting your webhook endpoint")

Now all your incoming messages will go to the webhook (callback) URL, so let’s write some code with Node.js and Express!

> Note: Above, we're setting the webhook endpoint for SMS at an account level. Alternatively, you can also set up unique webhook endpoints for each virtual number by clicking *Manage* next to one of [your virtual numbers](https://dashboard.nexmo.com/your-numbers) in the Vonage dashboard.

## Writing Webhook Endpoints With Express

Next, you'll handle the `POST` requests with [Express](https://expressjs.com/), so install it.

```shell
$ npm install express
```

Add `"type": "module"` to your `package.json` file to enable [import](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import) statements.

Create a `.js` file, instantiate Express, and listen at port 3000. Because you have set your ngrok to expose `localhost:3000`, you must stick with the same port.

```javascript
import express from 'express';

const { json, urlencoded } = express;

const app = express();

app.use(json());
app.use(
    urlencoded({
        extended: true
    })
);

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server listening at http://localhost:${PORT}`);
});
```

Next, create an HTTP POST route to handle the requests:

```javascript
app.post('/inbound', (req, res) => {
  handleParams(req.body, res);
});
```

Then define the `handleParams` function:

```javascript
function handleParams(params, res) {
  if (!params.to || !params.msisdn) {
    console.log('This is not a valid inbound SMS message!');
  } else {
    let incomingData = {
      messageId: params.messageId,
      from: params.msisdn,
      text: params.text,
      type: params.type,
      timestamp: params['message-timestamp']
    };
    console.log('Success', incomingData);
  }
  res.status(200).end();
}
```

Run the node code, and try sending some messages from your phone to your virtual number!

![screenshot of a user sending an SMS message from an Android phone](/content/blog/how-to-receive-sms-messages-with-node-js-and-express/screenshot-sending-sms.gif "screenshot of a user sending an sms message from an Android phone")

When you are tunneling your local app with ngrok, you can also inspect the request at <http://127.0.0.1:4040/> on your browser:

![ngrok inspector](/content/blog/how-to-receive-sms-messages-with-node-js-and-express/ngrok-inspector.png "ngrok inspector")

Voilà, now you can see your SMS message has been sent. Vonage has received the message and passed it on to your Express application via a Webhook!

I hope you found this helpful. Let us know [@VonageDev on Twitter](https://twitter.com/VonageDev).

## References

* [Vonage SMS API](https://developer.vonage.com/messaging/sms/overview)
* [Ngrok](https://ngrok.com/)
