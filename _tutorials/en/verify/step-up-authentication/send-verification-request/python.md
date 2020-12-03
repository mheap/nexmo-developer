---
title: Send the verification request
description: Start the verification process with a call to the Verify request endpoint
---

# Send the verification request

Start the verification process by using the [Verify API request endpoint](/api/verify#verifyRequest) to generate a verification code and send it to the user.

Use the Python Server SDK for this. Instantiate the client and use it to get an instance of the `Verify` class, after the lines of code that read your environment variables from `.env`:

```python
client = Client(key=VONAGE_API_KEY, secret=VONAGE_API_SECRET)
verify = Verify(client)
```

Then, create the verification request within the `/verify` route handler:

```python
@app.route("/verify", methods=["POST"])
def verify_user():
    session["unverified_number"] = request.form.get("mobile_number")
    response = verify.start_verification(number=session["unverified_number"],
                                         brand=VONAGE_BRAND_NAME)
    session["request_id"] = response["request_id"]
    print("Request ID: %s" % response["request_id"])

    if response["status"] == "0":
        return render_template("entercode.html")
    else:
        return render_template("index.html", error=response["error_text"])
```

> By default, the first verification attempt is sent by SMS. If the user fails to respond within a specified time period then the API makes a second and, if necessary, third attempt to deliver the PIN code using a voice call. You can learn more about the available workflows and customization options [in our guide](/verify/guides/workflows-and-events).