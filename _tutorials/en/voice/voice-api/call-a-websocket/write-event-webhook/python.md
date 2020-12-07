---
title: Write your event webhook
description: Listen for call lifecycle events
---

# Write your event webhook

Implement a webhook that captures call events so that you can observe the lifecycle of the call in the console.

We won't use the request data in this tutorial, so just return an `HTTP 200` response (`success`):

```python
@app.route("/webhooks/event", methods=["POST"])
def events():
    return "200"
```

Vonage makes a `POST` request to this endpoint every time the call status changes.
