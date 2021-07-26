---
title: Swift
language: swift
menu_weight: 1
---

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    NXMClient.shared.enablePushNotifications(withPushKitToken: nil, userNotificationToken: deviceToken, isSandbox: true, completionHandler: nil)
}
```