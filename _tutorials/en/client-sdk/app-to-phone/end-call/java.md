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

You need to store ongoing call reference in the `onGoingCall` property and add `addCallEventListener` to notify you when the call ends. In the `MainActivity` update the body of the `startCall` method:

```java
@SuppressLint("MissingPermission")
private void startCall() {
    client.call("PHONE_NUMBER", NexmoCallHandler.SERVER, new NexmoRequestListener<NexmoCall>() {
        @Override
        public void onError(@NonNull NexmoApiError nexmoApiError) {

        }

        @Override
        public void onSuccess(@Nullable NexmoCall call) {
            runOnUiThread(() -> {
                hideUI();
                endCallButton.setVisibility(View.VISIBLE);
            });

            onGoingCall = call;
            
            onGoingCall.addCallEventListener(new NexmoCallEventListener() {
                @Override
                public void onMemberStatusUpdated(NexmoCallMemberStatus callStatus, NexmoCallMember nexmoCallMember) {
                    if (callStatus == NexmoCallMemberStatus.COMPLETED || callStatus == NexmoCallMemberStatus.CANCELLED) {
                        onGoingCall = null;
                        
                        runOnUiThread(() -> {
                            hideUI();
                            startCallButton.setVisibility(View.VISIBLE);
                        }
                    });
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