---
title: Initialize the client
description: In this step you will initialize `NexmoClient`, so it can be used within the application.
---

# Initialize the client

[NexmoClient](https://developer.nexmo.com/sdk/stitch/android/com/nexmo/client/NexmoClient.html) is the main class used to interact with `Android-Client-SDK`. Prior to usage, you have to initialize the client by providing an instance of the Android [Context](https://developer.android.com/reference/android/content/Context) class. 

At the top of the `MainActivity` class define `client` property that will hold reference to the client:

```kotlin
private lateinit var client: NexmoClient
```

Locate the `onCreate` method in the `MainActivity` class and initialize `NexmoClient` using the builder:

```kotlin
client = NexmoClient.Builder().build(this)
```

Now below client initialization code add connection listener to monitor connection state:

```kotlin
client.setConnectionListener { connectionStatus, _ ->
    runOnUiThread { connectionStatusTextView.text = connectionStatus.toString() }

    if (connectionStatus == ConnectionStatus.CONNECTED) {
        runOnUiThread { startCallButton.visibility = View.VISIBLE }

        return@setConnectionListener
    }
}
```

 The above listener allows to determine that that user has logged in successfully and show the `START CALL` button. 
 
 Finally add the code to login the user. Please make sure to replace `ALICE_JWT` with the JWT you created during a previous step:

```kotlin
client.login("ALICE_JWT")
```

 The above listener allows to determine that that user has logged in successfully and show the chat UI. 
 
 Add the code to login the user at the bottom of the `onCreate` method. Please make sure to replace `ALICE_JWT` and `BOB_JWT` with the JWT you created during a previous step:

```kotlin
findViewById<View>(R.id.loginAsAliceButton).setOnClickListener {
    findViewById<TextView>(R.id.userNameTextView).text = "Alice: "
    client.login(ALICE_JWT)

    runOnUiThread {
        loginContainer.visibility = View.INVISIBLE
    }
}

findViewById<View>(R.id.loginAsBobButton).setOnClickListener {
    findViewById<TextView>(R.id.userNameTextView).text = "Bob: "
    client.login(BOB_JWT)

    runOnUiThread {
        loginContainer.visibility = View.INVISIBLE
    }
}
```

Finally add the code to logout the user:

```kotlin
findViewById<View>(R.id.logoutButton).setOnClickListener { client.logout() }
```

> **NOTE:** You can enable additional `Logcat` logging by using `logLevel()` method of the builder, for example, `NexmoClient.Builder().logLevel(ILogger.eLogLevel.SENSITIVE).build(this)`

![](/screenshots/tutorials/client-sdk/android-shared/missing-import-kotlin.png)

Run `Build` > `Make project` to make sure the project is compiling.
