---
title:  接收呼叫
description:  在此步骤中，您将学习如何接收应用内呼叫

---

接收呼叫
====

构建了呼叫界面后，您现在可以添加接收呼叫所需的代码。`NXMClientDelegate` 具有在来电时可调用的函数。在 `ViewController.swift` 文件的 `NXMClientDelegate` 扩展中为其添加实现。

```swift
extension ViewController: NXMClientDelegate {
    ...

    func client(_ client: NXMClient, didReceive call: NXMCall) {
        nc.post(name: .call, object: call)
    }
}

extension Notification.Name {
    static var call: Notification.Name {
        return .init(rawValue: "NXMClient.incommingCall")
    }
}
```

`CallViewController` 类将在前台运行，并且该类将处理呼叫，因此将使用 `NSNotification` post 传递该呼叫。为了使 `CallViewController` 收到此通知，需要观察它。在 `CallViewController` 中添加以下内容：

```swift
class CallViewController: UIViewController {
    ...
    
    override func viewDidLoad() {
        ...

        nc.addObserver(self, selector: #selector(didReceiveCall), name: .call, object: nil)

        hangUpButton.addTarget(self, action: #selector(endCall), for: .touchUpInside)
    }

    ...

    @objc private func didReceiveCall(_ notification: Notification) {
        guard let call = notification.object as? NXMCall else { return }
        DispatchQueue.main.async { [weak self] in
            self?.displayIncomingCallAlert(call: call)
        }
    }
    
    private func displayIncomingCallAlert(call: NXMCall) {
        var from = "Unknown"
        if let otherParty = call.otherCallMembers.firstObject as? NXMCallMember {
            from = otherParty.user.name
        }

        let alert = UIAlertController(title: "Incoming call from", message: from, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Answer", style: .default, handler: { _ in
            call.answer { error in
                if error != nil {
                    self.setStatusLabelText(error?.localizedDescription)
                    return
                }
                call.setDelegate(self)
                self.setHangUpButtonHidden(false)
                self.setStatusLabelText("On a call with (from)")
                self.call = call
            }
        }))

        alert.addAction(UIAlertAction(title: "Reject", style: .destructive, handler: { _ in
            call.reject(nil)
        }))

        self.present(alert, animated: true, completion: nil)
    }

    @objc private func endCall() {
        call?.hangup()
        self.setHangUpButtonHidden(true)
        self.setStatusLabelText("Ready to receive call...")
    }
}
```

收到通知后，将调用 `didReceiveCall`，该函数将依次调用 `displayIncomingCallAlert`，以便向用户显示接受或拒绝该呼叫的选项。如果用户接受，UI 将更新为显示用户的通话对象，并且 `hangUpButton` 变为可见状态。如果点击 `hangUpButton`，则会调用 `endCall`，将挂断电话并更新 UI。

呼叫代理
----

与 `NXMClient` 类似，`NXMCall` 也拥有用于处理呼叫更改的代理。在 `CallViewController.swift` 文件的末尾添加 `NXMCallDelegate` 的符合项。

```swift
extension CallViewController: NXMCallDelegate {
    func call(_ call: NXMCall, didUpdate callMember: NXMCallMember, with status: NXMCallMemberStatus) {
        switch status {
        case .answered:
            guard callMember.user.name != self.user.name else { return }
            setStatusLabelText("On a call with (callMember.user.name)")
        case .completed:
            setStatusLabelText("Call ended")
            setHangUpButtonHidden(true)
            self.call = nil
        default:
            break
        }
    }

    func call(_ call: NXMCall, didReceive error: Error) {
        setStatusLabelText(error.localizedDescription)
    }

    func call(_ call: NXMCall, didUpdate callMember: NXMCallMember, isMuted muted: Bool) {}
}
```

在下一步中，您将添加进行呼叫所需的代码。

