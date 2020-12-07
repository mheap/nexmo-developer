---
title: Create the WebSocket
description: Handle WebSocket connections
---

# Create the WebSocket

First, handle the `connection` event so that you can report when your webhook server is online and ready to receive the call audio:

```javascript
expressWs.getWss().on('connection', function (ws) {
  console.log('Websocket connection is open');
});
```

Then, create a route handler for the `/socket` route. This listens for a `message` event which is raised every time the WebSocket receives audio from the call. Your application should respond by echoing the audio back to the caller with the `send()` method:

```javascript
app.ws('/socket', (ws, req) => {
  ws.on('message', (msg) => {
    ws.send(msg)
  })
})
```
