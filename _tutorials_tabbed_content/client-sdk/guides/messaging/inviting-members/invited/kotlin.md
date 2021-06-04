---
title: Kotlin
language: kotlin
---

```kotlin
private val memberEventListener = object : NexmoMemberEventListener {
    override fun onMemberInvited(event: NexmoMemberEvent, member: NexmoMemberSummary) {    
        Log.d("TAG", "Member ${event.embeddedInfo.user.name} invited to the conversation");

        // Join user to the conversation (accept the invitation)
        conversation?.join(event.embeddedInfo.user.name, joinConversationListener)
    }

    override fun onMemberAdded(event: NexmoMemberEvent, member: NexmoMemberSummary) {}
    
    override fun onMemberRemoved(event: NexmoMemberEvent, member: NexmoMemberSummary) {}
}

private val joinConversationListener = object: NexmoRequestListener<String>{
    override fun onSuccess(memberId: String?) {
        Log.d("TAG", "Member joined the conversation $memberId")
    }

    override fun onError(apiError: NexmoApiError) {
        Log.d("TAG", "Error: Unable to join member to the conversation $apiError")
    }
}

conversation?.addMemberEventListener(memberEventListener)
```
