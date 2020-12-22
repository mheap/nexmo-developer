---
title:  Xcode 项目和工作区
description:  在此步骤中，您将创建 Xcode 项目和 iOS Client SDK 库。

---

Xcode 项目和工作区
============

您将在接下来创建的 Xcode 项目中用到 iOS Client SDK 库。

创建 Xcode 项目
-----------

* 打开 Xcode 并从菜单中选择 `File` > `New` > `Project...`。

* 为该应用程序类型选择 `Single View App`，然后点击 `Next`。

* 对于 `AppToAppChat` 中的 `Product Name` 类型，选择相关的 `Team` 和 `Organisation Identifier`。

* `Language` 的用户 `Objective-C` 和 `User Interface` 的 `Storyboard`。点击 `Next`。

* 选择 `Desktop` 作为项目文件夹所在的位置。您可以选择其他位置，但请确保记住它，因为您很快就需要从 `Terminal` 浏览到该位置。

* 您现在拥有了一个全新的 Xcode 项目。

**请关闭刚刚创建的新项目，然后再继续执行其他操作。** 

您将通过 [CocoaPods](https://cocoapods.org/) 将 iOS Client SDK 库添加到您的项目。

安装 CocoaPods
------------

* 打开 `Terminal` 应用，然后通过键入浏览到该项目文件夹：

```shell
cd ~/Desktop/AppToAppChat
```

* 如果尚未安装 CocoaPods，请在您的系统中安装：

```shell
sudo gem install cocoapods
```

注意：CocoaPods 是使用 Ruby 构建的，可以使用 macOS 上的默认 Ruby 进行安装。

* 为您的项目创建 Podfile：

```shell
pod init
```

添加 iOS Client SDK
-----------------

* 将 Vonage iOS Client SDK 添加到 Podfile。为此，请在 `Xcode` 打开它：

```shell
open -a Xcode Podfile
```

* 如下所示更新 Podfile：

    # Uncomment the next line to define a global platform for your project
    # platform :ios, '9.0'
    
    target 'AppToAppChat' do
      # Comment the next line if you don't want to use dynamic frameworks
      use_frameworks!
    
      # Pods for AppToAppChat
      pod 'NexmoClient'
      
    end

* 安装该库：

```shell
pod install
```

该库的最新版本将添加到您的项目：

    Analyzing dependencies
    Downloading dependencies
    Installing NexmoClient (2.2.1)
    Generating Pods project
    Integrating client project
    
    [!] Please close any current Xcode sessions and use `AppToAppChat.xcworkspace` for this project from now on.
    Pod installation complete! There is 1 dependency from the Podfile and 1 total pod installed.
    
    [!] Automatically assigning platform `iOS` with version `13.5` on target `AppToAppChat` because no platform was specified. Please specify a platform for this target in your Podfile. See `https://guides.cocoapods.org/syntax/podfile.html#platform`.

打开工作区
-----

如上面的输出中所述，请从现在开始使用 `AppToAppChat.xcworkspace` 而不是初始项目。要打开它，请在终端中键入以下内容：

```shell
open AppToAppChat.xcworkspace
```

