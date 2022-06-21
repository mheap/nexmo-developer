---
title: Javascript
language: javascript
menu_weight: 1
---

```javascript
conversation.on('message', (sender, event) => {
    // Can't set your own message status to seen
    if (conversation.me.id !== event.from) {
        event.seen().then(() => {
            console.log("message event status set to seen");
        }).catch((error)=>{
            console.error("error setting message event status to seen ", error);
        });
    };
});
```
