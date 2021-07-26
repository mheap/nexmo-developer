---
title: Java
language: java
---

```java
conversation.getMembers(100, NexmoPageOrder.NexmoMPageOrderAsc, new NexmoRequestListener<NexmoMembersSummaryPage>() {
    @Override
    public void onError(@NonNull @NotNull NexmoApiError error) {}

    @Override
    public void onSuccess(@Nullable @org.jetbrains.annotations.Nullable NexmoMembersSummaryPage membersSummaryPage) {
        Collection<NexmoMemberSummary> members = membersSummaryPage.getPageResponse().getData();
    }
});
```
