---
title: Understanding WhatsApp messaging
navigation_weight: 3
description: WhatsApp messaging solution for businesses.
---

# Understanding WhatsApp messaging

WhatsApp Business Solution messages can only be sent by businesses that have been approved by WhatsApp. This business profile will also have a green verified label to indicate that it is a legitimate business.

The advantage of WhatsApp is that the identifier of users on the platform is their mobile phone number.

> **NOTE:** WhatsApp is in Limited Availability and Vonage cannot guarantee you will receive a WhatsApp account.

## Setting up a WhatsApp Business Account

You can sign up for a WhatsApp Business Account via the [Vonage API Dashboard](https://dashboard.nexmo.com/). Navigate to the [Social channels](https://dashboard.nexmo.com/messages/social-channels) page of the Dashboard and select the option to set up a **WhatsApp Business Account**.

## Using existing WhatsApp Business Number

If you already have a WhatsApp Business Number and would like to use that number with the Vonage Messages API, the [WhatsApp Product](https://www.nexmo.com/products/messages/whatsapp) page has more details about how to get started using WhatsApp with Vonage.

> **NOTE:** Once a WhatsApp number is integrated with the API it cannot be used in the mobile app.

## Rules for Messaging Customers

WhatsApp has a concept of a 24 hour customer care window, during which a business can freely message an end user. The 24 hour window can be initiated in two ways:

- An end user sends a message to the business
- A business sends a templated message to the end user. The 24 hour window starts as soon as the end user replies.

Templates must be approved by WhatsApp before they can be used to send messages to an end user. When the 24 hour window expires, a new 24 hour customer care window must be initiated again.
It is important to be aware that 24 hour customer care windows are not the same as the 24 hour billable conversation window.

## WhatsApp Conversation-Based Pricing

Vonage now offers a Conversation-Based Pricing model for WhatsApp messaging. This is in line with the pricing model introduced by WhatsApp at the start of February 2022.

- **What is a conversation?** A conversation is any number of messages sent within a 'session', which is defined as a 24 hour period starting from the time the first message is sent **by the business**.
- **Who initiates a conversation?** A conversation can be *initiated* either by a *customer* (user-initiated) or *business* (business-initiated), but in either case the 'session' begins with the first message sent **by the business**..
- **How does Vonage price conversations?** The Vonage pricing for WhatsApp messaging is made up of two components, both of which are priced *per conversation*:
  - A Vonage platform fee
  - A WhatsApp fee

> **IMPORTANT**: Existing customers will by default remain on their current pricing model by default at the current per message pricing, with the option to move to the new conversation based pricing model.

For more information on Vonage WhatsApp pricing, see the [Messages API pricing](https://www.vonage.com/communications-apis/messages/pricing/) page. Further information on the Conversation-Based Pricing model can be found in the [WhatsApp developer documentation](https://developers.facebook.com/docs/whatsapp/pricing)

> **NOTE:** Since WhatsApp pricing is *per conversation* rather than *per message*, it is not possible to provide an accurate price per message. Therefore, the value given for the `price` property in the `usage` object contained in the body of a [Message Status callback](/api/messages-olympus#message-status) will be the *default price per conversation* rather than the actual price for *each message*.

## WhatsApp Number Hosting

We have two ways of managing WhatsApp numbers. We can either host your number on our servers using **WhatsApp’s On-premises** solution, or handle it directly in **WhatsApp’s Cloud** solution.

In the majority of cases, you will receive the same service, as Vonage takes care of the delivery of messages to and from your business. There are, however, some slight differences to be aware of.

| | WhatsApp Hosting | Vonage Hosting |
|---|---|---|
| Message Throughput | Auto-scales to around 80 messages per second | Around 20 messages per second by default, and this can be scaled on request |
| Encryption | Messages are sent securely to WhatsApp’s service where they are decrypted before being passed through the WhatsApp networks securely using the Signal protocol to end users | Messages are end-to-end encrypted between Vonage and end users using the signal protocol |
| Feature differences | WhatsApp’s hosting does not currently support stickers or product messages. (These are expected to be available by the second half of 2022) | Stickers or product messages are supported |

> **NOTE:** WhatsApp numbers provisioned on WhatsApp Cloud Hosting are currently unable to send messages to the following destinations:
>
> - Turkey

**Which Option Should You Choose?**

Unless you specifically need the stickers and product messages features or need to send messages to the destinations listed in the above note, for new customers setting up their WhatsApp account directly through the [Vonage dashboard](https://dashboard.nexmo.com/) we recommend using WhatsApp’s hosting as we can get your number ready instantly.

**How to enable WhatsApp’s number hosting**

For a number to be hosted on WhatsApp servers, customers must create a WhatsApp Business Account using [Vonage Dashboard External Accounts](https://dashboard.nexmo.com/messages/social-channels). When your WhatsApp number is provisioned there will be an option to use WhatsApp hosting.

**Transferring existing numbers**

Although it isn't currently possible to transfer already provisioned numbers between the two hosting solutions, we will soon provide a service to move numbers hosted on Vonage servers (using WhatsApp's On-premises solution) to WhatsApp’s Cloud hosting, and vice versa.


## WhatsApp message types

There are a number of different WhatsApp message types:

Message Type | Description
---|---
Text Message | A plain text message. This is the default message type.
Media Message | A media message. Types are: image, audio, document and video.
Message Template | Message Templates are created in the WhatsApp Manager. Outside of the Customer Care Window messages sent to a customer must be a Message Template type. Only templates created in your own namespace will work. Using an template with a namespace outside of your own results in an error code 1022 being returned.
Media Message Templates | Media message templates expand the content you can send to recipients beyond the standard message template type to include media, headers, and footers using a `components` object.
Contacts Message | Send a contact list as a message.
Location Message | Send a location as a message.
Interactive Message | The Vonage Messages API v1 supports two types of WhatsApp Interactive Messages: **List Messages** and **Reply Buttons**. [Read more](/messages/concepts/whatsapp-interactive-messages)

## How WhatsApp works

A business can start a conversation with a user and a user can start a conversation with a business.

WhatsApp has a core concept of Messages Templates (MTM). These were previously known as Highly Structured Messages (HSM).

> **IMPORTANT:** WhatsApp requires that a message that is sent to a user for the first time, or that is outside the Customer Care Window, be an MTM message. WhatsApp also requires that you obtain opt-in from your customers prior to sending them a message, this may be obtained on your website, IVR, or other standard means see [Facebook's docs](https://developers.facebook.com/docs/whatsapp/guides/opt-in/) for more details.

The MTM allows a business to send only the template identifier along with the appropriate parameters instead of the full message content.

> **NOTE:** New templates need to be approved by WhatsApp. Please contact your Vonage API Account Manager to submit the templates. Only templates created in your own namespace are valid. Using an template with a namespace outside of your own results in an error code 1022 being returned.

> **NOTE:** Templates are subject to a restriction of 60 characters in their header and footer, and 1024 characters in their body.

MTMs are designed to reduce the likelihood of spam to users on WhatsApp.

For the purpose of testing Vonage provides a template, `whatsapp:hsm:technology:nexmo:verify`, that you can use:

``` shell
{{1}} code: {{2}}. Valid for {{3}} minutes.
```

The parameters are an array. The first value being `{{1}}` in the MTM.

Below is an example API call:

``` shell
curl -X POST \
  https://api.nexmo.com/beta/messages \
  -H 'Authorization: Bearer' $JWT \
  -H 'Content-Type: application/json' \
  -d '{
   "from": "WHATSAPP_NUMBER",
   "to": "TO_NUMBER",
   "channel": "whatsapp",
   "whatsapp": {
     "policy": "deterministic",
     "locale": "en-GB"
   }
   "message_type": "template",
   "template":{
      "name":"whatsapp:hsm:technology:nexmo:verify",
      "parameters":[
         "Vonage Verification",
         "64873",
         "10"
      ]
   }
}'
```

## WhatsApp deterministic language policy

> **NOTE:** WhatsApp deprecated the "fallback" locale method when sending template messages on January 1st 2020. As of April 8, 2020, messages bearing the "fallback" policy will fail with a 1020 error in your message status webhook.

When a message template is sent with the deterministic language policy, the receiving device will query its cache for a *language pack* for the language and locale specified in the message. If not available in the cache, the device will query the server for the required language pack. With the deterministic language policy the target device language and locale settings are ignored. If the language pack specified for the message is not available an error will be logged.

Further information is available in the [WhatsApp documentation](https://developers.facebook.com/docs/whatsapp/message-templates/sending/#language).

## WhatsApp Provisioning API

The WhatsApp Provisioning API enables you to deploy a WhatsApp cluster, perform one time password (OTP) verification, and update profile information for a WhatsApp business account.

For more information see the [WhatsApp Provisioning API](/messages/whatsapp-provisioning/overview) documentation.

## Further information

* [Custom objects](/messages/concepts/custom-objects)
* [Interactive Messages: Overview](/messages/concepts/whatsapp-interactive-messages)
* [Working with Interactive Messages](/messages/concepts/working-with-whatsapp-interactive-messages)

WhatsApp developer documentation:

* [WhatsApp Developer documentation](https://developers.facebook.com/docs/whatsapp)
* [Text Message](https://developers.facebook.com/docs/whatsapp/api/messages/text)
* [Media Message](https://developers.facebook.com/docs/whatsapp/api/messages/media)
* [Message Template](https://developers.facebook.com/docs/whatsapp/api/messages/message-templates)
* [Media Message Template](https://developers.facebook.com/docs/whatsapp/api/messages/message-templates/media-message-templates)
* [Contacts message](https://developers.facebook.com/docs/whatsapp/api/messages/others#contacts-messages)
* [Location message](https://developers.facebook.com/docs/whatsapp/api/messages/others#location-messages)
* [Interactive Message](https://developers.facebook.com/docs/whatsapp/guides/interactive-messages)
