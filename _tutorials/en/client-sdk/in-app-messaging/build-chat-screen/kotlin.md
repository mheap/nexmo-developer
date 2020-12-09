---
title: Build chat screen
description: In this step you build chat screen.
---

# Converstion

Chat screen (`ChatFragment` and `ChatViewModel` classes) is responsible for fetching the conversation and all the conversation events and sending messages.

## Update chat layout

Open `fragment_chat.xml` layout and click `Code` button in top right corner to display layout XML code:

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/layout-resource.png
```

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
                android:paddingRight="10dp"
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

## Update ChatViewModel

Open `ChatViewModel` and repleace file content with below code snippet:

```kotlin
package com.vonage.tutorial.messaging

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoAttachmentEvent
import com.nexmo.client.NexmoClient
import com.nexmo.client.NexmoConversation
import com.nexmo.client.NexmoDeletedEvent
import com.nexmo.client.NexmoDeliveredEvent
import com.nexmo.client.NexmoEvent
import com.nexmo.client.NexmoMessageEventListener
import com.nexmo.client.NexmoSeenEvent
import com.nexmo.client.NexmoTextEvent
import com.nexmo.client.NexmoTypingEvent

class ChatViewModel : ViewModel() {

    private val client: NexmoClient = NexmoClient.get()

    private var conversation: NexmoConversation? = null

    private val _errorMessage = MutableLiveData<String>()
    val errorMessage = _errorMessage as LiveData<String>

    private val _userName = MutableLiveData<String>()
    val userName = _userName as LiveData<String>

    private val _conversationEvents = MutableLiveData<List<NexmoEvent>?>()
    val conversationEvents = _conversationEvents as LiveData<List<NexmoEvent>?>

    private val messageListener = object : NexmoMessageEventListener {
        override fun onTypingEvent(typingEvent: NexmoTypingEvent) {}

        override fun onAttachmentEvent(attachmentEvent: NexmoAttachmentEvent) {}

        override fun onTextEvent(textEvent: NexmoTextEvent) {
            TODO("Update the conversation")
        }

        override fun onSeenReceipt(seenEvent: NexmoSeenEvent) {}

        override fun onEventDeleted(deletedEvent: NexmoDeletedEvent) {}

        override fun onDeliveredReceipt(deliveredEvent: NexmoDeliveredEvent) {}
    }

    fun onInit() {
        getConversation()
        _userName.postValue(client.user.name)
    }

    private fun getConversation() {
        TODO("Get the conversation")
    }

    private fun getConversationEvents(conversation: NexmoConversation) {
        TODO("Get the conversation events")
    }

    private fun updateConversation(textEvent: NexmoEvent) {
        val events = _conversationEvents.value?.toMutableList() ?: mutableListOf()
        events.add(textEvent)
        _conversationEvents.postValue(events)
    }

    fun onSendMessage(message: String) {
        TODO("Send new message to client SDK")
    }

    fun onBackPressed() {
        client.logout()
    }

    fun onLogout() {
        client.logout()
    }

    override fun onCleared() {
        TODO("Unregister message listener")
    }
}
```

## Update ChatFragment

Open `ChatFragment` and repleace file content with below code snippet:

```kotlin
package com.vonage.tutorial.messaging

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController
import com.nexmo.client.NexmoEvent
import com.nexmo.client.NexmoMemberEvent
import com.nexmo.client.NexmoMemberState
import com.nexmo.client.NexmoTextEvent

class ChatFragment : Fragment(R.layout.fragment_chat), BackPressHandler {

    private val viewModel by viewModels<ChatViewModel>()

    private lateinit var progressBar: ProgressBar
    private lateinit var errorTextView: TextView
    private lateinit var chatContainer: ConstraintLayout
    private lateinit var logoutButton: Button
    private lateinit var sendMessageButton: Button
    private lateinit var userNameTextView: TextView
    private lateinit var messageEditText: EditText
    private lateinit var conversationEventsTextView: TextView

    private var errorMessageObserver = Observer<String> {
        progressBar.isVisible = false
        errorTextView.text = it
        errorTextView.isVisible = it.isNotEmpty()
        chatContainer.isVisible = it.isEmpty()
    }

    private var userNameObserver = Observer<String> {
        userNameTextView.text = "$it says:"
        logoutButton.text ="Logout $it"
    }

    private var conversationEvents = Observer<List<NexmoEvent>?> {
        TODO("Process incoming events")
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        if (Config.CONVERSATION_ID.isBlank()) {

            Toast.makeText(context, "Please set Config.CONVERSATION_ID", Toast.LENGTH_SHORT).show()
            activity?.onBackPressed()
            return
        }

        viewModel.onInit()

        viewModel.errorMessage.observe(viewLifecycleOwner, errorMessageObserver)
        viewModel.conversationEvents.observe(viewLifecycleOwner, conversationEvents)
        viewModel.userName.observe(viewLifecycleOwner, userNameObserver)

        progressBar = view.findViewById(R.id.progressBar)
        errorTextView = view.findViewById(R.id.errorTextView)
        chatContainer = view.findViewById(R.id.chatContainer)
        logoutButton = view.findViewById(R.id.logoutButton)
        sendMessageButton = view.findViewById(R.id.sendMessageButton)
        userNameTextView = view.findViewById(R.id.userNameTextView)
        messageEditText = view.findViewById(R.id.messageEditText)
        conversationEventsTextView = view.findViewById(R.id.conversationEventsTextView)

        sendMessageButton.setOnClickListener {
            val message = messageEditText.text.toString()

            if (message.isNotBlank()) {
                viewModel.onSendMessage(messageEditText.text.toString())
                messageEditText.setText("")
                hideKeyboard()
            } else {
                Toast.makeText(context, "Message is blank", Toast.LENGTH_SHORT).show()
            }
        }

        logoutButton.setOnClickListener {
            viewModel.onLogout()
            findNavController().popBackStack()
        }
    }

    private fun getConversationLine(textEvent: NexmoTextEvent): String {
        TODO("Convert event to line string")
    }

    private fun getConversationLine(memberEvent: NexmoMemberEvent): String {
        TODO("Convert event to line string")
    }

    override fun onBackPressed() {
        viewModel.onBackPressed()
    }

    private fun hideKeyboard() {
        val context = context ?: return

        val inputMethodManager = ContextCompat.getSystemService(context, InputMethodManager::class.java)
        var view = activity?.currentFocus
        if (view == null) {
            view = View(activity)
        }

        inputMethodManager?.hideSoftInputFromWindow(view.windowToken, 0)
    }
}
```