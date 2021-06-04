---
title: Java
language: java
---

```java
 private NexmoRequestListener<Void> earmuffListener = new NexmoRequestListener<Void>() {
    @Override
    public void onError(NexmoApiError apiError) {
        Timber.d("Error: Earmuff member " + apiError.getMessage());
    }

    @Override
    public void onSuccess(@Nullable Void result) {
        Timber.d("Member earmuff ");
    }
};

NexmoMember nexmoMember = call.getAllMembers().get(0);
nexmoMember.enableEarmuff(earmuffListener);
```
