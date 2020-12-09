---
title: Add permissions
description: In this step you add permissions
---

# Add permissions

Add `INTERNET` perission into `AndroidManifest.xml` file:

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/android-manifest-file.png
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="com.vonage.tutorial">

    <uses-permission android:name="android.permission.INTERNET" />
    ...
```

