---
title:  构建登录界面
description:  在此步骤中，您将构建应用的第一个画面。

---

构建登录界面
======

为了能够登录，您将需要在屏幕上添加三个元素：

* 用于使 Alice 登录的 `UIButton`
* 用于使 Bob 登录的 `UIButton`
* 用于显示连接状态的 `UILabel`。

打开 `ViewController.swift`，并通过编程方式进行添加。

```swift
class ViewController: UIViewController {

    let loginAliceButton = UIButton(type: .system)
    let loginBobButton = UIButton(type: .system)
    let statusLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loginAliceButton.setTitle("Log in as Alice", for: .normal)
        loginAliceButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginAliceButton)
        
        loginBobButton.setTitle("Log in as Bob", for: .normal)
        loginBobButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginBobButton)
        
        statusLabel.text = ""
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            loginAliceButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginAliceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginAliceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginAliceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            loginBobButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginBobButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginBobButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginBobButton.topAnchor.constraint(equalTo: loginAliceButton.bottomAnchor, constant: 20),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statusLabel.topAnchor.constraint(equalTo: loginBobButton.bottomAnchor, constant: 20)
        ])
    }
}
```

构建和运行
-----

再次运行项目 (`Cmd + R`) 以在模拟器中启动。

![界面](/images/client-sdk/ios-in-app-voice/login.png)

