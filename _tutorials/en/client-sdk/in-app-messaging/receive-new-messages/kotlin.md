---
title: Receive new messages
description: In this step you display any new messages
---

# Receive new messages

You can display incoming messages by implementing the conversation listener.

Now, locate the `getConversation` method and add `addMessageEventListener` call:

```kotlin
private fun getConversation() {
    client.getConversation(CONVERSATION_ID, object : NexmoRequestListener<NexmoConversation?> {
        override fun onSuccess(conversation: NexmoConversation?) {
            this@MainActivity.conversation = conversation

            conversation?.let {
                getConversationEvents(it)
                it.addMessageEventListener(object : NexmoMessageEventListener {
                    override fun onTextEvent(textEvent: NexmoTextEvent) {
                        conversationEvents.add(textEvent)
                        updateConversationView()
                    }

                    override fun onAttachmentEvent(attachmentEvent: NexmoAttachmentEvent) {}
                    override fun onEventDeleted(deletedEvent: NexmoDeletedEvent) {}
                    override fun onSeenReceipt(seenEvent: NexmoSeenEvent) {}
                    override fun onDeliveredReceipt(deliveredEvent: NexmoDeliveredEvent) {}
                    override fun onTypingEvent(typingEvent: NexmoTypingEvent) {}
                })
            }
        }

        override fun onError(apiError: NexmoApiError) {
            conversation = null
            Toast.makeText(this@MainActivity, "Error: Unable to load conversation", Toast.LENGTH_SHORT)
        }
    })
}
```

Now each time a new message is received `onTextEvent(textEvent: NexmoTextEvent)` listener is called, the new message will be passed to `updateConversation` method and dispatched to the view via `conversationEvents` `LiveData` (same `LiveData` used to dispatch all the messages after loading conversation events).

# Run the app

You can either launch the app on the physical phone (with [USB Debugging enabled](https://developer.android.com/studio/debug/dev-options#enable)) or create a new [Android Virtual Device](https://developer.android.com/studio/run/managing-avds). When device is present press `Run` button: 

![](/screenshots/tutorials/client-sdk/android-shared/launch-app.png)
