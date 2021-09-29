---
title: Java
language: java
menu_weight: 5
---

```java
NexmoRequestListener<NexmoCall> callListener = new NexmoRequestListener<NexmoCall>() {
    @Override
    public void onSuccess(@Nullable NexmoCall nexmoCall) {
        Log.d("TAG", "Call started: " + nexmoCall.toString());
    }

    @Override
    public void onError(@NonNull NexmoApiError apiError) {
        Log.d("TAG", "Error: Unable to start a call " + apiError.getMessage());
    }
};

HashMap<String, Object> customData = new HashMap<String, Object>();
customData.put("device_name", "Alice app");

client.serverCall("123456", customData, callListener)
```
