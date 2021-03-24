---
title: End a call
description: In this step you will end the call.
---

# End a call

The call can be ended by one of two parties:
- application by the calling the `hangup` method on the `call` instance
- callee by hanging up on the physical device

## End call when callee hangups

To end the call (hangup) you need to store the reference to the ongoing call object. Add `onGoingCall` property at the top of the `ManActivity`:

```java
@Nullable private NexmoCall onGoingCall;
```

You need to store ongoing call reference in the `onGoingCall` property and add `addCallEventListener` to notify you when the call ends. In the `MainActivity` update the body of the `makeCall` method:

```java
@SuppressLint("MissingPermission")
private void makeCall() {
    // Callee number is ignored because it is specified in NCCO config
    client.call("IGNORED_NUMBER", NexmoCallHandler.SERVER, new NexmoRequestListener<NexmoCall>() {
        @Override
        public void onError(@NonNull NexmoApiError nexmoApiError) {

        }

        @Override
        public void onSuccess(@Nullable NexmoCall call) {
            endCallButton.setVisibility(View.VISIBLE);
            makeCallButton.setVisibility(View.INVISIBLE);

            onGoingCall = call;
            onGoingCall.addCallEventListener(new NexmoCallEventListener() {
                @Override
                public void onMemberStatusUpdated(NexmoCallMemberStatus callStatus, NexmoCallMember nexmoCallMember) {
                    if (callStatus == NexmoCallMemberStatus.COMPLETED || callStatus == NexmoCallMemberStatus.CANCELLED) {
                        onGoingCall = null;
                        endCallButton.setVisibility(View.INVISIBLE);
                        makeCallButton.setVisibility(View.VISIBLE);
                    }
                }

                @Override
                public void onMuteChanged(NexmoMediaActionState nexmoMediaActionState, NexmoCallMember nexmoCallMember) {

                }

                @Override
                public void onEarmuffChanged(NexmoMediaActionState nexmoMediaActionState, NexmoCallMember nexmoCallMember) {

                }

                @Override
                public void onDTMF(String s, NexmoCallMember nexmoCallMember) {

                }
            });
        }
    });
}
```

When the call is ended (regardless of who ends the call app or callee) the UI is updated to reflect the current call state (`make a call button` is shown and `end call` button is hidden).

## End call in the application

In the `MainActivity` fill the body of the `hangup` method:

```java
private void hangup() {
    onGoingCall.hangup(new NexmoRequestListener<NexmoCall>() {
        @Override
        public void onError(@NonNull NexmoApiError nexmoApiError) {
            onGoingCall = null;
        }

        @Override
        public void onSuccess(@Nullable NexmoCall nexmoCall) {

        }
    });
}
```

Notice that after successful hangup you set the value of the `onGoingCall` property back to null.

## Build and Run

`Ctrl + R` to build and run the app. Start and end the call. UI in the app will be updated after starting and ending the call.