---
title: Objective-C
language: objective_c
menu_weight: 3
---

Call:

```objective_c
[NXMClient.shared reconnectCallWithConversationId:@"" andLegId:@"" completionHandler:^(NSError * _Nullable error, NXMCall * _Nullable call) {
    if (error) {
        // handle error
        return;
    }
    // handle call
}];
```

Conversation media:

```objective_c
[conversation reconnectMedia];
```