---
title:  初学者项目
description:  在此步骤中，您将克隆初学者项目

---

初学者项目
=====

为了使操作更容易，系统向您提供了一个初学者项目。

1. 克隆此 [GitHub 存储库](https://github.com/nexmo-community/client-sdk-android-tutorial-voice-app-to-phone)（由于存储库包含两个项目 `kotlin-start` 和 `kotlin-complted`，因此无法使用 Android Studio `New project from version control` 功能）。

2. 在 Android Studio 中打开 `kotlin-start` 项目：

   1. 浏览到菜单 `File -> Open`
   2. 从克隆的存储库中选择 `kotlin-start` 文件夹，然后点击 `Open`

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/select-kotlin-start-project.png
```

**3\.** 创建项目 `Build -> Make Project`。如果禁用了 `Make Project` 按钮，请等待，直到 Android Studio 完成对项目的解析（进度将显示在 Android Studio 的右下角）。

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/make-project.png
```

项目导航概述
------

```screenshot
image: public/screenshots/tutorials/client-sdk/android-app-to-phone/nav-graph.png
```

该应用程序包含三个画面：

* **登录** - 负责让用户登录
* **主** - 允许发起呼叫
* **通话中** - 在通话过程中显示，允许结束当前通话

项目内部结构
------

在本教程中要修改的所有文件都位于 `app/src/main/java/com/vonage/tutorial/voice` 目录中：

```screenshot
image: public/screenshots/tutorials/client-sdk/android-app-to-phone/project-files-java.png
```

> **注意：** 每个画面由两个类表示：作为精简视图的 `Fragment` 以及处理视图逻辑的 `ViewModel`。

