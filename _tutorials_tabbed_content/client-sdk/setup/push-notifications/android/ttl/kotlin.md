---
title: Kotlin
language: kotlin
---

```kotlin
// TTL value is in seconds, TTL ranges from 0 to 300.
val nexmoClient = NexmoClient.Builder()
    .pushNotificationTTL(30)
    .build(context)
```
