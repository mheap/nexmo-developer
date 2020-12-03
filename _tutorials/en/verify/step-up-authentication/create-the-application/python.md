---
title: Create the Node.js application
description: In this step you create the basic Node.js application
---

# Create the Python application

Enter the following commands at a terminal prompt:

```sh
mkdir stepup-auth
cd stepup-auth
touch server.py
mkdir -p static/styles
mkdir templates
```

This gives your project the following directory structure:

```
└── python-stepup-auth
    ├── server.py
    ├── static
    │   └── styles
    └── templates
```

The application you will create uses the [Flask](https://flask.palletsprojects.com/) framework for the routing and the built-in [`jinja` template engine](https://jinja.palletsprojects.com/) for creating the UI.

In addition to `flask`, you will be using the following external modules:

* `python-dotenv` - to store your Vonage API key and secret and the name of your application in a `.env` file
* `vonage` - the [Python Server SDK](https://github.com/Vonage/vonage-python-sdk)

Install these dependencies by running the following `pip` command at a terminal prompt:

```
pip install flask python-dotenv vonage
```

> **Note**: This tutorial assumes that you have [Python 3](https://www.python.org/download/releases/3.0/) installed and are running in a Unix-like environment. The terminal commands for Windows environments might be different.

