---
title: Swift
language: swift
menu_weight: 1
---

Add the current `ViewController`, or similar, as a delegate for the `call` object returned when making a call:

```swift
call.setDelegate(self)
call.answer { [weak self] error in
    ...
}
```

`ViewController` will now have to conform to `NXMCallDelegate`: 

```swift
extension ViewController: NXMCallDelegate {

    func call(_ call: NXMCall, didUpdate member: NXMMember, with status: NXMCallMemberStatus) {
        // Handle call status updates
        ...
    }
    
    func call(_ call: NXMCall, didUpdate member: NXMMember, isMuted muted: Bool) {
        // Handle member muting updates
        ...
    }
    
    func call(_ call: NXMCall, didReceive error: Error) {
        print("call error: \(error.localizedDescription)")
        // Handle call errors
        ...
    }
    
}
```
