---
title: Create a Messages webhook server
description: Receive an inbound message with a webhook server
---

In this code snippet you learn how to handle an inbound message.

> **NOTE:** We recommend using [JWT-based auth](https://developer.vonage.com/concepts/guides/authentication#json-web-tokens) as this allows you to configure your inbound and delivery receipt webhook URLs at the [application-level](https://dashboard.nexmo.com/applications). Otherwise, all callbacks from your different applications will be sent to your [account-level webhook URLs](https://dashboard.nexmo.com/settings).

## Example

Ensure that your inbound message [webhook is set](/tasks/olympus/configure-webhooks) in the Dashboard.  As a minimum your handler must return a 200 status code to avoid unnecessary callback queuing. Make sure your webhook server is running before testing your Messages application.

```code_snippets
source: '_examples/messages/webhook-server'
```
