---
title: Kotlin
language: kotlin
---

```kotlin
conversation.getMembers(100, NexmoPageOrder.NexmoMPageOrderAsc, object : NexmoRequestListener<NexmoMembersSummaryPage> {
    override fun onError(error: NexmoApiError) {}

    override fun onSuccess(membersSummaryPage: NexmoMembersSummaryPage?) {
        val members = membersSummaryPage?.pageResponse?.data?.joinToString(separator = " ")
        Log.d("Members", members)
    }
})
```
