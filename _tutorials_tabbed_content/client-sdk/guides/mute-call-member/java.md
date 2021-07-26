---
title: Java
language: java
---

```java
private NexmoRequestListener<Void> muteListener = new NexmoRequestListener<Void>() {
    @Override
    public void onError(NexmoApiError apiError) {
        Timber.d("Error: Mute member " + apiError.getMessage());
    }

    @Override
    public void onSuccess(@Nullable @org.jetbrains.annotations.Nullable Void result) {
        Timber.d("Member muted");
    }
};

NexmoMember nexmoMember = call.getMyMember();
nexmoMember.enableMute(muteListener);
```
