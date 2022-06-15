---
title: Javascript
language: javascript
menu_weight: 1
---

```javascript
conversation.sendMessage({
    "message_type": "text",
    "text": "Hi Vonage!"
}).then((event) => {
    console.log("message was sent", event);
}).catch((error)=>{
    console.error("error sending the message ", error);
});
```
