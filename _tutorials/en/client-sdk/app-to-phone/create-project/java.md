---
title: Create an Android project
description: In this step you create an Android project and add the Android Client SDK library.
---

# Create an Android project
## New Android Project

Create new `app-to-phone` folder inside `app-to-phone-java` folder:

```bash
mkdir app-to-phone
```

Open Android Studio and, from the menu, select `File` > `New` > `New Project...`. Select an `Empty Activity` template type and click `Next`.

![Create project](/screenshots/tutorials/client-sdk/android-shared/create-project-empty-activity.png)

Enter `app-to-phone` as project name, point location to previously created `app-to-phone-java/app-to-phone` folder,  select as `Java` language and press `Finish` button.

You now have a brand new Android Project.

## Add Client SDK dependency

You need to add a custom Maven URL repository to your Gradle configuration. Add the following `maven` block inside the `allprojects` block within the project-level `build.gradle` file:

![Build gradle](/screenshots/tutorials/client-sdk/android-shared/project-level-build-gradle-file.png)

```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        
        maven {
            url "https://artifactory.ess-dev.com/artifactory/gradle-dev-local"
        }
    }
}
```

> **NOTE** You can use the `Navigate file` action to open any file in the project. Run the keyboard shortcut (Mac: `Shift + Cmd + O` ; Win: `Shift + Ctrl + O`) and type the filename.

Now add the Client SDK to the project. Add the following dependency in the module-level `build.gradle` file.:

![Build gradle](/screenshots/tutorials/client-sdk/android-shared/module-level-build-gradle-file.png)

```groovy
dependencies {
    // ...

    implementation 'com.nexmo.android:client-sdk:3.0.0'
}