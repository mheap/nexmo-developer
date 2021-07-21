---
title: Java
language: java
---

```java
conversation.getMember("MEMBER_ID", new NexmoRequestListener<NexmoMember>() {
    @Override
    public void onError(@NonNull @NotNull NexmoApiError error) {}

    @Override
    public void onSuccess(@Nullable @org.jetbrains.annotations.Nullable NexmoMember member) {
        Log.d("Member", member.getUser().getDisplayName());
    }
});
```
