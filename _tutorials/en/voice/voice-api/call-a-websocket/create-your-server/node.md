---
title: Create your server
description: Start listening to incoming requests
---

# Create your Node.js server

Finally, write the code to instantiate your Node server:

```javascript
const port = 3000
app.listen(port, () => console.log(`Listening on port ${port}`))
```