---
title: Build incoming call screen
description: In this step you build OnCall screen.
---

# Build  incoming call screen

On call screen (`IncomingCallFragment` and `OnCallViewModel` classes) is responsible for answering incoming a call.

## Update `fragment_incoming_call` layout

Open the `fragment_incoming_call.xml` layout and click `Code` button in top right corner to display layout XML code:

![](public/screenshots/tutorials/client-sdk/android-shared/layout-resource.png)

![](public/screenshots/tutorials/client-sdk/android-shared/show-code-view.png)

Replace the file contents with the following code:

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

## Update `IncommingCallViewModel`

Open the `IncommingCallViewModel` and replace the file contents with the following code:

```kotlin
package com.vonage.tutorial.voice

import android.annotation.SuppressLint
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoCall
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener

class IncomingCallViewModel : ViewModel() {
    private val navManager: NavManager = NavManager
    private val callManager: CallManager = CallManager
    
    private val _toast = MutableLiveData<String>()
    var toast: LiveData<String> = _toast
    
    fun hangup() {
        hangupInternal(true)
    }

    @SuppressLint("MissingPermission")
    fun answer() {
        callManager.onGoingCall?.answer(object : NexmoRequestListener<NexmoCall?> {
            override fun onSuccess(call: NexmoCall?) {
                val navDirections = IncomingCallFragmentDirections.actionIncomingCallFragmentToOnCallFragment()
                navManager.navigate(navDirections)
            }

            override fun onError(apiError: NexmoApiError) {
                _toast.postValue(apiError.message)
            }
        })
    }

    fun onBackPressed() {
        hangupInternal(false)
    }

    private fun hangupInternal(popBackStack: Boolean?) {
        // TODO: Hangup
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

## Update `IncomingCallFragment`

Open the `IncomingCallFragment` and replace the file contents with the following code:

```kotlin
package com.vonage.tutorial.voice

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider

class IncomingCallFragment : Fragment(R.layout.fragment_incoming_call), BackPressHandler {

    private lateinit var viewModel: IncomingCallViewModel

    private lateinit var hangupButton: Button
    private lateinit var answerButton: Button

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel = ViewModelProvider(requireActivity()).get(IncomingCallViewModel::class.java)

        hangupButton = view.findViewById(R.id.hangupButton)
        answerButton = view.findViewById(R.id.answerButton)

        viewModel.toast.observe(viewLifecycleOwner, { Toast.makeText(requireActivity(), it, Toast.LENGTH_SHORT).show() })

        hangupButton.setOnClickListener { viewModel.hangup() }
        answerButton.setOnClickListener { viewModel.answer() }
    }

    override fun onBackPressed() {
        viewModel.onBackPressed()
    }
}
```

You are done. It's time to run the app and make the call.