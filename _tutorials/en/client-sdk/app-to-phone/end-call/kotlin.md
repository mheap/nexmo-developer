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

```kotlin
var onGoingCall: NexmoCall? = null
```

You need to store ongoing call reference in the `onGoingCall` property and add `addCallEventListener` to notify you when the call ends. In the `MainActivity` update the body of the `startCall` method. Please make sure to replace `PHONE_NUMBER` below with the actual phone number you want to call, in the [E.164](https://developer.nexmo.com/concepts/guides/glossary#e-164-format) format (for example, 447700900000):

```kotlin
@SuppressLint("MissingPermission")
fun startCall() {
    client.call("PHONE_NUMBER", NexmoCallHandler.SERVER, object : NexmoRequestListener<NexmoCall> {
        override fun onSuccess(call: NexmoCall?) {
            runOnUiThread { 
                hideUI()
                endCallButton.visibility = View.VISIBLE
            }

            onGoingCall = call

            onGoingCall?.addCallEventListener(object : NexmoCallEventListener {
                override fun onMemberStatusUpdated(callStatus: NexmoCallMemberStatus, nexmoMember: NexmoMember) {
                    if (callStatus == NexmoCallMemberStatus.COMPLETED || callStatus == NexmoCallMemberStatus.CANCELLED) {
                        onGoingCall = null
                        
                        runOnUiThread { 
                            hideUI()
                            startCallButton.visibility = View.VISIBLE
                        }
                    }
                }

                override fun onMuteChanged(nexmoMediaActionState: NexmoMediaActionState, nexmoMember: NexmoMember) {}

                override fun onEarmuffChanged(nexmoMediaActionState: NexmoMediaActionState, nexmoMember: NexmoMember) {}

                override fun onDTMF(dtmf: String, nexmoMember: NexmoMember) {}
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