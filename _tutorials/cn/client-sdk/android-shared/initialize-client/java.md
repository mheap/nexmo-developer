---
title:  初始化客户端
description:  在此步骤中，您将初始化 `NexmoClient`，以便能在应用程序中使用。

---

初始化客户端
======

[NexmoClient](https://developer.nexmo.com/sdk/stitch/android/com/nexmo/client/NexmoClient.html) 是用于与 `Android-Client-SDK` 进行交互的主类。在使用之前，我们必须通过提供 Android [Context](https://developer.android.com/reference/android/content/Context) 类的实例来初始化客户端。初始化客户端的最佳位置是自定义 Android [Application](https://developer.android.com/reference/android/app/Application) 类。

在 `BaseApplication` 类中找到 `initializeNexmoClient` 方法，并使用生成器初始化 `NexmoClient`。您可以在左侧的 Android 视图中找到此类，或使用 `Navigate class` 键盘快捷键（Mac：`Cmd + O`；Win：`Ctrl + O`）。

```kotlin
private fun initializeNexmoClient() {
    new NexmoClient.Builder().build(this);
}
```

> **注意：** 上面的代码将允许稍后使用 `NexmoClient.get()` 检索 `NexmoClient` 实例。

> **注意** ：您可以使用生成器的 `logLevel()` 方法启用其他 `Logcat` 日志记录，例如， `NexmoClient.Builder().logLevel(ILogger.eLogLevel.SENSITIVE).build(this)`

如果 Android Studio 找不到 `NexmoClient` 类的引用，则必须添加缺少的导入项。将鼠标悬停在 `NexmoClient` 类上，等待窗口出现，然后按 `Import`（在以下步骤中也需要执行此操作）。

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/missing-import-java.png
```

您现在拥有了一个工作客户端。下一步是对用户进行身份验证。

