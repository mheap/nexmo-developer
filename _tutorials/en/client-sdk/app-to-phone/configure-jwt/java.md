---
title: Configure JWT
description: In this step you learn how to add JWT to the application.
---

# Configure JWT

Create a `User` class in the `com.vonage.tutorial.voice` package to store user data. Right click on the `voice` package and select `New` > `Java Class`. Enter `User` and select `Class`.

Replace the file contents with the following code:

```java
package com.vonage.tutorial.voice;

public class User {

    public String jwt;
    String name;

    public User(String name, String jwt) {
        this.name = name;
        this.jwt = jwt;
    }

    public String getName() {
        return name;
    }

    public String getId() {
        return jwt;
    }
}
```

Create a `Config` class in the `com.vonage.tutorial.voice` package to store the configuration. Right click on the `voice` package and select `New` > `Java Class`. Enter `Config` and select `Class`.

Replace the file contents with the following code:

```java
package com.vonage.tutorial.voice;

public class Config {

    public static User getAlice() {
        return new User(
                "Alice",
                "ALICE_TOKEN" // TODO: "set Alice JWT token"
        );
    }
}
```

Now it's time to configure the `Alice` user with the JWT that you generated in an earlier step. Replace the `ALICE_TOKEN` with the JWT token, you obtained previously from Nexmo CLI.

Notice that these constants and values are hardcoded to store the properties of users. This makes it easier to use these values later in this tutorial.

Run `Build` > `Make project` to make sure project is compiling.