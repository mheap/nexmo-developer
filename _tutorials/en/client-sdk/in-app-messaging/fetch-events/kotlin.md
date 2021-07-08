---
title: Fetch conversation events
description: In this step you display any messages already sent as part of this Conversation
---

# Fetch conversation events

Add `getConversationEvents(conversation);` call inside `getConversationEvents()`:

```kotlin
private fun getConversation() {
    client.getConversation(CONVERSATION_ID, object : NexmoRequestListener<NexmoConversation?> {
        override fun onSuccess(conversation: NexmoConversation?) {
            this@MainActivity.conversation = conversation

            conversation?.let {
                getConversationEvents(it)
            }
        }

        override fun onError(apiError: NexmoApiError) {
            conversation = null
            Toast.makeText(this@MainActivity, "Error: Unable to load conversation", Toast.LENGTH_SHORT)
        }
    })
}
```

Add `getConversationEvents` method to retrieve conversation events:

```kotlin
private fun getConversationEvents(conversation: NexmoConversation) {
    conversation.getEvents(100, NexmoPageOrder.NexmoMPageOrderAsc, null,
        object : NexmoRequestListener<NexmoEventsPage?> {
            override fun onSuccess(nexmoEventsPage: NexmoEventsPage?) {
                nexmoEventsPage?.pageResponse?.data?.let { conversationEvents.addAll(it) }
                updateConversationView()

                runOnUiThread {
                    chatContainer.visibility = View.VISIBLE
                    loginContainer.visibility = View.GONE
                }
            }

            override fun onError(apiError: NexmoApiError) {
                Toast.makeText(this@MainActivity, "Error: Unable to load conversation events", Toast.LENGTH_SHORT)
            }
        })
}
```

Above method adds events to `conversationEvents` collection and updates the view. Now add the missing `updateConversationView` method:

```kotlin
 private fun updateConversationView() {
    val lines = ArrayList<String>()

    for (event in conversationEvents) {
        var line = ""

        when (event) {
            is NexmoMemberEvent -> {
                val userName = event.embeddedInfo.user.name

                line = when (event.state) {
                    NexmoMemberState.JOINED -> "$userName joined"
                    NexmoMemberState.INVITED -> "$userName invited"
                    NexmoMemberState.LEFT -> "$userName left"
                    NexmoMemberState.UNKNOWN -> "Error: Unknown member event state"
                }
            }
            is NexmoTextEvent -> {
                line = "${event.embeddedInfo.user.name} said: ${event.text}"
            }
        }
        lines.add(line)
    }

    // Production application should utilise RecyclerView to provide better UX
    conversationTextView.text = if (lines.isNullOrEmpty()) {
        "Conversation has No messages"
    } else {
        lines.joinToString(separator = "\n")
    }
}
```

> **NOTE:** In this tutorial, we are only handling member-related events `NexmoMemberEvent` and `NexmoTextEvent`. Other kinds of events are being ignored in the above `when` expression (`else -> null`).
