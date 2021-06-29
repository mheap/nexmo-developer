---
title: Swift
language: swift
menu_weight: 1
---

```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if NXMClient.shared.isNexmoPush(userInfo: userInfo) {
        if UIApplication.shared.applicationState != .active {
            // create and add notification
        } else {
            // show in app banner etc.
        }
        completionHandler(UIBackgroundFetchResult.newData)
    } else {
        completionHandler(UIBackgroundFetchResult.failed)
    }
}
```