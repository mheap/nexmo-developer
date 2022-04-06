---
title: Kotlin
language: kotlin
---

```kotlin
conversation.sendMessage(message, object : NexmoRequestListener<Void> {
    override fun onSuccess(p0: Void?) {
        Log.d("TAG", "Message has been sent")
    }

    override fun onError(apiError: CoreConversationApiError) {
        Log.d("TAG", "Error: Message not sent ${apiError.message}")
    }
})
```
