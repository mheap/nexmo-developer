---
title: Kotlin
language: kotlin
---

```kotlin
buildscript {
    repositories {
	    // Check that you have the following line (if not, add it):
        google()
    }

    dependencies {
	    // Add this line
	    classpath("com.google.gms:google-services:4.3.10")
    }
}

allprojects {
    repositories {
		// Check that you have the following line (if not, add it):
        google()
    }
}
```
