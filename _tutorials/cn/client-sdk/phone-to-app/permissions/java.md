---
title:  项目权限
description:  在此步骤中，您将向项目属性添加必要的权限。

---

项目权限
====

由于进行呼叫时您将使用麦克风，因此您需要请求麦克风的使用权限。

1. 将所需的权限添加到 `AndroidManifest.xml` 文件（通常为 `app/src/main/AndroidManifest.xml`）：

   ```xml
   <manifest ...>
       <uses-permission android:name="android.permission.INTERNET" />
       <uses-permission android:name="android.permission.RECORD_AUDIO" />
   </manifest>
   ```

2. 对于运行 Android M 版本（API 级别 23）或更高版本的设备，您应该在运行时请求 `RECORD_AUDIO` 权限。在 `onCreate` 方法内的 `MainActivity` 类中添加权限请求：

```java
@Override
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);

    // this is the current activity
    if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.RECORD_AUDIO}, 123);
    }
}
```

构建和运行
-----

按 `Cmd + R` 构建并运行该应用。

