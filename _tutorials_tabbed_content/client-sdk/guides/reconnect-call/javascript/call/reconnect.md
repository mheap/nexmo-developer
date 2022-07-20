---
title: JavaScript
language: javascript
menu_weight: 1
---

```javascript
application.reconnectCall(
    "conversation_id",
    "rtc_id",
    { audioConstraints: { deviceId: "device_id" } }
).then((nxmCall) => {
    console.log(nxmCall);
}).catch((error) => {
    console.error("error reconnecting call", error);
});
```
