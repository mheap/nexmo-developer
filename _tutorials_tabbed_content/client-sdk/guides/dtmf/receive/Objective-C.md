---
title: Objective-C
language: objective_c
menu_weight: 3
---

The DTMF events will be received in the implementation of the `DTMFReceived:callMember:` optional method for your `NXMCallDelegate`:

```objective_c
- (void)call:(NXMCall *)call didReceive:(NSString *)dtmf fromMember:(NXMMember *)member {
    NSLog(@"DTMF received: `%@` from `%@`", dtmf, member.user.name);
}
```
