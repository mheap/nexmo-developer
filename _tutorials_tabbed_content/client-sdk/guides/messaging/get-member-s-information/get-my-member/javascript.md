---
title: JavaScript
language: javascript
---

```javascript
conversation.getMyMember().then((member) => {
    console.log("Member: ", member);
}).catch((error) => {
    console.error("error getting my member", error);
});
```
