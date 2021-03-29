---
title: Initialize the client
description: In this step you will initialize Client, so it can be used within the application.
---

# Initialize the client

[NexmoClient](https://developer.nexmo.com/sdk/stitch/android/com/nexmo/client/NexmoClient.html) is the main class used to interact with `Android-Client-SDK`. Prior to usage, you have to initialize the client by providing an instance of the Android [Context](https://developer.android.com/reference/android/content/Context) class. 

At the top of the `MainActivity` class define `client` property that will hold reference to the client and `loggedInUser` property that will hold the name of currently logged in user:

```java
private NexmoClient client;
private String loggedInUser = "";
```

Locate the `onCreate` method in the `MainActivity` class and initialize `NexmoClient` using the builder:

```java
override fun onCreate(savedInstanceState: Bundle?) {
    
    // ...

    client = new NexmoClient.Builder().build(this);
}
```

Now below client initialization code add connection listener to monitor connection state:

```java
client.setConnectionListener((connectionStatus, connectionStatusReason) -> {
    runOnUiThread(() -> {
        connectionStatusTextView.setText(connectionStatus.toString());
    });

    if (connectionStatus == ConnectionStatus.CONNECTED) {
        runOnUiThread(() -> {
            startCallButton.setVisibility(View.VISIBLE);

            cleanUI();
            connectionStatusTextView.setVisibility(View.VISIBLE);

            if(loggedInUser == "Alice") {
                startCallButton.setVisibility(View.VISIBLE);

            } else if (loggedInUser == "Bob"){
                waitingForIncomingCallTextView.setVisibility(View.VISIBLE);
            }
        });
        
        return;
    }
});
```

The above listener allows us to determine that that user has logged in successfully. After successful login based on the user name, the app will show `start call` button (for `Alice`) or `Waiting for incoming call` text (for `Bob`).


Now in the `MainActivity` class add helper method that hides all UI items:

```java
private void cleanUI() {
    LinearLayout content = findViewById(R.id.content)

    for(int i =0; i< content.getChildCount(); i++){
        View view = content.getChildAt(i);
        view.setVisibility(View.GONE);
    }
}
```

 Finally fill the body of two methods to allow user login. Please make sure to replace `ALICE_JWT` and `BOB_JWT` with the JWTs you created during a previous step:

```kotlin
private void loginAsAlice() {
    loggedInUser = "Alice"
    client.login("BOB_JWT")
}

private void loginAsBob() {
    loggedInUser = "Bob"
    client.login("ALICE_JWT")
}
```

> **NOTE** Expiry time for the token was set to 6 hours so you will need to generate a new one if it is too old.

## Build and Run

Press `Ctrl + R` buttons to build and run the app. 

After successful `Alice` login you will see `make a call` button:

![Make a call](/screenshots/tutorials/client-sdk/app-to-app/call-screen-alice.png)

Launch app again. After successful `Bob` login you will see `Waiting for incoming call` text view:

![Make a call](/screenshots/tutorials/client-sdk/app-to-app/call-screen-alice.png)

