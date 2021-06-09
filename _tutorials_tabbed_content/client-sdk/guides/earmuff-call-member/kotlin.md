---
title: Kotlin
language: kotlin
---

```kotlin
private val earmuffListener = object : NexmoRequestListener<Void> {
    override fun onSuccess(result: Void?) {
        Timber.d("Member earmuff enabled")
    }

    override fun onError(error: NexmoApiError) {
        TODO("not implemented")
    }
}

val nexmoMember = call?.allMembers?.firstOrNull()
nexmoMember?.enableEarmuff(earmuffListener)
```
