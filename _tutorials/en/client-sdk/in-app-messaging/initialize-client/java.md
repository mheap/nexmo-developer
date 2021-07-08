---
title: Initialize the client
description: In this step you will initialize `NexmoClient`, so it can be used within the application.
---

# Initialize the client

[NexmoClient](https://developer.nexmo.com/sdk/stitch/android/com/nexmo/client/NexmoClient.html) is the main class used to interact with `Android-Client-SDK`. Prior to usage, you have to initialize the client by providing an instance of the Android [Context](https://developer.android.com/reference/android/content/Context) class. 

At the top of the `MainActivity` class define `client` property that will hold reference to the client:

```java
private NexmoClient client;
```

Locate the `onCreate` method in the `MainActivity` class and initialize `NexmoClient` using the builder:

```java
client = new NexmoClient.Builder().build(this);
```

IDE will display warning about unresolved reference:

![](/screenshots/tutorials/client-sdk/android-shared/missing-import-kotlin.png)

Put caret on the red text and press `Alt + Enter` to import the reference.

Now below client initialization code add connection listener to monitor connection state:

```java
client.setConnectionListener((connectionStatus, connectionStatusReason) -> {
    if (connectionStatus == NexmoConnectionListener.ConnectionStatus.CONNECTED) {
        Toast.makeText(this, "User connected", Toast.LENGTH_SHORT);
        
        getConversation();
    } else if (connectionStatus == NexmoConnectionListener.ConnectionStatus.DISCONNECTED) {
        Toast.makeText(this, "User disconnected", Toast.LENGTH_SHORT);
        
        runOnUiThread(() -> {
            chatContainer.setVisibility(View.GONE);
            loginContainer.setVisibility(View.VISIBLE);
        });
    }
});
```

 The above listener allows determining that that user has logged in successfully and show the chat UI. 
 
 Add empty `getConversation` method. You will update it in the following steps:

```java
private void getConversation() { }
```

 Add the code to login the users at the bottom of the `onCreate` method. Please make sure to replace `ALICE_JWT` and `BOB_JWT` with the JWT you created during a previous step:

```java
findViewById(R.id.loginAsAliceButton).setOnClickListener(it -> {
    client.login(ALICE_JWT);

    runOnUiThread(() -> loginContainer.setVisibility(View.GONE));
});

findViewById(R.id.loginAsBobButton).setOnClickListener(it -> {
    client.login(BOB_JWT);

    runOnUiThread(() -> loginContainer.setVisibility(View.GONE));
});
```

Finally in the same method add the code to logout the user:

```java
findViewById(R.id.logoutButton).setOnClickListener(it -> client.logout());
```

Run `Build` > `Make project` to make sure the project is compiling.
