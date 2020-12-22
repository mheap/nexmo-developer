---
title:  创建新的 Android 项目
description:  在此步骤中，您将创建一个 Android 项目并添加 Android Client SDK 库。

---

创建 Android 项目
-------------

* 打开 Android Studio 并从菜单中选择 `File` > `New` > `New Project...`。

* 选择 `Empty Activity` 模板类型并点击 `Next`。

* 键入 `Project Name` 并选择 `Kotlin` 语言。

* 点击 `Finish`

* 您现在拥有了一个全新的 Android 项目。

### 添加依赖项

您需要向 Gradle 配置添加自定义 Maven URL 存储库。在顶级 `build.gradle` 文件中添加以下 URL：

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/add-sdk/android/maven'
```

现在，将 Client SDK 添加到您的项目中。在您的应用级别 `build.gradle` 文件（通常为 `app/build.gradle`）中添加以下依赖项：

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/add-sdk/android/dependencies'
```

### 设置 Java 1\.8

在您的应用级别 `build.gradle` 文件中设置 Java 1\.8（通常为 `app/build.gradle`）：

```tabbed_content
source: '_tutorials_tabbed_content/client-sdk/setup/add-sdk/android/gradlejava18'
```

