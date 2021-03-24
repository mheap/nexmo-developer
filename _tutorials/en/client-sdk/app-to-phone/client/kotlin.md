---
title: Initialize the client
description: In this step you will initialize Client, so it can be used within the application.
---

# Initialize the client

[NexmoClient](https://developer.nexmo.com/sdk/stitch/android/com/nexmo/client/NexmoClient.html) is the main class used to interact with `Android-Client-SDK`. Prior to usage, you have to initialize the client by providing an instance of the Android [Context](https://developer.android.com/reference/android/content/Context) class. 

At the top of the `MainActivity` class define `client` property that will hold reference to the client:

```kotlin
private lateinit var client: NexmoClient
```

Locate the `onCreate` method in the `MainActivity` class and initialize `NexmoClient` using the builder:

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    
    // ...

    client = NexmoClient.Builder().build(this)
}
```

Now below client intialisation code add connection listener to monitor connection state:

```kotlin
client.setConnectionListener { connectionStatus, _ ->
    runOnUiThread { connectionStatusTextView.text = connectionStatus.toString() }

    if (connectionStatus == ConnectionStatus.CONNECTED) {
        makeCallButton.visibility = View.VISIBLE;

        return@setConnectionListener
    }
}
```

 The above listener allows us to determine that that user has logged in successfully and show `make a call` button. 
 
 Finally add the code to login the user. Please make sure to replace `ALICE_JWT` with the JWT you created during a previous step:

```kotlin
client.login("ALICE_JWT")
```

> **NOTE** Expiry time for the token was set to 6 hours so you will need to generate a new one if it is too old.

## Build and Run

`Ctrl + R` to build and run the app again. After sucesfull login you will see `make a call` button:

![Make a call](/screenshots/tutorials/client-sdk/app-to-phone/make-a-call.png)
