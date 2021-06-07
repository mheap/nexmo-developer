---
title: Kotlin
language: kotlin
---

```kotlin
conversation.kick("memberId", object : NexmoRequestListener<Any> {
    override fun onSuccess(p0: Any?) {
        Log.d("TAG", "User kick success")
    }

    override fun onError(apiError: NexmoApiError) {
        Log.d("TAG", "Error: Unable to kick user ${apiError.message}")
    }
})
```
