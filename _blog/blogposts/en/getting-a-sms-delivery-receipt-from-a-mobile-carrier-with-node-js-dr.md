---
title: How to Receive an SMS Delivery Receipt with Node.js
description: A step-by-step tutorial on how to receive SMS delivery receipts
  from mobile carriers with a webhook written with Node.js and Express.js
thumbnail: /content/blog/how-to-receive-an-sms-delivery-receipt-with-node-js/delievery-sms_node-js.png
author: tomomi
published: true
published_at: 2016-11-23T21:59:35.000Z
updated_at: 2021-11-08T09:56:45.989Z
category: tutorial
tags:
  - sms-api
  - nodejs
comments: true
redirect: ""
canonical: ""
---
In previous articles, you have learned [how to send SMS messages](https://learn.vonage.com/blog/2016/10/19/how-to-send-sms-messages-with-node-js-and-express-dr/), and [how to consume a webhook for incoming SMS](https://learn.vonage.com/blog/2016/10/27/receive-sms-messages-node-js-express-dr/) with Node.js.  

In this tutorial, you will learn how to find out if the SMS messages sent from your virtual number have been delivered.

**View** **[the source code on GitHub](https://github.com/Vonage/vonage-node-code-snippets/blob/master/sms/dlr-express.js)**

## How Do You Know When Your SMS Message is Delivered?

When you send a message to a mobile phone number using the Vonage SMS API (See the [Sending SMS with Node.js](https://learn.vonage.com/blog/2016/10/19/how-to-send-sms-messages-with-node-js-and-express-dr/) tutorial), the HTTP response from the API can tell you whether the message has been successfully *sent* from your app. However, it can't tell you if the message has actually been *delivered* to the recipient or not. To find out what the status is, you need to register a webhook callback URL to capture the changes in delivery status.

When a message gets delivered, the mobile phone carrier returns a **Delivery Receipt (DLR)** to Vonage  explaining the delivery status of your message. If you have set up a webhook endpoint, Vonage then forwards this delivery receipt to your endpoint.

![A diagram explaining how Delivery Receipts work](/content/blog/how-to-receive-an-sms-delivery-receipt-with-node-js/diagram-dlr-vonage.png "A diagram explaining how Delivery Receipts work")

### Setting Up the Endpoint with Vonage

When developing, it's convenient to use a tunneling service like [ngrok](https://ngrok.com/) to expose your local server to the internet—instead of having to redeploy every time. I am tunneling `localhost:5000` in this example.

Once you set up with ngrok and get a forwarding URL, sign in to your Vonage account, and go to [Settings](https://dashboard.nexmo.com/settings). Under "SMS Settings", fill out the **Delivery receipts (DLR) webhooks** field with the ngrok URL and a route, let’s call it `/receipt`, and save.

![Setting for ngrok Webhook endpoints](/content/blog/how-to-receive-an-sms-delivery-receipt-with-node-js/webhook-delivery-endpoint.png "Setting for ngrok Webhook endpoints")

Now, every time you send a message from your virtual number, the delivery receipt webhook call will be made to that URL. Let’s write some code with Node.js and Express to handle it!

## Handling a WebHook with Express

The code is similar to the example in [the last article](https://learn.vonage.com/blog/2016/10/27/receive-sms-messages-node-js-express-dr/), except for the HTTP route. For DLR, use `/receipt` or whatever the callback URL you have specified in the previous step in *Settings*.

```javascript
const server = app.listen(5000);

// For webhooks configured to use POST
app.post('/receipt', (req, res) => {
  handleParams(req.body, res);
});

// For webhooks configured to use GET
app.get('/receipt', (req, res) => {
  handleParams(req.query, res);
});
```

Then define the `handleParams` function as following:

```javascript
function handleParams(params, res) {
  if (params.status !== 'delivered') {
    console.log('Fail: ' + params.status);
  } else { // Success!
    console.log(params);
  }
  res.status(200).end();
}
```

When you receive the DLR, you must send a `200 OK` response. If you don’t, Vonage will keep resending the delivery receipt for the next 72 hours.

Let’s run the Node code, and try sending some messages from your virtual number to a real phone number! 

If your message has been successfully sent to your mobile phone, you should get a receipt with the info including status, message ID, network code, timestamp, etc.

```javascript
{
  "msisdn": "14155551234",
  "to": "12015556666",
  "network-code": "310090",
  "messageId": "02000000FEA5EE9B",
  "price": "0.00570000",
  "status": "delivered",
  "scts": "1208121359",
  "err-code": "0",
  "message-timestamp": "2016-10-19 22:40:30"
  }
```

*Note: Some US carriers do not support the feature. Also, if you are sending SMS to a Google Voice number, you will not get a delivery receipt. We do not provide reach to other virtual number providers due to fraud prevention purposes. If you have a particular business case where you would like to be able to reach virtual numbers, please [contact our Support team!](https://www.vonage.com/communications-apis/campaigns/contact-us/)*

## References

* [Delivery Receipts](https://developer.vonage.com/messaging/sms/guides/delivery-receipts)
* [Vonage SMS API](https://developer.vonage.com/messaging/sms/overview)
* [Vonage Webhooks](https://developer.vonage.com/concepts/guides/webhooks)
* [Vonage API Reference](https://developer.vonage.com/api/sms?theme=dark#delivery-receipt)
* [Ngrok](https://ngrok.com/)