---
title: Java
language: java
---

```java
private NexmoRequestListener<Void> muteListener = new NexmoRequestListener<Void>() {
    @Override
    public void onError(NexmoApiError apiError) {
        Timber.d("Error: Unmute member " + apiError.getMessage());
    }

    @Override
    public void onSuccess(@Nullable @org.jetbrains.annotations.Nullable Void result) {
        Timber.d("Member unmuted");
    }
};

NexmoMember nexmoMember = call.getMyMember();
nexmoMember.disableMute(muteListener);
```
