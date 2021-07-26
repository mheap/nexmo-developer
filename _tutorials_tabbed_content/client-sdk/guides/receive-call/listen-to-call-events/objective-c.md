---
title: Objective-C
language: objective_c
menu_weight: 2
---

Add the current `ViewController`, or similar, as a delegate for the `call` before answering:

```objective_c
[call setDelegate:self];
[call answer:^(NSError * _Nullable error) {
    ...
}];
```

`ViewController` will now have to conform to `NXMCallDelegate`: 

```objective_c
@interface ViewController () <NXMCallDelegate>
...
@end

@implementation ViewController
...

//MARK:- NXMCallDelegate

- (void)call:(nonnull NXMCall *)call didUpdate:(nonnull NXMMember *)member withStatus:(NXMCallMemberStatus)status {
    // Handle call status updates
    ...
}

- (void)call:(nonnull NXMCall *)call didUpdate:(nonnull NXMMember *)member isMuted:(BOOL)muted {
    // Handle member muting updates
    ...
}

- (void)call:(nonnull NXMCall *)call didReceive:(nonnull NSError *)error {
    NSLog(@"call error: %@", [error localizedDescription]);
    // Handle call errors
    ...
}

@end
```
