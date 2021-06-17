---
title: Kotlin
language: kotlin
---

```kotlin
private val muteListener = object : NexmoRequestListener<Void> {
    override fun onError(apiError: NexmoApiError) {
        Timber.d("Error: Unmute member ${apiError.message}")
    }

    override fun onSuccess(result: Void?) {
        Timber.d("Member unmuted")
    }
}

val nexmoMember = call?.myMember
nexmoMember?.disableMute(muteListener)
```
