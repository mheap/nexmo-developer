---
title: Groovy
language: groovy
---

```groovy
//...

allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url "https://artifactory.ess-dev.com/artifactory/gradle-dev-local"
        }
        
    }
}
```
