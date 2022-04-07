---
title: Kotlin
language: kotlin
---

```kotlin
private val messageListener = object : NexmoMessageEventListener {
    override fun onTypingEvent(typingEvent: NexmoTypingEvent) {}
	
	override fun onMessageEvent(messageEvent: NexmoMessageEvent) {
    	val userName = messageEvent.embeddedInfo.user.name
		val imageURL = messageEvent.message.imageUrl
		Log.d("TAG", "Message received. User $userName : $imageURL")
	}

    override fun onAttachmentEvent(attachmentEvent: NexmoAttachmentEvent) {}

    override fun onTextEvent(textEvent: NexmoTextEvent) {}
	
    override fun onSeenReceipt(seenEvent: NexmoSeenEvent) {}

    override fun onEventDeleted(deletedEvent: NexmoDeletedEvent) {}

    override fun onDeliveredReceipt(deliveredEvent: NexmoDeliveredEvent) {}
}

conversation?.addMessageEventListener(messageListener)
```
