---
title:  发送消息
description:  在此步骤中，您将构建发送消息功能。

---

发送消息
====

在上一步中，您了解了对话和事件，发送消息会创建新事件并通过对话进行发送。

要发送消息，请向 `ChatViewController.m` 类添加以下函数：

```objective_c
@implementation ViewController
    ...

- (void)sendMessage:(NSString *)message {
    [self.inputField setUserInteractionEnabled:NO];
    [self.conversation sendText:message completionHandler:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.inputField setUserInteractionEnabled:YES];
        });
    }];
}
```

要从 `inputField` 获取文本，您需要添加 `UITextFieldDelegate` 提供的另一个函数：

```objective_c
@implementation ViewController
    ...

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *text = self.inputField.text;
    
    if (text) {
        [self sendMessage:text];
    }
    self.inputField.text = @"";
    [self.inputField resignFirstResponder];
    return YES;
}
```

当按下键盘上的返回按钮时，将调用此代理函数。

构建和运行
-----

`Cmd + R` 构建并再次运行。您现在有了一个可以正常运行的聊天应用！要同时聊天，您可以在两个不同的模拟器/设备上运行该应用：

![发送消息](/images/client-sdk/ios-messaging/messages.png)

