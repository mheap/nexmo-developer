---
title: Objective-C
language: objective_c
menu_weight: 3
---

```objective_c
NXMClientConfig *configuration = [[NXMClientConfig alloc] init];
configuration.autoMediaReoffer = YES;
[NXMClient setConfiguration:configuration];
```