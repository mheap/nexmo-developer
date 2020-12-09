---
title: Create screens
description: In this step you create screens.
---

# Create empty screens

You will now create placeholders for screens in the application (we will define layouts and the functionality in following steps of this tutorial). You will create few files for each screen:

- layout
- Fragment (view)
- ViewModel (mnaages the view)

### Login screen

To create layout right click on `res/layout` folder, select `New` > `Layout Resource File`, enter `fragment_login` as file name and press `OK`.

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/layout-resource.png
```

To create fragment right click on `com.vonage.tutorial.messaging` package, select `New` > `Kotlin Class/File`, enter `LoginFragment` as file name and select `Class`.

```screenshot
image: public/screenshots/tutorials/client-sdk/android-in-app-messaging-chat/messaging-package.png
```

To create view model right click on `com.vonage.tutorial.messaging` package, select `New` > `Kotlin Class/File`, enter `LoginViewModel` as file name and select `Class`.

```screenshot
image: public/screenshots/tutorials/client-sdk/android-in-app-messaging-chat/messaging-package.png
```

### Chat screen

To create layout right click on `res/layout` folder, select `New` > `Layout Resource File`, enter `fragment_chat` as file name and press `OK`.

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/layout-resource.png
```

To create fragment right click on `com.vonage.tutorial.messaging` package, select `New` > `Kotlin Class/File`, enter `ChatFragment` as file name and select `Class`.

```screenshot
image: public/screenshots/tutorials/client-sdk/android-in-app-messaging-chat/messaging-package.png
```

To create view model right click on `com.vonage.tutorial.messaging` package, select `New` > `Kotlin Class/File`, enter `ChatViewModel` as file name and select `Class`.

```screenshot
image: public/screenshots/tutorials/client-sdk/android-in-app-messaging-chat/messaging-package.png
```

Now when all screens are created you can add dependencies.
