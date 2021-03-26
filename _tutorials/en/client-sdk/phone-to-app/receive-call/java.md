---
title: Manage the call
description: In this step you will receive the call.
---

# Manage call

## Receive call

Add `call` property at the top of the `ManActivity` class:

```java
private NexmoCall call;
```

To listen for incoming calls and store call reference add listener at the end of `onCreate` method inside `MainActivity` class:

```java
client.addIncomingCallListener(it -> {
    call = it;

    answerCallButton.setVisibility(View.VISIBLE);
    rejectCallButton.setVisibility(View.VISIBLE);
    endCallButton.setVisibility(View.GONE);
});
```

The app will now listen for the incoming call event. The above code shows the answer and the reject call buttons when the incoming call event is received. 

Before you will be able to perform actions using UI you also need to add listeners to the buttons. Add this code at of the `onCreate` inside `MainActivity` class:

```java
answerCallButton.setOnClickListener(view -> { answerCall();});
rejectCallButton.setOnClickListener(view -> { rejectCall();});
endCallButton.setOnClickListener(view -> { endCall();});
```

To answer the call add `answerCall` method inside `MainActivity` class:

```java
@SuppressLint("MissingPermission")
private void answerCall() {
    call.answer(new NexmoRequestListener<NexmoCall>() {
        @Override
        public void onError(@NonNull NexmoApiError nexmoApiError) {

        }

        @Override
        public void onSuccess(@Nullable NexmoCall nexmoCall) {
            answerCallButton.setVisibility(View.GONE);
            rejectCallButton.setVisibility(View.GONE);
            endCallButton.setVisibility(View.VISIBLE);
        }
    });
}
```

After answering the call the `end call` button will be shown.

**NOTE:** The `SuppressLint` annotation is used for simplicity. In the production app you should make sure permissions are granted before answering the call.

To reject the call add `rejectCall` method inside `MainActivity` class:

```java
private void rejectCall() {
    call.hangup(new NexmoRequestListener<NexmoCall>() {
        @Override
        public void onError(@NonNull NexmoApiError nexmoApiError) {

        }

        @Override
        public void onSuccess(@Nullable NexmoCall nexmoCall) {
            answerCallButton.setVisibility(View.GONE);
            rejectCallButton.setVisibility(View.GONE);
            endCallButton.setVisibility(View.GONE);
        }
    });
    call = null;
}
```

To end the call add `endCall` method inside `MainActivity` class:

```java
private void endCall() {
    call.hangup(new NexmoRequestListener<NexmoCall>() {
        @Override
        public void onError(@NonNull NexmoApiError nexmoApiError) {

        }

        @Override
        public void onSuccess(@Nullable NexmoCall nexmoCall) {
            answerCallButton.setVisibility(View.GONE);
            rejectCallButton.setVisibility(View.GONE);
            endCallButton.setVisibility(View.GONE);
        }
    });
    call = null;
}
```

Notice that after a successful rejecting or ending the call you set `call` property value back to null.

> **NOTE:** You can use `call.addCallEventListener` listener to be notified when caller ends the call.

## Build and Run

Please make sure that the webhook server you built in the previous steps is still running. 

Press `Ctrl + R` the buttons to build and run the app. Call the number.

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