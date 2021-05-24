---
title: WebSockets
description: You can connect the audio of a call to a WebSocket to work with it in real time.
navigation_weight: 7
---

# WebSockets

This guide introduces you to WebSockets and how and why you might want to use them in your Vonage Voice API applications.

> For sample applications and AI connectors, see [further reading](#further-reading).


## What is a WebSocket?

WebSockets is a computer communications [protocol](https://tools.ietf.org/html/rfc6455) that enables two-way communication over a single, persistent TCP connection without the overhead of the HTTP request/response model.

Using Vonage’s Voice API, you can connect phone calls to WebSocket endpoints. This means that any application that hosts a WebSocket server can be a participant in a Vonage voice conversation. It can receive raw audio from and play audio into the call in real time.

This enables some really innovative use cases, such as:

* Recording, transcribing or otherwise analyzing calls using third party solutions. For example: performing [sentiment analysis](https://learn.vonage.com/blog/2021/05/17/processing-voice-calls-with-amazon-transcribe-comprehend/) in call centers to determine customer satisfaction.
* Automating calls with bots to perform tasks such as [food ordering](https://www.vonage.com/resources/customers/novo-labs/) or requesting information from field experts.
* Including [artificial intelligence](/voice/voice-api/guides/cci) engines in conference calls to enable better decision making.

## Working with WebSockets

The WebSocket is an endpoint in the same way that a phone or SIP address is. This means it is a participant in your call and not a passive monitor like a recording. If you connect a WebSocket to a conference call, or a third-party in a 1-1 call, the audio it receives is a mix of all the audio in the call. It is not possible to receive a single leg of the conversation via the WebSocket.

The Vonage Voice API acts as the client when establishing the WebSocket connection. As the application developer you need to make a compatible server available to:

* Return an NCCO instructing Vonage to connect to your WebSocket endpoint
* Accept this WebSocket connection
* Handle JSON text-based protocol messages
* Handle mixed call audio binary messages

## Connecting to a WebSocket

To instruct Vonage to connect to a WebSocket your application server must return an [NCCO](/voice/voice-api/guides/ncco) when requested from your Vonage Application's [answer_url](/voice/voice-api/guides/call-flow#answer-url-payload). In order to do this the NCCO must contain a `connect` action with an `endpoint.type` of `websocket`. For example:

``` json
[
    {
       "action": "connect",
       "endpoint": [
           {
                "type": "websocket",
                "uri": "wss://example.com/socket",
                "content-type": "audio/l16;rate=16000",
                "headers": {
                    "language": "en-GB",                    
                    "caller-id": "447700900123"
                }
           }
       ]
     }
]
```

The specific data fields for webhooks are the following:

Field | Example | Description
 -- | -- | --
`uri` | `wss://example.com/socket` | The endpoint of your WebSocket server that Vonage will connect to
`content-type` | `audio/l16;rate=16000` | A string representing the audio sampling rate, either `audio/l16;rate=16000` or `audio/l16;rate=8000`. Most real-time transcription services work best with audio at 8kHz.
`headers` | `{ 'language': 'en-GB', 'caller-id': '447700900123' }` | An object of key/value pairs with additional optional properties to send to your Websocket server, with a maximum length of 512 bytes.

You can find all the data fields for an NCCO at the [NCCO Reference Guide](/voice/voice-api/ncco-reference).

## Handling incoming WebSocket messages

### First message

The initial message sent on an established WebSocket connection will be text-based and contain a JSON payload, it will have the `event` field set to `websocket:connected` and detail the audio format in `content-type`, along with any other metadata that you have put in the `headers` property of the WebSocket endpoint in your NCCO `connect` action. The `headers` property is not present on the JSON payload so the properties are at the top-level of the JSON. For example:

``` json
{
    "event":"websocket:connected",
    "content-type":"audio/l16;rate=16000",
    "prop1": "value1",
    "prop2": "value2"
}
```

Consider the following `connect` action example:

``` json
[
    {
       "action": "connect",
       "endpoint": [
           {
              "type": "websocket",
              "uri": "wss://example.com/socket",
              "content-type": "audio/l16;rate=16000", 
              "headers": {
                 "language": "en-GB",
                 "caller-id": "447700900123"
              }
           }
       ]
     }
]
```

This results in the following JSON in the first message on the WebSocket:

``` json
{
    "event":"websocket:connected",
    "content-type":"audio/l16;rate=16000",
    "language": "en-GB",
    "caller-id": "447700900123"
}
```
After the initial text message subsequent messages on the WebSocket can be text or binary.

### Binary audio messages

Messages that are binary represent the audio of the call. The audio codec presently supported on the WebSocket interface is Linear PCM 16-bit, with either a 8kHz or a 16kHz sample rate, and a 20ms frame size.

To choose the sampling rate set the `Content-Type` property to `audio/l16;rate=16000` or `audio/l16;rate=8000` depending on if you need the data at 16kHz or 8kHz. Most real-time transcription services work best with audio at 8kHz.

Each message will be a 20ms sample of the audio from the call. If you choose the 8kHz rate each message will be 320 bytes. Choosing the 16kHz rate will result in each message being 640 bytes. This is summarized in the following table:

| Sampling rate (samples per second) | Number of samples in 20ms | Bytes per message |
|----|----|----|
| 8000 | 160 | 160 x 2 = 320 |
| 16000 | 320 | 320 x 2 = 640 |

### JSON DTMF messages

If any party on the call connected to the websocket sends a [DTMF](/concepts/guides/glossary#dtmf) tone this will trigger an event on the websocket, this event is a *text* message with a JSON payload, it will be interleaved between the audio frames and have the following format:

```json
{"event":"websocket:dtmf","digit":"5","duration":260}
```

You will receive one event for each keypress and each event will contain only one digit.

* `event` allows you to identify it as a DTMF event
* `digit` contains the digit pressed `0-9` `*` or `#`
* `duration` is the duration the key was pressed for in milliseconds, on most digital phone systems this will be a fixed length.

## Writing audio to the WebSocket

You can send audio back into the call by writing binary messages to the WebSocket. The audio must be in the same format as described in the previous section. It is important that each message is 320 or 640 bytes (depending on sample rate) and contains 20ms of audio.

You can send the messages at a faster than real-time rate and they will be buffered by our API platform for later playback. So for example, you can send an entire file to the socket in one write, providing the 320/640 byte per message restriction is observed. Vonage will only buffer 1024 messages which should be enough for around 20 seconds of audio, if your file is longer than this you should implement a delay of 18-19ms between each message, or consider using the [REST API to play an audio file](/voice/voice-api/code-snippets/play-an-audio-stream-into-a-call/).


## WebSocket Event Callbacks

Event data is sent to the `eventURL` as with all voice applications. This is a `POST` request by default, but you can specify the request type in the `eventMethod` parameter of the `connect` action.

Event callbacks are documented in the [Webhook Reference Guide](/voice/voice-api/webhook-reference). In the guide you can find all the types of webhooks and the parameters each webhook sends as part of its payload.

Within WebSockets particularly, you can also set custom metadata in your event callback with the `headers` parameter. 

### Fallback Options

A common use case for custom metadata is providing useful information for fallback options. For example, you way want to include the original `from` number in the fallback event as `caller-id`. To do that, use the `headers` parameter in the `connect` action as described above. This information is then included in the event webhook payload as follows:

``` json
{
  "from": "442079460000",
  "to": "wss://example.com/socket",
  "uuid": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "conversation_uuid": "CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "status": "disconnected",
  "timestamp": "2020-03-31T12:00:00.000Z",
  "headers": {
    "caller-id": "447700900123"
  }
}
```

You can also be notified via an event when a connection to a WebSocket cannot be established or if the application terminates the WebSocket connection for any reason.

#### Connection cannot be established

To receive this event, you must include the `eventType: synchronous` in your `connect` action:

``` json
[
  {
    "action": "connect",
    "eventType": "synchronous",
    "eventUrl": [
      "https://example.com/events"
    ],
    "from": "447700900000",
    "endpoint": [
      {
        "type": "websocket",
        "uri": "wss://example.com/socket",
        "content-type": "audio/l16;rate=16000",
        "headers": {
            "caller-id": "447700900123"
        }        
      }
    ]
  }
]
```

You can then return a new NCCO in the response with the required fallback actions. For example, if you cannot establish a connection, you might want to play a message to the caller or transfer the call. In the event of a connection failure, the event `status` will be one of `failed` or `unanswered`. For example:

``` json
{
  "from": "442079460000",
  "to": "wss://example.com/socket",
  "uuid": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "conversation_uuid": "CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "status": "unanswered",
  "timestamp": "2020-03-31T12:00:00.000Z",
  "headers": {
    "caller-id": "447700900123"
  }  
}
```

You can return a new NCCO in your webhook response to handle the failed connection attempt. If you do not return an NCCO, the next action in the original NCCO will be processed. If there are no further actions in the original NCCO, the call will complete.

#### Websocket disconnected

If the connection is dropped by your application, you will receive an event on your `eventUrl` webhook with a `status` of `disconnected`:

``` json
{
  "from": "442079460000",
  "to": "wss://example.com/socket",
  "uuid": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "conversation_uuid": "CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "status": "disconnected",
  "timestamp": "2020-03-31T12:00:00.000Z"
}
```

When you receive a `disconnected` event, you can commence your fallback strategy by providing a new NCCO in the response.

However, the `disconnected` event gets raised both when the disconnection was unintentional (due to some problem) or you intentionally disconnected the websocket (as part of your business logic).

Ideally, you want to fallback _only when the disconnect is unintentional_, so a better approach than closing the connection is to explicitly terminate the call leg via an API request:

``` curl
PUT https://api.nexmo.com/v1/calls/aaaaaaaa-bbbb-cccc-dddd-0123456789ab

{
  "action": "hangup"
}
```

This method does not raise a `disconnected` event. Therefore, if you do receive a `disconnected` event you can reliably assume that it is an unintentional disconnection and fallback appropriately. You can also use the [Fallback URL webhook](/voice/voice-api/webhook-reference#fallback-url) with this approach.

## Further reading

Use the following resources to help you make the most of WebSockets in your Voice API applications:

* [Getting started with WebSockets](https://www.nexmo.com/blog/2017/02/15/webinar-getting-started-nexmo-voice-websockets-dr/) Webinar
* Tutorial: Create a WebSocket echo server
    * [Node](/voice/voice-api/tutorials/connect-to-a-websocket/introduction/node)
    * [Python](/voice/voice-api/tutorials/connect-to-a-websocket/introduction/python)
* Demo apps:
    * [Browser audio demo](https://github.com/nexmo-community/audiosocket-demo): Send conference call audio to a web browser using WebSockets and the browser Web Audio API (Python)
    * WebSocket recorder demo: Receive binary from a WebSocket, store it in a file and then convert it to WAV 
  format.
        * [Node](https://github.com/nexmo-community/node-websocket-recorder)
        * [Python](https://github.com/nexmo-community/python-websocket-recorder)
        * [.NET](https://github.com/nexmo-community/NET-Fleck-Websocket-recorder)

    * [Audio socket framework](https://github.com/nexmo-community/audiosocket_framework): A useful starting point for interfacing between Vonage and an AI bot platform
    * [Socket phone](https://github.com/nexmo-community/socketphone): Connect a Vonage WebSocket call to your local machine
* AI Connectors:
    * Voice Bots
        * [Amazon Lex](https://github.com/nexmo/lex-connector)
        * [Google DialogFlow](https://github.com/nexmo-se/nexmo-dialogflow)
    * Real-time transcription
        * [Amazon Transcribe](https://github.com/nexmo-community/transcribe-comprehend-multi-sub)
        * [Google Speech-to-Text](https://github.com/nexmo-community/voice-google-speechtotext-js)
        * [IBM Watson](https://github.com/nexmo-community/voice-ibm-speechtotext-py)        
        * [Microsoft Azure](https://github.com/nexmo-community/voice-azure-speechtotext-py)
    * Sentiment Analysis
        * [Amazon Comprehend](https://github.com/nexmo-community/transcribe-comprehend-multi-sub)
        * [IBM Watson](https://github.com/nexmo-community/sentiment-analysis-websockets)
* Blog articles:
    * [Processing Voice Calls With Amazon Transcribe & Comprehend](https://learn.vonage.com/blog/2021/05/17/processing-voice-calls-with-amazon-transcribe-comprehend/)
    * [How to Make and Receive Phone Calls with Nuxt.js](https://learn.vonage.com/blog/2020/03/02/how-make-receive-phone-calls-with-nuxt-js-dr/)
    * [Creating a WebSocket Server with the Spark Framework](https://learn.vonage.com/blog/2018/10/15/create-websocket-server-spark-framework-dr/)
    * [Creating a WebSocket Server with Spring Boot](https://learn.vonage.com/blog/2018/10/08/create-websocket-server-spring-boot-dr/)
    * [Real-time Call Transcription Using IBM Watson and Python](https://learn.vonage.com/blog/2017/10/03/real-time-call-transcription-ibm-watson-python-dr/)
