---
title: Java
language: java
---

```java
import com.nexmo.client.NexmoClient;
import com.nexmo.utils.logger.ILogger.eLogLevel;

NexmoClient client = new NexmoClient.Builder()
    .logLevel(eLogLevel.SENSITIVE)
    .build(this);
// Available options are CRITICAL, WARNING, DEBUG, INFO, VERBOSE, SENSITIVE
```
