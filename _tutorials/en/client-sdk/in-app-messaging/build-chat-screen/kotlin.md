---
title: Build chat screen
description: In this step you build chat screen.
---

# Create layout

Rght click on `res/layout` folder, select `New` > `Layout Resource File`, enter `fragment_chat` as file name and press `OK`.

Repleace file content with below code snippet:

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        xmlns:tools="http://schemas.android.com/tools"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="10dp">

    <androidx.core.widget.ContentLoadingProgressBar
            android:id="@+id/progressBar"
            style="?android:attr/progressBarStyleLarge"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintLeft_toLeftOf="parent"
            app:layout_constraintRight_toRightOf="parent"
            app:layout_constraintTop_toTopOf="parent" />

    <TextView
            android:id="@+id/errorTextView"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="#FF9494"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintLeft_toLeftOf="parent"
            app:layout_constraintRight_toRightOf="parent"
            app:layout_constraintTop_toBottomOf="@id/progressBar"
            tools:text="Error" />

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
                app:layout_constraintBottom_toTopOf="@id/conversationEventsScrollView"
                app:layout_constraintRight_toRightOf="parent"
                app:layout_constraintTop_toTopOf="parent"
                tools:text="Logout user" />

        <androidx.core.widget.NestedScrollView
                android:id="@+id/conversationEventsScrollView"
                android:layout_width="0dp"
                android:layout_height="0dp"
                app:layout_constraintBottom_toTopOf="@+id/messageEditText"
                app:layout_constraintLeft_toLeftOf="parent"
                app:layout_constraintRight_toRightOf="parent"
                app:layout_constraintTop_toBottomOf="@id/logoutButton">

            <TextView
                    android:id="@+id/conversationEventsTextView"
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
                android:hint="@string/message"
                android:inputType="text"
                android:textColor="@color/white"
                android:textColorHint="@color/white_alpha_60"
                app:layout_constraintBottom_toBottomOf="parent"
                app:layout_constraintLeft_toRightOf="@id/userNameTextView"
                app:layout_constraintRight_toLeftOf="@id/sendMessageButton"
                app:layout_constraintTop_toBottomOf="@+id/conversationEventsScrollView"
                tools:text="Message input" />

        <Button
                android:id="@+id/sendMessageButton"
                android:layout_width="wrap_content"
                android:layout_height="0dp"
                android:text="@string/send"
                app:layout_constraintBottom_toBottomOf="parent"
                app:layout_constraintLeft_toRightOf="@id/messageEditText"
                app:layout_constraintRight_toRightOf="parent"
                app:layout_constraintTop_toBottomOf="@+id/conversationEventsScrollView" />

    </androidx.constraintlayout.widget.ConstraintLayout>

</androidx.constraintlayout.widget.ConstraintLayout>
```

# Create Fragment

Rght click on `com.vonage.tutorial.messaging` package, select `New` > `Kotlin Class/File`, enter `LoginFragment` as file name, select `Class` and press `OK`.

Repleace file content with below code snippet:

```kotlin
package com.vonage.tutorial.messaging

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.core.view.isVisible
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus
import kotlin.properties.Delegates

class LoginFragment : Fragment(R.layout.fragment_login) {

    private val viewModel by viewModels<LoginViewModel>()

    private lateinit var loginAsAliceButton: Button
    private lateinit var loginAsBobButton: Button
    private lateinit var progressBar: ProgressBar
    private lateinit var connectionStatusTextView: TextView

    private var dataLoading: Boolean by Delegates.observable(false) { _, _, newValue ->
        loginAsAliceButton.isEnabled = !newValue
        loginAsBobButton.isEnabled = !newValue
        progressBar.isVisible = newValue
    }

    private val stateObserver = Observer<ConnectionStatus> {
        connectionStatusTextView.text = it.toString()

        if (it == ConnectionStatus.DISCONNECTED) {
            dataLoading = false
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.connectionStatus.observe(viewLifecycleOwner, stateObserver)

        loginAsAliceButton = view.findViewById(R.id.loginAsAliceButton)
        loginAsBobButton = view.findViewById(R.id.loginAsBobButton)
        progressBar = view.findViewById(R.id.progressBar)
        connectionStatusTextView = view.findViewById(R.id.connectionStatusTextView)

        loginAsAliceButton.setOnClickListener {
            loginUser(Config.alice)
        }

        loginAsBobButton.setOnClickListener {
            loginUser(Config.bob)
        }
    }

    private fun loginUser(user: User) {
        if (user.jwt.isBlank()) {
            Toast.makeText(context, "Error: Please set Config.${user.name.toLowerCase()}.jwt", Toast.LENGTH_SHORT)
        } else {
            viewModel.onLoginUser(user)
            dataLoading = true
        }
    }
}
```

# Add Fragment to navigation graph

Open `app_nav_graph.xml` file and repleace it's content with below code snippet to set `Loginragment` as start fragment in the application:

```xml
<?xml version="1.0" encoding="utf-8"?>
<navigation xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        xmlns:tools="http://schemas.android.com/tools"
        android:id="@+id/app_navigation_graph"
        app:startDestination="@id/loginFragment">
    <fragment
            android:id="@+id/loginFragment"
            android:name="com.vonage.tutorial.messaging.LoginFragment"
            android:label="LoginFragment"
            tools:layout="@layout/fragment_login">
    </fragment>
</navigation>
```

# Create ViewModel

Rght click on `com.vonage.tutorial.messaging` package, select `New` > `Kotlin Class/File`, enter `LoginViewModel` as file name, select `Class` and press `OK`.

Repleace file content with below code snippet:

```kotlin
package com.vonage.tutorial.messaging

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoClient
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus

class LoginViewModel : ViewModel() {

    private val navManager = NavManager

    private val _connectionStatus = MutableLiveData<ConnectionStatus>()
    val connectionStatus = _connectionStatus as LiveData<ConnectionStatus>

    private val client = NexmoClient.get()

    init {
        client.setConnectionListener { newConnectionStatus, _ ->
            if (newConnectionStatus == ConnectionStatus.CONNECTED) {
                navigate()
                return@setConnectionListener
            }

            _connectionStatus.postValue(newConnectionStatus)
        }
    }

    private fun navigate() {
        val navDirections = LoginFragmentDirections.actionLoginFragmentToChatFragment()
        navManager.navigate(navDirections)
    }

    fun onLoginUser(user: User) {
        if (user.jwt.isNotBlank()) {
            client.login(user.jwt)
        }
    }
}
```

