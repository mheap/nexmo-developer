---
title:  配置 JWT 和对话 ID
description:  在此步骤中，您将学习如何将 JWT 添加到应用程序并设置对话 ID。

---

现在是时候填充先前生成的 `CONVERSATION_ID` 和 `JWT` 令牌了。

打开 `Config.kt` 文件，并将占位符替换为实际值：

1. `CONVERSATION_ID` - 上一步中创建的对话 ID
2. `ALICE_TOKEN` - Alice JWT 令牌
3. `BOB_TOKEN` - Bob JWT 令牌

```kotlin
package com.vonage.tutorial.messaging

public class Config {

    public static String CONVERSATION_ID = ""; // TODO: set conversation Id

    public static User getAlice() {
        return new User(
                "Alice",
                "" // TODO: "set Alice JWT token"
        );
    }

    public static User getBob() {
        return new User(
                "Bob",
                "" // TODO: "set Bob JWT token"
        );
    }
}
```

请注意，这些常量和值经过硬编码，可存储用户的属性。这样，在本教程的后面部分中将能更容易地使用这些值。

