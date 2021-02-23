---
title: Fraud Prevention
description: Learn basic voice calling fraud prevention practices
navigation_weight: 10
---

# Fraud Prevention

Like in other businesses, there are people and companies trying to profit unfairly in the world of telephony communications. Vonage undertakes a series of automatic and manual actions and processes to protect you from fraud activities. Still, there are certain practices that, if followed, may help you avoid business impact and potential losses.

Typical fraud schemes are based on the generation of outbound calls to specific phone numbers known as "premium destinations" or "revenue shared numbers", so that the fraudsters get money for each second of the call. To do that, fraudsters should either know your API key and secret or use your service UI/API, which allows end-users to enter the destination phone number. Typical services that require this phone number input include a login or reset password page that uses two-factor authentication with a voice call. Follow the instruction provided below to reduce the risk of being affected by these types of schemes.

## Credentials Rotation

If you have any suspicions that your dashboard credentials or API key/secret were compromised, update it as soon as possible. You can change your password in the Dashboard [Edit profile](https://dashboard.nexmo.com/edit-profile) page and request a new API secret on the [Settings](https://dashboard.nexmo.com/settings) page. See also [Best Security Practices for your Vonage Account](https://help.nexmo.com/hc/en-us/articles/115014939548).

## Destinations Filtering

If your business operates in certain countries, you may restrict the destination number to those countries. Alternatively, you may restrict an entire destination, blocking the following country numbers, which are often used for fraud activities:

* Congo
* Gambia
* Guinea
* Haiti
* Ivory Coast
* Latvia
* Liberia
* Samoa
* the Solomon Islands
* Vanuatu

> Vonage equally respects all countries and nations; the hint above is based on our statistical data only.

In order to allow/block destinations, you may check the destination number (`from`) before performing a Vonage API request for an outbound call creation (`POST /calls` request or `connect` NCCO action) either by:

* first digits in the number - check if it falls under your allowed/blocked destinations,
* destination country using Number Insights API,

and return an appropriate message if the destination is not supported by your service.

Assuming you want to allow calls to, for example, the United States and Canada only, with the first approach, you can use this construction in JavaScript:

```js
if (phoneNumber.startsWith('1'))
{
    vonage.calls.create({ // ...
    })
} else {
    alert("Sorry, the destination is not supported.")
}
```

With its comparable simplicity, the drawback here is that, for the example above, `+1` phone country code corresponds not only to the US and Canada but a few other countries/regions which might be outside of your case relevant destinations, for example, the Bahamas or Antigua and Barbuda. To do a more precise check, it's recommended to use basic Number Insights API to check the destination country:

```js
vonage.numberInsight.get({level: 'basic', number: phoneNumber}, (error, result) => {
  if (result.country_code == 'US' || result.country_code == 'CA') {
    vonage.calls.create({ // ...
    })
  } else {
    alert('Sorry, the destination is not supported.')
  }
})

```

See also [Number Insight Basic](/number-insight/code-snippets/number-insight-basic) code snippet.

## Webhook Origination Checking

Other types of attacks might target getting access to your application or customer private data. In this type of attack, a fraudster impersonates Vonage and makes webhook requests to your application similar to Vonage API callbacks, in order to receive valuable information, for example, the text of the voice message you deliver potentially including some Personally Identifiable Information. To make sure the webhook requests to your application are coming from Vonage, you may:

* setup a firewall to accept requests from [Vonage IP ranges](https://help.nexmo.com/hc/en-us/articles/115004859247-Which-IP-addresses-should-I-whitelist-in-order-to-receive-voice-traffic-from-Nexmo-) only;
* check [callback signature](/voice/voice-api/guides/signed-webhooks).
