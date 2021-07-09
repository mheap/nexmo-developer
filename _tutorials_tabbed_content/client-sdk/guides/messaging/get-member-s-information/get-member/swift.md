---
title: Swift
language: swift
---

```swift
conversation.getMemberWithMemberUuid("MEM_ID") { error, member in
    guard let member = member, error == nil else { return }
    print(member)
}
```
