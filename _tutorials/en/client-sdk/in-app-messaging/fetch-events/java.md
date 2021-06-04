---
title: Fetch conversation events
description: In this step you display any messages already sent as part of this Conversation
---

# Fetch conversation events

Inside `ChatViewModel` class, locate the `getConversationEvents()` method and paste its implementation:

```java
private void getConversationEvents(NexmoConversation conversation) {
    conversation.getEvents(100, NexmoPageOrder.NexmoMPageOrderAsc, null,
            new NexmoRequestListener<NexmoEventsPage>() {
                @Override
                public void onSuccess(@Nullable NexmoEventsPage nexmoEventsPage) {
                    _conversationEvents.postValue(new ArrayList<>(nexmoEventsPage.getPageResponse().getData()));
                }

                @Override
                public void onError(@NonNull NexmoApiError apiError) {
                    _errorMessage.postValue("Error: Unable to load conversation events " + apiError.getMessage());
                }
            });
}
```

Once the events are retrieved (or an error is returned), we're updating the view (`ChatFragment`) to reflect the new data.

> **NOTE:** We are using two `LiveData` streams. `conversationEvents` to post successful API response and `_errorMessage` to post returned error.

Let's make our view react to the new data. Inside `ChatFragment` locate the `conversationEvents` property and add this code to handle our conversation history:

```java
private Observer<ArrayList<NexmoEvent>> conversationEvents = events -> {

    ArrayList<String> lines = new ArrayList<>();

    for (NexmoEvent event : events) {
        if (event == null) {
            continue;
        }

        String line = "";

        if (event instanceof NexmoMemberEvent) {
            line = getConversationLine((NexmoMemberEvent) event);
        } else if (event instanceof NexmoTextEvent) {
            line = getConversationLine((NexmoTextEvent) event);
        }

        lines.add(line);
    }

    // Production application should utilise RecyclerView to provide better UX
    if (events.isEmpty()) {
        conversationEventsTextView.setText("Conversation has no events");
    } else {

        String conversationEvents = "";

        for (String line : lines) {
            conversationEvents += line + "\n";
        }

        conversationEventsTextView.setText(conversationEvents);
    }

    progressBar.setVisibility(View.GONE);
    chatContainer.setVisibility(View.VISIBLE

    );
};
```

To handle member related events (member invited, joined or left) you need to fill the body of the `fun getConversationLine(memberEvent: NexmoMemberEvent)` method:

```java
private String getConversationLine(NexmoMemberEvent memberEvent) {
    String user = memberEvent.getEmbeddedInfo().getUser().getName();

    switch (memberEvent.getState()) {
        case JOINED:
            return user + " joined";
        case INVITED:
            return user + " invited";
        case LEFT:
            return user + " left";
        case UNKNOWN:
            return "Error: Unknown member event state";
    }

    return "";
}
```

Above method converts `NexmoMemberEvent` to a `String` that will be displayed as a single line in the chat conversation. Similar conversion need to be done for `NexmoTextEvent`. Let's fill the body of the `getConversationLine(textEvent: NexmoTextEvent)` method:

```java
private String getConversationLine(NexmoTextEvent textEvent) {
    String user = textEvent.getEmbeddedInfo().getUser().getName();
    return user + "  said: " + textEvent.getText();
}
```

> **NOTE:** In this tutorial, we are only handling member-related events `NexmoMemberEvent` and `NexmoTextEvent`. Other kinds of events are being ignored in the above `when` expression (`else -> null`).
