---
title: Build main screen
description: In this step you build main screen.
---

# Make a call

Main screen (`MainFragment` and `MainViewModel` classes) is responsible for starting a call.

## Create `CallManager`

Currently client SDK does not store call reference. We need to store call reference in the `CallManager` class, so it can be accessed from another screens.

Create `CallManager.kt` file in the `com.vonage.tutorial.voice` package to store the configuration. Right click on `voice` package and select `New` > `Kotlin Class/File`. Enter `CallManager` and select `Class`.

Replace file content with below code snippet:

```kotlin
package com.vonage.tutorial.voice

import com.nexmo.client.NexmoCall

object CallManager {
    var onGoingCall: NexmoCall? = null
}
```

## Update `fragment_main` layout

Open `fragment_main.xml` layout and click `Code` button in top right corner to display layout XML code:

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/layout-resource.png
```

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/show-code-view.png
```

Replace file content with below code snippet:

```xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:tools="http://schemas.android.com/tools"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="48dp">

    <TextView
            android:id="@+id/currentUserNameTextView"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="top|end"
            android:textSize="25sp"
            tools:text="Hello Alice" />

    <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:layout_gravity="center"
            android:gravity="center"
            android:orientation="vertical">

        <Button
                android:id="@+id/startAppToPhoneCallButton"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:drawablePadding="8dp"
                android:layout_marginTop="36dp"
                android:padding="16dp"
                android:text="Make phone call" />

        <androidx.core.widget.ContentLoadingProgressBar
                android:id="@+id/progressBar"
                android:layout_marginTop="36dp"
                style="?android:attr/progressBarStyleLarge"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:visibility="invisible" />
    </LinearLayout>

</FrameLayout>
```

## Update `MainViewModel`

Open `MainViewModel` and Replace file content with below code snippet:

```kotlin
package com.vonage.tutorial.voice.view.main

import android.annotation.SuppressLint
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoCall
import com.nexmo.client.NexmoCallHandler
import com.nexmo.client.NexmoClient
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener
import com.vonage.tutorial.voice.extension.asLiveData
import com.vonage.tutorial.voice.util.CallManager
import com.vonage.tutorial.voice.util.NavManager
import timber.log.Timber

class MainViewModel : ViewModel() {

    private val client = NexmoClient.get()
    private val callManager = CallManager
    private val navManager = NavManager

    private val _toast = MutableLiveData<String>()
    val toast = _toast as MutableLiveData<String>

    private val _loading = MutableLiveData<Boolean>()
    val loading = _loading as MutableLiveData<Boolean>

    private val callListener = object : NexmoRequestListener<NexmoCall> {
        override fun onSuccess(call: NexmoCall?) {
            callManager.onGoingCall = call

            _loading.postValue(false)

            val navDirections = MainFragmentDirections.actionMainFragmentToOnCallFragment()
            navManager.navigate(navDirections)
        }

        override fun onError(apiError: NexmoApiError) {
            Timber.e(apiError.message)
            _toast.postValue(apiError.message)
            _loading.postValue(false)
        }
    }

    override fun onCleared() {
        client.removeIncomingCallListeners()
    }

    @SuppressLint("MissingPermission")
    fun startAppToPhoneCall() {
        TODO("Start call")
    }

    fun onBackPressed() {
        client.logout()
    }
}
```

### Make a call

Repleace `startAppToPhoneCall` method within the `MainViewModel` class to enable the call:

```kotlin
@SuppressLint("MissingPermission")
fun startAppToPhoneCall() {
    // Callee number is ignored because it is specified in NCCO config
    client.call("IGNORED_NUMBER", NexmoCallHandler.SERVER, callListener)
    loadingMutableLiveData.postValue(true)
}
```

> **NOTE:** we set the `IGNORED_NUMBER` argument, because our number is specified in the NCCO config (Vonage application answer URL that you configured previously).


## Update `MainFragment`

Open `MainFragment` and Replace file content with below code snippet:

```kotlin
package com.vonage.tutorial.voice.view.main

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.ProgressBar
import androidx.core.view.isVisible
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.navArgs
import com.vonage.tutorial.R
import com.vonage.tutorial.voice.BackPressHandler
import com.vonage.tutorial.voice.extension.toast
import kotlin.properties.Delegates

class MainFragment : Fragment(R.layout.fragment_main), BackPressHandler {

    private lateinit var startAppToPhoneCallButton: Button
    private lateinit var progressBar: ProgressBar

    private var dataLoading: Boolean by Delegates.observable(false) { _, _, newValue ->
        startAppToPhoneCallButton.isEnabled = !newValue
        progressBar.isVisible = newValue
    }

    private val args: MainFragmentArgs by navArgs()

    private val viewModel by viewModels<MainViewModel>()

    private val toastObserver = Observer<String> {
        context?.toast(it)
    }

    private val loadingObserver = Observer<Boolean> {
        dataLoading = it
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.toast.observe(viewLifecycleOwner, toastObserver)
        viewModel.loading.observe(viewLifecycleOwner, loadingObserver)

        progressBar = view.findViewById(R.id.progressBar)
        startAppToPhoneCallButton = view.findViewById(R.id.startAppToPhoneCallButton)

        startAppToPhoneCallButton.setOnClickListener {
            viewModel.startAppToPhoneCall()
        }
    }

    override fun onBackPressed() {
        viewModel.onBackPressed()
    }
}
```
