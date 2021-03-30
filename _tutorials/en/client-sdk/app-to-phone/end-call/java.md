---
title: End a call
description: In this step you will end the call.
---

# End a call

The call can be ended by one of two parties:
- application by the calling the `hangup` method on the `call` instance
- callee by hanging up on the physical device

## End call when callee hangups

To end the call (hangup) you need to store the reference to the ongoing call object. Add `onGoingCall` property at the top of the `MainActivity`:

```java
@Nullable private NexmoCall onGoingCall;
```

You need to store ongoing call reference in the `onGoingCall` property and add `addCallEventListener` to notify you when the call ends. In the `MainActivity` update the body of the `startCall` method. Please make sure to replace `PHONE_NUMBER` below with the actual phone number you want to call, in the [E.164](https://developer.nexmo.com/concepts/guides/glossary#e-164-format) format (for example, 447700900000):


```java
@SuppressLint("MissingPermission")
private void startCall() {
    // Callee number is ignored because it is specified in NCCO config
    client.call("IGNORED_NUMBER", NexmoCallHandler.SERVER, new NexmoRequestListener<NexmoCall>() {
        @Override
        public void onError(@NonNull NexmoApiError nexmoApiError) {

        }

        @Override
        public void onSuccess(@Nullable NexmoCall call) {
            runOnUiThread(() -> {
                endCallButton.setVisibility(View.VISIBLE);
                startCallButton.setVisibility(View.INVISIBLE);
            });

            onGoingCall = call;
            onGoingCall.addCallEventListener(new NexmoCallEventListener() {
                @Override
                public void onMemberStatusUpdated(NexmoCallMemberStatus callStatus, NexmoCallMember nexmoCallMember) {
                    if (callStatus == NexmoCallMemberStatus.COMPLETED || callStatus == NexmoCallMemberStatus.CANCELLED) {
                            onGoingCall = null;

                            runOnUiThread(() -> {
                                        endCallButton.setVisibility(View.INVISIBLE);
                                        startCallButton.setVisibility(View.VISIBLE);
                                    }
                            );
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

When the call is ended (regardless of who ends the call app or callee) the UI is updated to reflect the current call state (`make a call button` is shown and `END CALL` button is hidden).

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

Press the `Ctrl + R` keys to build and run the app. Start and end the call to see the UI changes.