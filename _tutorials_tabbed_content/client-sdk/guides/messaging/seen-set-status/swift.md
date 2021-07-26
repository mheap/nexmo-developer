---
title: Swift
language: swift
menu_weight: 1
---

```swift
if conversation.myMember?.memberUuid != event.fromMemberId {
    conversation.sendMarkSeenMessage(event.uuid, completionHandler: nil)
}
```
