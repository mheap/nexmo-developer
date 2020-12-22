---
title:  接收呼叫
description:  在此步骤中，您将接收呼叫。

---

接收呼叫
====

在 `ViewController` 类的顶部，`client` 声明下方，添加 `NXMCall` 属性以保留对正在进行的任何呼叫的引用。

```objective_c
 @interface ViewController () <NXMClientDelegate>
 ...
 @property NXMCall * call;
 @end
```

当应用程序收到呼叫时，您希望提供接受或拒绝通话的选项。为此，请将 `displayIncomingCallAlert` 函数添加到 `ViewController` 类。

```objective_c
- (void)displayIncomingCallAlert:(NXMCall *)call {
    NSString *from = call.otherCallMembers.firstObject.channel.from.data;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Incoming call from" message:from preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Answer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.call = call;
        [call answer:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [call reject:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
```

`displayIncomingCallAlert` 函数使用 `NXMCall` 作为参数，使用此参数可以访问 `NXMCallMember` 类型的呼叫成员来检索呼入电话的电话号码。请注意，`UIAlertAction` 用于应答呼叫，您之前已将呼叫分配给该属性。

为了使用 `displayIncomingCallAlert`，您需要使用 `NXMClientDelegate`，它包含当客户端收到呼入 `NXMCall` 时系统将调用的函数。

```objective_c
- (void)client:(NXMClient *)client didReceiveCall:(NXMCall *)call {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayIncomingCallAlert:call];
    });
}
```

构建和运行
-----

按 `Cmd + R` 构建并再次运行，当您呼叫之前与您的应用程序链接的号码时，将显示提醒。您可以接听，呼叫将被接通！

![呼入电话提醒](/meta/client-sdk/ios-phone-to-app/alert.png)

