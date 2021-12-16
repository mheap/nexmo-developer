---
title: Java
language: java
menu_weight: 3
---

```java
client.getUserSessions("USR-id", 20, NexmoPageOrder.NexmoMPageOrderAsc, new NexmoRequestListener<NexmoUserSessionsPage>() {
    @Override
    public void onSuccess(@Nullable NexmoUserSessionsPage result) {
        // handle page of sessions
    }

    @Override
    public void onError(@NonNull NexmoApiError error) {
        // handle error
    }
});
```

You can also call this function with a NexmoUser object:

```java
user.getSessions(20, NexmoPageOrder.NexmoMPageOrderAsc, new NexmoRequestListener<NexmoUserSessionsPage>() {
    @Override
    public void onSuccess(@Nullable NexmoUserSessionsPage result) {
        // handle page of sessions
    }

    @Override
    public void onError(@NonNull NexmoApiError error) {
        // handle error
    }
});
```