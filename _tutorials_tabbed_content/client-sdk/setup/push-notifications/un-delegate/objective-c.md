---
title: Objective-C
language: objective_c
menu_weight: 2
---

```objective_c
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if ([NXMClient.shared isNexmoPushWithUserInfo:userInfo]) {
        if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
            // create and add notification
        } else {
            // show in app banner etc.
        }
        completionHandler(UIBackgroundFetchResultNewData);
    } else {
        completionHandler(UIBackgroundFetchResultFailed);
    }
}
```
