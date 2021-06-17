---
title: Java
language: java
---

```java
NexmoCallEventListener callEventListener = new NexmoCallEventListener() {
    @Override
    public void onMemberStatusUpdated(NexmoCallMemberStatus $memberStatus, NexmoMember nexmoMember) {
        Log.d("TAG", "onMemberStatusUpdated(): status: " + $memberStatus + " nexmoMember: " + nexmoMember);
    }

    @Override
    public void onMuteChanged(NexmoMediaActionState muteState, NexmoMember nexmoMember) {
        Log.d("TAG", "NexmoMediaActionState(): muteState: " + muteState + ", nexmoMember: " + nexmoMember);
    }

    @Override
    public void onEarmuffChanged(NexmoMediaActionState earmuffState, NexmoMember nexmoMember) {
        Log.d("TAG", "onEarmuffChanged(): earmuffState: " + earmuffState + ", nexmoMember: " + nexmoMember);
    }

    @Override
    public void onDTMF(String digit, NexmoMember nexmoMember) {
        Log.d("TAG", "onDTMF(): digit:" + digit + ", nexmoMember: " + nexmoMember);
    }
};

nexmoCall.addCallEventListener(callEventListener);
```

Remove the listener when needed:

```java
nexmoCall.removeCallEventListener(callEventListener);
```
