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
<li style='margin-bottom:16px;'>US dollars are the only supported currency</li>
<li style='margin-bottom:16px;'>Only Mastercard and Visa cards supported</li>
<li style='margin-bottom:16px;'>[Stripe](https://www.stripe.com) is the only supported payment gateway</li>
<li style='margin-bottom:16px;'>The feature is supported free of extra charge during Developer Preview.</li></ul>

## Preliminary Configuration

### Payment Gateway Configuration

To start, you should have your Stripe account ready. If you don't have an account yet, [sign up here](https://dashboard.stripe.com/register).

> In [Developer Preview](/product-lifecycle/dev-preview), Vonage will set up your payment gateway connector for you. [Contact us](mailto:pay.voice@vonage.com) to get it configured. Once this is done, continue with the following steps.

To process payments with Voice API, activate direct card information processing on your Stripe account. To do that, go to [Stripe Dashboard Integration Settings](https://dashboard.stripe.com/settings/integration) and turn the **Handle card information directly** switch on. In the dialog appearing, check all the boxes and select "I collect payment information securely through a PCI compliant third party vendor":

![Integration](/images/voice-api/payments_integration.png)

### Voice Application Configuration

Your application should have Payments over the Phone capability enabled. 

#### Get Application

Retrieve your application data with a [Get an application](/api/application.v2#getApplication) HTTP request using [Postman](/tools/postman) or another HTTP client of your choice:

```http
GET https://api.nexmo.com/v2/applications/YOUR_APPLICATION_ID
```

Copy the response body:

```json
{
    "id": "YOUR_APPLICATION_ID",
    "name": "My app",
    "keys": {
        "public_key": "YOUR_PUBLIC_KEY"
    },
    "capabilities": {
        "voice": {
            "webhooks": {
                "event_url": {
                    "address": "https://example.com",
                    "http_method": "POST"
                },
                "fallback_answer_url": {
                    "address": "",
                    "http_method": "GET"
                },
                "answer_url": {
                    "address": "https://example.com",
                    "http_method": "GET"
                }
            }
        }
    },
    "_links": {
        "self": {
            "href": "/v2/applications/YOUR_APPLICATION_ID"
        }
    }
}
```

> Unlike Voice API, the Applications API uses [header-based API Key and Secret Authentication] (https://developer.nexmo.com/concepts/guides/authentication#header-based-api-key-and-secret-authentication), which means you should use a [Base64](https://tools.ietf.org/html/rfc4648#section-4) encoded API key and secret joined by a colon in the `Authorization` header of the HTTP request.

#### Update Application

Update your application with a [Update an application](https://developer.nexmo.com/api/application.v2#updateApplication) HTTP request:

```http
PUT https://api.nexmo.com/v2/applications/YOUR_APPLICATION_ID
```

Use the response JSON from the previous step as the request body with the addition of the `payment_enabled` parameter:

```json
{
    "id": "YOUR_APPLICATION_ID",
    "name": "My app",
    "keys": {
        "public_key": "YOUR_PUBLIC_KEY"
    },
    "capabilities": {
        "voice": {
            "webhooks": {
                "event_url": {
                    "address": "https://example.com",
                    "http_method": "POST"
                },
                "fallback_answer_url": {
                    "address": "",
                    "http_method": "GET"
                },
                "answer_url": {
                    "address": "https://example.com",
                    "http_method": "GET"
                }
            },
            "payment_enabled": true
        }
    },
    "_links": {
        "self": {
            "href": "/v2/applications/YOUR_APPLICATION_ID"
        }
    }
}
```

You can make a `GET` request from step one again to ensure the parameter is applied (it should be returned in the response).

> Developer Preview limitation: if you change any parameter of your application via [Dashboard](https://dashboard.nexmo.com), the `payment_enabled` parameter will be dropped, and the feature will be inactivated, so you have to go through the activation steps again to turn it back on.

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

Set the `amount` to be charged in US dollars as in the sample above.

> In Developer Preview, only US dollars supported. More to come soon.

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
* [Webhook Reference](/voice/voice-api/webhook-reference#pay),
* [Contact Center Intelligence](/voice/voice-api/guides/cci) Guide.

> We appreciate your feedback! Do you need more currencies, payment gateways, outbound calls or any other `pay` action improvements? Please drop us a note at [pay.voice@vonage.com](mailto:pay.voice@vonage.com)!
