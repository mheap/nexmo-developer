---
title:  接收呼叫
description:  在此步骤中，您将学习如何接收应用内呼叫

---

接收呼叫
====

构建了呼叫界面后，您现在可以添加接收呼叫所需的代码。`NXMClientDelegate` 具有在来电时可调用的函数。在 `ViewController.m` 文件的 `NXMClientDelegate` 扩展中为其添加实现。

```objective_c
- (void)client:(NXMClient *)client didReceiveCall:(NXMCall *)call {
    [NSNotificationCenter.defaultCenter postNotificationName:@"NXMClient.incomingCall" object:call];
}
```

`CallViewController` 类将在前台运行，并且该类将处理呼叫，因此将使用 `NSNotification` post 传递该呼叫。为了使 `CallViewController` 收到此通知，需要观察它。在 `CallViewController.m` 文件中添加以下内容：

```objective_c
@implementation CallViewController

- (void)viewDidLoad {
    ...
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didReceiveCall:) name:@"NXMClient.incomingCall" object:nil];
    
    [self.hangUpButton addTarget:self action:@selector(endCall) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveCall:(NSNotification *)notification {
    NXMCall *call = (NXMCall *)notification.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayIncomingCallAlert:call];
    });
}

- (void)displayIncomingCallAlert:(NXMCall *)call {
    NSString *from = call.otherCallMembers.firstObject.channel.from.data;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Incoming call from" message:from preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Answer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.call = call;
        [call answer:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [call reject:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)endCall {
    [self.call hangup];
    [self setHangUpButtonHidden:YES];
    [self setStatusLabelText:@"Ready to receive call..."];
}

@end
```

收到通知后，将调用 `didReceiveCall`，该函数将依次调用 `displayIncomingCallAlert`，以便向用户显示接受或拒绝该呼叫的选项。如果用户接受，UI 将更新为显示用户的通话对象，并且 `hangUpButton` 变为可见状态。如果点击 `hangUpButton`，则会调用 `endCall`，将挂断电话并更新 UI。

呼叫代理
----

与 `NXMClient` 类似，`NXMCall` 也拥有用于处理呼叫更改的代理。在界面中添加 `NXMCallDelegate` 的符合项，并实现所需的函数。

```objective_c
@interface CallViewController () <NXMCallDelegate>
...
@end


@implementation CallViewController
- (void)call:(NXMCall *)call didUpdate:(NXMCallMember *)callMember withStatus:(NXMCallMemberStatus)status {
    switch (status) {
        case NXMCallMemberStatusAnswered:
            [self setStatusLabelText:[NSString stringWithFormat:@"On a call with %@", callMember.user.name]];
            break;
        case NXMCallMemberStatusCompleted:
            [self setStatusLabelText:@"Call ended"];
            [self setHangUpButtonHidden:YES];
            self.call = nil;
            break;
        default:
            break;
    }
}

- (void)call:(NXMCall *)call didReceive:(NSError *)error {
    [self setStatusLabelText:error.localizedDescription];
}

- (void)call:(NXMCall *)call didUpdate:(NXMCallMember *)callMember isMuted:(BOOL)muted {}
@end
```

在下一步中，您将添加进行呼叫所需的代码。

