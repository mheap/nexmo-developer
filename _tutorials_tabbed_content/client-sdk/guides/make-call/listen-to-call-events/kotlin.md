---
title: Kotlin
language: kotlin
---

```kotlin
val callEventListener = object : NexmoCallEventListener {
    override fun onDTMF(digit: String?, nexmoMember: NexmoMember?) {
        Log.d("TAG", "onDTMF(): digit: $digit, nexmoMember: $nexmoMember")
    }

    override fun onMemberStatusUpdated(memberStatus: NexmoCallMemberStatus?, nexmoMember: NexmoMember?) {
        Log.d("TAG", "onMemberStatusUpdated(): status: $memberStatus, nexmoMember: $nexmoMember")
    }

    override fun onMuteChanged(muteState: NexmoMediaActionState?, nexmoMember: NexmoMember?) {
        Log.d("TAG", ":NexmoMediaActionState(): muteState: $muteState, nexmoMember: $nexmoMember")
    }

    override fun onEarmuffChanged(earmuffState: NexmoMediaActionState?, nexmoMember: NexmoMember?) {
        Log.d("TAG", "onEarmuffChanged(): earmuffState: $earmuffState, nexmoMember: $nexmoMember")
    }
}

nexmoCall?.addCallEventListener(callEventListener)
```

Remove the listener when needed:

```kotlin
nexmoCall?.removeCallEventListener(callEventListener)
```
