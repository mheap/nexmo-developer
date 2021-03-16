---
title: Configure JWTs
description: In this step you learn how to add JWT to the application.
---

# Configure JWTs and conversation id

Create a `Config.kt` file in the `com.vonage.tutorial.voice` package to store the configuration. Right click on the `voice` package and select `New` > `Kotlin Class/File`.  Enter `Config` as name and select `File` and press Enter to confirm.

Replace the file contents with the following code:

```kotlin
package com.vonage.tutorial.voice

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

Now it's time to configure the `Alice` user with the JWT that you generated in an earlier step. Replace the `ALICE_TOKEN` with the JWT token, you obtained previously from Nexmo CLI.

Notice that these constants and values are hardcoded to store the properties of users. This makes it easier to use these values later in this tutorial.

Run `Build` > `Make project` to make sure project is compiling.