---
title: Kotlin
language: kotlin
menu_weight: 1
---

To get `MediaConnectionState` updates you need to add a `NexmoMediaStatusListener`. You can do this by setting it on a call's conversation object.

```kotlin
call?.conversation?.addMediaStatusListener(object: NexmoMediaStatusListener {
    override fun onMediaConnectionStateChange(legId: String, status: EMediaConnectionState) {
        // Update UI and/or reconnect
    }
})
```
