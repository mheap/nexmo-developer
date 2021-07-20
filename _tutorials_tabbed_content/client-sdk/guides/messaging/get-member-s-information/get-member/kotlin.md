---
title: Kotlin
language: kotlin
---

```kotlin
conversation.getMember("MEMBER_ID", object : NexmoRequestListener<NexmoMember?> {
    override fun onError(error: NexmoApiError) {}
    
    override fun onSuccess(member: NexmoMember?) {
        Log.d("Member", member!!.user.displayName)
    }
})
```
