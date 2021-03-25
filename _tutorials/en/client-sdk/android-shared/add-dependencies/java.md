---
title: Add dependencies
description: In this step you add external dependencies
---

# Add dependencies

## Client SDK

You need to add a custom Maven URL repository to your Gradle configuration. Add the following `maven` block inside the `allprojects` block within the project-level `build.gradle` file:

![](/screenshots/tutorials/client-sdk/android-shared/project-level-build-gradle-file.png)

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

Now add the Client SDK dependency to the project. Add the following dependency in the module level `build.gradle` file:

![](/screenshots/tutorials/client-sdk/android-shared/module-level-build-gradle-file.png)

```groovy
dependencies {
    // ...

    implementation 'com.nexmo.android:client-sdk:2.8.0'
}
```

## Navigation component

To navigate between screens you will use the [Navigation component](https://developer.android.com/guide/navigation).

To add the navigation component dependency define a variable called `ext.android_navigation_version` in the project-level `build.gradle` file and specify the required version:

```groovy
buildscript {
    ext.android_navigation_version = '2.3.2'

    // ...
}
```

In the same file, add a dependency for the Gradle `Safe Args` plugin. This provides type safety when navigating and passing data between destinations.

Add a new `classpath` in the `dependencies` block:

```groovy
dependencies {
    // ...

    classpath "androidx.navigation:navigation-safe-args-gradle-plugin:$android_navigation_version"
}
```

Then, add the `Safe Args` plugin:

![](/screenshots/tutorials/client-sdk/android-shared/module-level-build-gradle-file.png)

```groovy
plugins {
    // ...
    id 'androidx.navigation.safeargs'
}
```

In the same file, add a navigation component dependencies:

```groovy
dependencies {
    // ...

    implementation "androidx.navigation:navigation-fragment:$android_navigation_version"
    implementation "androidx.navigation:navigation-ui:$android_navigation_version"
}
```

Click the `Sync project with Gradle Files` icon to make sure build scripts have been correctly configured:

![](/screenshots/tutorials/client-sdk/android-shared/sync-project-wth-gradle-files.png)