---
title:  项目权限
description:  在此步骤中，您将向项目属性添加必要的权限。

---

项目权限
====

由于进行呼叫时您将使用麦克风，因此您需要请求麦克风的使用权限。

`Info.plist`
------------

每个 Xcode 项目都包含一个 `Info.plist` 文件，其中包含每个应用或捆绑包中所需的所有元数据 - 您将在 `AppToPhone` 组内找到该文件。

`Info.plist` 文件中需要新条目：

1. 将鼠标悬停在列表中的最后一个条目上，然后点击显示的小 `+` 按钮。

2. 从下拉列表中，选择 `Privacy - Microphone Usage Description` 并为其值添加 `Microphone access required in order to make and receive audio calls.`。

您的 `Info.plist` 应如下所示：

![Info.plist](/images/client-sdk/ios-voice/Xcode-permissions.jpg)

请求应用程序启动权限
----------

打开 `AppDelegate.swift`，并在包含 `UIKit` 的位置之后导入 `AVFoundation` 库：

```swift
import UIKit
import AVFoundation
```

接下来，调用 `application:didFinishLaunchingWithOptions:` 内的 `requestRecordPermission:`：

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    AVAudioSession.sharedInstance().requestRecordPermission { (granted:Bool) in
        NSLog("Allow microphone use. Response: %d", granted)
    }
    return true
}
```

构建和运行
-----

现在，您可以通过从顶部菜单中选择 `Product` > `Run`，或按 `Cmd + R` 来构建和运行项目，然后在模拟器中启动它。

请注意请求麦克风使用权限的提示：

![模拟器麦克风权限请求](/images/client-sdk/ios-voice/Simulator-microphone-permission-ask.jpg)

