---
title: Kotlin
language: kotlin
menu_weight: 2
---

```kotlin
client.getUserSessions("USR-id", 20, NexmoPageOrder.NexmoMPageOrderAsc, object: NexmoRequestListener<NexmoUserSessionsPage> {
    override fun onSuccess(result: NexmoUserSessionsPage?) {
        // handle page of sessions
    }

    override fun onError(error: NexmoApiError) {
        // handle error
    }
})
```

You can also call this function with a NexmoUser object:

```kotlin
user.getSessions(20, NexmoPageOrder.NexmoMPageOrderAsc, object: NexmoRequestListener<NexmoUserSessionsPage> {
    override fun onSuccess(result: NexmoUserSessionsPage?) {
        // handle page of sessions
    }

    override fun onError(error: NexmoApiError) {
        // handle error
    }
})
```