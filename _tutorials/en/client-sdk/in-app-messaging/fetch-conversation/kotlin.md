---
title: Fetch the conversation
description: In this step you join your Users to your Conversation
---

# Fetch the Conversation

Inside `MainActivity` class add the `conversation` property:

```java
private NexmoConversation conversation;
```

Now add the `getConversation()` method:

```kotlin
private fun getConversation() {
    client.getConversation(CONVERSATION_ID, object : NexmoRequestListener<NexmoConversation?> {
        override fun onSuccess(conversation: NexmoConversation?) {
            this@MainActivity.conversation = conversation
        }

        override fun onError(apiError: NexmoApiError) {
            conversation = null
            Toast.makeText(this@MainActivity, "Error: Unable to load conversation", Toast.LENGTH_SHORT)
        }
    })
}
```

Please make sure to replace `CONVERSATION_ID` with the conversation id you created during a previous step.

The above method loads the conversation using `client.getConversation` and then it loads all events from the conversation.

> **Note:** Conversation id is retrieved from `Config.CONVERSATION_ID` provided in the previous step.

