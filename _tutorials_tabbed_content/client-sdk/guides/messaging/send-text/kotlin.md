---
title: Kotlin
language: kotlin
---

```kotlin
val messageText = "TEXT TO SEND"
val massage = NexmoMessage.fromText(messageText)

conversation.sendMessage(message, object : NexmoRequestListener<Void> {
    override fun onSuccess(p0: Void?) {
        Log.d("TAG", "Message has been sent")
    }

    override fun onError(apiError: NexmoApiError) {
        Log.d("TAG", "Error: Message not sent ${apiError.message}")
    }
})
```
