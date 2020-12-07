---
title: Create the project
description: Create the project and install your dependencies
---

# Create the project

Make a directory for your application, `cd` into the directory and then create a file called `server.py` to contain your application code.

Then, install the [Flask](http://flask.pocoo.org/), [Flask-Sockets](https://www.npmjs.com/package/express-ws) and [gevent](https://pypi.org/project/gevent/) (a networking library that `Flask-Sockets` depends on) modules:

```sh
$ pip3 install Flask gevent Flask-Sockets
```
