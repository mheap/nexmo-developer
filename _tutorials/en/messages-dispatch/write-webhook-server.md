---
title: Create a Messages webhook server
description: Receive an inbound message with a webhook server
---

In this code snippet you learn how to handle an inbound message.

> **NOTE:** By authenticating using [basic auth](https://developer.vonage.com/concepts/guides/authentication#basic-authentication), both the inbound SMS and delivery receipt callbacks are sent to your [account-level webhooks](https://dashboard.nexmo.com/settings).  [JWT](https://developer.vonage.com/concepts/guides/authentication#json-web-tokens), on the other hand, sends both callbacks to your [application-level webhooks](https://dashboard.nexmo.com/applications).

## Example

Ensure that your inbound message [webhook is set](/tasks/olympus/configure-webhooks) in the Dashboard.  As a minimum your handler must return a 200 status code to avoid unnecessary callback queuing. Make sure your webhook server is running before testing your Messages application.

```code_snippets
source: '_examples/messages/webhook-server'
```
