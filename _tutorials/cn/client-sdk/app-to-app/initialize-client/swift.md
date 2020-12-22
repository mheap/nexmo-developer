---
title:  NXMClient
description:  在此步骤中，您将对 Vonage 服务器进行身份验证。

---

`NXMClient`
===========

在开始聊天之前，Client SDK 需要对 Vonage 服务器进行身份验证。需要向 `ViewController.swift` 添加以下内容。

在文件顶部，导入 `NexmoClient`。

```swift
import UIKit
import NexmoClient
```

在 `statusLabel` 下方添加 `NXMClient` 实例、`NotificationCenter` 实例和 `User` 属性。

```swift
class ViewController: UIViewController {
    ...
    let statusLabel = UILabel()

    let client = NXMClient.shared
    let nc = NotificationCenter.default
    
    var user: User? {
        didSet {
            login()
        }
    }
}
```

按钮目标
----

为了使登录按钮正常工作，您需要向其添加目标，点击时这些目标将运行函数。在 `ViewController.swift` 文件中添加这两个函数。

```swift
class ViewController: UIViewController {
    ...

    override func viewDidLoad() {
        ...
    }

    ...

    @objc func setUserAsAlice() {
        self.user = User.Alice
    }

    @objc func setUserAsBob() {
        self.user = User.Bob
    }
}
```

然后将两个函数链接到 `viewDidLoad` 函数末尾其相应的按钮。

```swift
override func viewDidLoad() {
    ...

    loginAliceButton.addTarget(self, action: #selector(setUserAsAlice), for: .touchUpInside)
    loginBobButton.addTarget(self, action: #selector(setUserAsBob), for: .touchUpInside)
}
```

添加登录函数
------

在 `ViewController.swift` 的末尾，添加用户属性所需的 `login` 函数。此函数用于设置客户端的代理，并在用户属性设置为新值时登录。

```swift
class ViewController: UIViewController {
    ...

    override func viewDidLoad() {
        ...
    }

    func login() {
        guard let user = self.user else { return }
        client.setDelegate(self)
        client.login(withAuthToken: user.jwt)
    }
}
```

客户端代理
-----

为了使代理正常工作，您需要确保 `ViewController` 符合 `NXMClientDelegate`。

```swift
extension ViewController: NXMClientDelegate {
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        DispatchQueue.main.async {
            switch status {
            case .connected:
                self.statusLabel.text = "Connected"
            case .disconnected:
                self.statusLabel.text = "Disconnected"
            case .connecting:
                self.statusLabel.text = "Connecting"
            @unknown default:
                self.statusLabel.text = ""
            }
        }
    }

    func client(_ client: NXMClient, didReceiveError error: Error) {
        DispatchQueue.main.async {
            self.statusLabel.text = error.localizedDescription
        }
    }
}
```

如果遇到错误，则会显示错误，并且 `statusLabel` 会更新为相关的连接状态。

构建和运行
-----

按 `Cmd + R` 构建并再次运行。如果您点击其中一个登录按钮，它将以相应的用户身份登录客户端：

![界面已连接](/images/client-sdk/ios-in-app-voice/client.png)

