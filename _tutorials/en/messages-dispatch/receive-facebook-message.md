---
title: Receive a Facebook message 
description: In this step you learn how to receive a Facebook message.
---

# Receive a Facebook message

First make sure your webhook server is running. It should correctly handle **both** [inbound message callbacks](/messages/code-snippets/inbound-message) and [message status callbacks](/messages/code-snippets/message-status)  returning at least a `200` to acknowledge each callback. You will need to have this in place so you can obtain the PSID of the Facebook User sending the inbound message. Once you have this you will be able to reply.

When a Facebook message is sent by a Facebook User to your Facebook Page a callback will be sent to your Inbound Message Webhook URL. An example callback is shown here:

```json
{
  "channel": "messenger",
  "message_uuid": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "to": "'$FB_RECIPIENT_ID'",
  "from": "'$FB_SENDER_ID'",
  "timestamp": "2020-01-01 14:00:00 UTC",
  "message_type": "text",
  "text": "Nexmo Verification code: 12345. Valid for 10 minutes."
}
```

You need to extract the `from` value here as this is the ID that you need to send a reply.
