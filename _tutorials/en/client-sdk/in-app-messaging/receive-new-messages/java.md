---
title: Receive new messages
description: In this step you display any new messages
---

# Receive new messages

You can display incoming messages by implementing the conversation listener.

Now, locate the `getConversation` method and add `addMessageEventListener` call:

```java
private void getConversation() {
    client.getConversation(CONVERSATION_ID, new NexmoRequestListener<NexmoConversation>() {
        @Override
        public void onSuccess(@Nullable NexmoConversation conversation) {
            MainActivity.this.conversation = conversation;
            getConversationEvents(conversation);

            conversation.addMessageEventListener(new NexmoMessageEventListener() {
                @Override
                public void onMessageEvent(@NonNull NexmoMessageEvent messageEvent) {
                    conversationEvents.add(messageEvent);
                    updateConversationView();
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

                @Override
                public void onTypingEvent(@NonNull NexmoTypingEvent typingEvent) {}
            });
        }

        @Override
        public void onError(@NonNull NexmoApiError apiError) {
            MainActivity.this.conversation = null;
            Toast.makeText(MainActivity.this, "Error: Unable to load conversation", Toast.LENGTH_SHORT);
        }
    });
}
```

Each time a new message is received `public void onMessageEvent(@NonNull NexmoMessageEvent messageEvent)` listener is called, the new message will be added to the `conversationEvents` collection and `updateConversationView` method will be called to reflect the changes.

# Run the app

You can either launch the app on the physical phone (with [USB Debugging enabled](https://developer.android.com/studio/debug/dev-options#enable)) or create a new [Android Virtual Device](https://developer.android.com/studio/run/managing-avds). When device is present press `Run` button: 

![](/screenshots/tutorials/client-sdk/android-shared/launch-app.png)
