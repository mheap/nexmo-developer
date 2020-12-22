---
title:  拨打电话
description:  在此步骤中，您将拨打电话。

---

拨打电话
====

在界面中添加 `NXMCall` 属性，以保留对正在进行的任何呼叫的引用：

```objective_c
@interface ViewController () <NXMClientDelegate>
...
@property NXMCall * call;
@end
```

根据 `call` 属性引用的对象，现在可以使用 `callButtonPressed` 方法来拨打电话或结束通话；每种情况都会触发 `placeCall` 和 `endCall` 方法。

请确保将下面的 `PHONE_NUMBER` 替换为您要拨打的实际电话号码。注意：必须与 gist NCCO 中指定的号码相同：

```objective_c
- (void)callButtonPressed {
    if (self.call) {
        [self placeCall];
    } else {
        [self endCall];
    }
}

- (void)placeCall {
    [self.client call:@"PHONE_NUMBER" callHandler:NXMCallHandlerServer completionHandler:^(NSError * _Nullable error, NXMCall * _Nullable call) {
        if (error) {
            self.connectionStatusLabel.text = error.localizedDescription;
            return;
        }
        
        self.call = call;
        [self.callButton setTitle:@"End call" forState:UIControlStateNormal];
    }];
}

- (void)endCall {
    [self.call hangup];
    self.call = nil;
    [self.callButton setTitle:@"Call" forState:UIControlStateNormal];
}
```

就是这样！现在您可以构建、运行和拨打电话了！太神奇了！

