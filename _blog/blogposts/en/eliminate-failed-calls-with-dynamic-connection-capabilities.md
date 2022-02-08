---
title: Eliminate Failed Calls with Dynamic Connection Capabilities
description: With the Nexmo Voice API's support for dynamic endpoints, call
  centers can route inbound calls to the next available agent when the main
  contact is busy.
thumbnail: /content/blog/eliminate-failed-calls-with-dynamic-connection-capabilities/nexmo_futureVoice.jpg
author: roland-selmer
published: true
published_at: 2017-02-23T21:53:43.000Z
updated_at: 2021-05-17T14:21:19.114Z
category: tutorial
tags:
  - voice-api
comments: true
redirect: ""
canonical: ""
---
We’re excited to announce the addition of dynamic connect for your [voice apps](https://www.nexmo.com/products/voice).

This enhancement helps eliminate failed calls when the primary line is in use or unavailable. For example, if you’re running a call center, you can have customers dial into a central number. If your main contact person is on another call, the inbound calls will be sent to the next available agent.

## The new stuff

The connect functionality works with existing failed call states such as `timeout` when call connections time out and `machine` when answer machines are detected. In addition to this, this release includes four new call states which are as follows:

* failed - the call failed to complete
* rejected - the call was rejected
* unanswered - the call was not answered
* busy - the person being called was on another call


## How does this new functionality work?

When such systems are used the NCCO appears as follows:

```json
[{
    "action": "connect",
    "from": "4155550123",
    "timeout": "10",
    "eventType": "synchronous",
    "eventUrl": ["https://example.com/events"],
    "endpoint": [{
        "type": "phone",
        "number": "4155550123"
    }]
}]
```

A new option has been introduced to the `connect` action called *eventType*, which instructs the action to be blocking if the value is set to *synchronous*. (*"eventType"*: *"asynchronous"* is the default and is non-blocking).

If the call enters a failed state (failed, rejected, unanswered, busy or timeout if the call takes longer than 10 seconds to connect in this specific example) then Nexmo makes an HTTP call to the `eventUrl`.

Your web server can then respond to this HTTP request with an NCCO that replaces the existing executing NCCO. This is very similar to how the existing [`input`](https://docs.nexmo.com/voice/voice-api/ncco-reference#input) functionality works.

The following example would inform Nexmo to try to connect to an alternative number.

```json
[{
    "action": "connect",
    "from": "442038973494",
    "endpoint": [{
        "type": "phone",
        "number": "442079354442"
    }]
}]
```

We hope that with this new feature, failed calls will no longer negatively impact the customer experience of your call center.

All this and more is also covered in the [dynamic NCCO `connect` docs](https://docs.nexmo.com/voice/voice-api/ncco-reference#connect_fallback).