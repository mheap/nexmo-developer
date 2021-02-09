---
title: Kotlin
language: kotlin
---

```kotlin
import com.nexmo.client.NexmoClient
import com.nexmo.utils.logger.ILogger.eLogLevel

val nexmoClient = NexmoClient.Builder()
        .logLevel(eLogLevel.SENSITIVE)
        .build(this)
// Available options are CRITICAL, WARNING, DEBUG, INFO, VERBOSE, SENSITIVE
```
