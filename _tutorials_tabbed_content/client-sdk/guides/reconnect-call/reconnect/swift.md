---
title: Swift
language: swift
menu_weight: 4
---

Call:

```swift
NXMClient.shared.reconnectCall(withConversationId: "", andLegId: "") { error, call in
    if error != nil {
        // handle error
        return
    }
    // handle call
}
```

Conversation media:

```swift
conversation.reconnectMedia()
```