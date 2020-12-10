---
title: Build main screen
description: In this step you build main screen.
---

# Call

Main screen (`MainFragment` and `MainViewModel` classes) is responsible for starting a call.

## Update `fragment_chat` layout

Open `fragment_chat.xml` layout and click `Code` button in top right corner to display layout XML code:

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
                android:drawableEnd="@drawable/ic_phone"
                android:drawablePadding="8dp"
                android:layout_marginTop="36dp"
                android:padding="16dp"
                android:text="@string/make_phone_call" />

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

## Update `ChatViewModel`

Open `ChatViewModel` and Replace file content with below code snippet:

```java
package com.vonage.tutorial.voice.view.main;

import android.annotation.SuppressLint;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;
import androidx.navigation.NavDirections;
import com.nexmo.client.NexmoCall;
import com.nexmo.client.NexmoCallHandler;
import com.nexmo.client.NexmoClient;
import com.nexmo.client.NexmoIncomingCallListener;
import com.nexmo.client.request_listener.NexmoApiError;
import com.nexmo.client.request_listener.NexmoRequestListener;
import com.vonage.tutorial.voice.util.CallManager;
import com.vonage.tutorial.voice.util.NavManager;
import timber.log.Timber;

public class MainViewModel extends ViewModel {

    private NexmoClient client = NexmoClient.get();
    private CallManager callManager = CallManager.getInstance();
    private NavManager navManager = NavManager.getInstance();

    private MutableLiveData<String> _toast = new MutableLiveData<>();
    public LiveData<String> toast = toastMutableLiveData;

    private MutableLiveData<Boolean> loadingMutableLiveData = new MutableLiveData<>();
    public LiveData<Boolean> loadingLiveData = loadingMutableLiveData;

    private NexmoIncomingCallListener callListener = call -> {
        callManager.setOnGoingCall(call);
        String otherUserName = call.getCallMembers().get(0).getUser().getName();
        NavDirections navDirections = MainFragmentDirections.actionMainFragmentToOnCallFragment();
        navManager.navigate(navDirections);
    };

    private NexmoRequestListener<NexmoCall> callListener = new NexmoRequestListener<NexmoCall>() {
        @Override
        public void onSuccess(@Nullable NexmoCall call) {
            callManager.setOnGoingCall(call);

            loadingMutableLiveData.postValue(false);

            NavDirections navDirections = MainFragmentDirections.actionMainFragmentToOnCallFragment();
            navManager.navigate(navDirections);
        }

        @Override
        public void onError(@NonNull NexmoApiError apiError) {
            Timber.e(apiError.getMessage());
            toastMutableLiveData.postValue(apiError.getMessage());
            loadingMutableLiveData.postValue(false);
        }
    };

    @Override
    protected void onCleared() {
        super.onCleared();
    }

    @SuppressLint("MissingPermission")
    public void startAppToPhoneCall() {
        // TODO: Start call
    }

    public void onBackPressed() {
        client.logout();
    }
}

```

### Make a call

Repleace `startAppToPhoneCall` method within the `MainViewModel` class to enable the call:

```java
@SuppressLint("MissingPermission")
public void startAppToPhoneCall() {
    // Callee number is ignored because it is specified in NCCO config
    client.call("IGNORED_NUMBER", NexmoCallHandler.SERVER, callListener);
    loadingMutableLiveData.postValue(true);
}
```

> **NOTE:** we set the `IGNORED_NUMBER` argument, because our number is specified in the NCCO config (Vonage application answer URL that you configured previously).

## Update `MainFragment`

Open `MainFragment` and Replace file content with below code snippet:

```java
package com.vonage.tutorial.voice.view.main;

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
import com.vonage.tutorial.R;
import com.vonage.tutorial.voice.BackPressHandler;

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

        startAppToPhoneCallButton = view.findViewById(R.id.startAppToPhoneCallButton);
        progressBar = view.findViewById(R.id.progressBar);

        viewModel = new ViewModelProvider(requireActivity()).get(MainViewModel.class);

        viewModel.toast.observe(getViewLifecycleOwner(), toastObserver);
        viewModel.loading.observe(getViewLifecycleOwner(), loadingObserver);

        startAppToPhoneCallButton.setOnClickListener(it -> viewModel.startAppToPhoneCall());
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
