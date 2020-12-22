---
title:  构建登录界面
description:  在此步骤中，您将构建应用的第一个画面。

---

构建登录界面
======

为了能够登录，您将需要在屏幕上添加三个元素：

* 用于使 Alice 登录的 `UIButton`
* 用于使 Bob 登录的 `UIButton`
* 用于显示连接状态的 `UILabel`。

打开 `ViewController.m`，并通过编程方式进行添加。

```objective_c
@interface ViewController ()
@property UIButton *loginAliceButton;
@property UIButton *loginBobButton;
@property UILabel *statusLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.loginAliceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loginAliceButton setTitle:@"Log in as Alice" forState:UIControlStateNormal];
    self.loginAliceButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loginAliceButton];
    
    self.loginBobButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loginBobButton setTitle:@"Log in as Bob" forState:UIControlStateNormal];
    self.loginBobButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loginBobButton];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"";
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];
    
    
    [NSLayoutConstraint activateConstraints:@[
        [self.loginAliceButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.loginAliceButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loginAliceButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.loginAliceButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        
        [self.loginBobButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loginBobButton.topAnchor constraintEqualToAnchor:self.loginAliceButton.bottomAnchor constant:20.0],
        [self.loginBobButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.loginBobButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        
        [self.statusLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.loginBobButton.bottomAnchor constant:20.0],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0]
    ]];
}

@end
```

构建和运行
-----

再次运行项目 (`Cmd + R`) 以在模拟器中启动。

![界面](/images/client-sdk/ios-in-app-voice/login.png)

