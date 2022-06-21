---
title: Java
language: java
menu_weight: 1
---

```java
public void onMessageEvent(@NonNull NexmoMessageEvent messageEvent) {
    messageEvent.markAsSeen(new NexmoRequestListener() {
        @Override
        public void onError(@NonNull NexmoApiError error) { ... }

        @Override
        public void onSuccess(@Nullable Object result) { ... }
    });
}
```
