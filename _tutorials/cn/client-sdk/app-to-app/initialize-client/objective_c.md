---
title:  NXMClient
description:  在此步骤中，您将对 Vonage 服务器进行身份验证。

---

`NXMClient`
===========

在开始聊天之前，Client SDK 需要对 Vonage 服务器进行身份验证。需要向 `ViewController.m` 添加以下内容。

在文件顶部，导入 `NexmoClient` 和 `User`。

```objective_c
#import "ViewController.h"
#import "User.h"
#import <NexmoClient/NexmoClient.h>
```

在 `statusLabel` 下方添加 `NXMClient` 实例和 `user` 属性。

```objective_c
@interface ViewController ()
    ...
    @property UILabel *statusLabel;
    @property NXMClient *client;
    @property User *user;
@end
```

按钮目标
----

为了使登录按钮正常工作，您需要向其添加目标，点击时这些目标将运行函数。在 `ViewController.m` 文件中添加以下内容：

```objective_c
@implementation ViewController
    ...

- (void)viewDidLoad {
    ...
}

- (void)setUserAsAlice {
    self.user = User.Alice;
    [self login];
}

- (void)setUserAsBob {
    self.user = User.Bob;
    [self login];
}
```

然后将两个函数链接到 `viewDidLoad` 函数末尾其相应的按钮。

```objective_c
- (void)viewDidLoad {
    ...

    [self.loginAliceButton addTarget:self action:@selector(setUserAsAlice) forControlEvents:UIControlEventTouchUpInside];
    [self.loginBobButton addTarget:self action:@selector(setUserAsBob) forControlEvents:UIControlEventTouchUpInside];
}
```

添加登录函数
------

在 `ViewController.m` 的末尾，添加 `setUserAs` 函数所需的 `login` 函数。此函数用于设置客户端的代理并登录。

```objective_c
@implementation ViewController
    ...

- (void)login {
    [self.client setDelegate:self];
    [self.client loginWithAuthToken:self.user.jwt];
}
```

客户端代理
-----

为了使代理正常工作，您需要确保 `ViewController` 符合 `NXMClientDelegate`。为此，您需要向 `ViewController.m` 的界面定义添加 `NXMClientDelegate`。

```objective_c
@interface ViewController () <NXMClientDelegate>

...

@end
```

然后，在文件末尾添加以下 `NXMClientDelegate` 函数。

```objective_c
- (void)client:(NXMClient *)client didChangeConnectionStatus:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (status) {
            case NXMConnectionStatusConnected:
                self.statusLabel.text = @"Connected";
                break;
            case NXMConnectionStatusConnecting:
                self.statusLabel.text = @"Connecting";
                break;
            case NXMConnectionStatusDisconnected:
                self.statusLabel.text = @"Disconnected";
                break;
        }
    });
}

- (void)client:(NXMClient *)client didReceiveError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = error.localizedDescription;
    });
}
```

如果遇到错误，则会显示错误，并且 `statusLabel` 会更新为相关的连接状态。

构建和运行
-----

按 `Cmd + R` 构建并再次运行。如果您点击其中一个登录按钮，它将以相应的用户身份登录客户端：

![界面已连接](/images/client-sdk/ios-in-app-voice/client.png)

