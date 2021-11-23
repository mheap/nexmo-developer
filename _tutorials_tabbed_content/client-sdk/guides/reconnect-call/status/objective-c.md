---
title: Objective-C
language: objective_c
menu_weight: 3
---

To get `NXMMediaConnectionStatus` updates you need to conform to the `NXMConversationDelegate`. You can do this by setting it on a call's conversation object.

```objective_c
call.conversation.delegate = self
```

Then you can implement the `onMediaConnectionStateChange` delegate function

```objective_c
- (void)conversation:(NXMConversation *)conversation didReceive:(NSError *)error {}

- (void)conversation:(NXMConversation *)conversation onMediaConnectionStateChange:(NXMMediaConnectionStatus)state legId:(NSString *)legId {
    // Update UI and/or reconnect
}
```