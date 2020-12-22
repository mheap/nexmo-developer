---
title:  构建界面
description:  在此步骤中，您将构建应用的唯一一个画面。

---

构建界面
====

为了能够拨打电话，您将需要在屏幕上添加两个元素：

* 用于显示连接状态的 `UILabel`。
* 用于开始和结束呼叫的 `UIButton`

打开 `ViewController.swift`，并通过编程方式添加这两个元素：

```swift
class ViewController: UIViewController {

    var connectionStatusLabel = UILabel()
    var callButton = UIButton(type: .roundedRect)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        connectionStatusLabel.text = "Unknown"
        connectionStatusLabel.textAlignment = .center
        connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(connectionStatusLabel)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[label]-20-|", 
          options: [], metrics: nil, views: ["label" : connectionStatusLabel]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-40-[label(20)]", 
          options: [], metrics: nil, views: ["label" : connectionStatusLabel]))
        
        callButton.setTitle("Call", for: .normal)
        callButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(callButton)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[button]-20-|", 
          options: [], metrics: nil, views: ["button": callButton]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-40-[button(40)]", 
          options: [], metrics: nil, views: ["label" : connectionStatusLabel, "button": callButton]))
        callButton.alpha = 0
        callButton.addTarget(self, action: #selector(callButtonPressed(_:)), for: .touchUpInside)
    }

    @IBAction func callButtonPressed(_ sender: Any) {
         
    }

}
```

`callButton` 已隐藏，其 `alpha` 设置为 0，并且将在建立连接时显示。

此外，还添加了点击 `callButton` 时显示的目标，该目标将用于拨打电话和结束呼叫。

构建和运行
-----

再次运行项目 (`Cmd + R`) 以在模拟器中启动。

![界面](/images/client-sdk/ios-voice/interface.jpg)

