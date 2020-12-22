---
title:  配置 JWT
description:  在此步骤中，您将学习如何将 JWT 添加到应用程序。

---

配置 JWT
======

现在是时候填充先前生成的 `JWT` 令牌了。

打开 `Config.kt` 文件，并将 `ALICE_TOKEN` 占位符替换为实际值：

```java
public class Config {

    public static User getAlice() {
        return new User(
                "Alice",
                "ALICE_TOKEN" // TODO: "set Bob JWT token"
        );
    }

    //...
}
```

请注意，这些值采用硬编码的方式。这样，在本教程的后面部分中将能更容易地使用这些值，但在生产应用程序中应从外部 API 检索这些值。

