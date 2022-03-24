---
title: Swift
language: swift
---

``` swift
let config = NXMClientConfig()
config.apiUrl = "https://api-eu-1.nexmo.com/"
config.websocketUrl = "wss://ws-eu-1.nexmo.com/"
config.ipsUrl = "https://api-eu-1.nexmo.com/v1/image/"
NXMClient.setConfiguration(config)
let nexmoClient = NXMClient.shared
```
