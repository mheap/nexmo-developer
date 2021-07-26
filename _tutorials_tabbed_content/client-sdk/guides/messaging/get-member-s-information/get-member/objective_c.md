---
title: Objective-C
language: objective_c
---

```objective_c
[conversation getMemberWithMemberUuid:@"MEM_ID" completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
    if (!error && member) {
        NSLog(@"%@", member);
    }
}];
```
