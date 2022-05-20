---
title: Java
language: java
---

```java
// TTL value is in seconds, TTL ranges from 0 to 300.
NexmoClient nexmoClient = new NexmoClient.Builder()
    .pushNotificationTTL(30)
    .build(this);
```
