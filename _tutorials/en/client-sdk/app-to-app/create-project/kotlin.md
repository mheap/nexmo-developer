---
title: Create an Android project
description: In this step you create an Android project and add the Android Client SDK library.
---

# Create an Android project

## Project overview

You will be building an Android application with the following screens:

- **login** - responsible for logging the user
- **main** - allows to start a call and listens for incoming call
- **incoming call** - answer or reject incoming call
- **on call** - displayed during ongoing call, allows to end current call

![](/screenshots/tutorials/client-sdk/android-app-to-app/nav-graph.png)

## New Android Project

Open Android Studio and, from the menu, select `File` > `New` > `New Project...`. Select a `Empty Activity` template type and click `Next`.

![](/screenshots/tutorials/client-sdk/android-shared/create-project-empty-activity.png)

Enter `client-sdk-app-to-app` as project name, `com.vonage.tutorial.voice` as package, select `Kotlin` language and press `Finish` button.

You now have a brand new Android Project.
