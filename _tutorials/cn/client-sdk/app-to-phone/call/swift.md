---
title:  拨打电话
description:  在此步骤中，您将拨打电话。

---

拨打电话
====

在 `ViewController` 类的顶部，`client` 声明下方，添加 `NXMCall` 属性以保留对正在进行的任何呼叫的引用

```swift
class ViewController: UIViewController, NXMClientDelegate {
    ...
    let client = NXMClient.shared
    var call: NXMCall?
    ...
}
```

根据 `call` 属性引用的对象，现在可以使用 `callButtonPressed` 方法来拨打电话或结束通话；每种情况都会触发 `placeCall` 和 `endCall` 方法。

请确保将下面的 `PHONE_NUMBER` 替换为您要拨打的实际电话号码。注意：必须与 gist NCCO 中指定的号码相同：

```swift
@IBAction func callButtonPressed(_ sender: Any) {
    if call == nil {
        placeCall()
    } else {
        endCall()
    }
}

func placeCall() {
    callButton.setTitle("End Call", for: .normal)
    client.call("PHONE_NUMBER", callHandler: .server) {  [weak self] (error, call) in
        if let error = error {
            self?.connectionStatusLabel.text = error.localizedDescription
            self?.callButton.setTitle("Call", for: .normal)
        }
        self?.call = call
    }
}

func endCall() {
    call?.hangup()
    call = nil
    callButton.setTitle("Call", for: .normal)
}
```

就是这样！现在您可以构建、运行和拨打电话了！太神奇了！

