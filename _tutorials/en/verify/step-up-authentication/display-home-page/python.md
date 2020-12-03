---
title: Display the home page
description: Show the home page and the user's authentication status
---

# Display the home page

In the `/` route, you want to check if a session already exists. If not, you prompt the user to verify their account details using their mobile number before they are allowed to continue.

After being authenticated, a session will be created and you can use this to retrieve and display the user's mobile number.

Enter the following code in the `/` route handler:

```python
@app.route("/")
def index():
    registered_number = None
    if "verified_number" in session:
        registered_number = session["verified_number"]
    return render_template("index.html",
                           number=registered_number,
                           brand=VONAGE_BRAND_NAME)
```

Run the following command:

```sh
python server.py
```

Visit `http://localhost:5000` in your browser and make sure that the page appears correctly:

![The home page](/images/tutorials/verify-stepup-auth-home-page.png)

Also ensure that when you click the "Verify me" button, you are redirected to a page where you can enter your mobile number:

![The enter code page](/images/tutorials/verify-stepup-auth-enter-number-page.png)

Although you can enter your number here, you still won't receive a verification code. You'll implement that functionality in the next step!




