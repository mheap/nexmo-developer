---
title: Payments Over the Phone Now Supports Multi-Currency
description: Use the Vonage Voice API to take payments securely in multiple currencies.
thumbnail: /content/blog/payments-over-the-phone-now-supports-multi-currency/multi-currency-payment.png
author: abdul-ajetunmobi
published: true
published_at: 2022-01-11T10:51:44.213Z
updated_at: 2022-01-06T12:24:36.891Z
category: release
tags:
  - voice-api
  - payments
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
[Payments Over the Phone](https://developer.vonage.com/voice/voice-api/guides/payments) allows you to securely charge cards with the Vonage Voice API. The [Voice API](https://developer.vonage.com/client-sdk/overview) enables you to build voice applications, including the ability to record calls, create conference calls and text-to-speech messages in over 40 languages.

You can control the flow of calls with the Voice API using a [Call Control Object](https://developer.vonage.com/voice/voice-api/ncco-reference). Call Control Objects (NCCO) have different actions to allow you to control the flow of your calls. 

<youtube id="26rm0MP2up0"></youtube>

## The `Pay` Action

The `Pay` NCCO action collects card information using DTMF input, in a secure ([PCI-DSS compliant](https://www.pcisecuritystandards.org/pci_security/)) way.

Here is an example of an NCCO using the `Pay` action:

```json
[
  {
    "action": "pay",
    "amount": 9.99
  }
]
```

If you set your Voice API answer URL to return the above NCCO, you will hear prompts for entering card details and payment will be taken.

The payment currency is specified using the `currency` option. The default is USD, the [Payments Over the Phone guide](https://developer.vonage.com/voice/voice-api/guides/payments) has a list of the available currencies. Here is the same example NCCO, this time specifying a GBP currency:

```json
[
  {
    "action": "pay",
    "currency": "gbp",
    "amount": 9.99
  }
]
```

### Further Customization

You can further customize the `Pay` action using options. For example, you can set the Text to Speech voice using any of the [supported languages](https://developer.vonage.com/voice/voice-api/guides/text-to-speech#supported-languages):

```json
[
  {
    "action": "pay",
    "currency": "gbp",
    "amount": 9.99,
    "voice": {
       "language": "en-GB",
       "style": 0
    }
  }
]
```

Or even have [custom prompts](https://developer.vonage.com/voice/voice-api/guides/payments#custom-prompts) for entering card or errors completely.

## What Next?

Visit [developer.vonage.com](https://developer.vonage.com/) to learn more about the Voice API or the [Payments Over the Phone guide](https://developer.vonage.com/voice/voice-api/guides/payments) for information on how to get started accepting payments.