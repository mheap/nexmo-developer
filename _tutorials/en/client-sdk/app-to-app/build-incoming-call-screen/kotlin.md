---
title: Build incoming call screen
description: In this step you build OnCall screen.
---

# Build  incomming call sreen

On call screen (`IncomingCallFragment` and `OnCallViewModel` classes) is responsible for answering incoming a call.

## Update `fragment_incoming_call` layout

Open `fragment_incoming_call.xml` layout and click `Code` button in top right corner to display layout XML code:

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/layout-resource.png
```

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/show-code-view.png
```

Replace file content with below code snippet:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:layout_gravity="center"
        android:gravity="center"
        android:orientation="vertical"
        android:padding="48dp">

    <TextView
            android:id="@+id/titleTextView"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="top|center_horizontal"
            android:layout_marginTop="50dp"
            android:gravity="center"
            android:singleLine="true"
            android:text="Incoming call from Alice"
            android:textColor="@color/white"
            android:textSize="40sp" />

    <Button
            android:id="@+id/hangupButton"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginBottom="50dp"
            android:text="Hangup" />

    <Button
            android:id="@+id/answerButton"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Answer" />
</LinearLayout>
```

## Update `OnCallViewModel`

Open `OnCallViewModel` and Replace file content with below code snippet:

```kotlin
package com.vonage.tutorial.voice

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoCallEventListener
import com.nexmo.client.NexmoCallMember
import com.nexmo.client.NexmoCallMemberStatus
import com.nexmo.client.NexmoMediaActionState

class OnCallViewModel : ViewModel() {
    private val callManager = CallManager
    private val navManager = NavManager

    private val _toast = MutableLiveData<String>()
    val toast = _toast as LiveData<String>

    private val callEventListener = object : NexmoCallEventListener {
        override fun onMemberStatusUpdated(nexmoCallStatus: NexmoCallMemberStatus, callMember: NexmoCallMember) {
            if (nexmoCallStatus == NexmoCallMemberStatus.COMPLETED || nexmoCallStatus == NexmoCallMemberStatus.CANCELLED) {
                callManager.onGoingCall = null
                navManager.popBackStack(R.id.mainFragment, false)
            }
        }

        override fun onMuteChanged(nexmoMediaActionState: NexmoMediaActionState, callMember: NexmoCallMember) {}

        override fun onEarmuffChanged(nexmoMediaActionState: NexmoMediaActionState, callMember: NexmoCallMember) {}

        override fun onDTMF(dtmf: String, callMember: NexmoCallMember) {}
    }

    init {
        val onGoingCall = checkNotNull(callManager.onGoingCall) { "Call is null" }
        onGoingCall.addCallEventListener(callEventListener)
    }

    override fun onCleared() {
        super.onCleared()

        callManager.onGoingCall?.removeCallEventListener(callEventListener)
    }

    fun onBackPressed() {
        hangupInternal()
    }

    fun hangup() {
        hangupInternal()
    }

    private fun hangupInternal() {
        TODO("Hangup incoming call")
    }
}
```

### Hangup incoming phone call

Locate `hangupInternal` method and replace its body:


```kotlin
private fun hangupInternal() {
    callManager.onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
        override fun onSuccess(call: NexmoCall?) {
            callManager.onGoingCall = null
        }

        override fun onError(apiError: NexmoApiError) {
            _toast.postValue(apiError.message)
        }
    })
}
```

## Update `OnCallFragment`

Open `OnCallFragment` and Replace file content with below code snippet:

```kotlin
package com.vonage.tutorial.voice

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer

class OnCallFragment : Fragment(R.layout.fragment_on_call),
    BackPressHandler {

    private lateinit var endCall: Button

    private val viewModel by viewModels<OnCallViewModel>()

    private val toastObserver = Observer<String> {
        Toast.makeText(requireActivity(), it, Toast.LENGTH_SHORT).show();
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.toast.observe(viewLifecycleOwner, toastObserver)

        endCall = view.findViewById(R.id.endCall)

        endCall.setOnClickListener {
            viewModel.hangup()
        }
    }

    override fun onBackPressed() {
        viewModel.onBackPressed()
    }
}
```

You are done. It's time to run the app and make the call.