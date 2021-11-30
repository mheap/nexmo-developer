---
title: Kotlin
language: kotlin
menu_weight: 1
---

Call:

```kotlin
client.reconnectCall("conversationId", "legId", object : NexmoRequestListener<NexmoCall> {
    override fun onSuccess(result: NexmoCall?) {
        // handle call
    }

    override fun onError(error: NexmoApiError) {
        // handle error
    }
})
```

Conversation media:

```kotlin
conversation.reconnectMedia()
```