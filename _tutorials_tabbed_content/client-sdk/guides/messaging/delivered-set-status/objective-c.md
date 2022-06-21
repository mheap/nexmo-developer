---
title: Objective-C
language: objective_c
menu_weight: 2
---

```objective_c
if (conversation.myMember.memberUuid != event.fromMemberId) {
    [conversation sendMarkDeliveredMessage:event.uuid completionHandler:nil];
}
```