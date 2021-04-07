---
title: Receive call
description: In this step you will receive the call.
---

# Receive call

Before making a call you will receive call functionality to the application. Add `onGoingCall` property at the top of the `MainActivity` class:

```kotlin
private var onGoingCall: NexmoCall? = null
```

To listen for incoming calls add incoming call listener at the end of `onCreate` method inside `MainActivity` class:

```kotlin
client.addIncomingCallListener { it ->
    onGoingCall = it

    runOnUiThread {
      hideUI()
      answerCallButton.visibility = View.VISIBLE
      rejectCallButton.visibility = View.VISIBLE
    }
}
```

The app will now listen for the incoming call event. The above code shows the answer and the reject call buttons when the incoming call event is received. Notice that you are storing `call` reference to interact later with the call.

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
    onGoingCall?.answer(object : NexmoRequestListener<NexmoCall> {
        override fun onError(p0: NexmoApiError) {
        }

        override fun onSuccess(p0: NexmoCall?) {
            runOnUiThread {
                hideUI()
                endCallButton.visibility = View.VISIBLE
            }
        }
    })
}
```

After answering the call the `end call` button will be shown.

**NOTE:** The `SuppressLint` annotation is used for simplicity. In the production app you should make sure permissions are granted before answering the call.

To reject the call add `rejectCall` method inside `MainActivity` class:

```kotlin
private fun rejectCall() {
    onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
        override fun onError(p0: NexmoApiError) {
        }

        override fun onSuccess(p0: NexmoCall?) {
          runOnUiThread {
              hideUI()
              startCallButton.visibility = View.VISIBLE
              waitingForIncomingCallTextView.visibility = View.VISIBLE
          }
        }
    })

    onGoingCall = null
}
```

To end the call add `endCall` method inside `MainActivity` class:

```kotlin
private fun endCall() {
    onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
        override fun onError(p0: NexmoApiError) {
        }

        override fun onSuccess(p0: NexmoCall?) {
            runOnUiThread {
                hideUI()
                startCallButton.visibility = View.VISIBLE
                waitingForIncomingCallTextView.visibility = View.VISIBLE
            }
        }
    })

    onGoingCall = null
}
```

Notice that after a successful rejecting or ending the call you set `call` property value back to null.
