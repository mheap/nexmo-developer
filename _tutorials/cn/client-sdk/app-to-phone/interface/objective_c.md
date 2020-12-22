---
title:  构建界面
description:  在此步骤中，您将构建应用的唯一一个画面。

---

构建界面
====

为了能够拨打电话，您将需要在屏幕上添加两个元素：

* 用于显示连接状态的 `UILabel`。
* 用于开始和结束呼叫的 `UIButton`

打开 `ViewController.h`，并通过编程方式添加这两个元素：

```objective_c
@interface ViewController ()
@property UIButton *callButton;
@property UILabel *connectionStatusLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.connectionStatusLabel = [[UILabel alloc] init];
    self.connectionStatusLabel.text = @"Unknown";
    self.connectionStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.connectionStatusLabel];
    
    self.callButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.callButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.callButton setAlpha:0];
    [self.callButton addTarget:self action:@selector(callButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.callButton setTitle:@"Call" forState:UIControlStateNormal];
    [self.view addSubview:self.callButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.connectionStatusLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.connectionStatusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.connectionStatusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        [self.callButton.topAnchor constraintEqualToAnchor:self.connectionStatusLabel.bottomAnchor constant:40],
        [self.callButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.callButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}

- (void)callButtonPressed {
    
}

@end
```

`callButton` 已隐藏，其 `alpha` 设置为 0，并且将在建立连接时显示。

此外，还添加了点击 `callButton` 时显示的目标，该目标将用于拨打电话和结束呼叫。

构建和运行
-----

再次运行项目 (`Cmd + R`) 以在模拟器中启动。

![界面](/images/client-sdk/ios-voice/interface.jpg)

