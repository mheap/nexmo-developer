---
title: Manage the call
description: In this step you will receive the call.
---

# Manage call

## Receive call

Add `call` property at the top of the `MainActivity` class:

```java
private NexmoCall call;
```

To listen for incoming calls add incoming call listener at the end of `onCreate` method inside `MainActivity` class:

```java
client.addIncomingCallListener(it -> {
    call = it;

    answerCallButton.setVisibility(View.VISIBLE);
    rejectCallButton.setVisibility(View.VISIBLE);
    endCallButton.setVisibility(View.GONE);
});
```

The app will now listen for the incoming call event. The above code shows the answer and the reject call buttons when the incoming call event is received. Notice that you are storing `call` reference to interact later with the call.

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

Press the `Ctrl + R` keys to build and run the app. Call the number.

Call the number linked with your application from the earlier step.

## Webhooks

As you proceed with the call, please switch to the terminal and notice the `/voice/answer` endpoint being called to retrieve the NCCO:

```bash
NCCO request:
  - caller: 447700900000
  - callee: 442038297050
```

Also, as the call progresses through various stages, `/voice/event` is being sent events:

```bash
EVENT:
{
  headers: {},
  from: '447700900000',
  to: '442038297050',
  uuid: '0779a56d002f1c7f47f82ef5fe84ab79',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'ringing',
  direction: 'inbound',
  timestamp: '2021-03-29T21:20:05.582Z'
}
---
EVENT:
{
  headers: {},
  from: '447700900000',
  to: '442038297050',
  uuid: '0779a56d002f1c7f47f82ef5fe84ab79',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'started',
  direction: 'inbound',
  timestamp: '2021-03-29T21:20:05.582Z'
}
---
EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: '447700900000',
  to: '442038297050',
  uuid: '0779a56d002f1c7f47f82ef5fe84ab79',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'answered',
  direction: 'inbound',
  network: null,
  timestamp: '2021-03-29T21:20:06.182Z'
}
---
EVENT:
{
  from: '447700900000',
  to: 'Alice',
  uuid: '944bf4bf-8dc7-4e23-86b2-2f4234777416',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'started',
  direction: 'outbound',
  timestamp: '2021-03-29T21:20:13.025Z'
}
---
EVENT:
{
  start_time: null,
  headers: {},
  rate: null,
  from: '447700900000',
  to: 'Alice',
  uuid: '944bf4bf-8dc7-4e23-86b2-2f4234777416',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'answered',
  direction: 'outbound',
  network: null,
  timestamp: '2021-03-29T21:20:13.025Z'
}
---
EVENT:
{
  headers: {},
  end_time: '2021-03-29T21:20:16.000Z',
  uuid: '944bf4bf-8dc7-4e23-86b2-2f4234777416',
  network: null,
  duration: '5',
  start_time: '2021-03-29T21:20:11.000Z',
  rate: '0.00',
  price: '0',
  from: '447700900000',
  to: 'Alice',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'completed',
  direction: 'outbound',
  timestamp: '2021-03-29T21:20:17.574Z'
}
---
EVENT:
{
  headers: {},
  end_time: '2021-03-29T21:20:18.000Z',
  uuid: '0779a56d002f1c7f47f82ef5fe84ab79',
  network: 'GB-FIXED',
  duration: '12',
  start_time: '2021-03-29T21:20:06.000Z',
  rate: '0.00720000',
  price: '0.00144000',
  from: ' 447700900000',
  to: '442038297050',
  conversation_uuid: 'CON-8f5a100c-fbce-4218-8d4b-16341335bcd6',
  status: 'completed',
  direction: 'inbound',
  timestamp: '2021-03-29T21:20:17.514Z'
}
---
```