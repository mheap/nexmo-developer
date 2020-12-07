---
title: Create your server
description: Start listening to incoming requests
---

# Create your server

Finally, write the code to instantiate the server:

```python
if __name__ == "__main__":
    from gevent import pywsgi
    from geventwebsocket.handler import WebSocketHandler

    server = pywsgi.WSGIServer(("", 3000), app, handler_class=WebSocketHandler)
    server.serve_forever()
```
