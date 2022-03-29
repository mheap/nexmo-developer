---
title: Kotlin
language: kotlin
---

```kotlin
// this is the current activity
val callsPermissions = arrayOf(Manifest.permission.RECORD_AUDIO, Manifest.permission.READ_PHONE_STATE)
ActivityCompat.requestPermissions(this, callsPermissions, 123)
```
