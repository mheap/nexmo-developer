---
title: Webhooks
description: How to set and use webhook endpoints for the Vonage APIs.
navigation_weight: 5
---

# Webhooks

Webhooks are an extension of an API, but instead of your code requesting data from our API platform, Vonage sends the data to you. The data arrives in a web request to your application. A webhook may be the result of an earlier API call (this type of webhook is also called a "callback"), such as an asynchronous request to the Number Insight API. Webhooks are also used to notify your application of events such as an incoming call or message.

Since the Vonage servers need to be able to send data to your application via webhooks, you need to set up a webserver to receive the incoming HTTP requests. You also need to specify the URL of each webhook on your webserver so that data can be sent to each one.

## Webhooks workflow

With webhooks, it's important that the URL to send the webhooks to is configured. When there is data available, Vonage sends the webhook to your application as an HTTP request. Your application should respond with an HTTP success code to indicate that it successfully received the data.

The process looks something like this:

```sequence_diagram
Your App->>Vonage: Configure URL for webhook
Note over Your App, Vonage: Some time later ...
Vonage->>Your App: Sending some interesting data
Your App->>Vonage: 200 OK - I got it, thanks
```

Webhooks provide a convenient mechanism for Vonage to send information to your application for events such as an incoming call or message, or a change in call status. They can also be used to send follow-up information such as a delivery receipt which may become available some time after the request it relates to.

## Which APIs support webhooks?

