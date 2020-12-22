---
title:  NXMClient
description:  在此步骤中，您将对 Vonage 服务器进行身份验证。

---

`NXMClient`
===========

在您拨打电话之前，Client SDK 需要对 Vonage 服务器进行身份验证。需要向 `ViewController.swift` 添加以下内容。

在文件顶部，导入 `NexmoClient`。

```swift
import UIKit
import NexmoClient
```

在 `callButton` 下方添加 `NXMClient` 实例。

```swift
class ViewController: UIViewController {
    ...
    var callButton = UIButton(type: .roundedRect)
    let client = NXMClient.shared
    ...
}
```

添加 JWT
------

在 `viewDidLoad` 的末尾，设置客户端代理并登录 - 请确保将 `ALICE_JWT` 替换为您在上一步中创建的 `JWT`。请谨记，令牌的有效期已设置为 6 个小时，因此如果令牌太旧，则需要生成新的令牌。

```swift
override func viewDidLoad() {
    ...
    client.setDelegate(self)
    client.login(withAuthToken: "ALICE_JWT")
}
```

客户端代理
-----

为了使代理部分正常工作，您需要确保 `ViewController` 符合 `NXMClientDelegate`。在文件末尾添加此扩展。

```swift
extension ViewController: NXMClientDelegate {
    
    func client(_ client: NXMClient, didReceiveError error: Error) {
        print("✆  ‼️ connection error: (error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
            self?.callButton.alpha = 0
            self?.connectionStatusLabel.text = error.localizedDescription
        }
    }
    
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus,
                reason: NXMConnectionStatusReason) {
        DispatchQueue.main.async { [weak self] in
            self?.callButton.alpha = 0
            switch status {
            case .connected:
                self?.connectionStatusLabel.text = "Connected"
                self?.callButton.alpha = 1
            case .disconnected:
                self?.connectionStatusLabel.text = "Disconnected"
            case .connecting:
                self?.connectionStatusLabel.text = "Connecting"
            @unknown default:
                self?.connectionStatusLabel.text = "Unknown"
            }
        }
    }
    
}
```

如果遇到错误，则会显示错误，并且 `connectionStatusLabel` 会更新为相关的连接状态。此外，连接时还会显示 `callButton`

构建和运行
-----

`Cmd + R` 构建并再次运行：

![界面已连接](/images/client-sdk/ios-voice/interface-connected.jpg)

