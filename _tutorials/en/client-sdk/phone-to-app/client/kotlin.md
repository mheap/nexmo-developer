---
title: Initialize client
description: In this step you will authenticate to the Vonage servers.
---

# Initialize client

Before you can place a call, you need to initialize Client SDK. Add this line at the end of `onCreate` method of `MainActivity` class:

```kotlin
val client: NexmoClient = NexmoClient.Builder().build(this)
```

# Set connection listener

You have to listen for the st

```kotlin
client.setConnectionListener { connectionStatus, _ ->
    runOnUiThread {
        connectionStatusTextView.text = connectionStatus.toString()
    }
}
```



Now client needs to authenticate to the Vonage servers. The following additions are required to `onCreate` method inside `MainActivity`. Replace the `ALICE_TOKEN` with the JWT token, you obtained previously from Nexmo CLI:

```kotlin
client.login("ALICE_TOKEN");
```


## Build and Run

Press `Cmd + R` to build and run the app.
