---
title: Groovy
language: groovy
---

```groovy
android {
    
    // ...

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    // Only for Kotlin projects
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }
}
```
