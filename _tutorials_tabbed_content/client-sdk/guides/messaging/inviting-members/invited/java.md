---
title: Java
language: java
---

```java
NexmoMemberEventListener memberEventListener = new NexmoMemberEventListener() {
    @Override
    public void onMemberInvited(@NonNull @NotNull NexmoMemberEvent event, @NonNull @NotNull NexmoMemberSummary member) {
        Log.d("TAG", "Member " + event.embeddedInfo().getUser().getName() + " invited to the conversation");

        // Join user to the conversation (accept the invitation)
        conversation.join(event.embeddedInfo().getUser().getName(), joinConversationListener);
    }

    @Override
    public void onMemberAdded(@NonNull @NotNull NexmoMemberEvent event, @NonNull @NotNull NexmoMemberSummary member) {}

    @Override
    public void onMemberRemoved(@NonNull @NotNull NexmoMemberEvent event, @NonNull @NotNull NexmoMemberSummary member) {}
};

NexmoRequestListener<String> joinConversationListener = new NexmoRequestListener<String>() {
    @Override
    public void onSuccess(@Nullable String memberId) {
        Log.d("TAG", "Member joined the conversation " + memberId);
    }

    @Override
    public void onError(@NonNull NexmoApiError apiError) {
        Log.d("TAG", "Error: Unable to join member to the conversation " + apiError);
    }
};

conversation.addMemberEventListener(memberEventListener);
```
