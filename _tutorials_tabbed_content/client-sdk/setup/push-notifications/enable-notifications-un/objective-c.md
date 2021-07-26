---
title: Objective-C
language: objective_c
menu_weight: 2
---

```objective_c
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [NXMClient.shared enablePushNotificationsWithPushKitToken:nil userNotificationToken:deviceToken isSandbox:true completionHandler:nil];
}
```
