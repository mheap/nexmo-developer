---
title: Build on call screen
description: In this step you build OnCall screen.
---

# Call

On call screen (`OnCallFragment` and `OnCallViewModel` classes) is responsible for starting a call.

## Update `fragment_on_call` layout

Open `fragment_on_call.xml` layout and click `Code` button in top right corner to display layout XML code:

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
        xmlns:app="http://schemas.android.com/apk/res-auto"
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
            android:text="@string/on_a_call"
            android:textColor="@color/white"
            android:textSize="40sp" />

    <Space
            android:layout_width="1dp"
            android:layout_height="0dp"
            android:layout_weight="1" />

    <com.google.android.material.floatingactionbutton.FloatingActionButton
            android:id="@+id/hangupFab"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="center"
            android:layout_marginBottom="40dp"
            android:src="@drawable/ic_end_call"
            app:backgroundTint="@color/negativeCallAction"
            app:fabSize="normal" />
</LinearLayout>
```

## Update `OnCallViewModel`

Open `OnCallViewModel` and Replace file content with below code snippet:

```kotlin
package com.vonage.tutorial.voice.view.oncall

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoCall
import com.nexmo.client.NexmoCallEventListener
import com.nexmo.client.NexmoCallMember
import com.nexmo.client.NexmoCallMemberStatus
import com.nexmo.client.NexmoMediaActionState
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener
import com.vonage.tutorial.R
import com.vonage.tutorial.voice.extension.asLiveData
import com.vonage.tutorial.voice.util.CallManager
import com.vonage.tutorial.voice.util.NavManager
import timber.log.Timber

class OnCallViewModel : ViewModel() {
    private val callManager = CallManager
    private val navManager = NavManager

    private val _toast = MutableLiveData<String>()
    val toast = _toast.asLiveData()

    private val callEventListener = object : NexmoCallEventListener {
        override fun onMemberStatusUpdated(nexmoCallStatus: NexmoCallMemberStatus, callMember: NexmoCallMember) {
            Timber.d("CallEventListener.onMemberStatusUpdated: ${callMember.user.name} : $nexmoCallStatus")

            if (nexmoCallStatus == NexmoCallMemberStatus.COMPLETED || nexmoCallStatus == NexmoCallMemberStatus.CANCELED) {
                callManager.onGoingCall = null
                navManager.popBackStack(R.id.mainFragment, false)
            }
        }

        override fun onMuteChanged(nexmoMediaActionState: NexmoMediaActionState, callMember: NexmoCallMember) {
            Timber.d("CallEventListener.onMuteChanged: ${callMember.user.name} : $nexmoMediaActionState")
        }

        override fun onEarmuffChanged(nexmoMediaActionState: NexmoMediaActionState, callMember: NexmoCallMember) {
            Timber.d("CallEventListener.onEarmuffChanged: ${callMember.user.name} : $nexmoMediaActionState")
        }

        override fun onDTMF(dtmf: String, callMember: NexmoCallMember) {
            Timber.d("CallEventListener.onDTMF: ${callMember.user.name} : $dtmf")
        }
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
            navManager.popBackStack()
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
package com.vonage.tutorial.voice.view.oncall

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.vonage.tutorial.R
import com.vonage.tutorial.voice.BackPressHandler
import com.vonage.tutorial.voice.extension.toast
import kotlinx.android.synthetic.main.fragment_on_call.*

class OnCallFragment : Fragment(R.layout.fragment_on_call),
    BackPressHandler {

    private val viewModel by viewModels<OnCallViewModel>()

    private val toastObserver = Observer<String> {
        context?.toast(it)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.toast.observe(viewLifecycleOwner, toastObserver)

        hangupFab.setOnClickListener {
            viewModel.hangup()
        }
    }

    override fun onBackPressed() {
        viewModel.onBackPressed()
    }
}
```
