---
title: Java
language: java
---

```java
// this is the current activity
String[] callsPermissions = new String[]{Manifest.permission.RECORD_AUDIO, Manifest.permission.READ_PHONE_STATE};
ActivityCompat.requestPermissions(this, callsPermissions, 123);
```
