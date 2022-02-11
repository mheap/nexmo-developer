---
title: Forward a Telephone Call Via Voice Proxy with Python and Starlette
description: Learn how to create a voice proxy service in Python and Starlette
  to protect your user's privacy when making telephone call
thumbnail: /content/blog/forward-telephone-call-voice-proxy-python-starlette-dr/Forward-a-call-via-voice-proxy-with-python.png
author: aaron
published: true
published_at: 2019-08-09T15:13:23.000Z
updated_at: 2021-05-07T14:01:53.918Z
category: tutorial
tags:
  - python
  - voice-api
comments: true
redirect: ""
canonical: ""
---
There are a few situations where we might need a stranger to be able to call us, or for us to be able to call them. A delivery driver might need to call you about your package; you might need to call your taxi driver because you've forgotten your umbrella. In these situations, it is convenient to be able to call and speak to the actual person and not a call centre. However, neither person wants a stranger to have their private number.

With call forwarding, you can allow people to call each other without either party knowing the other's telephone number. Forwarding calls in this way is known as a voice proxy.

## Before You Start

There are a few things you need before you begin:

1. Python 3.6+. This example uses the asynchronous [Starlette](https://www.starlette.io/) framework, so a recent version of Python is a must.
2. If you're running the example in your local development environment, you need a way to expose it to the internet, such as by using [ngrok](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/).

<sign-up></sign-up>

## Download the Code

All the code for this example is available in the Nexmo Community organisation on Github. Clone the repository now:

```
git clone git@github.com:nexmo-community/nexmo-python-voiceproxy.git
cd nexmo-python-voiceproxy
```

Once you have cloned the repository, you should install its dependencies. I recommend that you always do this in a new virtual environment.

```
python -m venv nexmo-voiceproxy
source nexmo-voiceproxy/bin/activate
pip install -r requirements.txt
```

## Creating a Starlette Server

We provide instructions to the Nexmo Voice API using a [Nexmo Call Control Object (NCCO)](https://developer.nexmo.com/voice/voice-api/guides/ncco/python). The NCCO is a JSON file which contains a list of actions Nexmo should perform whenever a user calls a Nexmo Virtual Number. In this example, the NCCO has a single action, `connect`. The `connect` action enables us to connect the call to different endpoints. An endpoint could be another number, a WebSocket or a SIP endpoint. In this example, you use the `number` type. Forwarding a call to a different number in this way is not visible to the user.

```python
async def get(self, request):
    return JSONResponse(
        [
            {
                "action": "connect",
                "from": os.getenv("NEXMO_NUMBER_FROM"),
                "endpoint": [
                    {"type": "phone", "number": os.getenv("NEXMO_NUMBER_TO")}
                ],
            }
        ]
    )
```

The code above has two environment variables which you must supply. `NEXMO_NUMBER_FROM`, this is the telephone number which the user calls to initiate the proxy, it is also the number which the other user sees as the caller. This number must be a Nexmo Virtual Number; I'll explain how you can rent a Virtual Number and link it to your application later in the article.

`NEXMO_NUMBER_TO` is the telephone number of the user that receives the proxied call. This number can be any E.164 formatted telephone number.

## Voice API Events

You can track the status of your proxied call using the event webhook. Whenever there is a change in the status of the call Nexmo notifies you via a webhook. The information supplied to the webhook differs depending on the current status, you can find a complete list in the [Voice API documentation](https://developer.nexmo.com/voice/voice-api/webhook-reference).

In this example, the information is logged to the terminal so you can watch as the events occur in real-time. It is worth noting that you should always return a `200 OK` HTTP response to all Nexmo webhooks. If you do not return a `200 OK` response, the Nexmo API assumes there was an error, and after a short delay it retries the endpoint. To avoid multiple requests and duplicate data ensure you always return a `200 OK`. 

```python
async def post(self, request):
    event = await request.json()
    log.msg("Voice Proxy", **event)
    return PlainTextResponse()
```

By default, the Nexmo API requests the NCCO file via `GET` and notifies the event webhook using a `POST` request with a JSON body. You can change this in your application settings, but the code for this tutorial assumes that `GET` requests are for the NCCO, and `POST` requests are event notifications.

## Linking a Virtual Number to a Voice Application

The Nexmo API needs to be able to access your Starlette server. If you're running this example locally, you need to expose your server to the public internet. For more information on how to create a tunnel to localhost read our [blog post on ngrok](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/).

Ensure that you have your server running `python server.py` and then open a new terminal for `ngrok`:

```
ngrok http 8000
```

Now your proxy server is running and reachable by the Nexmo API, you can rent a Nexmo Virtual Number and create a new Voice Application using the [Nexmo dashboard](https://dashboard.nexmo.com/voice/create-application), or via the [Vonage CLI](https://github.com/Vonage/vonage-cli). You can find more information about how to install the Vonage CLI [here](https://learn.vonage.com/blog/2021/09/21/vonage-cli-is-v1-0-0/).

To do this via the CLI you need to run several commands:

```
vonage numbers:search [COUNTRYCODE]
vonage numbers:buy [NUMBER] [COUNTRYCODE]
vonage apps:create
vonage apps:link [APPLICATION_ID] --number=number
```

The commands above perform the following:

* Search for an available number with `COUNTRYCODE`. Pass in `GB` for British virtual numbers and `US`  for ones in the USA.
* Once you have found a suitable number you buy it using `vonage numbers:buy [NUMBER] [COUNTRYCODE]`
* When creating a new Voice Application run `vonage apps:create` and follow the prompts. You must supply a name for the application, the URL of your NCCO file, the URL of your events webhook, and a location to save your private key. The private key is used to authenticate with the Nexmo Voice API when making outbound calls. As this example only handles inbound calls, you do not need this private key this time.
* Finally, link the Virtual Number to your new application. Multiple numbers can be associated with a single application, for example, if you wanted to have different local numbers for users in different countries.

## Putting it All Together

Once you have a Virtual Number associated with your Voice Application and have your proxy server running and exposed to the public internet, you're ready to proxy your first call.

If you use a second device to phone the Nexmo Virtual Number associated with your application you can see the request for the NCCO in the Starlette terminal. 

When the call is proxied, and your other phone begins to ring check the number displayed for the caller. The number shown is not the telephone number of the phone which initiated the call, it is the Nexmo Virtual Number you specified as your `NEXMO_NUMBER_FROM` number. With a dozen lines of code, you've created an anonymous voice proxy!

## Further Reading

Call forwarding is only one of the many things you can do with the Nexmo Voice API. You should try connecting the call to a WebSocket, or [modify the events webhook to track statistics about your calls](https://www.nexmo.com/blog/2017/08/03/inbound-voice-call-campaign-tracking-dr). You could even do [real-time sentiment analysis of the call](https://www.youtube.com/watch?v=nFIj8RVy8Pg).

## Get in Touch

If you have any questions or comments about this post, or if you want to the first to know when we write something new or find some cool technology, then you follow us on Twitter: [@NexmoDev](https://twitter.com/nexmodev)