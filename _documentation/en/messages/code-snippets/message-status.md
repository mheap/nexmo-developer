---
title: Message Status Webhook
navigation_weight: 6
---

# Message Status Webhook

In this code snippet you learn how to receive message status updates using the message status webhook.

> **NOTE:** By authenticating using [basic auth](https://developer.vonage.com/concepts/guides/authentication#basic-authentication), the message status callback is sent to your [account-level webhooks](https://dashboard.nexmo.com/settings).  [JWT-based auth](https://developer.vonage.com/concepts/guides/authentication#json-web-tokens), on the other hand, sends the callback to your [application-level webhooks](https://dashboard.nexmo.com/applications).

> **NOTE:** Messages API supports [signed webhooks](/concepts/guides/webhooks#decoding-signed-webhooks) so you can verify a request is coming from Vonage and its payload has not been tampered with during transit.

## Example

Ensure that your message status [webhook is set](/messages/code-snippets/configure-webhooks) in the Dashboard. As a minimum your handler must return a 200 status code to avoid unnecessary callback queuing. Make sure your webhook server is running before testing your Messages application.

```code_snippets
source: '_examples/messages/message-status'
application:
  type: messages
  name: 'Message status'
```

## Try it out

The webhook is invoked on a change in status for an outbound message sent from Vonage. The message status is also printed to the console.

The format of the message status `POST` request can be found in the [Message Status](/api/messages-olympus#message-status) section of the [API reference](/api/messages-olympus#overview).
