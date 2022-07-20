---
title: JavaScript
language: javascript
menu_weight: 1
---

```javascript
conversation.media.enable({ 
    reconnectRtcId: "UUID",
    audioConstraints: { deviceId: "device_id" }
}).then((stream) => {
    console.log(stream)
}).catch((error) => {
    console.error("error renabling media", error);
});
```
