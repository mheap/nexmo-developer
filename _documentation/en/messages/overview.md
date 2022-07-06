---
title: Overview
meta_title: Send messages via SMS, MMS, WhatsApp, Viber and Facebook Messenger with a single API.
description: The Messages API allows you to send and in some cases receive messages over SMS/MMS, Facebook Messenger, Viber, WhatsApp.
navigation_weight: 1
---

# Messages API Overview

The Messages API allows you to send and in some cases receive messages over SMS, MMS, Facebook Messenger, Viber, and WhatsApp. Further channels may be supported in the future.

> Note: Major US carriers have announced their requirements for a new standard for application-to-person (A2P) messaging in the USA, which applies to all messaging over 10-digit geographic phone numbers, also known as 10 DLC. If you are or are planning to send SMS/MMS traffic from a +1 Country Code 10 Digit Long Code into US networks, you will need to register a brand and campaign in order to get approval for sending messages. See the [10 DLC documentation](10-dlc/overview.md) for details.

The following diagram illustrates how the Vonage Messages API enables you to send messages via multiple channels from a single endpoint:

<img src="/images/messages-overview.png" alt="Messages and Dispatch Overview" style="width: 75%;">

## Contents

* [Versions](#versions)
* [Supported features](#supported-features)
* [External Accounts API](#external-accounts-api)
* [Getting started](#getting-started)
* [Concepts](#concepts)
* [Code Snippets](#code-snippets)
* [Tutorials](#tutorials)
* [Use Cases](#use-cases)
* [Reference](#reference)

## Versions

There are currently two versions of the API, v0.1 and v1. Each version has its own API endpoint:

- **v1**: `https://api.nexmo.com/v1/messages`
- **v0.1**: `https://api.nexmo.com/v0.1/messages`

One of the primary differences between the two versions is that v1 provides a much simpler and flatter structure for the JSON structure used in the request and response data. Check the relevant [API specification](/api/messages-olympus) for details of the required structure.

> **NOTE:** Most of the code examples in this documentation (other than examples for the Node SDK) use the structure for v1 of the API.

As well as the difference in JSON structure, v1 supports some [additional features](#additional-v1-features).

We recommend using v1 of the API. If you are using v0.1 of the API, and are intending to move to v1, check our [Migration Guide](/messages/concepts/migration-guide).

## Supported features

The following features are supported in both v0.1 and v1 versions of the API:

Channel | Outbound Text | Outbound Image | Outbound Audio | Outbound Video | Outbound File | Outbound Template
:--- | :---: | :---: | :---: | :---: | :---: | :---:
SMS | ✅ | n/a | n/a | n/a | n/a | n/a
MMS | ✅ | ✅ | n/a | n/a | n/a | n/a
Viber Business Messages | ✅ | ✅ | n/a | n/a | n/a | ✅
Facebook Messenger | ✅ | ✅ | ✅ | ✅ | ✅ | ✅
WhatsApp | ✅ | ✅ | ✅ | ✅ | ✅ | ✅

Channel | Inbound Text | Inbound Image | Inbound Audio | Inbound Video | Inbound File | Inbound Location
:--- | :---: | :---: | :---: | :---: | :---: | :---:
SMS | ✅ | n/a | n/a | n/a | n/a | n/a
MMS | ✅ | ✅ | n/a | n/a | n/a | n/a
Viber Business Messages | ✅ | n/a | n/a | n/a | n/a | n/a
Facebook Messenger | ✅ | ✅ | ✅ | ✅ | ✅ | ✅
WhatsApp | ✅ | ✅ | ✅ | ✅ | ✅ | ✅

Limited support is also provided for [custom objects](/messages/concepts/custom-objects):

Channel | Outbound Button | Outbound Location | Outbound Contact
:--- | :---: | :---: | :---:
SMS | n/a | n/a | n/a
MMS | n/a | n/a | n/a
Viber Business Messages | ✅ | n/a | n/a
Facebook Messenger | ✅ | n/a | n/a
WhatsApp | ✅ | ✅ | ✅

**Key:**

* ✅ = Supported.
* ❌ = Supported by the channel, but not by Vonage.
* n/a = Not supported by the channel.

### Additional v1 Features

As well as all of the existing features from v0.1, there are some additional features supported in v1 of the API.

- **WhatsApp Interactive Messages**: v1 of the Messages API, supports WhatsApp's interactive message feature. See our [overview](/messages/concepts/whatsapp-interactive-messages) of this feature. Once you're ready to start working with interactive messages, read our [more detailed explanation](/messages/concepts/working-with-whatsapp-interactive-messages).

- **WhatsApp Reply Context**: in v1 of the Messages API, the callbacks to the inbound messages webhooks can provide a [reply context](https://developers.facebook.com/docs/whatsapp/api/webhooks/components#quick_reply).

- **WhatsApp Profile Name**: in v1 of the Messages API, the callbacks to the inbound messages webhooks can provide [profile name](https://developers.facebook.com/docs/whatsapp/api/webhooks/components#profile).

- **Provider messages**: in v1 of the Messages API, the callbacks to the inbound messages webhooks can provide [error messages from WhatsApp](https://developers.facebook.com/docs/whatsapp/api/webhooks/components#errors-object) under a new `provider_message` field.

## External Accounts API

The [External Accounts API](/api/external-accounts) is used to manage your accounts for Viber Business Messages, Facebook Messenger and WhatsApp when using those channels with the Messages and Dispatch APIs.

## Getting started

In this example you will need to replace the following variables with actual values using any convenient method:

Key | Description
-- | --
`VONAGE_API_KEY` | Vonage API key which can be obtained from your [Vonage API Dashboard](https://dashboard.nexmo.com).
`VONAGE_API_SECRET` | Vonage API secret which can be obtained from your [Vonage API Dashboard](https://dashboard.nexmo.com).
`FROM_NUMBER` | A phone number you own or some text to identify the sender.
`TO_NUMBER` | The number of the phone to which the message will be sent.

> **NOTE:** Don't use a leading `+` or `00` when entering a phone number, start with the country code, for example 447700900000.

The following code shows how to send an SMS message using the Messages API:

```code_snippets
source: '_examples/messages/sms/send-sms-basic-auth'
```

## Concepts

```concept_list
product: messages
```

## Code Snippets

```code_snippet_list
product: messages
```

## Tutorials

* [How to send an SMS message](/messages/tutorials/send-sms-with-messages/introduction)
* [How to send a Viber message](/messages/tutorials/send-viber-message/introduction)
* [How to send a WhatsApp message](/messages/tutorials/send-whatsapp-message/introduction)
* [How to send a Facebook Messenger message](/messages/tutorials/send-fbm-message/introduction)

## Use Cases

```use_cases
product: messages
```

## Reference

* [Messages API Reference](/api/messages-olympus)
* [External Accounts API Reference](/api/external-accounts)
