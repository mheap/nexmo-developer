---
title: Java
language: java
---

```java
// Option 1: Listen for typing events using NexmoTypingEventListener
conversation.addTypingEventListener(typingEventListener);

// or

// Option 2: Listen for typing events using NexmoMessageEventListener
conversation.addMessageEventListener(messageListener);

private NexmoTypingEventListener typingEventListener = new NexmoTypingEventListener() {
    @Override
    public void onTyping(NexmoTypingEvent typingEvent) {
        String typingState;

        if (typingEvent.getState() == NexmoTypingState.ON) {
            typingState = "typing";
        } else {
            typingState = "not typing";
        }

        Timber.d("User " + typingEvent.getFromMemberId() + " is " + typingState);
    }
};

private NexmoMessageEventListener messageListener = new NexmoMessageEventListener() {
    @Override
    public void onTypingEvent(@NonNull NexmoTypingEvent typingEvent) {
        String typingState;

        if (typingEvent.getState() == NexmoTypingState.ON) {
            typingState = "typing";
        } else {
            typingState = "not typing";
        }

        Log.d("TAG", "User " + typingEvent.getFromMemberId() + " is " + typingState);
    }

    @Override
    public void onTextEvent(@NonNull NexmoTextEvent textEvent) {}

    @Override
    public void onAttachmentEvent(@NonNull NexmoAttachmentEvent attachmentEvent) {}

    @Override
    public void onEventDeleted(@NonNull NexmoDeletedEvent deletedEvent) {}

    @Override
    public void onSeenReceipt(@NonNull NexmoSeenEvent seenEvent) {}

    @Override
    public void onDeliveredReceipt(@NonNull NexmoDeliveredEvent deliveredEvent) {}
};
```
