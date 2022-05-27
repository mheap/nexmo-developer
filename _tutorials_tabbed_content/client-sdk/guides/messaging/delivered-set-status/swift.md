---
title: Swift
language: swift
menu_weight: 1
---

```swift
if conversation.myMember?.memberUuid != event.fromMemberId {
    conversation.sendMarkDeliveredMessage(event.uuid, completionHandler: nil)
}
```
