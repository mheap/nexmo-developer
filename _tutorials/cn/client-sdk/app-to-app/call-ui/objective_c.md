---
title:  构建呼叫界面
description:  在此步骤中，您将构建应用的第二个画面。

---

构建呼叫界面
======

为了能够进行呼叫，您将需要为呼叫界面创建新的视图控制器。从 Xcode 菜单中，选择 `File` > `New` > `File...`。选择 *Cocoa Touch 类* ，将其命名为 `CallViewController`，子类为 `UIViewController`，语言为 `Objective-C`。

![Xcode 添加文件](/images/client-sdk/ios-in-app-voice/callviewcontrollerobjc.png)

此操作将创建名为 `CallViewController.m` 的新文件，在顶部导入 `NexmoClient` 和 `User`。

```objective_c
#import "User.h"
#import <NexmoClient/NexmoClient.h>
```

呼叫界面将需要：

* 用于发起呼叫的 `UIButton`
* 用于结束呼叫的 `UIButton`
* 用于显示状态更新的 `UILabel`

打开 `CallViewController.m`，并通过编程方式进行添加。

```objective_c
@interface CallViewController () <NXMCallDelegate>
@property UIButton *callButton;
@property UIButton *hangUpButton;
@property UILabel *statusLabel;
@end

@implementation CallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    
    self.callButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.callButton setTitle:[NSString stringWithFormat:@"Call %@", self.user.callPartnerName] forState:UIControlStateNormal];
    self.callButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.callButton];
    
    self.hangUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.hangUpButton setTitle:@"Hang up" forState:UIControlStateNormal];
    self.hangUpButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self setHangUpButtonHidden:YES];
    [self.view addSubview:self.hangUpButton];
    
    self.statusLabel = [[UILabel alloc] init];
    [self setStatusLabelText:@"Ready to receive call..."];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.callButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.callButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.callButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.callButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        
        [self.hangUpButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.hangUpButton.topAnchor constraintEqualToAnchor:self.callButton.bottomAnchor constant:20.0],
        [self.hangUpButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.hangUpButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        
        [self.statusLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.hangUpButton.bottomAnchor constant:20.0],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0]
    ]];
}

- (void)setHangUpButtonHidden:(BOOL)isHidden {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hangUpButton setHidden:isHidden];
        [self.callButton setHidden:!self.hangUpButton.isHidden];
    });
}

- (void)setStatusLabelText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = text;
    });
}

@end
```

有两个辅助函数 `setHangUpButtonHidden` 和 `setStatusLabelText`，可用于避免重复调用 `DispatchQueue.main.async`，因为根据 `UIKit` 的要求，需要在主线程上更改 UI 元素的状态。`setHangUpButtonHidden` 函数用于切换 `hangUpButton` 的可见性，因为只需要在活动呼叫期间显示此按钮。

显示 `CallViewController`
-----------------------

构建了呼叫界面后，您将需要从刚刚构建的登录屏幕中显示视图控制器。您将需要有关在两个视图控制器之间传递的登录用户的信息。在 `ChatViewController.h` 内，在文件顶部导入 `User` 类。

```objective_c
#import <UIKit/UIKit.h>
#import "User.h"
```

向界面添加初始值设定项。

```objective_c
@interface ChatViewController : UIViewController

-(instancetype)initWithUser:(User *)user;

@end
```

然后在 `CallViewController.m` 中，向界面添加用户和客户端属性。

```objective_c
@interface ChatViewController ()
...
@property User *user;
@property NXMClient *client;
@end
```

实现初始值设定项：

```objective_c
@implementation CallViewController

- (instancetype)initWithUser:(User *)user {
    if (self = [super init])
    {
        _user = user;
        _client = NXMClient.shared;
    }
    return self;
}
...
@end
```

此操作为拥有 `User.type` 作为其参数的类定义了自定义初始值设定项，然后将其存储在本地 `user` 属性中。拥有用户信息后，您可以使用 `callButton` 显示用户呼叫的对象；在 `viewDidLoad` 中添加以下内容。

```objective_c
self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logout)];
[self.callButton setTitle:[NSString stringWithFormat:@"Call %@", self.user.callPartnerName];
if ([self.user.name isEqualToString:@"Alice"]) {
    [self.callButton setAlpha:0];
}
```

这将隐藏 Alice 的呼叫按钮，在此演示中，只有 Bob 才能打电话给 Alice。在生产应用程序中，应用程序的应答 URL 返回的 `NCCO` 将动态返回正确的用户名，以避免出现这种情况。它还会在导航栏中创建注销按钮，将相应的 `logout` 函数添加到末尾 `CallViewController.m`

```objective_c
@implementation ChatViewController
    ...
- (void)logout {
    [self.client logout];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
```

现在，您可以显示呼叫界面以及用户信息。为执行此操作，您需要编辑 `ViewController.m` 文件中的 `NXMClientDelegate` 扩展。

```objective_c
- (void)client:(NXMClient *)client didChangeConnectionStatus:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason {
    switch (status) {
        case NXMConnectionStatusConnected: {
            self.statusLabel.text = @"Connected";
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[CallViewController alloc] initWithUser:self.user]];
            navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:navigationController animated:YES completion:nil];
            break;
        }
        case NXMConnectionStatusConnecting:
            self.statusLabel.text = @"Connecting";
            break;
        case NXMConnectionStatusDisconnected:
            self.statusLabel.text = @"Disconnected";
            break;
    }
}
```

然后在文件顶部导入 `CallViewController`。

```objective_c
...
#import "CallViewController.h"
```

如果用户连接成功，将显示包含所需用户数据的 `CallViewController`。

构建和运行
-----

再次运行项目 (`Cmd + R`) 以在模拟器中启动。如果您使用其中一位用户登录，则会看到呼叫界面

![呼叫界面](/images/client-sdk/ios-in-app-voice/call.png)

