---
title: Run the Flask Server
description: Configure and run the web application on a Flask server
---

# Run the Flask Server

Before you can start your server, you’ll need to provide configuration in a `.env` file. Start with the following and fill in your details:

```
# Do not use this in production:
FLASK_DEBUG=true
 
# Replace the following with any random value you like:
FLASK_SECRET_KEY=RANDOM-STRING_CHANGE-THIS-Ea359
 
# Get from https://dashboard.nexmo.com/your-numbers
NEXMO_NUMBER=447700900025
 
# Get the following from https://dashboard.nexmo.com/settings
NEXMO_API_KEY=abcd1234
NEXMO_API_SECRET=abcdef12345678
```

Now start your app with:

```
# You may need to change the path below if your Flask app is in a different Python file:
$ FLASK_APP=smsweb/server.py flask run
* Serving Flask app "smsweb.server"
* Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
```

Now if you load http://localhost:5000/, you should see something like this:

![SMS Flask application window, showing fields for phone number and message](https://www.nexmo.com/wp-content/uploads/2017/06/smsweb_send.png)