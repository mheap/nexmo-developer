---
title:  NXMClient
description:  在此步骤中，您将对 Vonage 服务器进行身份验证。

---

`NXMClient`
===========

在您拨打电话之前，Client SDK 需要对 Vonage 服务器进行身份验证。需要向 `ViewController.m` 添加以下内容。

在文件顶部，导入 `NexmoClient`。

```objective_c
#import "ViewController.h"
#import <NexmoClient/NexmoClient.h>
```

在界面中添加 `NXMClient` 实例及 `NXMClientDelegate` 的符合项。

```objective_c
@interface ViewController () <NXMClientDelegate>
...
@property NXMClient *client;
@end
```

添加 JWT
------

在 `viewDidLoad` 的末尾，设置客户端代理并登录 - 请确保将 `ALICE_JWT` 替换为您在上一步中创建的 `JWT`。请谨记，令牌的有效期已设置为 6 个小时，因此如果令牌太旧，则需要生成新的令牌。

```objective_c
- (void)viewDidLoad {
    ...
    
    self.client = NXMClient.shared;
    [self.client setDelegate:self];
    [self.client loginWithAuthToken:@"ALICE_JWT"];
}
```

客户端代理
-----

为了使代理部分正常工作，您需要确保 `ViewController` 符合 `NXMClientDelegate`。将这两个代理函数添加到该类。

```objective_c
- (void)client:(nonnull NXMClient *)client didChangeConnectionStatus:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (status) {
            case NXMConnectionStatusConnected:
                [self.callButton setAlpha:1];
                self.connectionStatusLabel.text = @"Connected";
                break;
            case NXMConnectionStatusConnecting:
                self.connectionStatusLabel.text = @"Connecting";
                break;
            case NXMConnectionStatusDisconnected:
                self.connectionStatusLabel.text = @"Disconnected";
                break;
        }
    });
}

- (void)client:(nonnull NXMClient *)client didReceiveError:(nonnull NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connectionStatusLabel.text = error.localizedDescription;
        [self.callButton setAlpha:0];
    });
}
```

如果遇到错误，则会显示错误，并且 `connectionStatusLabel` 会更新为相关的连接状态。此外，连接时还会显示 `callButton`

构建和运行
-----

`Cmd + R` 构建并再次运行：

![界面已连接](/images/client-sdk/ios-voice/interface-connected.jpg)