Information resulting from requests to the SMS API, Voice API, Number Insight API, US Short Codes API, and Vonage virtual numbers are sent in an HTTP request to your webhook endpoint on an HTTP server. To configure your webhook endpoint, please visit the [Vonage dashboard](https://dashboard.nexmo.com/settings)

Vonage sends and retrieves the following information using webhooks:

| API Name                          | Webhooks usage                                                                                                                                                                                                                                                               |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SMS API                           | Sends the delivery status of your message and receives inbound SMS                                                                                                                                                                                                           |
| Voice API                         | Retrieves the [Nexmo Call Control Objects](/voice/voice-api/ncco-reference) you use to control the call from one webhook endpoint, and sends information about the call status to another. View the [Webhook Reference](/voice/voice-api/webhook-reference) for more detail. |
| Number Insight Advanced Async API | Receives complete information about a phone number                                                                                                                                                                                                                           |
| US Short Codes API                | Sends the delivery status of your message and receives inbound SMS                                                                                                                                                                                                           |
| Client SDK/Conversation API       | Real-time Communication (RTC) events are sent to the RTC event webhook                                                                                                                                                                                                       |
| Message and Dispatch APIs         | Supports both inbound message and message status webhooks                                                                                                                                                                                                                    |

## Setting webhook endpoints

```tabbed_content
source: '_examples/concepts/guides/webhooks-setup/'
```

## Receiving webhooks

To interact with Vonage webhooks:

1. Create a Vonage account.
2. Write scripts to handle the information sent or requested by Vonage. Your server must respond with a success status code (any status code between 200 OK and 205 Reset Content) to inbound messages from Vonage.
3. Publish your scripts by deploying to a server (for local development, try [Ngrok](https://ngrok.com/)).
4. [Configure a webhook endpoint](#setting-webhook-endpoints) in the API you would like to use.
5. Take an action (such as sending an SMS) that will trigger that webhook.

Information about your request is then sent to your webhook endpoint.

## Decoding signed webhooks

Signed webhooks are supported by Messages, Dispatch and Voice APIs and are enabled by default. They provide a method for your application to verify a request is coming from Vonage and its payload has not been tampered with during transit. When receiving a request, the incoming webhook will include a JWT token in the authorization header which is signed with your signature secret.

> **NOTE**: For previously created Voice applications, Signed Webhooks is off by default. To turn it on manually, go to the application settings in the Dashboard, click "Show advanced features" link in the Voice capability section and then turn on the **Use signed webhooks** check:
> 
> ![Voice Signed Webhooks](/images/concepts/guides/db_voice_signed_webhooks.png)
> 
> You can also turn it off for new application by this check (not recommended, use in exceptional cases only).

Validating signed webhooks provides a number of security benefits, including:

* The ability to verify a request originates from Vonage
* Ensuring that the message has not been tampered with while in transit
* Defending against interception and later replay

### Validating signed webhooks

There are two parts to validating signed webhooks:

1. Verifying the request
2. Verifying the payload (optional)

#### Verifying the request

Webhooks will include a JWT in the `Authorization` header. Use the API key included in the JWT claims to identify which of your signature secrets has been used to sign the request. The secret used to sign the request corresponds to the signature secret associated with the `api_key` included in the JWT claims. You can identify your signature secret on the [Dashboard](https://dashboard.nexmo.com/settings). It's recommended that signature secrets be no less than 32 bits to ensure their security.

> **NOTE**: The `signature method` drop down does not affect the method used for signing Messages API webhooks, SHA-256 is always used.

#### Verify the payload has not been tampered with in transit

Once you have verified the authenticity of the request, you may optionally verify the request payload has not been tampered with by comparing a SHA-256 hash of the payload to the `payload_hash` field found in the JWT claims. If they do not match, then the payload has been tampered with during transit. You only need to verify the payload if you are using HTTP rather than HTTPS, as Transport Layer Security (TLS) prevents [MITM attacks](https://en.wikipedia.org/wiki/Man-in-the-middle_attack).

> **NOTE:** In the rare case of an internal error, it is possible that the callback service will send an unsigned callback. By returning an HTTP 5xx response, a retry will be triggered giving the system time to resolve the error and sign future callbacks.

The code example below shows how to verify a webhook signature. It is recommended you use HTTPS protocol as it ensures that the request and response are encrypted on both the client and server ends.

```snippet_variables
- NEXMO_API_KEY
- NEXMO_SIG_SECRET

```

```code_snippets
source: '_examples/messages/signed-webhooks'
```

### Sample Signed JWT

```json
// header
{
  "alg": "HS256",
  "typ": "JWT",
}
// payload
{
  "iat": 1587494962,
  "jti": "c5ba8f24-1a14-4c10-bfdf-3fbe8ce511b5",
  "iss": "Vonage",
  "payload_hash" : "d6c0e74b5857df20e3b7e51b30c0c2a40ec73a77879b6f074ddc7a2317dd031b",
  "api_key": "a1b2c3d",
  "application_id": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab"
}
```

#### Signed JWT Header

The contents of the signed JWT header are described in the following table:

Header | Value
-- | --
`alg` | HS256
`typ` | JWT

#### Signed JWT Payload

The contents of the signed JWT payload are described in the following table, using the values included in the sample signed JWT shown previously:

Field | Example Value | Description
--- | --- | ---
`iat` |  `1587494962` | The time at which the JWT was issued. Unix timestamp in SECONDS.
`jti` | `c5ba8f24-1a14-4c10-bfdf-3fbe8ce511b5` | A unique ID for the JWT.
`iss` | `Vonage` | The issuer of the JWT. This will always be 'Vonage'.
`payload_hash` | `d6c0e74b5857df20e3b7e51b30c0c2a40ec73a77879b6f074ddc7a2317dd031b` | A SHA-256 hash of the request payload. Can be compared to the request payload to ensure it has not been tampered with during transit.
`api_key` | `a1b2c3d` | The API key associated with the account that made the original request.
`application_id` | `aaaaaaaa-bbbb-cccc-dddd-0123456789ab` | (Optional) The id of the application that made the original request if an application was used.


## Testing webhooks locally

In order to test the correct functioning of webhooks on your locally running application, you will need to create a secure tunnel between Vonage and your application. You can do this with a secure tunnel application such as [Ngrok](https://ngrok.com). See the [Testing with Ngrok](/tools/ngrok) topic for more information.

## Configuring your firewall

If you restrict inbound traffic (including delivery receipts), you need to add the Vonage IP addresses to your firewall's list of approved IP addresses. You can find more information how to do this in our knowledge base:

* [Voice IP Ranges](https://help.nexmo.com/hc/en-us/articles/115004859247)
* [SMS IP Ranges](https://help.nexmo.com/hc/en-us/articles/204015053)
* [Messages and Dispatch IP Ranges](https://help.nexmo.com/hc/en-us/articles/360035845911)

## Tips for debugging webhooks

**Start small** - Publish the smallest possible script that you can think of to respond when the webhook is received and perhaps print some debug information. This makes sure that the URL is what you think it is, and that you can see the output or logs of the application.

**Code defensively** - Inspect that data values exist and contain what you expected before you go ahead and use them. Depending on your setup, you could be open to receiving unexpected data so always bear this in mind.

**Look at examples** - Vonage provides examples implemented with several technology stacks in an attempt to support as many developers as possible. For example code using webhooks see the following:

* [Receive an SMS](/messaging/sms/code-snippets/receiving-an-sms)
* [Handle delivery receipts](/messaging/sms/guides/delivery-receipts)
* [Receive an incoming call](/voice/voice-api/code-snippets/receive-an-inbound-call)

You can also check the code snippets section of the documentation for the API you are using.

## See also

* More information on webhook types and application capabilities can be found in the [Application documentation](/application/overview).
