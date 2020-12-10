---
title: Build on call screen
description: In this step you build OnCall screen.
---

# Call

On call screen (`OnCallFragment` and `OnallViewModel` classes) is responsible for starting a call.

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

Open `on_callViewModel` and Replace file content with below code snippet:

```java
package com.vonage.tutorial.voice.view.oncall;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;
import com.nexmo.client.*;
import com.nexmo.client.request_listener.NexmoApiError;
import com.nexmo.client.request_listener.NexmoRequestListener;
import com.vonage.tutorial.R;
import com.vonage.tutorial.voice.util.CallManager;
import com.vonage.tutorial.voice.util.NavManager;
import timber.log.Timber;

public class OnCallViewModel extends ViewModel {

    private CallManager callManager = CallManager.getInstance();
    private NavManager navManager = NavManager.getInstance();

    private MutableLiveData<String> _toast = new MutableLiveData<>();
    LiveData<String> toast = _toast;

    private NexmoCallEventListener callEventListener = new NexmoCallEventListener() {
        @Override
        public void onMemberStatusUpdated(NexmoCallMemberStatus callMemberStatus, NexmoCallMember callMember) {
            Timber.d("CallEventListener.onMemberStatusUpdated: %s : %s", callMember.getUser().getName(), callMemberStatus);

            if (callMemberStatus == NexmoCallMemberStatus.COMPLETED || callMemberStatus == NexmoCallMemberStatus.CANCELED) {
                callManager.setOnGoingCall(null);
                navManager.popBackStack(R.id.mainFragment, false);
            }
        }

        @Override
        public void onMuteChanged(NexmoMediaActionState mediaActionState, NexmoCallMember callMember) {
            Timber.d("CallEventListener.onMuteChanged: %s : %s", callMember.getUser().getName(), mediaActionState);
        }

        @Override
        public void onEarmuffChanged(NexmoMediaActionState mediaActionState, NexmoCallMember callMember) {
            Timber.d("CallEventListener.onEarmuffChanged: %s : %s", callMember.getUser().getName(), mediaActionState);
        }

        @Override
        public void onDTMF(String dtmf, NexmoCallMember callMember) {
            Timber.d("CallEventListener.onDTMF: %s : %s", callMember.getUser().getName(), dtmf);
        }
    };

    public OnCallViewModel() {
        NexmoCall onGoingCall;

        if (callManager.getOnGoingCall() == null) {
            throw new RuntimeException("Call is null");
        } else {
            onGoingCall = callManager.getOnGoingCall();
        }

        onGoingCall.addCallEventListener(callEventListener);
    }

    @Override
    protected void onCleared() {
        super.onCleared();

        NexmoCall ongoingCall = callManager.getOnGoingCall();

        if (ongoingCall != null) {
            ongoingCall.removeCallEventListener(callEventListener);
        }
    }

    public void onBackPressed() {
        hangupInternal();
    }

    public void hangup() {
        hangupInternal();
    }

    private void hangupInternal() {
        //TODO: Hangup incoming call
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

Open `OnallFragment` and Replace file content with below code snippet:

```java
package com.vonage.tutorial.voice.view.oncall;

import android.os.Bundle;
import android.view.View;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.vonage.tutorial.R;
import com.vonage.tutorial.voice.BackPressHandler;

public class OnCallFragment extends Fragment implements BackPressHandler {

    OnCallViewModel viewModel;

    FloatingActionButton hangupFab;

    public OnCallFragment() {
        super(R.layout.fragment_on_call);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        viewModel = new ViewModelProvider(requireActivity()).get(OnCallViewModel.class);

        hangupFab = view.findViewById(R.id.hangupFab);

        viewModel.toast.observe(getViewLifecycleOwner(), it -> Toast.makeText(requireActivity(), it, Toast.LENGTH_SHORT));

        hangupFab.setOnClickListener(view1 -> viewModel.hangup());
    }


    @Override
    public void onBackPressed() {
        viewModel.onBackPressed();
    }
}
```
