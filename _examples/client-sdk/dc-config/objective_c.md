---
title: Objective-C
language: objective_c
---

```objective_c
NXMClientConfig *config = [[NXMClientConfig alloc] init];
config.apiUrl = @"https://api-eu-1.nexmo.com/";
config.websocketUrl = @"wss://ws-eu-1.nexmo.com/";
config.ipsUrl = "https://api-eu-1.nexmo.com/v1/image/";
[NXMClient setConfiguration:config];
NXMClient *client = NXMClient.shared;
```
