---
title: Announcing Vonage Messages API Version 1.0
description: Version 1.0 of the Vonage Messages API is now live. This version
  brings a simpler API design and a number of new features.
thumbnail: /content/blog/announcing-vonage-messages-api-version-1-0/blog_sdk-updates_1200x600.png
author: karl-lingiah
published: true
published_at: 2021-11-16T10:29:05.677Z
updated_at: 2021-11-15T14:44:02.300Z
category: release
tags:
  - messages-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
We're excited to announce that, as of November 10th 2021, Version 1 of the [Vonage Messages API](https://developer.vonage.com/messages/overview) is now live! The Messages API as a whole is currently still in beta, but v1 brings some significant improvements in terms of simplifying interactions with the API, as well adding a number of exciting new features.

## What's New In v1?

### Cleaner API Design

A major difference in [v1](https://developer.vonage.com/api/messages-olympus), when compared with [v0.1](https://developer.vonage.com/api/messages-olympus.v0), is a much cleaner and flatter API design, This can be observed in the structure of the request data for calls to the API endpoint as well as in callbacks to webhooks. Below is a comparison of the data payload required to send an SMS message in both versions.

**Version 0.1**

```json
{
  "to": {
    "type": "sms",
    "number": "447700900000"
  },
  "from": {
    "type": "sms",
    "number": "447700900001"
  },
  "message": {
    "content": {
      "type": "text",
      "text": "Hello From Vonage!"
    }
  }
}
```

**Version 1**

```json
{
  "to": "447700900000",
  "from": "447700900001",
  "channel": "sms",
  "message_type": "text",
  "text": "Hello From Vonage!"
}
```

### Additional Features

Version 1 also brings a number of [new features](https://developer.vonage.com/messages/overview#additional-v1-features) to the WhatsApp channel, such as Reply Context, Profile Name, and Provider Messages.

Another new WhatsApp feature is Interactive Messages. This feature lets you implement List Messages and Reply Buttons in a WhatsApp chat.

**List Message Example**

![Mock-up of a WhatsApp List Message, displaying five account management options](/content/blog/announcing-vonage-messages-api-version-1-0/list-messages-whatsapp.png "WhatsApp List Message mock-up")

**Reply Button Example**

![Mock-up of a WhatsApp Reply Button displaying three payment options](/content/blog/announcing-vonage-messages-api-version-1-0/reply-buttons-whatsapp.png "WhatsApp Reply Button mock-up")

## Migrating to v1

If you are already using Message API v0.1 and are thinking of migrating to v1, our [migration guide](https://developer.vonage.com/messages/concepts/migration-guide) outlines a number of things to be aware of.