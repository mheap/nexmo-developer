---
title: JavaScript
language: javascript
---

```javascript
conversation.getMembers().then((members_page) => {
    members_page.items.forEach(member => {
        console.log("Member: ", member);
    })
}).catch((error) => {
    console.error("error getting the members ", error);
});
```
