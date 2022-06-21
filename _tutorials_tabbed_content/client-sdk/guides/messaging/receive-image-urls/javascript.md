---
title: Javascript
language: javascript
menu_weight: 1
---

```javascript
conversation.on('message', (sender, event) => {
  if (event.body.message_type === 'image'){
    console.log('*** Image sender: ', sender);
    console.log('*** Image event: ', event);
  }
});
```
