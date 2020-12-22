---
title: Receive a call
description: In this step you learn how to receive an in-app call
---

# Receive a call
## Create `CallManager`

Call manager is a helper class that holds reference to currently onging call. Right click on `com.vonage.tutorial.voice` package, select `New` > `Java Class`, enter `CallManager` as file name and select `Class`.

```java
package com.vonage.tutorial.voice.util;

import com.nexmo.client.NexmoCall;

public final class CallManager {

    private static CallManager INSTANCE;
    private static NexmoCall onGoingCall;

    public static CallManager getInstance() {
        if(INSTANCE == null) {
            INSTANCE = new CallManager();
        }

        return INSTANCE;
    }

    public NexmoCall getOnGoingCall() {
        return onGoingCall;
    }

    public void setOnGoingCall(NexmoCall onGoingCall) {
        CallManager.onGoingCall = onGoingCall;
    }
}
```

## Configure `fragment_main` layout

Prepare layout to the `main` screen. Open `fragment_main` and copy below code:

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

```java
package com.vonage.tutorial.voice;

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

public class MainViewModel extends ViewModel {

    private NexmoClient client = NexmoClient.get();
    private CallManager callManager = CallManager.getInstance();
    private NavManager navManager = NavManager.getInstance();

    private MutableLiveData<String> _toast = new MutableLiveData<>();
    public LiveData<String> toast = _toast;

    private MutableLiveData<Boolean> _loading = new MutableLiveData<>();
    public LiveData<Boolean> loading = _loading;

    private String otherUserName = null;

    private NexmoIncomingCallListener incomingCallListener = call -> {
        // TODO: "Fill listener body"
    };

    private NexmoRequestListener<NexmoCall> callListener = new NexmoRequestListener<NexmoCall>() {
        @Override
        public void onSuccess(@Nullable NexmoCall call) {
            callManager.setOnGoingCall(call);

            _loading.postValue(false);

            NavDirections navDirections = MainFragmentDirections.actionMainFragmentToOnCallFragment(otherUserName);
            navManager.navigate(navDirections);
        }

        @Override
        public void onError(@NonNull NexmoApiError apiError) {
            _toast_.postValue(apiError.getMessage());
            _loading.postValue(false);
        }
    };

    public void onInit(MainFragmentArgs mainFragmentArgs) {
        String currentUserName = mainFragmentArgs.getUserName();
        otherUserName = Config.getOtherUserName(currentUserName);

        // The same callback can be registered twice, so we are removing all callbacks to be save
        // TODO: "Register incoming call listener"
    }

    @Override
    protected void onCleared() {
        super.onCleared();
    }

    @SuppressLint("MissingPermission")
    public void startAppToAppCall() {
        // TODO: "Start a call"
    }


    public void onBackPressed() {
        client.logout();
    }
}

```

Locate the `incomingCallListener` property within the `MainViewModel` class and fill its body:

```java
private NexmoIncomingCallListener incomingCallListener = call -> {
    callManager.setOnGoingCall(call);
    String otherUserName = call.getCallMembers().get(0).getUser().getName();
    NavDirections navDirections = MainFragmentDirections.actionMainFragmentToIncomingCallFragment(otherUserName);
    navManager.navigate(navDirections);
};
```

Now you need to make sure that above listener will be called. Locate the `onInit` method within the `MainViewModel` class and configure listener:

```java
public void onInit(MainFragmentArgs mainFragmentArgs) {
    // ...

    // The same callback can be registered twice, so we are removing all callbacks to be save
    client.removeIncomingCallListeners();
    client.addIncomingCallListener(incomingCallListener);
}
```

## Configure view

Open `MainFragment` and fill the below code:

```java
package com.vonage.tutorial.voice;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

public class MainFragment extends Fragment implements BackPressHandler {

    MainViewModel viewModel;

    Button callBobButton;

    ProgressBar progressBar;

    private Observer<String> toastObserver = it -> Toast.makeText(requireActivity(), it, Toast.LENGTH_SHORT).show();

    private Observer<Boolean> loadingObserver = this::setDataLoading;

    public MainFragment() {
        super(R.layout.fragment_main);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        callBobButton = view.findViewById(R.id.callBobButton);
        progressBar = view.findViewById(R.id.progressBar);

        viewModel = new ViewModelProvider(requireActivity()).get(MainViewModel.class);

        assert getArguments() != null;
        MainFragmentArgs args = MainFragmentArgs.fromBundle(getArguments());
        viewModel.onInit(args);

        viewModel.toast.observe(getViewLifecycleOwner(), toastObserver);
        viewModel.loading.observe(getViewLifecycleOwner(), loadingObserver);

        callBobButton.setOnClickListener(it -> viewModel.startAppToAppCall());
    }

    @Override
    public void onBackPressed() {
        viewModel.onBackPressed();
    }

    private void setDataLoading(Boolean dataLoading) {
        callBobButton.setEnabled(!dataLoading);

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