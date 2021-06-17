---
title: Java
language: java
---

```java
conversation.kick("memberName", new NexmoRequestListener<Void>() {
    @Override
    public void onSuccess(@Nullable Void aVoid) {
        Log.d("TTAG", "User kick success");
    }

    @Override
    public void onError(@NonNull NexmoApiError apiError) {
        Log.d("TTAG", "Error: Unable to kick user " + apiError.getMessage());
    }
);
```
