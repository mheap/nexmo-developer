---
title:  构建呼叫界面
description:  在此步骤中，您将构建应用的第二个画面。

---

构建呼叫界面
======

为了能够进行呼叫，您将需要为呼叫界面创建新的视图控制器。从 Xcode 菜单中，选择 `File` > `New` > `File...`。选择 *Cocoa Touch 类* ，将其命名为 `CallViewController`，子类为 `UIViewController`，语言为 `Swift`。

![Xcode 添加文件](/images/client-sdk/ios-in-app-voice/callviewcontroller.png)

此操作将创建名为 `CallViewController` 的新文件，在顶部导入 `NexmoClient`。

```swift
import UIKit
import NexmoClient
```

呼叫界面将需要：

* 用于发起呼叫的 `UIButton`
* 用于结束呼叫的 `UIButton`
* 用于显示状态更新的 `UILabel`

打开 `CallViewController.swift`，并通过编程方式进行添加。

```swift
class CallViewController: UIViewController {
    
    let callButton = UIButton(type: .system)
    let hangUpButton = UIButton(type: .system)
    let statusLabel = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        callButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(callButton)
        
        hangUpButton.setTitle("Hang up", for: .normal)
        hangUpButton.translatesAutoresizingMaskIntoConstraints = false

        setHangUpButtonHidden(true)
        view.addSubview(hangUpButton)
        
        setStatusLabelText("Ready to receive call...")
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            callButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            callButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            callButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            callButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            hangUpButton.topAnchor.constraint(equalTo: callButton.bottomAnchor, constant: 20),
            hangUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hangUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hangUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: hangUpButton.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setHangUpButtonHidden(_ isHidden: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hangUpButton.isHidden = isHidden
            self.callButton.isHidden = !self.hangUpButton.isHidden
        }
    }
    
    private func setStatusLabelText(_ text: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.statusLabel.text = text
        }
    }
}
```

有两个辅助函数 `setHangUpButtonHidden` 和 `setStatusLabelText`，可用于避免重复调用 `DispatchQueue.main.async`，因为根据 `UIKit` 的要求，需要在主线程上更改 UI 元素的状态。`setHangUpButtonHidden` 函数用于切换 `hangUpButton` 的可见性，因为只需要在活动呼叫期间显示此按钮。

显示 `CallViewController`
-----------------------

构建了呼叫界面后，您将需要从刚刚构建的登录屏幕中显示视图控制器。您将需要有关在两个视图控制器之间传递的登录用户的信息。在 `CallViewController.swift` 中添加以下内容。

```swift
class CallViewController: UIViewController {
    ...
    let user: User
    let client = NXMClient.shared
    let nc = NotificationCenter.default
    
    var call: NXMCall?

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
```

此操作为拥有 `User.type` 作为其参数的类定义了自定义初始值设定项，然后将其存储在本地 `user` 属性中。拥有用户信息后，您可以使用 `callButton` 显示用户呼叫的对象；在 `viewDidLoad` 中添加以下内容。

```swift
navigationItem.leftBarButtonItem = 
UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(self.logout))
callButton.setTitle("Call (user.callPartnerName)", for: .normal)
if user.name == "Alice" {
    callButton.alpha = 0
}
```

这将隐藏 Alice 的呼叫按钮，在此演示中，只有 Bob 才能打电话给 Alice。在生产应用程序中，应用程序的应答 URL 返回的 `NCCO` 将动态返回正确的用户名，以避免出现这种情况。它还会在导航栏中创建注销按钮，将相应的 `logout` 函数添加到末尾 `CallViewController.swift`

```swift
class CallViewController: UIViewController {
    ...

     @objc func logout() {
        client.logout()
        dismiss(animated: true, completion: nil)
    }
```

现在，您可以显示呼叫界面以及用户信息。为执行此操作，您需要编辑 `ViewController.swift` 文件中的 `NXMClientDelegate` 扩展。

```swift
extension ViewController: NXMClientDelegate {
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        guard let user = self.user else { return }

        switch status {
        case .connected:
            self.statusLabel.text = "Connected"
            let navigationController = UINavigationController(rootViewController: CallViewController(user: user))
            navigationController.modalPresentationStyle = .overFullScreen
            self.present(navigationController, animated: true, completion: nil)
        ...
        }
    }
    ...
}
```

如果用户连接成功，将显示包含所需用户数据的 `CallViewController`。

构建和运行
-----

再次运行项目 (`Cmd + R`) 以在模拟器中启动。如果您使用其中一位用户登录，则会看到呼叫界面

![呼叫界面](/images/client-sdk/ios-in-app-voice/call.png)

