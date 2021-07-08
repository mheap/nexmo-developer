---
title: Build main screen
description: In this step you build main screen.
---

# Building the interface

To be able to place the call, you need to add three elements to the screen:

* A `TextView` to show the connection status
* A `Button` to start the call
* A `Button` to end the call

Open the `app/res/layout/activity_main.xml` file. Click the `Code` button in the top right corner:

![Code view](/screenshots/tutorials/client-sdk/android-shared/show-code-view.png)

Replace the file contents with the following:

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
        xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        xmlns:tools="http://schemas.android.com/tools"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="10dp">

    <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:id="@+id/loginContainer"
            android:orientation="vertical"
            android:gravity="center"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintLeft_toLeftOf="parent"
            app:layout_constraintRight_toRightOf="parent"
            app:layout_constraintTop_toTopOf="parent">

        <Button
                android:id="@+id/loginAsAliceButton"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginBottom="40dp"
                android:text="Login Alice" />

        <Button
                android:id="@+id/loginAsBobButton"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginBottom="40dp"
                android:text="Login Bob" />

    </LinearLayout>

    <androidx.constraintlayout.widget.ConstraintLayout
            android:id="@+id/chatContainer"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:visibility="gone"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintLeft_toLeftOf="parent"
            app:layout_constraintRight_toRightOf="parent"
            app:layout_constraintTop_toBottomOf="parent"
            tools:visibility="visible">

        <Button
                android:id="@+id/logoutButton"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Logout"
                app:layout_constraintBottom_toTopOf="@id/conversationEventsScrollView"
                app:layout_constraintRight_toRightOf="parent"
                app:layout_constraintTop_toTopOf="parent" />

        <androidx.core.widget.NestedScrollView
                android:id="@+id/conversationEventsScrollView"
                android:layout_width="0dp"
                android:layout_height="0dp"
                app:layout_constraintBottom_toTopOf="@+id/messageEditText"
                app:layout_constraintLeft_toLeftOf="parent"
                app:layout_constraintRight_toRightOf="parent"
                app:layout_constraintTop_toBottomOf="@id/logoutButton">

            <TextView
                    android:id="@+id/conversationTextView"
                    android:layout_width="match_parent"
                    android:layout_height="match_parent"
                    android:textSize="20sp"
                    tools:text="Conversation events" />

        </androidx.core.widget.NestedScrollView>

        <TextView
                android:id="@+id/userNameTextView"
                android:layout_width="wrap_content"
                android:layout_height="0dp"
                android:gravity="center_vertical"
                android:paddingRight="10dp"
                android:textSize="20sp"
                app:layout_constraintBottom_toBottomOf="parent"
                app:layout_constraintLeft_toLeftOf="parent"
                app:layout_constraintRight_toLeftOf="@id/messageEditText"
                app:layout_constraintTop_toBottomOf="@+id/conversationEventsScrollView"
                tools:text="User name" />

        <EditText
                android:id="@+id/messageEditText"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:hint="Message"
                android:inputType="text"
                android:textColor="@color/black"
                android:textColorHint="#AAAAAA"
                app:layout_constraintBottom_toBottomOf="parent"
                app:layout_constraintLeft_toRightOf="@id/userNameTextView"
                app:layout_constraintRight_toLeftOf="@id/sendMessageButton"
                app:layout_constraintTop_toBottomOf="@+id/conversationEventsScrollView"
                tools:text="Message" />

        <Button
                android:id="@+id/sendMessageButton"
                android:layout_width="wrap_content"
                android:layout_height="0dp"
                android:text="Send"
                app:layout_constraintBottom_toBottomOf="parent"
                app:layout_constraintLeft_toRightOf="@id/messageEditText"
                app:layout_constraintRight_toRightOf="parent"
                app:layout_constraintTop_toBottomOf="@+id/conversationEventsScrollView" />

    </androidx.constraintlayout.widget.ConstraintLayout>

</androidx.constraintlayout.widget.ConstraintLayout>
```

You will control the view using code, so you have to store references to the views. Add these properties at the top of the `MainActivity` class:

```java
private ConstraintLayout chatContainer;
private LinearLayout loginContainer;
private EditText messageEditText;
private TextView conversationTextView;
```

Now you need to assign views to previously added properties. Add below code to the `onCreate` method inside `MainActivity` class (below request permissions code):

```java
chatContainer = findViewById(R.id.chatContainer);
loginContainer = findViewById(R.id.loginContainer);
messageEditText = findViewById(R.id.messageEditText);
conversationTextView = findViewById(R.id.conversationTextView);
```


Now you need to assign views to previously added properties. Add below code to the `onCreate` method inside `MainActivity` class (below request permissions code):


```java
chatContainer = findViewById(R.id.chatContainer);
loginContainer = findViewById(R.id.loginContainer);
messageEditText = findViewById(R.id.messageEditText);
conversationTextView = findViewById(R.id.conversationTextView);
```

## Build and Run

Run the project again (`Ctrl + R`).
