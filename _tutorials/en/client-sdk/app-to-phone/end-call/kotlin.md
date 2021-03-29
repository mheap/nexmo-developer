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

```kotlin
var onGoingCall: NexmoCall? = null
```

You need to store ongoing call reference in the `onGoingCall` property and add `addCallEventListener` to notify you when the call ends. In the `MainActivity` update the body of the `startCall` method:

```kotlin
@SuppressLint("MissingPermission")
fun startCall() {
    // Callee number is ignored because it is specified in NCCO config
    client.call("IGNORED_NUMBER", NexmoCallHandler.SERVER, object : NexmoRequestListener<NexmoCall> {
        override fun onSuccess(call: NexmoCall?) {
            runOnUiThread { 
                endCallButton.visibility = View.VISIBLE
                startCallButton.visibility = View.INVISIBLE
            }

            onGoingCall = call

            onGoingCall?.addCallEventListener(object : NexmoCallEventListener {
                override fun onMemberStatusUpdated(callStatus: NexmoCallMemberStatus, callMember: NexmoCallMember) {
                    if (callStatus == NexmoCallMemberStatus.COMPLETED || callStatus == NexmoCallMemberStatus.CANCELLED) {
                        onGoingCall = null
                        
                        runOnUiThread { 
                            endCallButton.visibility = View.INVISIBLE
                            startCallButton.visibility = View.VISIBLE
                        }
                    }
                }

                override fun onMuteChanged(nexmoMediaActionState: NexmoMediaActionState, callMember: NexmoCallMember) {}

                override fun onEarmuffChanged(nexmoMediaActionState: NexmoMediaActionState, callMember: NexmoCallMember) {}

                override fun onDTMF(dtmf: String, callMember: NexmoCallMember) {}
            })
        }

        override fun onError(apiError: NexmoApiError) {
        }
    })
}
```

When the call is ended (regardless of who ends the call app or callee) the UI is updated to reflect the current call state (`make a call button` is shown and `END CALL` button is hidden).

## End call in the application

In the `MainActivity` fill the body of the `hangup` method:

```kotlin
private fun hangup() {
    onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
        override fun onSuccess(call: NexmoCall?) {
            onGoingCall = null
        }

        override fun onError(apiError: NexmoApiError) {
        }
    })
}
```

Notice that after successful hangup you set the value of the `onGoingCall` property back to null.

## Build and Run

Press the `Ctrl + R` keys to build and run the app. Start and end the call to see the UI changes.