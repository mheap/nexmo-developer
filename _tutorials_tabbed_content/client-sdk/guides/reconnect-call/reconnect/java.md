---
title: Java
language: java
menu_weight: 2
---

Call:

```java
NexmoRequestListener<NexmoCall> listener = new NexmoRequestListener<NexmoCall>() {
    @Override
    public void onSuccess(@Nullable NexmoCall result) {
        // handle call
    }

    @Override
    public void onError(@NonNull NexmoApiError error) {
        // handle error
    }
};

client.reconnectCall("conversationId", "legId", listener);
```

Conversation media:

```java
conversation.reconnectMedia();
```