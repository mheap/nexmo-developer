---
title: Objective-C
language: objective_c
menu_weight: 2
---

```objective_c
NXMessage *message = [[NXMMessage alloc] initWithText:@""];
[conversation sendMessage:message completionHandler:^(NSError * _Nullable error) {
    ...
}];
```
