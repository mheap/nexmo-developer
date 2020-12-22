---
title:  构建聊天界面
description:  在此步骤中，您将构建应用的第二个画面。

---

构建聊天界面
======

为了能够进行聊天，您将需要为聊天界面创建新的视图控制器。从 Xcode 菜单中，选择 `File` > `New` > `File...`。选择 *Cocoa Touch 类* ，将其命名为 `ChatViewController`，子类为 `UIViewController`，语言为 `Objective-C`。

![Xcode 添加文件](/images/client-sdk/ios-messaging/chatviewcontrollerobjc.png)

此操作将创建名为 `ChatViewController.m` 的新文件，在顶部导入 `NexmoClient` 和 `User`。

```objective_c
#import "ChatViewController.h"
#import "User.h"
#import <NexmoClient/NexmoClient.h>
```

聊天界面将需要：

* 用于显示聊天消息的 `UITextView`
* 用于键入消息的 `UITextField`

打开 `ChatViewController.m`，并通过编程方式进行添加。

```objective_c
@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    
    self.conversationTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.conversationTextView.text = @"";
    self.conversationTextView.backgroundColor = UIColor.lightGrayColor;
    [self.conversationTextView setUserInteractionEnabled:NO];
    self.conversationTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.conversationTextView];
    
    self.inputField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.inputField.delegate = self;
    self.inputField.returnKeyType = UIReturnKeySend;
    self.inputField.layer.borderWidth = 1.0;
    self.inputField.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.inputField.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:self.inputField];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.conversationTextView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.conversationTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.conversationTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.conversationTextView.bottomAnchor constraintEqualToAnchor:self.inputField.topAnchor constant:-20.0],
        
        [self.inputField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.inputField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        [self.inputField.heightAnchor constraintEqualToConstant:40.0],
        [self.inputField.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor constant:-20.0]
    ]];
}

- (void)viewWillAppear:(BOOL)animated {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary *keyboardInfo = notification.userInfo;
    
    if (keyboardInfo) {
        CGSize kbSize = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        self.view.layoutMargins = UIEdgeInsetsMake(0, 0, kbSize.height - 20.0, 0);
    }
}

@end
```

在 `viewWillAppear` 函数中，将观察者添加到 `keyboardDidShowNotification`，该观察者调用 `keyboardWasShown`。`keyboardWasShown` 函数用于调整视图的布局边距，以移动输入字段。这样可防止在键入时 `inputField` 被键盘挡住。

`UITextField` 代理
----------------

您将需要符合 `UITextFieldDelegate`，才能知道用户何时完成输入，以将输入字段移动到其原始位置。

```objective_c
@interface ChatViewController () <NXMClientDelegate>

...

@end
```

在 `ChatViewController` 类的末尾，添加 `textFieldDidEndEditing` 代理函数。

```objective_c
@implementation ChatViewController

...

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.view.layoutMargins = UIEdgeInsetsZero;
}

@end
```

显示 `ChatViewController`
-----------------------

构建了聊天界面后，您将需要从刚刚构建的登录屏幕中显示视图控制器。您将需要有关在两个视图控制器之间传递的登录用户的信息。在 `ChatViewController.h` 内，在文件顶部导入 `User` 类。

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

然后在 `ChatViewController.m` 中，向界面添加用户和客户端属性。

```objective_c
@interface ChatViewController () <UITextFieldDelegate>
...
@property User *user;
@property NXMClient *client;
@end
```

实现初始值设定项：

```objective_c
@implementation ChatViewController

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

此操作为拥有 `User.type` 作为其参数的类定义了自定义初始值设定项，然后将其存储在本地 `user` 属性中。拥有用户信息后，您可以使用导航栏显示用户的聊天对象。在 `viewDidLoad` 中添加以下内容。

```objective_c
self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logout)];
self.title = [NSString stringWithFormat:@"Conversation with %@", self.user.chatPartnerName];
```

此操作还会在导航栏中创建注销按钮，将 `logout` 函数添加到 `ChatViewController.m` 的末尾。

```objective_c
@implementation ChatViewController
    ...
- (void)logout {
    [self.client logout];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
```

现在，您可以显示聊天界面以及用户信息。为执行此操作，您需要编辑 `ViewController.m` 文件中的 `didChangeConnectionStatus` 函数。

```objective_c
- (void)client:(NXMClient *)client didChangeConnectionStatus:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason {
    switch (status) {
        case NXMConnectionStatusConnected: {
            [self setStatusLabelText:@"Connected"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[ChatViewController alloc] initWithUser:self.user]];
            navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:navigationController animated:YES completion:nil];
            break;
        }
        case NXMConnectionStatusConnecting:
            [self setStatusLabelText:@"Connecting"];
            break;
        case NXMConnectionStatusDisconnected:
            [self setStatusLabelText:@"Disconnected"];
            break;
    }
}
```

然后在文件顶部导入 `ChatViewController`。

```objective_c
...
#import "ChatViewController.h"
```

如果用户连接成功，将显示包含所需用户数据的 `ChatViewController`。

构建和运行
-----

再次运行项目 (`Cmd + R`) 以在模拟器中启动。如果您使用其中一位用户登录，则会看到聊天界面

![聊天界面](/images/client-sdk/ios-messaging/chat.png)

