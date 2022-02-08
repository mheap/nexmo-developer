---
title: Voice Security Improvements
description: Learn about the improvements of security being implemented to
  Vonage's Voice APIs. Covering Secure Real-Time Transfer, Signed Callbacks, and
  HTTPS Caching
thumbnail: /content/blog/voice-security-improvements/voice-security_1200x600.png
author: victorshisterov
published: true
published_at: 2021-06-17T09:28:22.669Z
updated_at: 2021-06-11T08:47:46.154Z
category: announcement
tags:
  - voice-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
At Vonage, we’re constantly improving our APIs, with security being one of the essential aspects. In this short article, we’ll cover significant improvements we have delivered recently.

## Secure Real-Time Transfer

The Secure Real-time Transfer Protocol (SRTP) is an Internet Engineering Task Force (IETF) standard for the secure transmission of real-time media, such as voice in a Voice over IP (VoIP) call.

SRTP allows you to use our SIP products and ensure that the media exchanged between your SIP endpoints and Vonage’s platform is encrypted, securing its contents from malicious intents.
The use of SRTP should be paired up with the already existing SIP over TLS feature to provide security both in the signaling and media exchanges.

## Signed Callbacks

[Signed callbacks](https://developer.nexmo.com/messages/concepts/signed-webhooks) (also known as "webhooks") allow you to check the JWT ([JSON Web Token](https://jwt.io/)) signature of the incoming requests to make sure it's sent from Vonage specifically to your application. The feature was already available as Developer Preview with a limited set of events supported. As of now, all the Voice API webhooks, including the Answer URL, are fully supported. The Beta stage requires an API request to Applications API to be activated for your Voice app; see [the guide](https://developer.vonage.com/voice/voice-api/guides/signed-webhooks#activation) to learn how to do that. On July 19th, the feature will become generally available and turned on automatically for all accounts and applications.

## HTTPS Caching

Voice API supports playing prerecorded audio during the call with [stream](https://developer.vonage.com/voice/voice-api/ncco-reference#stream) action. For some use-cases, when the same audio file is being used multiple times, it's feasible to instruct Vonage to cache the file (with standard HTTP Cache-Control header). Caching was only available for HTTP URLs; recently, we have improved to support HTTPS caching, so now you don't have to compromise between performance and security. In conclusion, Vonage is continuously working to provide secure interfaces for all of them, no matter which Vonage APIs or products you are using. Our objective here at Vonage is to ensure that your user's private data will remain private.

## Further Reading

* [Vonage SIP Documentation](https://developer.nexmo.com/voice/sip/overview)
* [Voice API Signed Callbacks Guide](https://developer.vonage.com/voice/voice-api/guides/signed-webhooks#activation)
* [Fraud Prevention Guide](https://developer.vonage.com/voice/voice-api/guides/fraud-prevention)
* [Build High Availability Voice API Applications](https://learn.vonage.com/blog/2020/12/09/build-high-availability-voice-api-applications/)

