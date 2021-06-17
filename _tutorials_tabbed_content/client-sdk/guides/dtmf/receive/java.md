---
title: Java
language: java
---

```java
NexmoRequestListener<NexmoCall> callListener = new NexmoRequestListener<NexmoCall>() {
    @Override
    public void onSuccess(@Nullable NexmoCall nexmoCall) {
        Log.d("TAG", "Call started: " + nexmoCall.toString());

        nexmoCall.addCallEventListener(callEventListener);
    }

    @Override
    public void onError(@NonNull NexmoApiError apiError) {
        Log.d("TAG", "Error: Unable to start a call " + apiError.getMessage());
    }
};

NexmoCallEventListener callEventListener = new NexmoCallEventListener() {

    @Override
    public void onMemberStatusUpdated(NexmoCallMemberStatus $memberStatus, NexmoMember nexmoMember) {}

    @Override
    public void onMuteChanged(NexmoMediaActionState muteState, NexmoMember nexmoMember) {}

    @Override
    public void onEarmuffChanged(NexmoMediaActionState earmuffState, NexmoMember nexmoMember) {}

    @Override
    public void onDTMF(String digit, NexmoMember nexmoMember) {
        Log.d("TAG", "onDTMF(): digit:" + digit + ", nexmoMember: " + nexmoMember);
    }
};

nexmoClient.call("123456", NexmoCallHandler.SERVER, callListener);
```
