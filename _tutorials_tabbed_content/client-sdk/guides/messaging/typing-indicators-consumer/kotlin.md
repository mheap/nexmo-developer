---
title: Kotlin
language: kotlin
---

```kotlin
// Option 1: Listen for typing events using NexmoTypingEventListener
conversation.addTypingEventListener(typingEventListener)

// or

// Option 2: Listen for typing events using NexmoMessageEventListener
conversation.addMessageEventListener(messageListener)

private val typingEventListener = NexmoTypingEventListener { typingEvent ->
    val typingState = if(typingEvent?.state == NexmoTypingState.ON) "typing" else "not typing"
    Timber.d("User ${typingEvent.fromMemberId} is $typingState")
}

private val messageListener = object : NexmoMessageEventListener {
    override fun onTypingEvent(typingEvent: NexmoTypingEvent) {
        val typingState = if(typingEvent.state == NexmoTypingState.ON) "typing" else "not typing"
        Log.d("TAG", "User ${typingEvent.fromMemberId} is $typingState")
    }

    override fun onAttachmentEvent(attachmentEvent: NexmoAttachmentEvent) {}

    override fun onTextEvent(textEvent: NexmoTextEvent) {}

    override fun onSeenReceipt(seenEvent: NexmoSeenEvent) {}

    override fun onEventDeleted(deletedEvent: NexmoDeletedEvent) {}

    override fun onDeliveredReceipt(deliveredEvent: NexmoDeliveredEvent) {}
}
```
