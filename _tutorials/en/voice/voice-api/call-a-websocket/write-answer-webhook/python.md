---
title: Write your answer webhook
description: Be alerted when you have incoming calls
---

# Write your answer webhook

When Vonage receives an inbound call on your virtual number, it will make a request to your `/webhooks/answer` route. This route should accept an HTTP `GET` request and return a [Nexmo Call Control Object (NCCO)](/voice/voice-api/ncco-reference) that tells Vonage how to handle the call.

Your NCCO should use the `text` action to greet the caller, and the `connect` action to connect the call to your webhook endpoint:

```python
#!/usr/bin/env python3
from flask import Flask, request, jsonify
from flask_sockets import Sockets

app = Flask(__name__)
sockets = Sockets(app)


@app.route("/ncco")
def answer_call():
    ncco = [
        {
            "action": "talk",
            "text": "Please wait while we connect you to the echo server",
        },
        {
            "action": "connect",
            "from": "VonageTest",
            "endpoint": [
                {
                    "type": "websocket",
                    "uri": "wss://{0}/socket".format(request.host),
                    "content-type": "audio/l16;rate=16000",
                }
            ],
        },
    ]

    return jsonify(ncco)
```

The `type` of `endpoint` is `websocket`, the `uri` is the `/socket` route where your WebSocket server will be accessible and the `content-type` specifies the audio quality.