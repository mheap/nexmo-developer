---
title: Javascript
language: javascript
menu_weight: 1
---

```javascript
conversation.on('text', (sender, event) => {
    // Can't set your own text status to seen
    if (conversation.me.id !== event.from) {
        event.seen().then(() => {
            console.log("text event status set to seen");
        }).catch((error)=>{
            console.error("error setting text event status to seen ", error);
        });
    };
});
```
