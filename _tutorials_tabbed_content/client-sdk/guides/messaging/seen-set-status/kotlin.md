---
title: Kotlin
language: kotlin
menu_weight: 1
---

```kotlin
override fun onMessageEvent(messageEvent: NexmoMessageEvent) {
    messageEvent.markAsSeen(object: NexmoRequestListener<Void> {
        override fun onError(error: NexmoApiError) {...}
        override fun onSuccess(result: Void?) {...}
    })
}
```
