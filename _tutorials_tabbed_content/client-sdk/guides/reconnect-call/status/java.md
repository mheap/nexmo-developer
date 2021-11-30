---
title: Java
language: java
menu_weight: 2
---

To get `MediaConnectionState` updates, you need to add a `NexmoMediaStatusListener`. You can do this by setting it on a call's conversation object.

```java
NexmoMediaStatusListener listener = new NexmoMediaStatusListener() {
    @Override
    public void onMediaConnectionStateChange(@NonNull String legId, @NonNull EMediaConnectionState status) {
        // Update UI and/or reconnect
    }
};

call.getConversation().addMediaStatusListener(listener);
```
