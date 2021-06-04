---
title: Kotlin
language: kotlin
---

```kotlin
private val muteListener = object : NexmoRequestListener<Void> {
    override fun onError(apiError: NexmoApiError) {
        Timber.d("Error: Mute member ${apiError.message}")
    }

    override fun onSuccess(result: Void?) {
        Timber.d("Member muted")
    }
}

val nexmoMember = call?.allMembers?.firstOrNull()
nexmoMember?.enableMute(muteListener)
```
