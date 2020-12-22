---
title:  进行呼叫
description:  在此步骤中，您将学习如何进行应用到应用的呼叫。

---

进行呼叫
====

要进行呼叫，您将使用 `CallViewController` UI 中的 `callButton`。首先，您需要在 `viewDidLoad` 函数中向该按钮添加一个目标。

```objective_c
- (void)viewDidLoad {
    ...
    [self.callButton addTarget:self action:@selector(makeCall) forControlEvents:UIControlEventTouchUpInside];
}
```

点击 `callButton` 时，它将调用 `makeCall` 函数。将其添加到 `CallViewController.m` 类的末尾。

```objective_c
- (void)makeCall {
    [self setStatusLabelText:[NSString stringWithFormat:@"Calling %@", self.user.callPartnerName]];
    
    [self.client call:self.user.callPartnerName callHandler:NXMCallHandlerServer completionHandler:^(NSError * _Nullable error, NXMCall * _Nullable call) {
        if (error) {
            [self setStatusLabelText:error.localizedDescription];
            return;
        }
        
        [call setDelegate:self];
        [self setHangUpButtonHidden:NO];
        self.call = call;
    }];
}
```

`makeCall` 函数使用 `NXMClient` 实例进行呼叫。Client SDK 支持通过服务器、提供 `NCCO` 的应答 URL 进行呼叫，或者直接在应用程序中进行呼叫。如果没有错误，则可以设置呼叫的代理，以便监控对呼叫进行的更改并使 `hangUpButton` 可见。

构建和运行
-----

按 `Cmd + R` 构建并再次运行。您现在有了一个可以正常运行的呼叫应用！要进行测试，您可以在两个不同的模拟器/设备上运行该应用，然后从以 Bob 用户身份登录的设备呼叫以 Alice 用户身份登录的设备：

![发送消息](/images/client-sdk/ios-in-app-voice/active-call.png)

