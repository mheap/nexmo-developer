---
title: Fraud Prevention
description: Protect your Voice API applications from fraud
navigation_weight: 10
---

# Fraud Prevention

Like in other businesses, there are people and companies trying to profit unfairly in the world of telephony communications. Vonage undertakes a series of automatic and manual actions and processes to protect you from fraud activities. Still, there are certain practices that, if followed, may help you avoid business impact and potential losses.

Typical fraud schemes are based on the generation of outbound calls to specific phone numbers known as "premium destinations" or "revenue shared numbers", so that the fraudsters get money for each second of the call. To do that, fraudsters should either know your API key and secret or use your service UI/API, which allows end-users to enter the destination phone number. Typical services that require this phone number input include a login or reset password page that uses two-factor authentication with a voice call. Follow the instruction provided below to reduce the risk of being affected by these types of schemes.

## Credentials Rotation

If you have any suspicions that your dashboard credentials or API key/secret have been compromised, update them as soon as possible. You can change your password in the Dashboard [Edit profile](https://dashboard.nexmo.com/edit-profile) page and request a new API secret on the [Settings](https://dashboard.nexmo.com/settings) page. See also [Best Security Practices for your Vonage Account](https://help.nexmo.com/hc/en-us/articles/115014939548).

## Destinations Filtering

If your business only operates in certain countries, you might choose to create an "allow list" to restrict calls to those countries. Alternatively, you can create a "block list" that allows calls to be made anywhere except to those countries in the list.

Some users elect to prevent calls from being placed to countries that are perceived as being high risk. These include:

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

The flaw with this approach is that the `+1` phone country code allows calls not only to the US and Canada but also, for example, the Bahamas or Antigua and Barbuda, which might not be your intention. You can target countries more precisely by using the Number Insight API:

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

Other types of attacks might attempt to gain access to your application or your customers' private data. In these attacks, a fraudster impersonates the Vonage Platform by making webhook requests to your application. These can reveal the voice message text which could contain sensitive data. To ensure that requests to your webhooks are from Vonage, you can:

* Setup a firewall to accept requests from [Vonage IP ranges](https://help.nexmo.com/hc/en-us/articles/115004859247-Which-IP-addresses-should-I-whitelist-in-order-to-receive-voice-traffic-from-Nexmo-) only;
* Check [callback signature](/voice/voice-api/guides/signed-webhooks).
