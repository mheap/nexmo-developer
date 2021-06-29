---
title: Objective-C
language: objective_c
menu_weight: 2
---

Import `UserNotifications`:

```objective_c
#import <UserNotifications/UserNotifications.h>
```

Then request permissions and register for remote notifications:

```objective_c
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self registerForPushNotificationsIfNeeded];
    return YES;
    
    
}

- (void)registerForPushNotificationsIfNeeded {
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge;

    [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            [self getNotificationSettings];
        }
    }];
}

- (void)getNotificationSettings {
    [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication.sharedApplication registerForRemoteNotifications];
            });
        }
    }];
}

...

@end
```