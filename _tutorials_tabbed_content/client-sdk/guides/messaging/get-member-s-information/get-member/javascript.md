---
title: JavaScript
language: javascript
---

```javascript
conversation.getMember("MEM-id").then((member) => {
    console.log("Member: ", member);
}).catch((error) => {
    console.error("error getting member", error);
});
```
