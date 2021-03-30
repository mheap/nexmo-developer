---
title: Build main screen
description: In this step you build main screen.
---

# Building the interface

To be able to place and manage the call, you need to add few elements to the screen:

* Button to login `Alice` user
* Button to login `Bob` user
* A `TextView` to show the connection status
* A `Button` to start the call
* A `Button` to end the call
* A `Button` to answer the call
* A `Button` to reject the call

Open the `app/res/layout/activity_main.xml` file. Click the `Code` button in the top right corner:

![Code view](/screenshots/tutorials/client-sdk/android-shared/show-code-view.png)

Replace the file contents with the following:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        xmlns:tools="http://schemas.android.com/tools"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical"
        android:gravity="center"
        android:id="@+id/content"
        tools:context=".MainActivity">

    <TextView
            android:id="@+id/connectionStatusTextView"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginBottom="40dp" />

    <Button
            android:id="@+id/loginAsAlice"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginBottom="40dp"
            android:text="Login Alice" />

    <Button
            android:id="@+id/loginAsBob"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginBottom="40dp"
            android:text="Login Bob" />

    <TextView
            android:id="@+id/waitingForIncomingCallTextView"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginBottom="40dp"
            android:text="Waiting for incoming call"
            android:visibility="gone"
            tools:visibility="visible"/>

    <Button
            android:id="@+id/startCallButton"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginBottom="40dp"
            android:text="Start call"
            android:visibility="gone"
            tools:visibility="visible" />

    <Button
            android:id="@+id/answerCallButton"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginBottom="40dp"
            android:text="Answer"
            android:visibility="gone"
            tools:visibility="visible" />

    <Button
            android:id="@+id/rejectCallButton"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginBottom="40dp"
            android:text="Reject"
            android:visibility="gone"
            tools:visibility="visible" />

    <Button
            android:id="@+id/endCallButton"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginBottom="40dp"
            android:text="End"
            android:visibility="gone"
            tools:visibility="visible" />

</LinearLayout>
```

You will control the view using code, so you have to store references to the views. Add these properties at the top of the `ManActivity` class:

```java
private TextView connectionStatusTextView;
private TextView waitingForIncomingCallTextView;
private Button loginAsAlice;
private Button loginAsBob;
private Button startCallButton;
private Button answerCallButton;
private Button rejectCallButton;
private Button endCallButton;
```

Now you need to assign views to previously added properties and add callbacks to the buttons. Add below code to the `onCreate` method inside `MainActivity` class (below request permissions code):

```java
// init views
connectionStatusTextView = findViewById(R.id.connectionStatusTextView);
waitingForIncomingCallTextView = findViewById(R.id.waitingForIncomingCallTextView);
loginAsAlice = findViewById(R.id.loginAsAlice);
loginAsBob = findViewById(R.id.loginAsBob);
startCallButton = findViewById(R.id.startCallButton);
answerCallButton = findViewById(R.id.answerCallButton);
rejectCallButton = findViewById(R.id.rejectCallButton);
endCallButton = findViewById(R.id.endCallButton);

loginAsAlice.setOnClickListener(v -> loginAsAlice());
loginAsBob.setOnClickListener(v -> loginAsBob());
```

To make code compile add these two empty methods in the `MainActivity` class:

```java
private void loginAsAlice() {
    // TODO: update body
}

private void loginAsBob() {
    // TODO: update body
}
```

You will fill the body of these methods in the following steps of this tutorial.

## Build and Run

Run the project again (`Ctrl + R`). 

Notice that some views are hidden by default. After launching the app you will see `login alice` and `login bob` buttons:

![Main screen](/screenshots/tutorials/client-sdk/app-to-app/main-screen.png)
