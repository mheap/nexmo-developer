---
title:  构建界面
description:  在此步骤中，您将构建应用的唯一一个画面。

---

构建界面
====

为了能够查看应用的连接状态，您需要将 `UILabel` 元素添加到屏幕。打开 `ViewController.swift`，并通过编程方式进行添加。

```objective_c
@interface ViewController ()
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
    
    [NSLayoutConstraint activateConstraints:@[
        [self.connectionStatusLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.connectionStatusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.connectionStatusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}

@end
```

构建和运行
-----

再次运行项目 (`Cmd + R`) 以在模拟器中启动。

![界面](/meta/client-sdk/ios-phone-to-app/interface.png)

