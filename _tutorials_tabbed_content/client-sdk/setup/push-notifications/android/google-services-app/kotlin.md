---
title: Kotlin
language: kotlin
---

```kotlin
plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
}

dependencies {
  // Import the Firebase BoM
  implementation platform('com.google.firebase:firebase-bom:30.1.0')
}
```
