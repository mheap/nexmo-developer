---
title: Objective-C
language: objective_c
menu_weight: 2
---

```objective_c
NXMClientConfig *config = [[NXMClientConfig alloc] init];
// TTL value is in seconds, TTL ranges from 0 to 300.
config.pushNotificationTTL = 30;
[NXMClient setConfiguration:config];
```
