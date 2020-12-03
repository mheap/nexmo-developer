---
title: Initialize your dependencies
description: Load the modules that your application will use
---

# Initialize your dependencies


In `server.py`, write the following code to initialize dependencies and define some variables which you will use to configure your application: 

```python
# server.py

from flask import Flask, render_template, session, request
import os
from os.path import join, dirname
from dotenv import load_dotenv
from vonage import Client, Verify

dotenv_path = join(dirname(__file__), "../.env")

app = Flask(__name__)
app.config["SECRET_KEY"] = "VonageVerify"

VONAGE_API_KEY = os.getenv("VONAGE_API_KEY")
VONAGE_API_SECRET = os.getenv("VONAGE_API_SECRET")
VONAGE_BRAND_NAME = os.getenv("VONAGE_BRAND_NAME")

# define your routes here

# run the server
if __name__ == "__main__":
    app.run(debug=True)
```
