---
title: Xcode project and workspace
description: In this step you create an Xcode project and add the iOS Client SDK library.
---

# Xcode project and workspace

You will be using the iOS Client SDK library inside an Xcode project you'll create next.


## Create an Xcode project

* Select `iOS` as platform.

* Select a `App` for the Application type and click `Next`.

* For the `Product Name` type in `AppToApp`.

* Select or add the relevant value for `Team` and `Organisation Identifier`. NB: If you don't possess that info, select `None` for `Team` and enter `com.test` for `Organisation Identifier`.

* Use `Storyboard` for `Interface` and `Swift` for `Language`. 

* Ensure that both `Use Core Data` and `Include Tests` options are deselected. Click `Next`.

* Select your project folder, `app-to-app-swift` as the place where your Xcode project will reside.

* You now have a brand new Xcode Project.

> **IMPORTANT:** Before continuing, please close the new project you created.

You will add the iOS Client SDK library to your project via [CocoaPods](https://cocoapods.org/).

## Install CocoaPods

* Open the `Terminal` app and navigate to the project folder by typing.

``` shell
cd app-to-app-swift/AppToApp
```

* Install CocoaPods in your system, if you don't have it already.

``` shell
sudo gem install cocoapods
```

Note: CocoaPods is built with Ruby, available by default on macOS.

* Create a Podfile for your project.

``` shell
pod init
```

## Add the iOS Client SDK

* Add the Vonage iOS Client SDK to the Podfile. To do this, let's open it in `Xcode`.

``` shell
open -a Xcode Podfile
```

* Update the Podfile as shown below.

```
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'AppToAppCall' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AppToAppCall
  pod 'NexmoClient'
  
end
```

* Install the library.

``` shell
pod install
```

The latest version of the library will be added to your project:

```
Analyzing dependencies
Downloading dependencies
Installing NexmoClient (3.0.0)
Generating Pods project
Integrating client project

[!] Please close any current Xcode sessions and use `AppToAppCall.xcworkspace` for this project from now on.
Pod installation complete! There is 1 dependency from the Podfile and 1 total pod installed.

[!] Automatically assigning platform `iOS` with version `14.4` on target `AppToAppCall` because no platform was specified. Please specify a platform for this target in your Podfile. See `https://guides.cocoapods.org/syntax/podfile.html#platform`.
```

## Open the workspace

As described in the output above, please use `AppToAppCall.xcworkspace` rather than the initial project from now on. To open it, type the following in the terminal.

``` shell
open AppToAppCall.xcworkspace
```
