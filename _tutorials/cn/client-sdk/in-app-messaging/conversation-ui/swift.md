---
title:  构建聊天界面
description:  在此步骤中，您将构建应用的第二个画面。

---

构建聊天界面
======

为了能够进行聊天，您将需要为聊天界面创建新的视图控制器。从 Xcode 菜单中，选择 `File` > `New` > `File...`。选择 *Cocoa Touch 类* ，将其命名为 `ChatViewController`，子类为 `UIViewController`，语言为 `Swift`。

![Xcode 添加文件](/images/client-sdk/ios-messaging/chatviewcontrollerswift.png)

此操作将创建名为 `ChatViewController` 的新文件，在顶部导入 `NexmoClient`：

```swift
import UIKit
import NexmoClient
```

聊天界面将需要：

* 用于显示聊天消息的 `UITextView`
* 用于键入消息的 `UITextField`

打开 `ChatViewController.swift`，并通过编程方式进行添加：

```swift
class ChatViewController: UIViewController {
    let inputField = UITextField()
    let conversationTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        conversationTextView.text = ""
        conversationTextView.backgroundColor = .lightGray
        conversationTextView.isUserInteractionEnabled = false
        conversationTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(conversationTextView)
        
        inputField.delegate = self
        inputField.returnKeyType = .send
        inputField.layer.borderWidth = 1
        inputField.layer.borderColor = UIColor.lightGray.cgColor
        inputField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputField)
        
        NSLayoutConstraint.activate([
            conversationTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            conversationTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            conversationTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            conversationTextView.bottomAnchor.constraint(equalTo: inputField.topAnchor, constant: -20),
            
            inputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inputField.heightAnchor.constraint(equalToConstant: 40),
            inputField.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])   
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown),
         name: UIResponder.keyboardDidShowNotification, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification) {
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size {
            view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height - 20, right: 0)
        }
    }
```

在 `viewWillAppear` 函数中，将观察者添加到 `keyboardDidShowNotification`，该观察者调用 `keyboardWasShown`。`keyboardWasShown` 函数用于调整视图的布局边距，以移动输入字段。这样可防止在键入时 `inputField` 被键盘挡住。

`UITextField` 代理
----------------

您将需要符合 `UITextFieldDelegate`，才能知道用户何时完成输入，以将输入字段移动到其原始位置。在文件末尾添加：

```swift
extension ChatViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
```

显示 `ChatViewController`
-----------------------

构建了聊天界面后，您将需要从刚刚构建的登录屏幕中显示视图控制器。您将需要有关在两个视图控制器之间传递的登录用户的信息。在 `ChatViewController.swift` 中添加：

```swift
class ChatViewController: UIViewController {
    ...
    let client = NXMClient.shared
    let user: User

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
```

此操作为拥有 `User.type` 作为其参数的类定义了自定义初始值设定项，然后将其存储在本地 `user` 属性中。拥有用户信息后，您可以使用导航栏显示用户的聊天对象。在 `viewDidLoad` 中添加：

```swift
navigationItem.leftBarButtonItem = 
UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(self.logout))
title = "Conversation with (user.chatPartnerName)"

```

此操作还会在导航栏中创建注销按钮，将 `logout` 函数添加到 `ChatViewController.swift` 的末尾：

```swift
class ChatViewController: UIViewController {
    ...

     @objc func logout() {
        client.logout()
        dismiss(animated: true, completion: nil)
    }
```

现在，您可以显示聊天界面以及用户信息。为执行此操作，您需要编辑 `ViewController.swift` 文件中的 `NXMClientDelegate` 扩展：

```swift
extension ViewController: NXMClientDelegate {
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        guard let user = self.user else { return }

        switch status {
        case .connected:
            setStatusLabel("Connected")
            let navigationController = UINavigationController(rootViewController: ChatViewController(user: user))
            navigationController.modalPresentationStyle = .overFullScreen
            present(navigationController, animated: true, completion: nil)
        ...
        }
    }
    ...
}
```

如果用户连接成功，将显示包含所需用户数据的 `ChatViewController`。

构建和运行
-----

再次运行项目 (`Cmd + R`) 以在模拟器中启动。如果您使用其中一位用户登录，则会看到聊天界面

![聊天界面](/images/client-sdk/ios-messaging/chat.png)

