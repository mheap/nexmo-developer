---
title: Objective-C
language: objective_c
---

```objective_c
[conversation getMembersPageWithPageSize:100 order:NXMPageOrderAsc completion:^(NSError * _Nullable error, NXMMembersSummaryPage * _Nullable page) {
    if (!error && page) {
        NSLog(@"%@", page.memberSummaries);
    }
}];
```
