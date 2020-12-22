---
title: Build main screen
description: In this step you build main screen.
---

# Build main screen

Main screen (`MainFragment` and `MainViewModel` classes) is responsible for starting a call and listening for incomming call.

## Create `CallManager`

Currently client SDK does not store call reference. We need to store call reference in the `CallManager` class, so it can be accessed from all screens.

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

    <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:layout_gravity="center"
            android:gravity="center"
            android:orientation="vertical">

        <TextView
                android:id="@+id/waitingTextView"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:drawablePadding="8dp"
                android:textSize="20sp"
                android:padding="16dp"
                android:text="Waiting for incoming call" />

        <Button
                android:id="@+id/callBobButton"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="36dp"
                android:drawablePadding="8dp"
                android:padding="16dp"
                android:text="Start call with Bob" />

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

    private val _toast = MutableLiveData<String>()
    val toast = _toast.asLiveData()

    private val _loading = MutableLiveData<Boolean>()
    val loading = _loading.asLiveData()

    private val incomingCallListener = NexmoIncomingCallListener { call ->
        TODO("Fill listener body")
    }

    private val callListener = object : NexmoRequestListener<NexmoCall> {
        override fun onSuccess(call: NexmoCall?) {
            callManager.onGoingCall = call

            _loading.postValue(false)

            val navDirections = MainFragmentDirections.actionMainFragmentToOnCallFragment()
            navManager.navigate(navDirections)
        }

        override fun onError(apiError: NexmoApiError) {
            _toast.postValue(apiError.message)
            _loading.postValue(false)
        }
    }

    init {
        TODO("Register incoming call listener")
    }

    override fun onCleared() {
        client.removeIncomingCallListeners()
    }

    @SuppressLint("MissingPermission")
    fun startAppToAppCall() {
        client.call(otherUserName, NexmoCallHandler.IN_APP, callListener)
        _loading.postValue(true)
    }

    fun onBackPressed() {
        client.logout()
    }
}
```

### Make a call

Replace `startAppToPhoneCall` method within the `MainViewModel` class to enable the call:

```kotlin
@SuppressLint("MissingPermission")
fun startAppToAppCall() {
    client.call("IGNORED", NexmoCallHandler.SERVER, callListener)
    _loading.postValue(true)
}
```

> **NOTE:** we set the `IGNORED` argument, because our number is specified in the NCCO config (Vonage application answer URL that you configured previously).

Replace `callListener` property with below implementation to know when call has started:

```java
private val callListener = object : NexmoRequestListener<NexmoCall> {
    override fun onSuccess(call: NexmoCall?) {
        callManager.onGoingCall = call

        _loading.postValue(false)

        val navDirections = MainFragmentDirections.actionMainFragmentToOnCallFragment()
        navManager.navigate(navDirections)
    }

    override fun onError(apiError: NexmoApiError) {
        _toast.postValue(apiError.message)
        _loading.postValue(false)
    }
}
```

### Handle incoming calls

Fill the body of `incomingCallListener` listener:

```kotlin
private val incomingCallListener = NexmoIncomingCallListener { it ->
    callManager.onGoingCall = it
    val navDirections = MainFragmentDirections.actionMainFragmentToIncomingCallFragment(otherUserName)
    navManager.navigate(navDirections)
}
```

Register `incomingCallListener` inside `init` block of `MainViewModel`:

```kotlin
init {
    client.addIncomingCallListener(incomingCallListener);
}
```


## Update `MainFragment`

Open `MainFragment` and Replace file content with below code snippet:

```kotlin
package com.vonage.tutorial.voice;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

public class MainFragment extends Fragment implements BackPressHandler {

    MainViewModel viewModel;

    Button startAppToPhoneCallButton;

    ProgressBar progressBar;


    private Observer<String> toastObserver = it -> Toast.makeText(requireActivity(), it, Toast.LENGTH_SHORT).show();

    private Observer<Boolean> loadingObserver = this::setDataLoading;

    public MainFragment() {
        super(R.layout.fragment_main);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        startAppToPhoneCallButton = view.findViewById(R.id.callBobButton);
        progressBar = view.findViewById(R.id.progressBar);

        viewModel = new ViewModelProvider(requireActivity()).get(MainViewModel.class);

        viewModel.toast.observe(getViewLifecycleOwner(), toastObserver);
        viewModel.loading.observe(getViewLifecycleOwner(), loadingObserver);

        startAppToPhoneCallButton.setOnClickListener(it -> viewModel.startAppToAppCall());
    }

    @Override
    public void onBackPressed() {
        viewModel.onBackPressed();
    }

    private void setDataLoading(Boolean dataLoading) {
        startAppToPhoneCallButton.setEnabled(!dataLoading);

        int visibility;

        if (dataLoading) {
            visibility = View.VISIBLE;
        } else {
            visibility = View.GONE;
        }

        progressBar.setVisibility(visibility);
    }
}
```

Now you can login and make a call. Last screen to implement is `on call screen`, where you can end existing call.