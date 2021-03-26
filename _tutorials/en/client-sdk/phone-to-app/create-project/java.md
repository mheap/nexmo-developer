---
title: Create an Android project
description: In this step you create an Android project and add the Android Client SDK library.
---

# Create an Android project
## New Android Project

Create new `phone-to-app` folder inside `phone-to-app-java` folder:

```bash
mkdir phone-to-app
```

Open Android Studio and, from the menu, select `File` > `New` > `New Project...`. Select an `Empty Activity` template type and click `Next`.

![Create project](/screenshots/tutorials/client-sdk/android-shared/create-project-empty-activity.png)

Enter `phone-to-app` as project name, point location to previously created `phone-to-app-java/phone-to-app` folder,  select as `Java` language and press `Finish` button.

You now have a brand new Android Project.

## Add Client SDK dependency

You need to add a custom Maven URL repository to your Gradle configuration. Add the following `maven` block inside the `allprojects` block within the project-level `build.gradle` file:

![Build gradle](/screenshots/tutorials/client-sdk/android-shared/project-level-build-gradle-file.png)

```groovy
allprojects {
    repositories {
        google()
        jcenter()
        
        maven {
            url "https://artifactory.ess-dev.com/artifactory/gradle-dev-local"
        }
    }
}
```

> **NOTE** You can use the `Navigate file` action to open any file in the project. Run the keyboard shortcut (Mac: `Shift + Cmd + O` ; Win: `Shift + Ctrl + O`) and type the filename.

Now add the Client SDK to the project. Add the following dependency in the module-level `build.gradle` file.:

Now add the Client SDK dependency to the project in the module-level `build.gradle` file:

![Build gradle](/screenshots/tutorials/client-sdk/android-shared/module-level-build-gradle-file.png)

```groovy
dependencies {
    // ...

    implementation 'com.nexmo.android:client-sdk:2.8.1'
}