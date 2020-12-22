---
title: Make a call
description: In this step you learn how to make an app-to-app call.
---

# Make a call

Add `callListener` property within the `MainViewModel` class:

```java
private NexmoRequestListener<NexmoCall> callListener = new NexmoRequestListener<NexmoCall>() {
    @Override
    public void onSuccess(@Nullable NexmoCall call) {
        callManager.setOnGoingCall(call);

        loadingMutableLiveData.postValue(false);

        NavDirections navDirections = MainFragmentDirections.actionMainFragmentToOnCallFragment(lastCalledUserName);
        navManager.navigate(navDirections);
    }

    @Override
    public void onError(@NonNull NexmoApiError apiError) {
        toastMutableLiveData.postValue(apiError.getMessage());
        loadingMutableLiveData.postValue(false);
    }
};
```

Locate the `startAppToAppCall` method within the `MainViewModel` class and fill its body to enable call:

```java
@SuppressLint("MissingPermission")
public void startAppToAppCall() {
    String otherUserName = otherUserLiveData.getValue();
    lastCalledUserName = otherUserName;
    client.call(otherUserName, NexmoCallHandler.SERVER, callListener);
    loadingMutableLiveData.postValue(true);
}
```

> **NOTE** Only Alice calling Bob scenario will work given used NCCO config.