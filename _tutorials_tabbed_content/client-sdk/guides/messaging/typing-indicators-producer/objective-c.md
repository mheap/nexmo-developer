---
title: Objective-C
language: objective_c
menu_weight: 2
---

```objective_c
// call this when member starts typing
[conversation sendStartTyping:^(NSError * _Nullable error) completionHandler];

// call this when member stops typing
[conversation sendStopTyping:^(NSError * _Nullable error) completionHandler];
```