---
title: Swift
language: swift
menu_weight: 2
---

The DTMF events will be received in the implementation of the `dtmfReceived(_, callMember)` optional method for your `NXMCallDelegate`:


```swift
func call(_ call: NXMCall, didReceive dtmf: String, from member: NXMMember?) {
    print("DTMF received:`\(dtmf)` from `\(String(describing: member?.user.name))`")
}
```
