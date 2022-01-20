---
title: Fetch conversation events
description: In this step you display any messages already sent as part of this Conversation
---

# Fetch conversation events

Add `getConversationEvents(conversation);` call inside `onSucess` callback inside `getConversationEvents()` method:

```java
private void getConversation() {
    client.getConversation(CONVERSATION_ID, new NexmoRequestListener<NexmoConversation>() {
        @Override
        public void onSuccess(@Nullable NexmoConversation conversation) {
            MainActivity.this.conversation = conversation;
            getConversationEvents(conversation);
        }

        @Override
        public void onError(@NonNull NexmoApiError apiError) {
            MainActivity.this.conversation = null;
            Toast.makeText(MainActivity.this, "Error: Unable to load conversation", Toast.LENGTH_SHORT);
        }
    });
}
```

Add `conversationEvents` method to store conversation events:

```java
private ArrayList<NexmoEvent> conversationEvents = new ArrayList<>();
```

Add `getConversationEvents` method to retrieve conversation events:

```java
private void getConversationEvents(NexmoConversation conversation) {
    conversation.getEvents(100, NexmoPageOrder.NexmoMPageOrderAsc, null,
            new NexmoRequestListener<NexmoEventsPage>() {
                @Override
                public void onSuccess(@Nullable NexmoEventsPage nexmoEventsPage) {
                    conversationEvents.addAll(nexmoEventsPage.getPageResponse().getData());
                    updateConversationView();

                    runOnUiThread(() -> {
                        chatContainer.setVisibility(View.VISIBLE);
                        loginContainer.setVisibility(View.GONE);
                    });
                }

                @Override
                public void onError(@NonNull NexmoApiError apiError) {
                    Toast.makeText(MainActivity.this, "Error: Unable to load conversation events", Toast.LENGTH_SHORT);
                }
            });
}
```

Above method adds events to `conversationEvents` collection and updates the view. Now add the missing `updateConversationView` method:

```java
private void updateConversationView() {
    ArrayList<String> lines = new ArrayList<>();

    for (NexmoEvent event : conversationEvents) {
        if (event == null) {
            continue;
        }

        String line = "";

        if (event instanceof NexmoMemberEvent) {
            NexmoMemberEvent memberEvent = (NexmoMemberEvent) event;
            String userName = "";
            if (memberEvent.getEmbeddedInfo() != null ) {
                userName = memberEvent.getEmbeddedInfo().getUser().getName();
            }

            switch (memberEvent.getState()) {
                case JOINED:
                    line = userName + " joined";
                    break;
                case INVITED:
                    line = userName + " invited";
                    break;
                case LEFT:
                    line = userName + " left";
                    break;
                case UNKNOWN:
                    line = "Error: Unknown member event state";
                    break;
            }
        } else if (event instanceof NexmoMessageEvent) {
            NexmoMessageEvent messageEvent = (NexmoMessageEvent) event;
            String userName = messageEvent.getEmbeddedInfo().getUser().getName();
            line = userName + "  said: " + messageEvent.getMessage().getText();
        }

        lines.add(line);
    }

    // Production application should utilise RecyclerView to provide better UX
    if (lines.isEmpty()) {
        conversationTextView.setText("Conversation has no events");
    } else {

        String conversation = "";

        for (String line : lines) {
            conversation += line + "\n";
        }

        conversationTextView.setText(conversation);
    }
}
```

Events are stored in the `conversationEvents` property. You should remove these events after the logout. Update the body of the `setConnectionListener` and call `conversationEvents.clear`:

```java
client.setConnectionListener((connectionStatus, connectionStatusReason) -> {
    if (connectionStatus == NexmoConnectionListener.ConnectionStatus.CONNECTED) {
        // ...
    } else if (connectionStatus == NexmoConnectionListener.ConnectionStatus.DISCONNECTED) {
        // ...

        conversationEvents.clear();
    }
});
```

> **NOTE:** In this tutorial, we are only handling member-related events `NexmoMemberEvent` and `NexmoMessageEvent`. Other kinds of events are being ignored in the above `when` expression (`else -> null`).
