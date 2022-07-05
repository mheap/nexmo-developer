---
title: Create the code to make an in-app voice call
description: In this step you learn how to write the code to make an in-app voice call to another app.
---

# Create the code to make an in-app voice call

For this tutorial, `Alice` will be calling `Bob`.

Create an HTML file called `client_alice.html` in your project directory and add the following code, making sure to paste Alice's JWT you generated in the [earlier step](/client-sdk/tutorials/app-to-app/client-sdk/generate-jwts) to the `aliceJWT` constant:

``` html
<!DOCTYPE html>
<html lang="en">
  <head>
    <script src="./node_modules/nexmo-client/dist/nexmoClient.js"></script>
  </head>
  <body>
    <h1>App from App Call (Alice)</h1>
    <button id="btn-call" type="button">Call</button>
    <button id="btn-hangup" type="button">Hang Up</button>
    <script>

      const aliceJWT = "PASTE ALICE JWT HERE";

      const btnCall = document.getElementById("btn-call");
      const btnHangUp = document.getElementById("btn-hangup");
      new NexmoClient({ debug: true })
        .createSession(aliceJWT)
        .then(app => {
          btnCall.addEventListener("click", () => {
            console.log("Calling Bob...");
            app.callServer("Bob", "app");
          });
          app.on("member:call", (member, call) => {
            btnHangUp.addEventListener("click", () => {
              console.log("Hanging up...");
              call.hangUp();
            });
          });
        })
        .catch(console.error);
    </script>
  </body>
</html>
```

This is your client application that uses the Client SDK to make an in-app voice call to the destination *user* (Bob) .

There are several key components to this code:

1. Code that logs the user (Alice) into the Client SDK (a JWT is used for authentication) using `.createSession(aliceJWT)`.
2. The function to make the call is `callServer(username, type)`, where `type` in this case is "app", and the destination is the specified user (Bob).
> **NOTE**: Another way to make Voice Calls is with `inAppCall(username)` which uses peer-peer call functionality. [More info on `inAppCall()`](/sdk/stitch/javascript/Application.html#inAppCall__anchor)
3. When a call is made, a button handler is loaded. When the `Hang Up` button is clicked `call.hangUp()` terminates the call.
