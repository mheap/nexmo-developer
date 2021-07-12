---
title: Fetch the conversation
description: In this step you join your Users to your Conversation
---

# Fetch the Conversation

Inside `MainActivity` class add the `conversation` property:

```java
private NexmoConversation conversation;
```

Update body of the `getConversation()` method:

```java
private void getConversation() {
    client.getConversation(CONVERSATION_ID, new NexmoRequestListener<NexmoConversation>() {
        @Override
        public void onSuccess(@Nullable NexmoConversation conversation) {
            MainActivity.this.conversation = conversation;
        }

        @Override
        public void onError(@NonNull NexmoApiError apiError) {
            MainActivity.this.conversation = null;
            Toast.makeText(MainActivity.this, "Error: Unable to load conversation", Toast.LENGTH_SHORT);
        }
    });
}
```

Please make sure to replace `CONVERSATION_ID` with the conversation id you created during a previous step.

The above method loads the conversation and stores it in the `conversation` property.

> **Note:** Conversation id is retrieved from `Config.CONVERSATION_ID` provided in the previous step.

