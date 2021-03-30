---
title: Initialize the client
description: In this step you will initialize Client, so it can be used within the application.
---

# Initialize the client

[NexmoClient](https://developer.nexmo.com/sdk/stitch/android/com/nexmo/client/NexmoClient.html) is the main class used to interact with `Android-Client-SDK`. Prior to usage, you have to initialize the client by providing an instance of the Android [Context](https://developer.android.com/reference/android/content/Context) class. 

At the top of the `MainActivity` class define `client` property that will hold the reference to the client and `otherUser` property that will hold the name of 2nd user (the user that call will be made to):

```kotlin
private lateinit var client: NexmoClient
private var otherUser: String = ""
```

Locate the `onCreate` method in the `MainActivity` class and initialize `NexmoClient` using the builder:

```kotlin
client = NexmoClient.Builder().build(this)
```

Now below client initialization code add connection listener to monitor connection state:

```kotlin
client.setConnectionListener { connectionStatus, _ ->
    runOnUiThread { connectionStatusTextView.text = connectionStatus.toString() }

    if (connectionStatus == NexmoConnectionListener.ConnectionStatus.CONNECTED) {
        runOnUiThread {
            hideUI()
            connectionStatusTextView.visibility = View.VISIBLE
            startCallButton.visibility = View.VISIBLE
            waitingForIncomingCallTextView.visibility = View.VISIBLE
        }

        return@setConnectionListener
    }
}
```

The above listener allows us to determine that that user has logged in successfully. After successful login based on the user name, the app will show `start call` button (for `Alice`) or `Waiting for incoming call` text (for `Bob`).

Now in the `MainActivity` class add helper method that hides all UI items:

```kotlin
private fun hideUI() {
    val content = findViewById<LinearLayout>(R.id.content)
    content.forEach { it.visibility = View.GONE }
}
```
 
 Finally fill the body of two methods to allow user login. Please make sure to replace `ALICE_JWT` and `BOB_JWT` with the JWTs you created during a previous step:

```kotlin
private fun loginAsAlice() {
    otherUser = "Bob";

    client.login("ALICE_JWT");
}

private fun loginAsBob() {
    otherUser = "Alice";

    client.login("BOB_JWT");
}
```

> **NOTE** Expiry time for the token was set to 6 hours so you will need to generate a new one if it is too old.

## Build and Run

Press `Ctrl + R` buttons to build and run the app. 

After successful user login you will see  `waiting for incoming call` text and `make a call` button:

![Make a call](/screenshots/tutorials/client-sdk/app-to-app/make-call.png)
