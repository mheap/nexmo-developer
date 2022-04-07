---
title: Swift
language: swift
menu_weight: 1
---

```swift
let message = NXMMessage(text: "")
conversation.sendMessage(message, completionHandler: { [weak self] (error) in
   ...
})
```
