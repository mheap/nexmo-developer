---
title: Introducing Distribution Ledger Technology - SMS Indian Regulation
description: A brief introduction into a new SMS regulation in India called DLT,
  as well as how to make use of this using Vonage APIs or Vonage SDKs.
thumbnail: /content/blog/introducing-distribution-ledger-technology-sms-indian-regulation/dlt_sms_1200x600.png
author: greg-holmes
published: true
published_at: 2021-05-12T08:21:33.729Z
updated_at: 2021-04-27T11:19:18.678Z
category: tutorial
tags:
  - sms-api
  - node
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
## What Is Distribution Ledger Technology (DLT)?

Distributed Ledger Technology (also known as DLT) is a digital method allowing users and systems to record transactions related to their assets. Traditional databases have a central location to store their information; however, DLT stores the data at multiple locations to provide better security, transparency and trust amongst the parties utilizing the service.

## What Does DLT Have To Do With Indian Regulation?

A regulation set by the Telecom Regulatory Authority of India (TRAI) requires any domestic enterprise that submits Application 2 Phone (A2P) SMS through domestic connections to the end recipients to have a successful registration of DLT. Any enterprise that fails to pre-register for DLT will become non-compliant and unable to send A2P SMS to end recipients via domestic connections in India.

## How Can I Register for DLT?

If you are an enterprise in India or are sending A2P SMS to domestic phone numbers in India, you will need to be compliant with DLT. To do this, you will need to register your Principal Entity, Headers, Templates (with your Brand Name) and provide consent on any one of the DLT systems listed below:

* [Vodafone-Idea Ltd DLT URL](https://www.vilpower.in)
* [BSNL DLT URL](https://www.ucc-bsnl.co.in)
* [Airtel DLT URL](https://dltconnect.airtel.in)
* [Reliance JIO DLT URL](https://trueconnect.jio.com/)

## How Can I Use DLT With Vonage?

### Update Your Project and Submit DLT Required Parameters at Every Request

You need to make changes to your application to use your Entity ID, Sender ID/Header and Templates as shown in the DLT portal. You will need to use the additional parameters for every API request or SMPP request when you submit your SMS messages.

### Sending an SMS with the API

If you are using our API without one of our SDKs, then you'd need to update your POST request when making a request to send an SMS. You would need to add two parameters to the request, as shown below:

* entity-id (string)
* content-id (string)

More information on this request with the API when sending an SMS can be found on the [API Docs](https://developer.nexmo.com/api/sms#send-an-sms).

### Sending an SMS With Our SDKs

The example below uses the Node SDK, however we have other SDKS as listed in the [developer docs code snippets](https://developer.nexmo.com/messaging/sms/code-snippets/send-an-sms).

<sign-up></sign-up>

The example below shows how to send an SMS with the Vonage Node SDK, including the two required parameters to be compliant with DLT regulations:

> **Note** To run this example, you'll need to replace the VONAGE_API_KEY, VONAGE_API_SECRET, VONAGE_BRNAD_NAME, TO_NUMBER, DLT_APPROVED_PEID, and DLT_APPROVED_TEMPLATE_ID with your own values.

```node
const Vonage = require('@vonage/server-sdk')

const vonage = new Vonage({
  apiKey: VONAGE_API_KEY,
  apiSecret: VONAGE_API_SECRET
})

const from = VONAGE_BRAND_NAME
const to = TO_NUMBER
const text = 'A text message sent using the Vonage SMS API'
const opts = {
  "entity-id": DLT_APPROVED_PEID,
  "content-id": DLT_APPROVED_TEMPLATE_ID
}

vonage.message.sendSms(from, to, text, opts, (err, responseData) => {
    if (err) {
        console.log(err);
    } else {
        if(responseData.messages[0]['status'] === "0") {
            console.log("Message sent successfully.");
        } else {
            console.log(`Message failed with error: ${responseData.messages[0]['error-text']}`);
        }
    }
})
```

### How Do I Know It Worked?

There may be various reasons why sending an SMS that needs to be DLT compliant does not successfully get sent. To check for the error, you'll need to create a webhook to listen for a specific pre-configured URL that you create in your application. For a full list of the errors that are returned in a delivery receipt, please check the [Developer Docs](https://developer.nexmo.com/messaging/sms/guides/delivery-receipts#dlr-error-codes). The table below shows the errors that are relevant to sending DLT SMS messages.

| Error Code | Meaning        | Description                                                                            |
| ---------- | -------------- | -------------------------------------------------------------------------------------- |
| 50         | Entity Filter  | The message failed due to entity-id being incorrect or not provided.                   |
| 51         | Header Filter  | The message failed because the header ID (from phone number) was incorrect or missing. |
| 52         | Content Filter | The message failed due to content-id being incorrect or not provided.                  |
| 53         | Consent Filter | The message failed due to consent not being authorized.                                |

An example of a webhook to receive SMS Delivery Receipts with Node is shown below:

```node
const app = require('express')()
const bodyParser = require('body-parser')

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

app
  .route('/webhooks/delivery-receipt')
  .get(handleDeliveryReceipt)
  .post(handleDeliveryReceipt)

function handleDeliveryReceipt(request, response) {
  const params = Object.assign(request.query, request.body)
  console.log(params)
  response.status(204).send()
}

app.listen(process.env.PORT || 3000)
```

Your application will need to be exposed to the Internet for the webhook to be accessible. For development purposes we suggest people to use ngrok [and we have a nice tutorial on how to get set up with ngrok](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/).

The last change you'll need to make for this is to configure your Delivery Receipts Webhook URL on the [Vonage Dashboard API settings page](https://dashboard.nexmo.com/settings). Replace the contents of the `Webhook URL for Delivery Receipts` input field with your Webhook url, for example: `https://demo.ngrok.io/webhooks/delivery-receipt`.

A successful SMS message being sent will show as similar to the example below:

```json
{
  "err-code": "0",
  "message-timestamp": "2020-10-25 12:10:29",
  "messageId": "0B00000127FDBC63",
  "msisdn": "447700900000",
  "network-code": "23410",
  "price": "0.03330000",
  "scts": "1810251310",
  "status": "delivered",
  "to": "Vonage"
}
```

However, if there is an issue, `err_code` will not be 0, and the `status` will be `rejected`.

### Sending SMS with SMPP

To send an SMS message with SMPP, you’ll need to add extra parameters to your request. For more information on what these extra parameters are please refer to the [knowledgebase under “Complying with DLT and Vonage”](https://help.nexmo.com/hc/en-us/articles/204017423-India-SMS-Features-Restrictions)

### Letting Vonage manage DLT for you

Vonage is providing a temporary solution, where you let Vonage detect your template with zero change at your end. Please check the [knowledgebase, section 2, option 2](https://help.nexmo.com/hc/en-us/articles/204017423-India-SMS-Features-Restrictions) for more information. While this method is not suggested by Vonage, we recommend updating your project and using the new API parameters to send DLT compliant SMS.