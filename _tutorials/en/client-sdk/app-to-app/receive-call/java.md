---
title: Receive call
description: In this step you will receive the call.
---

# Receive call

Before making a call you will receive call functionality to the application. Add `onGoingCall` property at the top of the `MainActivity` class:

```java
private NexmoCall onGoingCall;
```

To listen for incoming calls add incoming call listener at the end of `onCreate` method inside `MainActivity` class:

```java
client.addIncomingCallListener(it -> {
    onGoingCall = it;

    runOnUiThread(() -> {
        hideUI();
        answerCallButton.setVisibility(View.VISIBLE);
        rejectCallButton.setVisibility(View.VISIBLE);
    });
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
    onGoingCall.answer(new NexmoRequestListener<NexmoCall>() {
        @Override
        public void onError(@NonNull NexmoApiError nexmoApiError) {

        }

        @Override
        public void onSuccess(@Nullable NexmoCall nexmoCall) {
            onGoingCall.addCallEventListener(callListener);
            runOnUiThread(() -> {
                hideUI();
                endCallButton.setVisibility(View.VISIBLE);
            });
        }
    });
}
```

After answering the call the `end call` button will be shown.

**NOTE:** The `SuppressLint` annotation is used for simplicity. In the production app you should make sure permissions are granted before answering the call.

To reject the call add `rejectCall` method inside `MainActivity` class:

```java
private void rejectCall() {
    onGoingCall.hangup(new NexmoRequestListener<NexmoCall>() {
        @Override
        public void onError(@NonNull NexmoApiError nexmoApiError) {

        }

        @Override
        public void onSuccess(@Nullable NexmoCall nexmoCall) {
            runOnUiThread(() -> {
                hideUI();
                startCallButton.setVisibility(View.VISIBLE);
                waitingForIncomingCallTextView.setVisibility(View.VISIBLE);
            });
        }
    });
    onGoingCall = null;
}
```

To end the call add `endCall` method inside `MainActivity` class:

```java
private void endCall() {
    onGoingCall.hangup(new NexmoRequestListener<NexmoCall>() {
        @Override
        public void onError(@NonNull NexmoApiError nexmoApiError) {

        }

        @Override
        public void onSuccess(@Nullable NexmoCall nexmoCall) {
            runOnUiThread(() -> {
                hideUI();
                startCallButton.setVisibility(View.VISIBLE);
                waitingForIncomingCallTextView.setVisibility(View.VISIBLE);
            });
        }
    });
    
    onGoingCall = null;
}
```

Notice that after a successful rejecting or ending the call you set `call` property value back to null.
