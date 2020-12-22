---
title: Receive a call
description: In this step you learn how to receive an in-app call
---

# Receive a call
## Create `CallManager`

Call manager is a helper class that holds reference to currently onging call. Right click on `com.vonage.tutorial.voice` package, select `New` > `Java Class`, enter `CallManager` as file name and select `Class`.

```kotlin
package com.vonage.tutorial.voice.util

import com.nexmo.client.NexmoCall

object CallManager {
    var onGoingCall: NexmoCall? = null
}
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:tools="http://schemas.android.com/tools"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="48dp">

    <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:layout_gravity="center"
            android:gravity="center"
            android:orientation="vertical">

        <TextView
                android:id="@+id/waitTextView"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:drawablePadding="8dp"
                android:textSize="20sp"
                android:padding="16dp"
                android:text="Waiting for incoming call" />

        <TextView
                android:id="@+id/orTextView"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="36dp"
                android:text="or" />

        <Button
                android:id="@+id/callBobButton"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="36dp"
                android:drawablePadding="8dp"
                android:padding="16dp"
                tools:text="Start call with Bob" />

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
## Configure `MainViewModel`

Open the `MainViewModel` class paste below code:

```kotlin
package com.vonage.tutorial.voice.view.main

import android.annotation.SuppressLint
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoCall
import com.nexmo.client.NexmoCallHandler
import com.nexmo.client.NexmoClient
import com.nexmo.client.NexmoIncomingCallListener
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener
import com.vonage.tutorial.voice.Config
import com.vonage.tutorial.voice.extension.asLiveData
import com.vonage.tutorial.voice.util.CallManager
import com.vonage.tutorial.voice.util.NavManager
import com.vonage.tutorial.voice.util.observer
import timber.log.Timber

class MainViewModel : ViewModel() {

    private val client = NexmoClient.get()
    private val callManager = CallManager
    private val navManager = NavManager

    private var otherUserName: String by observer("") {
        otherUserNameMutableLiveData.postValue(it)
    }

    // SDK does not expose this info on call success
    private var lastCalledUserName = ""

    private val toastMutableLiveData = MutableLiveData<String>()
    val toastLiveData = toastMutableLiveData.asLiveData()

    private val loadingMutableLiveData = MutableLiveData<Boolean>()
    val loadingLiveData = loadingMutableLiveData.asLiveData()

    private val currentUserNameMutableLiveData = MutableLiveData<String>()
    val currentUserNameLiveData = currentUserNameMutableLiveData.asLiveData()

    private val otherUserNameMutableLiveData = MutableLiveData<String>()
    val otherUserNameLiveData = otherUserNameMutableLiveData.asLiveData()

    private val incomingCallListener = NexmoIncomingCallListener { call ->
        TODO("Fill listener body")
    }

    private val callListener = object : NexmoRequestListener<NexmoCall> {
        override fun onSuccess(call: NexmoCall?) {
            callManager.onGoingCall = call

            loadingMutableLiveData.postValue(false)

            val navDirections = MainFragmentDirections.actionMainFragmentToOnCallFragment(lastCalledUserName)
            navManager.navigate(navDirections)
        }

        override fun onError(apiError: NexmoApiError) {
            Timber.e(apiError.message)
            toastMutableLiveData.postValue(apiError.message)
            loadingMutableLiveData.postValue(false)
        }
    }

    fun onInit(arg: MainFragmentArgs) {
        val currentUserName = arg.userName
        currentUserNameMutableLiveData.postValue(currentUserName)
        otherUserName = Config.getOtherUserName(currentUserName)

        TODO("Register incoming call listener")
    }

    override fun onCleared() {
        client.removeIncomingCallListeners()
    }

    @SuppressLint("MissingPermission")
    fun startAppToAppCall() {
        lastCalledUserName = otherUserName
        client.call(otherUserName, NexmoCallHandler.IN_APP, callListener)
        loadingMutableLiveData.postValue(true)
    }

    fun onBackPressed() {
        client.logout()
    }
}
```

Locate the `incomingCallListener` property within the `MainViewModel` class and fill its body:

```kotlin
private val incomingCallListener = NexmoIncomingCallListener { call ->
    callManager.onGoingCall = call
    val otherUserName = call.callMembers.first().user.name
    val navDirections = MainFragmentDirections.actionMainFragmentToIncomingCallFragment(otherUserName)
    navManager.navigate(navDirections)
}
```

Now you need to make sure that above listener will be called. Locate the `onInit` method within the `MainViewModel` class and configure listener:

```kotlin
fun onInit(mainFragmentArg: MainFragmentArgs) {
    // ...

    client.removeIncomingCallListeners()
    client.addIncomingCallListener(incomingCallListener)
}
```
