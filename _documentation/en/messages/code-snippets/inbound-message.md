---
title: Inbound Message Webhook
navigation_weight: 5
---

# Inbound Message Webhook

In this code snippet you learn how to receive an inbound message using the inbound message webhook.

> **NOTE:** By authenticating using [basic auth](https://developer.vonage.com/concepts/guides/authentication#basic-authentication), both the inbound SMS and delivery receipt callbacks are sent to your [account-level webhooks](https://dashboard.nexmo.com/settings).  [JWT-based auth](https://developer.vonage.com/concepts/guides/authentication#json-web-tokens), on the other hand, sends both callbacks to your [application-level webhooks](https://dashboard.nexmo.com/applications).

> **NOTE:** Messages API supports [signed webhooks](/concepts/guides/webhooks#decoding-signed-webhooks) so you can verify a request is coming from Vonage and its payload has not been tampered with during transit.

## Example

Ensure that your inbound message [webhook is set](/messages/code-snippets/configure-webhooks) in the Dashboard.  As a minimum your handler must return a 200 status code to avoid unnecessary callback queuing. Make sure your webhook server is running before testing your Messages application.

```code_snippets
source: '_examples/messages/inbound-message'
application:
  type: messages
  name: 'Inbound message'
```

## Try it out

The webhook is invoked on receipt of an [inbound message](/api/messages-olympus#inbound-message) and the message details and data are printed to the console.
