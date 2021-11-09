---
title: WhatsApp v0.1 to v1 Migration Guide
navigation_weight: 3
description: Differences to be aware of between the two versions of the API if migrating to v1
---

# WhatsApp v0.1 to v1 Migration Guide

There are currently two versions of the Messages API: **v0.1** and **v1**. While v1 supports all of the features of v0.1, there are some significant differences between the two versions which should be borne in mind if you are already using v0.1 of the API and are planning on migrating to v1.

## JSON Schema

One of the most important differences between the two versions is the schema used for the JSON data in requests to the API and for incoming webhook data; v1 provides a simplified, flatter structure. In order for your application to work with v1, it will be necessary to change any code that generates or references the JSON data.

Some of the differences between the two structures include:

- `to` and `from` are single value nodes instead of an object
- The messaging `channel` only needs to be specified once instead of being specified as a `type` in `to` and `from`
- The `message` object has been replaced by a `message_type`, and a single value node with the content type implied by the label e.g. `"text": "this is a text"`

**Examples**

Outgoing WhatsApp text V0.1

```json
{
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
      "type": "text",
      "text": "Hello From Vonage!"
    }
  }
}
```

Outgoing WhatsApp text V1

```json
{
  "message_type": "text",
  "text": "Hello From Vonage!",
  "to": "447700900000",
  "from": "447700900001",
  "channel": "whatsapp"
}
```

Incoming WhatsApp text webhook v0.1

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
      "type": "text",
      "text": "Hello From Vonage!"
    }
  }
}
```

Incoming WhatsApp text webhook v1

```json
{
  "channel": "whatsapp",
  "message_uuid": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "to": "447700900000",
  "from": "447700900001",
  "timestamp": "2020-01-01 14:00:00 UTC",
  "message_type": "text",
  "text": "Nexmo Verification code: 12345. Valid for 10 minutes.",
  "profile": {
    "name": "Jane Smith"
  },
  "context": {
    "message_uuid": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
    "message_from": "447700900000"
  }
}
```

The above are a few examples. Check the [specification](/api/messages) for a comprehensive set of fields for the various message types and webhooks.

## Use of Vonage Applications for Webhooks

If you use [webhooks](/messages/code-snippets/configure-webhooks), for v1 these must be configured within a [Vonage Application](/application/overview). Additionally, the Application must be set to use v1 as the version.

A basic workflow for setting this up via the [Dashboard](https://dashboard.nexmo.com/) would be as follows:

1. Create a new application under Your applications (providing it with an appropriate name, etc)
2. Under Capabilities, enable Messages
3. Enabling Messages should expose fields for inbound and status webhooks. Set the inbound webhook to the URL where you want to receive the callbacks for the WhatsApp Interactive Messages.
4. Set the Messages API version to v1 using the drop-down menu
5. Click on Generate new application

## Use of JWTs for Authentication if using a Vonage Applications

If you are setting up a Vonage Application, an important thing to be aware of is that Vonage Applications mandate the usage of JWT (JSON Web Tokens) to authenticate requests to the API. In other words, HTTP Basic authentication is not an option in this situation. [Read more about JWTs](/concepts/guides/authentication#json-web-tokens-jwt).

## Additional Features

One reason that you might wish to migrate to v1 if you are currently using v1, is to take advantage of some of the [additional features](/messages/overview#additional-v1-features) that v1 offers, for example [WhatsApp Interactive Messages](/messages/concepts/whatsapp-interactive-messages).
