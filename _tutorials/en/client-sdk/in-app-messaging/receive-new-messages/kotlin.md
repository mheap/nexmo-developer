---
title: Receive new messages
description: In this step you display any new messages
---

# Receive new messages

You can display incoming messages by implementing the conversation listener.


Now, locate the `private val messageListener = object : NexmoMessageEventListener` property in the `ChatViewModel` class and implement conversation listener `onTextEvent` method:

```kotlin
private val messageListener = object : NexmoMessageEventListener {
    override fun onTypingEvent(typingEvent: NexmoTypingEvent) {}

    override fun onAttachmentEvent(attachmentEvent: NexmoAttachmentEvent) {}

    override fun onTextEvent(textEvent: NexmoTextEvent) {
        updateConversation(textEvent)
    }

    override fun onSeenReceipt(seenEvent: NexmoSeenEvent) {}

    override fun onEventDeleted(deletedEvent: NexmoDeletedEvent) {}

    override fun onDeliveredReceipt(deliveredEvent: NexmoDeliveredEvent) {}
}
```

Now each time a new message is received `onTextEvent(textEvent: NexmoTextEvent)` listener is called, the new message will be passed to `updateConversation` method and dispatched to the view via `conversationEvents` `LiveData` (same `LiveData` used to dispatch all the messages after loading conversation events).

The last thing to do is to make sure that all listeners are removed when `ChatViewModel` is destroyed, for example, when the user navigates back. Fill the body of the `onCleared()` method in the `ChatViewModel` class.

```kotlin
override fun onCleared() {
    conversation?.removeMessageEventListener(messageListener)
}
```

# Run the app

You can either launch the app on the physical phone (with [USB Debugging enabled](https://developer.android.com/studio/debug/dev-options#enable)) or create a new [Android Virtual Device](https://developer.android.com/studio/run/managing-avds). When device is present press `Run` button: 

```screenshot
image: public/screenshots/tutorials/client-sdk/android-shared/launch-app.png
```