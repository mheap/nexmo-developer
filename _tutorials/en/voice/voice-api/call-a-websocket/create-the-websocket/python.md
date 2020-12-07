---
title: Create the WebSocket
description: Handle WebSocket connections
---

# Create the WebSocket

Create a route handler for the `/socket` route. This listens for a `message` event which is raised every time the WebSocket receives audio from the call. Your application should respond by echoing the audio back to the caller with the `send()` method:

```python
@sockets.route("/socket", methods=["GET"])
def echo_socket(ws):
    while not ws.closed:
        message = ws.receive()
        ws.send(message)
```
