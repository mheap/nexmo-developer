---
title: Objective-C
language: objective_c
menu_weight: 2
---

```objective_c
if (conversation.myMember.memberUuid != event.fromMemberId) {
    [conversation sendMarkSeenMessage:event.uuid completionHandler:nil];
}
```