---
title: Configure JWTs and conversation id
description: In this step you learn how to add JWT to the application and set the conversation id.
---

# Configure JWTs and conversation id

Create a `Config.kt` file in the `com.vonage.tutorial.messaging` package to store the configuration. Right click on the `messaging` package and select `New` > `Kotlin Class/File`. Enter `Config` as name and select `File` and press Enter to confirm.

Replace the file contents with the following code:

```kotlin
package com.vonage.tutorial.messaging

object Config {

    const val CONVERSATION_ID: String = "" // TODO: set conversation Id

    val alice = User(
        "Alice",
        "ALICE_TOKEN" // TODO: "set Alice's JWT token"
    )
    val bob = User(
        "Bob",
        "BOB_TOKEN" // TODO: "set Bob's JWT token"
    )
}

data class User(
    val name: String,
    val jwt: String
)
```


Now it's time to configure conversation and users. Replace the `CONVERSATION_ID` and JWT tokens with values generated in a earlier steps:

1. `CONVERSATION_ID` - id of the conversation created in the previous step
2. `ALICE_TOKEN` - Alice JWT token
3. `BOB_TOKEN` - Bob JWT token

Notice that these constants and values are hardcoded to store the properties of users. This makes it easier to use these values later in this tutorial.