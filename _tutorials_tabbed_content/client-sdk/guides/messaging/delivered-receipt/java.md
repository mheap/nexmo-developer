---
title: Java
language: java
---

```java
private NexmoMessageEventListener messageListener = new NexmoMessageEventListener() {
    @Override
    public void onTextEvent(@NonNull NexmoTextEvent textEvent) {}

    @Override
    public void onAttachmentEvent(@NonNull NexmoAttachmentEvent attachmentEvent) {}

    @Override
    public void onEventDeleted(@NonNull NexmoDeletedEvent deletedEvent) {}

    @Override
    public void onSeenReceipt(@NonNull NexmoSeenEvent seenEvent) {}

    @Override
    public void onDeliveredReceipt(@NonNull NexmoDeliveredEvent deliveredEvent) {
        String userName = deliveredEvent.getEmbeddedInfo().getUser().getName();

        Log.d("TAG", "Event " + deliveredEvent.initialEventId() + "delivered to User " + userName);
    }

    @Override
    public void onTypingEvent(@NonNull NexmoTypingEvent typingEvent) {}
};

conversation.addMessageEventListener(messageListener);
```
