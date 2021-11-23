---
title: Swift
language: swift
menu_weight: 4
---

To get `NXMMediaConnectionStatus` updates you need to conform to the `NXMConversationDelegate`. You can do this by setting it on a call's conversation object.

```swift
call.conversation.delegate = self
```

Then you can implement the `onMediaConnectionStateChange` delegate function

```swift
extension ViewController: NXMConversationDelegate {
    func conversation(_ conversation: NXMConversation, didReceive error: Error) {}
    
    func conversation(_ conversation: NXMConversation, onMediaConnectionStateChange state: NXMMediaConnectionStatus, legId: String) {
        // Update UI and/or reconnect
    }
}
```