---
title: Objective-C
language: objective_c
---

```objective_c
NXMClientConfig *config = [[NXMClientConfig alloc] init];
config.apiUrl = restUrl;
config.websocketUrl = wsUrl;
config.ipsUrl = ipsUrl;
config.iceServerUrls = iceUrls;
[NXMClient setConfiguration:config];
// NOTE: You must call `setConfiguration` method before using `NXMClient.shared`.
```
