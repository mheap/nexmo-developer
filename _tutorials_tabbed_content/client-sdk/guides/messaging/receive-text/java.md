---
title: Java
language: java
---

```java
NexmoMessageEventListener messageListener = new NexmoMessageEventListener() {

	@Override
    public void onMessageEvent(@NonNull NexmoMessageEvent messageEvent) {
		String userName = messageEvent.getEmbeddedInfo().getUser().getName();
		String text = messageEvent.getMessage().getText();

		Log.d("TAG", "Message received. User " + userName + " : " + text);
    }

    @Override
    public void onAttachmentEvent(@NonNull NexmoAttachmentEvent attachmentEvent) {}

    @Override
    public void onEventDeleted(@NonNull NexmoDeletedEvent deletedEvent) {}

    @Override
    public void onSeenReceipt(@NonNull NexmoSeenEvent seenEvent) {}

    @Override
    public void onDeliveredReceipt(@NonNull NexmoDeliveredEvent deliveredEvent) {}

    @Override
    public void onTypingEvent(@NonNull NexmoTypingEvent typingEvent) {}
};

conversation.addMessageEventListener(messageListener);
```
