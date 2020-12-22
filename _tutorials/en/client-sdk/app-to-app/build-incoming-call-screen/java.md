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

## Update `IncommingCallViewModel`

Open `IncommingCallViewModel` and Replace file content with below code snippet:

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
import com.nexmo.client.request_listener.NexmoApiError;
import com.nexmo.client.request_listener.NexmoRequestListener;

public class IncomingCallViewModel extends ViewModel {

    private NavManager navManager = NavManager.getInstance();
    private CallManager callManager = CallManager.getInstance();

    private MutableLiveData<String> _toast = new MutableLiveData<>();
    public LiveData<String> toast = _toast;

    public void hangup() {
        hangupInternal(true);
    }

    @SuppressLint("MissingPermission")
    public void answer() {
        callManager.getOnGoingCall().answer(new NexmoRequestListener<NexmoCall>() {

            @Override
            public void onSuccess(@Nullable NexmoCall call) {
                NavDirections navDirections = IncomingCallFragmentDirections.actionIncomingCallFragmentToOnCallFragment();
                navManager.navigate(navDirections);
            }

            @Override
            public void onError(@NonNull NexmoApiError apiError) {
                _toast.postValue(apiError.getMessage());
            }
        });
    }

    public void onBackPressed() {
        hangupInternal(false);
    }

    public void hangupInternal(Boolean popBackStack) {
        // TODO: Hangup
    }
}
```

### Hangup incoming phone call

Locate `hangupInternal` method and replace its body:


```java
private void hangupInternal() {
    NexmoCall ongoingCall = callManager.getOnGoingCall();

    if (ongoingCall != null) {
        ongoingCall.hangup(new NexmoRequestListener<NexmoCall>() {
            @Override
            public void onSuccess(@Nullable NexmoCall call) {
                callManager.setOnGoingCall(null);
            }

            @Override
            public void onError(@NonNull NexmoApiError apiError) {
                _toast.postValue(apiError.getMessage());
            }
        });
    }
}
```

## Update `IncomingCallFragment`

Open `IncomingCallFragment` and Replace file content with below code snippet:

```java
package com.vonage.tutorial.voice;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

public class IncomingCallFragment extends Fragment implements BackPressHandler {

    private IncomingCallViewModel viewModel;

    Button hangupButton;

    Button answerButton;

    public IncomingCallFragment() {
        super(R.layout.fragment_incoming_call);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        viewModel = new ViewModelProvider(requireActivity()).get(IncomingCallViewModel.class);

        hangupButton = view.findViewById(R.id.hangupButton);
        answerButton = view.findViewById(R.id.answerButton);

        viewModel.toast.observe(getViewLifecycleOwner(), it -> Toast.makeText(requireActivity(), it, Toast.LENGTH_SHORT));

        hangupButton.setOnClickListener(it -> viewModel.hangup());

        answerButton.setOnClickListener(it -> viewModel.answer());
    }


    @Override
    public void onBackPressed() {
        viewModel.onBackPressed();
    }
}
```

You are done. It's time to run the app and make the call.
