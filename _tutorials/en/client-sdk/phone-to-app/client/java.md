---
title: Initialize client
description: In this step you will authenticate to the Vonage servers.
---

# Initialize client

Before you can place a call, you need to initialize Client SDK. Add this line at the end of `onCreate` method of `MainActivity` class:

```java
NexmoClient client = new NexmoClient.Builder().build(this);
```

IDE will display a warning about the unresolved reference:

![](/screenshots/tutorials/client-sdk/android-shared/missing-import-java.png)

Put caret on the red text and press `Alt + Enter` to import the reference.

# Set connection listener

Now below client initialization code add connection listener to monitor connection state:

```java
client.setConnectionListener((connectionStatus, connectionStatusReason) -> runOnUiThread(() -> connectionStatusTextView.setText(connectionStatus.toString())));
```



Now client needs to authenticate to the Vonage servers. The following additions are required to `onCreate` method inside `MainActivity`. Replace the `ALICE_TOKEN` with the JWT token, you obtained previously from Vonage CLI:

```java
client.login("ALICE_TOKEN");
```


## Build and Run

Press the `Ctrl + R` keys to build and run the app again. After successful login you will see `CONNECTED` text:

![Connected](/screenshots/tutorials/client-sdk/phone-to-app/connected.png)
