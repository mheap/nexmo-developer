---
title:  初始化客户端
description:  在此步骤中，您将对 Vonage 服务器进行身份验证。

---

初始化客户端
======

在您拨打电话之前，需要初始化 Client SDK。在 `MainActivity` 类的 `onCreate` 方法的末尾添加此行：

```kotlin
val client: NexmoClient = NexmoClient.Builder().build(this)
```

设置连接侦听器
=======

您必须侦听 st

```kotlin
client.setConnectionListener { connectionStatus, _ ->
    runOnUiThread {
        connectionStatusTextView.text = connectionStatus.toString()
    }
}
```

现在，客户端需要对 Vonage 服务器进行身份验证。需要向 `MainActivity` 内的 `onCreate` 方法添加以下内容。将 `ALICE_TOKEN` 替换为上一步中生成的 JWT：

```kotlin
client.login("ALICE_TOKEN");
```

构建和运行
-----

按 `Cmd + R` 构建并运行该应用。

