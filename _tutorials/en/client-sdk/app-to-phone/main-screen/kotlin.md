---
title: Build main screen
description: In this step you build main screen.
---

# Building the interface

To be able to place the call, you need to add three elements to the screen:

* A `TextView` to show the connection status
* A `Button` to start the call
* A `Button` to end the call

Open the `app/res/layout.activity_main.xml` file. Click the `Code` button in the top right corner:

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
        tools:context=".MainActivity">

    <TextView
            android:id="@+id/connectionStatusTextView"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@color/colorPrimary"
            android:layout_marginBottom="20dp"
            tools:text="Connection status" />

    <Button
            android:id="@+id/makeCallButton"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:drawablePadding="8dp"
            android:layout_marginBottom="20dp"
            android:padding="16dp"
            android:text="Make phone call" />

    <Button
            android:id="@+id/endCallButton"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="End call"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintLeft_toLeftOf="parent"
            app:layout_constraintRight_toRightOf="parent"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintVertical_bias="0.2"
            android:visibility="gone"
            tools:visibility="visible"/>
</LinearLayout>
```

You will control the view using code, so you have to store references to the views. Add these properties at the top of the `ManActivity` class:

```kotlin
private lateinit var makeCallButton: Button
private lateinit var endCallButton: Button
private lateinit var connectionStatusTextView: TextView
```

Now you need to assign views to previously added properties and add callbacks to the buttons. Add below code to the `onCreate` method inside `MainActivity` class (just below request permissions code):

```kotlin
// init views
makeCallButton = findViewById(R.id.makeCallButton)
endCallButton = findViewById(R.id.endCallButton)
connectionStatusTextView = findViewById(R.id.connectionStatusTextView)

makeCallButton.setOnClickListener {
        makeCall()
}

endCallButton.setOnClickListener {
        hangup()
}
```

To make code compile add these two empty methods in the `MainActivity` class:

```kotlin
@SuppressLint("MissingPermission")
private void makeCall() {
        // TODO: update body
}

private fun hangup() {
        // TODO: update body
}
```

You will fill the body of these methods in the following steps of this tutorial.
## Build and Run

Run the project again (`Ctrl + R`). 

Notice that buttons are hidden by default:

![Main screen](/screenshots/tutorials/client-sdk/app-to-phone/main-screen.png)

The state of the connection will be displayed and the `make a call` button will be shown after logging in the user.