---
title: Swift
language: swift
menu_weight: 1
---

```swift
let config = NXMClientConfig()
// TTL value is in seconds, TTL ranges from 0 to 300.
config.pushNotificationTTL = 30
NXMClient.setConfiguration(config)
```
