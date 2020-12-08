---
title: Authenticate Users
description: In this step you authenticate your users via the JWTs you created earlier
---

# Authenticate Users

You perform this authentication using the `JWTs` generated in previous steps. Users must be authenticated to be able to participate in the Conversation. You will now build login screen (`LoginFragment` and `LoginViewModel` classes) responsible for authenticating the users.

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/login-screen-users.png
```

## Create layout

Right click on `res/layout` folder, select `New` > `Layout Resource File`, enter `fragment_login` as file name and press `OK`.

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/new-android-resource-file.png
```

Click `Code` button in top right corner to display layout XML code:

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/show-code-view.png
```

Repleace file content with below code snippet:

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        xmlns:tools="http://schemas.android.com/tools"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="10dp">

    <Button
            android:id="@+id/loginAsAliceButton"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Login as Alice"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintLeft_toLeftOf="parent"
            app:layout_constraintRight_toRightOf="parent"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintVertical_bias="0.2" />

    <Button
            android:id="@+id/loginAsBobButton"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Login as Bob"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintLeft_toLeftOf="parent"
            app:layout_constraintRight_toRightOf="parent"
            app:layout_constraintTop_toBottomOf="@id/loginAsAliceButton"
            app:layout_constraintVertical_bias="0.1" />

    <androidx.core.widget.ContentLoadingProgressBar
            android:id="@+id/progressBar"
            style="?android:attr/progressBarStyleLarge"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:visibility="invisible"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintLeft_toLeftOf="parent"
            app:layout_constraintRight_toRightOf="parent"
            app:layout_constraintTop_toBottomOf="@id/loginAsBobButton" />

    <TextView
            android:id="@+id/connectionStatusTextView"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="@color/colorPrimary"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintLeft_toLeftOf="parent"
            app:layout_constraintRight_toRightOf="parent"
            app:layout_constraintTop_toBottomOf="@id/progressBar"
            tools:text="Connection status" />

</androidx.constraintlayout.widget.ConstraintLayout>
```

## Create Fragment

Right click on `com.vonage.tutorial.messaging` package, select `New` > `Kotlin Class/File`, enter `LoginFragment` as file name and select `Class`.

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

## Create ViewModel

Right click on `com.vonage.tutorial.messaging` package, select `New` > `Kotlin Class/File`, enter `LoginViewModel` as file name and select `Class`.

Repleace file content with below code snippet:

```kotlin
package com.vonage.tutorial.messaging

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoClient
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus

class LoginViewModel : ViewModel() {

    private val navManager = NavManager

    private val _connectionStatus = MutableLiveData<ConnectionStatus>()
    val connectionStatus = _connectionStatus as LiveData<ConnectionStatus>

    private var user: User? = null

    private val client: NexmoClient = TODO("Retrieve NexmoClient instance")

    init {
        TODO("Add client connection listener")
    }

    fun onLoginUser(user: User) {
        TODO("Login user")
    }
}
```

### Get NexmoClient instance

You have to retrieve client instance inside `LoginViewModel` class. Usually, it would be provided it via injection, but for tutorial purposes you will retrieve instance directly using static method. Repleace the `client` property in the `LoginViewModel` class:

```kotlin
private val client = NexmoClient.get()
```

### Login user

Your user must be authenticated to be able to participate in the Conversation. Repleace the `onLoginUser` method inside `LoginViewModel` class:

```kotlin
fun onLoginUser(user: User) {
    if (user.jwt.isNotBlank()) {
        this.user = user
        client.login(user.jwt)
    }
}
```

> **NOTE:** Inside `LoginFragment` class, explore the `loginUser` method. This method is called when one of the two `Login ...` buttons are clicked. This method calls the above `onLoginUser` method. 

### Monitor connection state

When a successful connection is established you need to navigate user to `ChatFragment`. Locate the `init` block inside `LoginViewModel` class and replace it's body:


```kotlin
class LoginViewModel : ViewModel() {
    init {
        client.setConnectionListener { newConnectionStatus, _ ->

            if (newConnectionStatus == ConnectionStatus.CONNECTED) {
                val navDirections = LoginFragmentDirections.actionLoginFragmentToChatFragment()
                navManager.navigate(navDirections)
                
                return@setConnectionListener
            }

            _connectionStatus.postValue(newConnectionStatus)
        }
    }

    // ...
}
```

The above code will monitor connection state and if the user is authenticated (`ConnectionStatus.CONNECTED`) it will navigate the user to the `ChatFragment`, otherwise it will emit connestion status to the UI (`LoginFragmnt`).

## Create ChatFragment

Right click on `com.vonage.tutorial.messaging` package, select `New` > `Kotlin Class/File`, enter `ChatFragment` as file name and select `Class`.

Repleace file content with below code snippet:

```kotlin
package com.vonage.tutorial.messaging

import androidx.fragment.app.Fragment

class ChatFragment: Fragment() {
    
}
```

For now this fragmnt is just a placeholder for navigation. You will add functionality to it in following steps.

## Add Fragment to navigation graph

Open `app_nav_graph.xml` file and repleace it's content with below code snippet to define navigation graph for the application. 

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
            android:label="LoginFragment">
        <action
                android:id="@+id/action_loginFragment_to_chatFragment"
                app:destination="@id/chatFragment" />
    </fragment>
    <fragment
            android:id="@+id/chatFragment"
            android:name="com.vonage.tutorial.messaging.ChatFragment"
            android:label="ChatFragment"/>
</navigation>
```

Navigation graph defines navigation directions between fragmensts in the application. Notice that now `LoginFragment` is now start fragment in the application

# Run the app

You can either launch the app on the physical phone (with [USB Debugging enabled](https://developer.android.com/studio/debug/dev-options#enable)) or create a new [Android Virtual Device](https://developer.android.com/studio/run/managing-avds). When device is present press `Run` button: 

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/launch-app.png
```

You should see login screen with two buttons `Login Bob` and `Login Alice`. After clicking one of them user should login in and empty chat screen should open.

You're now ready to rerieve and send messages.

