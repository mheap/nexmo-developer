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

Right click on `com.vonage.tutorial.messaging` package, select `New` > `Java File`, enter `LoginFragment` as file name and select `Class`.

Repleace file content with below code snippet:

```java
package com.vonage.tutorial.messaging;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus;

public class LoginFragment extends Fragment {

    private Button loginAsAliceButton;
    private Button loginAsBobButton;
    private ProgressBar progressBar;
    private TextView connectionStatusTextView;

    private LoginViewModel viewModel;

    public LoginFragment() {
        super(R.layout.fragment_login);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        viewModel = new ViewModelProvider(requireActivity()).get(LoginViewModel.class);

        viewModel._connectionStatusLiveData.observe(getViewLifecycleOwner(), connectionStatus -> {
            connectionStatusTextView.setText(connectionStatus.toString());

            if (connectionStatus == ConnectionStatus.DISCONNECTED) {
                setDataLoading(false);
            }
        });

        loginAsAliceButton = view.findViewById(R.id.loginAsAliceButton);
        loginAsBobButton = view.findViewById(R.id.loginAsBobButton);
        progressBar = view.findViewById(R.id.progressBar);
        connectionStatusTextView = view.findViewById(R.id.connectionStatusTextView);


        loginAsAliceButton.setOnClickListener(it -> loginUser(Config.getAlice()));

        loginAsBobButton.setOnClickListener(it -> loginUser(Config.getBob()));
    }

    private void setDataLoading(Boolean dataLoading) {
        loginAsAliceButton.setEnabled(!dataLoading);
        loginAsBobButton.setEnabled(!dataLoading);

        int visibility;

        if (dataLoading) {
            visibility = View.VISIBLE;
        } else {
            visibility = View.GONE;
        }

        progressBar.setVisibility(visibility);
    }

    private void loginUser(User user) {
        if (user.jwt.trim().isEmpty()) {
            Toast.makeText(getActivity(), "Error: Please set Config." + user.name + " jwt", Toast.LENGTH_SHORT).show();
        } else {
            viewModel.onLoginUser(user);
            setDataLoading(true);
        }
    }
}
```

## Create ViewModel

Right click on `com.vonage.tutorial.messaging` package, select `New` > `Java Class`, enter `LoginViewModel` as file name and select `Class`.

Repleace file content with below code snippet:

```java
package com.vonage.tutorial.messaging;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;
import androidx.navigation.NavDirections;
import com.nexmo.client.NexmoClient;
import com.nexmo.client.request_listener.NexmoConnectionListener;
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus;

public class LoginViewModel extends ViewModel {

    private NexmoClient client = null

    NavManager navManager = NavManager.getInstance();
    private MutableLiveData<ConnectionStatus> connectionStatusMutableLiveData = new MutableLiveData<ConnectionStatus>();
    public LiveData<ConnectionStatus> _connectionStatusLiveData = connectionStatusMutableLiveData;

    public LoginViewModel() {
        // TODO: Add client connection listener
    }

    private void navigate() {
        NavDirections navDirections = LoginFragmentDirections.actionLoginFragmentToChatFragment();
        navManager.navigate(navDirections);
    }

    void onLoginUser(User user) {
        // TODO: Login user
    }
}
```

### Get NexmoClient instance

You have to retrieve client instance inside `LoginViewModel` class. Usually, it would be provided it via injection, but for tutorial purposes you will retrieve instance directly using static method. Repleace the `client` property in the `LoginViewModel` class:

```java
NexmoClient.get();
```

### Login user

Your user must be authenticated to be able to participate in the Conversation. Repleace the `onLoginUser` method inside `LoginViewModel` class:

```java
fun onLoginUser(user: User) {
    if (user.jwt.isNotBlank()) {
        this.user = user
        client.login(user.jwt)
    }
}
```

> **NOTE:** Inside `LoginFragment` class, explore the `loginUser` method. This method is called when one of the two `Login ...` buttons are clicked. This method calls the above `onLoginUser` method. 

### Monitor connection state

When a successful connection is established you need to navigate user to `ChatFragment`. Locate the ``LoginViewModel` constructor and replace its body:


```java
public class LoginViewModel extends ViewModel {

    // ...

    public LoginViewModel() {
        client.setConnectionListener(new NexmoConnectionListener() {
            @Override
            public void onConnectionStatusChange(@NonNull ConnectionStatus connectionStatus, @NonNull ConnectionStatusReason connectionStatusReason) {
                if (connectionStatus == ConnectionStatus.CONNECTED) {
                    NavDirections navDirections = LoginFragmentDirections.actionLoginFragmentToChatFragment();
        navManager.navigate(navDirections);
                    return;
                }

                connectionStatusMutableLiveData.postValue(connectionStatus);
            }
        });
    }

    // ...
}
```

The above code will monitor connection state and if the user is authenticated (`ConnectionStatus.CONNECTED`) it will navigate the user to the `ChatFragment`, otherwise it will emit connestion status to the UI (`LoginFragmnt`).

## Create ChatFragment

Right click on `com.vonage.tutorial.messaging` package, select `New` > `Java Class`, enter `ChatFragment` as file name and select `Class`.

Repleace file content with below code snippet:

```java
package com.vonage.tutorial.messaging;

import androidx.fragment.app.Fragment;

public class ChatFragment extends Fragment {
    
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

You're now ready to retrieve and send messages.

