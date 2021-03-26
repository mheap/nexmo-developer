---
title: Manage the call
description: In this step you will receive the call.
---

# Manage call

## Receive call

Add `call` property at the top of the `ManActivity` class:

```kotlin
private var call: NexmoCall? = null
```

To listen for incoming calls and store call reference add listener at the end of `onCreate` method inside `MainActivity` class:

```kotlin
client.addIncomingCallListener { it ->
    call = it

    answerCallButton.visibility = View.VISIBLE
    rejectCallButton.visibility = View.VISIBLE
    endCallButton.visibility = View.GONE
}
```

The app will now listen for the incoming call event. The above code shows the answer and the reject call buttons when the incoming call event is received. 

Before you will be able to perform actions using UI you also need to add listeners to the buttons. Add this code at of the `onCreate` inside `MainActivity` class:

```kotlin
answerCallButton.setOnClickListener { answerCall() }
rejectCallButton.setOnClickListener { rejectCall() }
endCallButton.setOnClickListener { endCall() }
```

To answer the call add `answerCall` method inside `MainActivity` class:

```kotlin
@SuppressLint("MissingPermission")
private fun answerCall() {
    call?.answer(object : NexmoRequestListener<NexmoCall> {
        override fun onError(p0: NexmoApiError) {
        }

        override fun onSuccess(p0: NexmoCall?) {
            answerCallButton.visibility = View.GONE
            rejectCallButton.visibility = View.GONE
            endCallButton.visibility = View.VISIBLE
        }
    })
}
```

After answering the call the `end call` button will be shown.

**NOTE:** The `SuppressLint` annotation is used for simplicity. In the production app you should make sure permissions are granted before answering the call.

To reject the call add `rejectCall` method inside `MainActivity` class:

```kotlin
private fun rejectCall() {
    call?.hangup(object : NexmoRequestListener<NexmoCall> {
        override fun onError(p0: NexmoApiError) {
        }

        override fun onSuccess(p0: NexmoCall?) {
            answerCallButton.visibility = View.GONE
            rejectCallButton.visibility = View.GONE
            endCallButton.visibility = View.GONE
        }
    })

    call = null
}
```

To end the call add `endCall` method inside `MainActivity` class:

```kotlin
private fun endCall() {
    call?.hangup(object : NexmoRequestListener<NexmoCall> {
        override fun onError(p0: NexmoApiError) {
        }

        override fun onSuccess(p0: NexmoCall?) {
            answerCallButton.visibility = View.GONE
            rejectCallButton.visibility = View.GONE
            endCallButton.visibility = View.GONE
        }
    })

    call = null
}
```

Notice that after a successful rejecting or ending the call you set `call` property value back to null.

> **NOTE:** You can use `call.addCallEventListener` listener to be notified when caller ends the call.

## Build and Run

Please make sure that the webhook server you built in the previous steps is still running. 

Press the `Ctrl + R` keys to build and run the app. Call the number.

Call the number linked with your application from the earlier step.

## Webhooks

As you proceed with the call, please switch to the terminal and notice the `/voice/answer` endpoint being called to retrieve the NCCO:

```bash
EVENT:
{
  headers: {},
  from: '447000000000',
  to: '447441444905',
  uuid: '83105191634ccab73a94dfb2f7fa2d07',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'ringing',
  direction: 'inbound',
  timestamp: '2021-03-23T13:21:56.882Z'
}
---
NCCO request:
  - from: 447000000000
---
EVENT:
{
  headers: {},
  from: '447000000000',
  to: '447441444905',
  uuid: '83105191634ccab73a94dfb2f7fa2d07',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'started',
  direction: 'inbound',
  timestamp: '2021-03-23T13:21:56.882Z'
}
---
EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: '447000000000',
  to: '447441444905',
  uuid: '83105191634ccab73a94dfb2f7fa2d07',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'answered',
  direction: 'inbound',
  network: null,
  timestamp: '2021-03-23T13:21:57.846Z'
}
---
EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: 'Unknown',
  to: 'Alice',
  uuid: '5050d0e7-ee5d-438e-a38c-3aba8d8379e2',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'answered',
  direction: 'outbound',
  network: null,
  timestamp: '2021-03-23T13:22:05.841Z'
}
---
EVENT:
{
  from: 'Unknown',
  to: 'Alice',
  uuid: '5050d0e7-ee5d-438e-a38c-3aba8d8379e2',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'started',
  direction: 'outbound',
  timestamp: '2021-03-23T13:22:05.841Z'
}
---
EVENT:
{
  headers: {},
  end_time: '2021-03-23T13:22:08.000Z',
  uuid: '83105191634ccab73a94dfb2f7fa2d07',
  network: '23409',
  duration: '11',
  start_time: '2021-03-23T13:21:57.000Z',
  rate: '0.00720000',
  price: '0.00132000',
  from: '447000000000',
  to: '447441444905',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'completed',
  direction: 'inbound',
  timestamp: '2021-03-23T13:22:08.706Z'
}
---
EVENT:
{
  headers: {},
  end_time: '2021-03-23T13:22:08.000Z',
  uuid: '5050d0e7-ee5d-438e-a38c-3aba8d8379e2',
  network: null,
  duration: '3',
  start_time: '2021-03-23T13:22:05.000Z',
  rate: '0.00',
  price: '0',
  from: 'Unknown',
  to: 'Alice',
  conversation_uuid: 'CON-3567680b-a4b4-43ac-9cc7-1d3b4a958e5c',
  status: 'completed',
  direction: 'outbound',
  timestamp: '2021-03-23T13:22:09.292Z'
}
---
```