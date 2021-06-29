---
title: JavaScript
language: javascript
---

```javascript
const params = {
    order: "desc", // default "asc"
    page_size: 100 // default 10
}
conversation.getMembers(params).then((members_page) => {
    members_page.items.forEach(member => {
        console.log("Member: ", member);
    })
}).catch((error) => {
    console.error("error getting the members ", error);
});
```
