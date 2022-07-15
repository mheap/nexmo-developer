---
title: Payments over the Phone
description: Take payments during phone calls in a PCI compliant secure way
navigation_weight: 11
---

# Payments over the Phone [Developer Preview]

There are various scenarios when you may want to charge the user during the phone call, for example, automated order processing, subscription renewal, debt collection. To do that securely with credit cards, the application which deals with sensitive card data (numbers, expiration dates, security codes) must follow PCI compliance rules. Vonage Voice API provides you with the option to seamlessly embed secure payment processing into the call flow using the [NCCO](/voice/voice-api/guides/ncco) syntax.

> Payments over the Phone are currently offered as [Developer Preview](/product-lifecycle/dev-preview). The feature can be used in your projects for supported scenarios (see below). The following limitations apply:
<ul style='list-style:disc;margin-left:16px;margin-top:16px;'><li style='margin-bottom:16px;'>payment gateway configuration is being done by request,</li>
<li style='margin-bottom:16px;'>The `pay` action supported for inbound calls only</li>
<li style='margin-bottom:16px;'>Only Mastercard and Visa cards supported</li>
<li style='margin-bottom:16px;'>[Stripe](https://www.stripe.com) is the only supported payment gateway</li>
<li style='margin-bottom:16px;'>The feature is supported free of extra charge during Developer Preview.</li></ul>

## Preliminary Configuration

### Payment Gateway Configuration

To start, you should have your Stripe account ready. If you don't have an account yet, [sign up here](https://dashboard.stripe.com/register).

To enable payments with Stripe using Vonage, please login to the Vonage Customer Dashboard and proceed to the [Integrations section](https://dashboard.nexmo.com/integrations).

Insert picture here

In the integrations section select *stripe connect*

A popup should show asking you to provide a name for this integration. After defining the name press Connect with StripeConnect button.

After being redirected to Stripe's page, please go through all the necessary activation steps. Once finished return back to Vonage.


### Voice Application Configuration

Having completed the Payment Gateway integration, it is now necessary to enable a Vonage Application to use this integration.

If you don't have an Application

## Pay Action

To start the secure payment IVR, use the `pay` [NCCO action](/voice/voice-api/guides/ncco):

```json
[
  {
     "action": "pay",
     "amount": 9.99
  }
]
```

This will trigger the IVR flow with the following prompts:
- *Please enter your long card number*
- *Please enter your four-digit credit card expiration date*
- *Please enter your three-digit credit card security code*

In case the user enters the card data correctly, they will be charged $9.99, and your application will get the following callback:

```json
{
  from: '15551234567',
  to: '15557654321',
  type: 'payment',
  uuid: '041f4dffd9f4aa932512dd55e3abc123',
  conversation_uuid: 'CON-0e4a51ee-af50-41aa-bd2d-4e895edef456',
  status: 'success',
  timestamp: '2021-06-23T15:27:46.479Z'
}
```

and you will see the transaction in your [Stripe dashboard](https://dashboard.stripe.com/).

> In Developer Preview, `pay` action is only applicable for inbound calls and the first [leg of the conversation](/voice/voice-api/guides/legs-conversations) (the inbound one).

If the user doesn't enter the card number, expiration date, or security code within 10 seconds, the prompt will be played one more time giving the user another try. If the user enters any of the card information incorrectly or doesn't enter anything after the second prompt, the following callback is sent to the application:

```json
{
  from: '15551234567',
  to: '15557654321',
  type: 'payment',
  uuid: '041f4dffd9f4aa932512dd55e3abc123',
  conversation_uuid: 'CON-0e4a51ee-af50-41aa-bd2d-4e895edef456',
  status: 'failure',
  timestamp: '2021-06-23T15:27:46.479Z'
}
```

You can configure the following parameters of the `pay` action.

### Event URL

Similarly to other actions, you can set a custom URL for the `pay` action status event by using `eventUrl` parameter:

```json
[
  {
     "action": "pay",
     "amount": 9.99,
     "eventUrl": [ "https://www.example.com/webhooks/pay"]
  }
]
```

### Amount

Set the `amount` to be charged as in the sample above.

### Currency

US dollar is used as the currency by default. Use `currency` parameter to select the required one:

```json
[
  {
     "action": "pay",
     "amount": 9.99,
     "currency": "gbp",
     "eventUrl": [ "https://www.example.com/webhooks/pay"]
  }
]
```

Supported currencies:

 Code | Description 
------|------------
`aed` | United Arab Emirates dirham
`ars` | Argentine peso
`aud` | Australian dollar
`bgn` | Bulgarian lev
`brl` | Brazilian real
`cad` | Canadian dollar
`chf` | Swiss franc
`clp` | Chilean peso
`cop` | Colombian peso
`crc` | Costa Rican colon
`czk` | Czech koruna
`dkk` | Danish krone
`dop` | Dominican peso
`eur` | Euro
`gbp` | Pound sterling
`hkd` | Hong Kong dollar
`hrk` | Croatian kuna
`huf` | Hungarian forint
`idr` | Indonesian rupiah
`ils` | Israeli new shekel
`inr` | Indian rupee
`isk` | Icelandic króna
`jpy` | Japanese yen
`mxn` | Mexican peso
`myr` | Malaysian ringgit
`nok` | Norwegian krone
`nzd` | New Zealand dollar
`pen` | Peruvian sol
`pln` | Polish złoty
`ron` | Romanian leu
`sek` | Swedish krona
`sgd` | Singapore dollar
`thb` | Thai baht
`usd` | United States dollar
`uyu` | Uruguayan peso

### Text to Speech Voice
You can select any of the supported Text to Speech voices and languages by adding the following parameters:

```json
[
  {
     "action": "pay",
     "amount": 9.99,
     "voice": {
       "language": "en-US',
       "style": 3
     },
     
  }
]
```

> In Developer Preview, default prompts are in English, to use any language except for English, you should provide custom prompts (see below).

### Custom Prompts
You can change the default IVR prompts to custom ones, including the prompts playing in case of timeout. To do that, provide `prompts` structure in the `pay` action as follows:

```json
[
  {
    "action": "pay",
    "amount": 9.99,
    "prompts": [
      {
        "type": "CardNumber",
        "text": "Your custom prompt for card number",
        "errors": {
          "InvalidCardType": {
            "text": "The type of your credit card is not supported. Please try another one"
          },
          "InvalidCardNumber": {
            "text": "Invalid credit card number. Please try again"
          },
          "Timeout": {
            "text": "Please enter your long credit card number"
          }
        }
      },
      {
        "type": "ExpirationDate",
        "text": "Please enter expiry date",
        "errors": {
          "InvalidExpirationDate": {
            "text": "Invalid expiration date. Please try again"
          },
          "Timeout": {
            "text": "Please enter your 4-digit credit card expiration date"
          }
        }
      },
      {
        "type": "SecurityCode",
        "text": "Please enter CVV",
        "errors": {
          "InvalidSecurityCode": {
            "text": "Invalid security code. Please try again"
          },
          "Timeout": {
            "text": "Please enter your 3-digit credit card security code"
          }
        }
      }
    ]
  }
]
```

## Further Reading
* [NCCO Reference](/voice/voice-api/ncco-reference#pay),
* [Webhook Reference](/voice/voice-api/webhook-reference#payment),
* [Contact Center Intelligence](/voice/voice-api/guides/cci) Guide.

> We appreciate your feedback! Do you need more currencies, payment gateways, outbound calls or any other `pay` action improvements? Please drop us a note at [pay.voice@vonage.com](mailto:pay.voice@vonage.com)!
