---
title: Learn how to configure your webhooks 
description: Learn how to configure your webhooks to receive messages from your chosen channel
---

There are at least two webhooks you must configure:

* Message Status webhook
* Inbound Message webhook

When messages status updates are generated, such as `delivered`, `rejected` or `accepted`, callbacks will be received on the _Message Status_ webhook URL.

When an inbound message is received, a callback with message payload is invoked on the _Inbound Message_ webhook URL.

> **IMPORTANT:** Both webhook URLs should be configured. At the very least your webhook handlers should return 200 responses for both Inbound Message and Message Status callbacks.

### To configure the webhook URLs

In the [Dashboard](https://dashboard.nexmo.com), go to [Messages and Dispatch](https://dashboard.nexmo.com/messages/create-application).

> **TIP:** If the Webhook URLs for messages in your Vonage Account are already in production use and you would like a second one for using the Messages API, please email [support@nexmo.com](mailto:support@nexmo.com) and ask for a sub API Key.

Enter your Webhook URLs in the fields labeled **Status URL** and **Inbound URL**.

The values you enter for webhook URLs depends on where your webhook server is located, for example:

|Webhook | URL|
|---|---|
|Status URL | `https://www.example.com/webhooks/message-status`|
|Inbound URL | `https://www.example.com/webhooks/inbound-message`|

> **NOTE:** The default method of `POST` should be used for both of the webhook URLs.

### Inbound SMS webhooks

> **NOTE:** We recommend using [JWT-based auth](https://developer.vonage.com/concepts/guides/authentication#json-web-tokens) as this allows you to configure your inbound and delivery receipt webhook URLs at the [application-level](https://dashboard.nexmo.com/applications). Otherwise, all callbacks from your different applications will be sent to your [account-level webhook URLs](https://dashboard.nexmo.com/settings).

### Webhook queue

Please note that webhooks emanating from Vonage, such as those on your Message Status webhook URL and Inbound Message URL, are queued by Vonage on a per-message basis.

Please ensure that all applications acknowledge webhooks with a 200 response.

### Signed webhooks

In order to validate the origin of your webhooks, you can validate the signature of the webhooks, see instructions [here](/concepts/guides/webhooks#decoding-signed-webhooks)
