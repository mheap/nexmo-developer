---
title: Handling Unsupported Inbound Messages With the Messages API
description: Find out how to understand if a user or customer has sent you an
  unsupported message type, like a sticker, and handle it using the Messages
  API.
thumbnail: /content/blog/handling-unsupported-inbound-messages-with-the-messages-api-dr/Blog_Unsupported-Inbound-Messages_1200x600.png
author: stevelorello
published: true
published_at: 2020-09-24T13:13:56.000Z
updated_at: 2021-05-10T22:13:13.539Z
category: tutorial
tags:
  - messages-api
  - node
comments: true
redirect: ""
canonical: ""
---
The [Messages API](https://developer.nexmo.com/messages/overview) enables you to connect with your customers over many social-messaging channels such as WhatsApp, Facebook Messenger, and Viber.

The connection is two-way; you can both send and receive messages. But in the rapidly evolving world of social-messaging channels, there's a unique issue. What happens if a customer manages to send a message type to your business that is not yet supported?

Case in point, what happens when your customer sends you a sticker via WhatsApp? This question is pervasive for folks integrating with the Messages API.

The answer lies in the request body of the inbound message. The JSON of the inbound message contains a `type` field inside the message's content object.

If the type is unsupported, the `type` field is `unsupported`; this is true for WhatsApp, Viber, Facebook Messenger, and MMS. The message body for an inbound message with an unsupported payload will look like this:

```json
{
  "message_uuid": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "timestamp": "2020-01-01T14:00:00.000Z",
  "to": {
    "type": "whatsapp",
    "number": "447700900000"
  },
  "from": {
    "type": "whatsapp",
    "number": "447700900001"
  },
  "message": {
    "content": {
      "type": "unsupported"
    }
  }
}
```

Notice how it furnishes you with your customer's WhatsApp number. Armed with this information, you can decide how your app will handle it. You may want to make a note that your customer responded to you, and you may wish to reply to them, indicating that they sent a message that you're unable to understand.

## Detecting an Unsupported Message in Code

I usually like code examples to illustrate concepts like these, so let's look at an example using Node JS. Create a new directory and in its run `npm install express body-parser`

Now create a new file called `server.js`. Here, we'll add the following code.

```js
const app = require('express')()
const bodyParser = require('body-parser')

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

app.post('/webhooks/inbound-message', (req, res) => {  
  if(req.body['message']['content']['type'] == 'unsupported'){
    console.log("Received an unsupported message from " 
      + req.body['from']['number']);
    // add the rest of your unsupported logic here.
  }
  else{
    console.log(req.body['message']['content'])
  }
  res.status(200).end();
});


app.listen(5000)
```

Start our server by running `node server.js`. With our server running, the last thing we need to do is to wire up WhatsApp Messages to it.

I'd recommend using [ngrok](https://developer.nexmo.com/tools/ngrok) to receive inbound WhatsApp messages locally from the Vonage Messages API. You can start it up by running `ngrok http 5000` - which will produce a base URL for you. Your app is going to receive messages on `BASE_URL/webhooks/inbound-messages`, so use that URL when setting up the [Messages API Sandbox](https://developer.nexmo.com/messages/concepts/messages-api-sandbox#configure-webhooks).

With all that wired up, you can now send yourself messages. So, if I were to go into WhatsApp and send the Messages Sandbox a Coffee Sticker:

![Coffee Sticker](/content/blog/handling-unsupported-inbound-messages-with-the-messages-api/coffeesticker.png)

My app will receive it and print out the message: `Received an unsupported message from WHATSAPP_NUMBER`.

Otherwise, it will print the content of the message.

![The response in action](/content/blog/handling-unsupported-inbound-messages-with-the-messages-api/demo.png)

## Resources

* If you want to learn how to send a WhatsApp message - there's a great [explainer](https://www.nexmo.com/blog/2020/04/15/send-a-whatsapp-message-with-node-dr) from Garann Means
* If you're interested in using the Messages API generally, our [docs website](https://developer.nexmo.com/messages/overview) has loads of content and explanations on how to get up and running.
* You can find the code for this blog post in [GitHub](https://github.com/nexmo-community/handling-unsupported-inbound-messages)