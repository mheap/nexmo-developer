---
title: Write your event webhook
description: Listen for call lifecycle events
---

# Write your event webhook

Implement a webhook that captures call events so that you can observe the lifecycle of the call in the console.

```javascript
app.post('/webhooks/events', (req, res) => {
  console.log(req.body)
  res.send(200);
})
```

Vonage makes a `POST` request to this endpoint every time the call status changes.
