---
title: Make a call
description: In this step you learn how to make an app-to-app call.
---

# Make a call

Add `callListener` property within the `MainViewModel` class:

```kotlin

```

Locate the `startAppToAppCall` method within the `MainViewModel` class and fill its body to enable call:

```kotlin
@SuppressLint("MissingPermission")
fun startAppToAppCall() {
    lastCalledUserName = otherUserName
    client.call(otherUserName, NexmoCallHandler.SERVER, callListener)
    loadingMutableLiveData.postValue(true)
}
```

> **NOTE** Only Alice calling Bob scenario will work given used NCCO config.