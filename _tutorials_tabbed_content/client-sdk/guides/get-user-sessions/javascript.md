---
title: Javascript
language: javascript
menu_weight: 1
---

```javascript
application.getUserSessions({ user_id: "USR-id", page_size: 20 }).then((user_sessions_page) => {
  // handle page of sessions
}).catch((error) => {
  // handle error
});
```