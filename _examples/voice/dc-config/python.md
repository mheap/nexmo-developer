---
title: Python
language: python
---

```python
from vonage import Client

client = Client(key='YOUR_API_KEY', secret='YOUR_API_SECRET')
client.host('rest-sg-1.nexmo.com')
client.api_host('api-sg-1.nexmo.com')
```