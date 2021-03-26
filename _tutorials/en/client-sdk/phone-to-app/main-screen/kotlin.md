---
title: Building the interface
description: In this step you will build the only screen of the app.
---

# Building the interface

To be able view the connection status of the app you will need to add a `TextView` view to the screen. You will also add buttons to control the call (Answer, Reject, End). Replace content of `app/res/layout/activity_main.xml` file with below layout:

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
            android:layout_marginBottom="40dp"
            app:layout_constraintRight_toRightOf="parent" />

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

## Retrieve views references

You will control the view using code, so references to the views have to be stored in the `MainActivity` class. Add these properties at the top of the `ManActivity` class:

```kotlin
private lateinit var connectionStatusTextView: TextView
private lateinit var answerCallButton: Button
private lateinit var rejectCallButton: Button
private lateinit var endCallButton: Button
```

Now you need to assign views to previously added properties. Add below code to the `onCreate` method inside `MainActivity` class (below request permissions code):

```kotlin
// init views
connectionStatusTextView = findViewById(R.id.connectionStatusTextView)
answerCallButton = findViewById(R.id.answerCallButton)
rejectCallButton = findViewById(R.id.rejectCallButton)
endCallButton = findViewById(R.id.endCallButton)
```

You will fill the body of these methods in the following steps of this tutorial.

## Build and Run

Run the project again (`Ctrl + R`). 

Notice that buttons are hidden by default:

![Main screen](/screenshots/tutorials/client-sdk/phone-to-app/main-screen.png)

The state of the connection and the call controls buttons will be shown after logging in the user. You will do it in the following step.
