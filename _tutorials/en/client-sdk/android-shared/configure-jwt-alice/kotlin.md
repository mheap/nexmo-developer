---
title: Configure JWT
description: In this step you learn how to add JWT to the application.
---

# Configure JWTs

Create a `Config.kt` file in the `com.vonage.tutorial.voice` package to store the configuration. Right click the `voice` package and select `New` > `Kotlin Class/File`. Enter `Config` as the name, then select `File` and press Enter to confirm.

Replace the file contents with the following code:

```kotlin
object Config {

    val alice = User(
        "Alice",
        "ALICE_TOKEN" // TODO: "set Alice's JWT token"
    )
}

data class User(
    val name: String,
    val jwt: String
)
```

Now it's time to fill previously generated and `JWT` token. Replace `ALICE_TOKEN` placeholder with real value.

Notice that these constants and values are hardcoded to store the properties of users. This makes it easier to use these values later in this tutorial.
