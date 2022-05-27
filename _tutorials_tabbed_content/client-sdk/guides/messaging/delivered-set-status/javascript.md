---
title: Javascript
language: javascript
menu_weight: 1
---

```javascript
conversation.on('message', (sender, event) => {
    // Can't set your own text status to seen
    if (conversation.me.id !== event.from) {
        event.delivered().then(() => {
            console.log("message event status set to delivered");
        }).catch((error)=>{
            console.error("error setting message event status to delivered ", error);
        });
    };
});
```
