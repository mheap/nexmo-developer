---
title: Define the routes
description: Configure your application's endpoints
---

# Define the routes

You will use the following routes in your application:

* `/` - the home page, where you will determine if a user is authenticated and prompt them to authenticate if not
* `/authenticate` - to display a page where the user can enter their phone number
* `/verify` - when the user has entered their phone number, redirect here to start the verification process and display a page where they can enter the code that they receive
* `/check-code` - when the user has entered the verification code, this endpoint will use the Verify API to check if the code that they entered is the one that they were sent
* `/logout` - to remove any session details and send the user back to the home page

Create these routes in `server.py`, immediately before the code that initializes and runs the server:

```javascript
@app.route("/")
def index():
    return "/"

@app.route("/authenticate")
def authenticate():
    return render_template("authenticate.html")

@app.route("/verify", methods=["POST"])
def verify_user():
    return "/verify"

@app.route("/check-code", methods=["POST"])
def check_code():
    return "/check-code"

@app.route("/logout")
def cancel():
    return render_template("index.html", brand=VONAGE_BRAND_NAME)
```