---
title: JavaScript
language: javascript
menu_weight: 1
---

```javascript
new NexmoClient()
    .login(USER_JWT)
    .then(application => {
        ...
        application.callServer(phoneNumber, "phone", {"device_name": "Alice app"});
    })
```