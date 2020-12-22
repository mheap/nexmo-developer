---
title:  构建用户模型
description:  在此步骤中，您将构建用户模型结构。

---

构建用户模型
======

要进行对话，您需要存储有关用户的一些信息：

* 用户名称
* 用户的 JWT
* 他们呼叫的对象

为此，您将创建一个新用户 `Class`。从 Xcode 菜单中，选择 `File` > `New` > `File...`。选择 `Cocoa Touch Class`，将其命名为 `User`，子类为 `NSObject`，所选语言为 `Objective-C`：

![Xcode 添加文件](/images/client-sdk/ios-messaging/userclass.png)

打开 `User.h`，声明存储用户信息所需的属性和函数。

```objective_c
@interface User : NSObject

@property NSString *name;
@property NSString *jwt;
@property NSString *callPartnerName;

-(instancetype)initWithName:(NSString *)name jwt:(NSString *)jwt callPartnerName:(NSString *)chatPartnerName;

+(instancetype)Alice;
+(instancetype)Bob;

@end
```

为了后续的简便性，用户 Alice 和 Bob 的 `User` 类型具有一些静态属性。打开 `User.m` 以实现这些属性以及该类的初始值设定项，使用您先前创建的值替换 `ALICE_JWT` 和 `BOB_JWT`。

```objective_c
@implementation User

- (instancetype)initWithName:(NSString *)name jwt:(NSString *)jwt callPartnerName:(NSString *)callPartnerName {
    if (self = [super init])
    {
        _name = name;
        _jwt = jwt;
        _callPartnerName = callPartnerName;
    }
    return self;
}

+ (instancetype)Alice {
    return [[User alloc] initWithName:@"Alice" jwt:@"ALICE_JWT" callPartnerName:@"Bob"];
}

+ (instancetype)Bob {
    return [[User alloc] initWithName:@"Bob" jwt:@"BOB_JWT" callPartnerName:@"Alice"];
}

@end
```

