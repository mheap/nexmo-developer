---
title: Swift
language: swift
---

```swift
let config = NXMClientConfig()
config.apiUrl = restUrl
config.websocketUrl = wsUrl
config.ipsUrl = ipsUrl
config.iceServerUrls = iceUrls
NXMClient.setConfiguration(config)

// NOTE: You must call `setConfiguration` method before using `NXMClient.shared`.
```
