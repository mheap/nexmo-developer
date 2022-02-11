---
title: Using Message Signatures to Ensure Secure Incoming Webhooks
description: In this post you'll see why enabling message signing on your
  inbound webhooks can help protect against timing attacks or malicious incoming
  data.
thumbnail: /content/blog/using-message-signatures-to-ensure-secure-incoming-webhooks-dr/Secure-Webhooks.png
author: lornajane
published: true
published_at: 2019-06-28T07:01:04.000Z
updated_at: 2021-04-26T14:16:55.686Z
category: tutorial
tags:
  - sms-api
comments: true
redirect: ""
canonical: ""
---
One-way conversations are no fun - at Vonage we're all about two-way conversations and that includes our APIs. For example, to send an SMS you call our API. To receive an SMS reply, your application will need to handle an incoming webhook. Webhooks are brilliant for using HTTP to notify of events, but they require that your application be available on a public URL. The downside? Your public URL is, well, public. Anyone or anything could send data to it, and how will you be sure that the messages came from Vonage?

> ***Note:*** Using message signatures to verify incoming webhooks is currently only available on the Vonage SMS API.

This is a common problem with webhooks in all kinds of applications. At Vonage we recommend you enable [message signing](https://developer.nexmo.com/concepts/guides/signing-messages) on your account to ensure the security of incoming webhooks. This article will explain how the message signatures work and how to set this up for your own applications. The same approach is used in a few places but today's example shows it in the context of receiving an SMS, we've got some [code examples for receiving an SMS](https://developer.nexmo.com/messaging/sms/code-snippets/receiving-an-sms) if you're interested to see those before we dive in.

## Enable Message Signing

New Vonage accounts don't have the message signing enabled by default so your first stop is an email to `support@nexmo.com` requesting that message signatures be enabled on your account. There is a second option to require that all the messages you send also have a signature with them; we're not covering that usage today but it's worth knowing it is there.

## Get Your Signature Secret

Once you have the signing enabled, you'll want to visit the [settings page in your dashboard](https://dashboard.nexmo.com/settings). Here you can set which signature algorithm to use (I'm using the `SHA-256 HMAC` option in these examples), and you can access your signature secret. Copy this signature secret, it is the "shared secret" that we'll use to calculate signatures on both server and client.

> A "shared secret" is a key that is shared in advance between two parties, in this case between Vonage's servers and you. This shared secret is never transmitted but is used by both Vonage and your application to ensure that the data originates from the expected server and has not been changed in any way.

Also on this settings page is the option to change the HTTP verb for your webhooks to `POST`. The default is `GET` and the examples here use `GET` but if you'd like to change it (I prefer `POST` personally), that setting is here under "Default SMS Setting" -> "HTTP Method".

## Vonage Cooks Up a Signature

When an SMS arrives to your Vonage number, Vonage will send a webhook to the URL configured for that number containing all the information about the arriving message. With message signatures enabled, it also calculates a signature to send along with it.

You can read the [detailed manual steps for creating a signature](https://developer.nexmo.com/concepts/guides/signing-messages/php#manually-generate-a-signature) but the short version is:

* Get form fields in alphabetical order, concatenate them into a long string of keys and values
* Append the signature secret to the end
* Hash the string you've created according to the chosen algorithm, e.g. SHA-256 HMAC. Ta-da! This is the signature

> A hash is a textual representation of a (usually longer) string. It isn't possible from the hash to reverse-engineer the original string. We can safely transmit this hash (in this case, it's the message signature) without risk of revealing the string it was created from.

## Vonage Sends the Data and a Signature

With the signature created, then the webhook containing the message data and the signature but NOT the secret is sent to the URL you configured for this number. It looks something like this:

```
msisdn: 44784xxxxxxx
to: 44741xxxxxxx
messageId: 16000002632BEC99
text: Next step
type: text
keyword: NEXT
message-timestamp: 2019-01-23 10:51:39
timestamp: 1548240699
nonce: 9a706fdd-2b68-4761-87ab-c6ea80cab452
sig: 062470CA9A00C81FBF32FACE34B73D819BCDED07B36203DF7C0714E1094D86DE
```

We receive this data in our application, and we can use these and the signature secret we copied earlier to recreate the signature and check it against what arrived.

## Calculate the Expected Signature

From the data that was sent over, plus the signature secret, we can follow the same steps to create a signature and ensure that we get something that exactly matches. The manual process was outlined and linked above but our Server SDKs for your chosen tech stack will create the signature for you.

For example here is the [PHP library](https://github.com/Nexmo/nexmo-php) in action:

```php
    $signature = new \Nexmo\Client\Signature(
        $_GET,
        NEXMO_API_SIGNATURE_SECRET,
        'sha256'
    );
    $isValid = $signature->check($_GET['sig']);
```

The value of `$isValid` will indicate whether the signatures matched or not.

## Attacking Your Own Code

You can try a little light hacking by capturing requests to your local development platform [using Ngrok](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/), capture the data and try sending webhooks to your application using an HTTP Client such as Postman. If you change any field - the message, the phone number, the timestamp - the signature matching fails.

## Ensuring Secure Incoming Webhooks

In traditional web applications we have session/cookie information, CSRF tokens and other measures to protect us against malicious incoming data. Webhooks don't have the same context and so an approach like a shared secret with a message signature can protect against timing attacks and incoming data that has either been tampered with or originates somewhere other than Vonage's servers. In my experience, most "malicious" data is really just someone put the wrong URL in somewhere or something equally innocuous. Whether an attack or not, this still results in data that your application should not be processing.

Take the time to enable the signatures on your Vonage account and add the checking code, secure applications are happy applications :)

