---
title: Objective-c
language: objective_c
---

```objective_c
if (events.hasPreviousPage) {
    [events previousPage:^(NSError * _Nullable error, NXMEventsPage * _Nullable page) {
        // handle page events
    }];
}
```
