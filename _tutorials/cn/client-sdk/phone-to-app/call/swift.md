---
title:  接收呼叫
description:  在此步骤中，您将接收呼叫。

---

接收呼叫
====

在 `ViewController` 类的顶部，`client` 声明下方，添加 `NXMCall` 属性以保留对正在进行的任何呼叫的引用。

```swift
class ViewController: UIViewController {
    ...
    let client = NXMClient.shared
    var call: NXMCall?
    ...
}
```

当应用程序收到呼叫时，您希望提供接受或拒绝通话的选项。为此，请将 `displayIncomingCallAlert` 函数添加到 `ViewController` 类。

```swift
class ViewController: UIViewController {
    ...
    func displayIncomingCallAlert(call: NXMCall) {
        var from = "Unknown"
        if let otherParty = call.otherCallMembers.firstObject as? NXMCallMember {
            from = otherParty.channel?.from.data ?? "Unknown"
        }
        
        let alert = UIAlertController(title: "Incoming call from", message: from, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Answer", style: .default, handler: { _ in
            self.call = call
            call.answer(nil)

        }))
        alert.addAction(UIAlertAction(title: "Reject", style: .default, handler: { _ in
            call.reject(nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
```

`displayIncomingCallAlert` 函数使用 `NXMCall` 作为参数，使用此参数可以访问 `NXMCallMember` 类型的呼叫成员来检索呼入电话的电话号码。请注意，`UIAlertAction` 用于应答呼叫，您之前已将呼叫分配给该属性。

为了使用 `displayIncomingCallAlert`，您需要使用 `NXMClientDelegate`，它包含当客户端收到呼入 `NXMCall` 时系统将调用的函数。

```swift
extension ViewController: NXMClientDelegate {
    ...
    func client(_ client: NXMClient, didReceive call: NXMCall) {
        DispatchQueue.main.async { [weak self] in
            self?.displayIncomingCallAlert(call: call)
        }
    }
}
```

构建和运行
-----

按 `Cmd + R` 构建并再次运行，当您呼叫之前与您的应用程序链接的号码时，将显示提醒。您可以接听，呼叫将被接通！

![呼入电话提醒](/meta/client-sdk/ios-phone-to-app/alert.png)

