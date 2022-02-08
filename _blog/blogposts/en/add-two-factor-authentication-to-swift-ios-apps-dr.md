---
title: Add 2FA to iOS Apps with Swift and Nexmo’s Verify API
description: Two-factor authentication (2FA) adds an extra layer of security for
  users that are accessing sensitive information. In this tutorial, we will
  cover how to add 2FA for an iOS app written in Swift.
thumbnail: /content/blog/add-two-factor-authentication-to-swift-ios-apps-dr/nexmo-2fa_ios_swift.jpg
author: eric_giannini
published: true
published_at: 2018-05-10T16:11:17.000Z
updated_at: 2021-05-12T20:51:53.584Z
category: tutorial
tags:
  - 2fa
  - ios
  - verify-api
comments: true
redirect: ""
canonical: ""
---
[Two-factor authentication](https://www.nexmo.com/blog/2014/11/11/why-two-factor-authentication-2fa/) (2FA) adds an extra layer of security for users that are accessing sensitive information.

While there are multiple modes of authenticating with something you know, are, or have, we will focus exclusively on the last. In this tutorial, we will cover how to implement two-factor authentication for a user's phone number with Nexmo's Verify API endpoints.

After reading the blog post about [how to set up a server to use Nexmo Verify](https://www.nexmo.com/blog/2018/05/10/nexmo-verify-api-implementation-guide-dr/) you're now ready to set up an iOS app to network with the server.

The app will need to do a few things. Store a `request_id` as a `responseId` so that a verification request can be canceled or completed. As well as make a network call to three endpoints:

* Start a verification.
* Check a verification code.
* Cancel a verification request.

## Nexmo Setup

After reading the blog post about [how to set up a server to use Nexmo Verify](https://www.nexmo.com/blog/2018/05/09/nexmo-verify-api-implementation-guide-dr) you're now ready to set up an iOS app to network with the server.

## Environment Setup

1. Download the starter project, a single view application:

   git clone https://github.com/nexmo-community/verify-ios-demo/

2. Add a CocoaPods file to its root directory, and install the pod after modifying its podfile to include the following:

```
pod 'Alamofire'
```

3. Make sure to have an iPhone with a SIM card handy.
4. To correctly configure the environment we need to simulate a server as in the [Glitch server app.](https://glitch.com/edit/#!/nexmo-verify) To configure, go to the .env file and set the values as required for `API_KEY` &amp; `API_SECRET`

# Review the UI

With the setup out of the way let's review the user interface for verification and confirmation.

1. A CocoaTouch file called `VerificationViewController` that is a subclass of UIViewController; this class is assigned to a scene in `Main.storyboard` so that it takes `VerificationViewController` as its custom class.
2. Three TextFields in `VerificationViewController`, outlets called `inputEmailAddress`, `inputPassword`, `inputTelephoneNumber` respectively.
3. A Button in `VerificationViewController` called `loginBtn`.
4. A Button in `VerificationViewController`, an action called `cancelVerification`.
5. A segue called `authenticateWith2FACode`, connecting `VerificationViewController` to `ConfirmationViewController`.
6. A CocoaTouch file called `ConfirmationViewController` that is a subclass of UIViewController; assigned to a scene in `Main.storyboard` so that it takes `ConfirmationViewController` as its custom class.
7. A TextField, `ConfirmationViewController`, `inputEmailAddress`.
8. A Button in `VerificationViewController`, an action called `cancelVerification`.

<strong>Note:</strong> You are free to set the constraints for the TextFields, Buttons, or Labels however you would like!

# Setting Up the Glitch Server

Let's break down what lies ahead. Nexmo's API for verification is essentially two links. The first one is <em>https://api.nexmo.com/verify/json</em>. This link verifies the user's telephone number. The second link is <em>https://api.nexmo.com/verify/check/json</em>. This link verifies that the user is in possession of the device by sending an SMS with a PIN.

In this tutorial, however, we do not directly hit either of these API endpoints. We use an SDK called `Alamofire` to communicate through an intermediary Glitch server.

### Steps for Setting Up Server

The first step to setting up the Glitch server is to remix the [Glitch server](https://glitch.com/edit/#!/nexmo-verify) for your own deployment. On the site there is a remix button.

## Programming the UI

With the Glitch server set up, the next step is to program the app's UI to request or respond to requests with the server.

1. At the top of `VerificationViewController` include the line `import Alamofire`.
2. Within the scope of `VerificationViewController`'s class declaration add the line `var responseId = String()`. We are initializing an empty string where we will hold a reference to our `responseId`.

<strong>Note: You may want to use NSUserDefaults or one of the many different classes for local storage. Since it is a matter of preference we leave it to you as a developer to decide how to store the `responseId`.</strong>

3. In the `@IBAction` for `verifyTelephoneNumber` add the following line: `self.verifyViaAPI()`, which is a function we will program to hit the first link.
4. Create a function called `verifyViaAPI()` with the following code:

```swift
    func requestVerificationWithAPI() {
        //Sending SMS
        let param = ["telephoneNumber": telephoneTextField.text]

        Alamofire.request("https://nexmo-verify.glitch.me/request", parameters: param as Any).responseJSON { response in

            print("--- Sent SMS API ----")
            print("Response: \(response)")

            if let json = response.result.value as? [String:AnyObject] {

                self.responseId = json["request_id"] as! String
                self.performSegue(withIdentifier: "authenticateWith2FA", sender: self)
            }
        }
    }
```

When the verification request is sent, our next step is to segue from the one view controller to the next. During the transition, we will pass our `responseId` so that our Glitch server knows with which app it is dealing. Here is how to program `prepare(for:sender:)`:

```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  let confirmationVC = segue.destination as! ConfirmationViewController
  confirmationVC.responseId = responseId
}
```

As we pass the `responseId` from one view controller to the next, we land on the `ConfirmationViewController` where we confirm whether the user requesting authentication has the device associated with their number.

### Second Link : SMS

1. In the `@IBAction` for `verifyPin` add the line `self.verifyPinViaAPI()`, which is a function we will program to hit the second link.
2. Create a function called `verifyPinViaAPI()` with the following code:

```swift
    func verifyPinViaAPI() {

        guard let requestId = requestId,
                let code = codeTextField.text else { return }

        let url = "https://nexmo-verify.glitch.me/check"
        let parameters = ["request_id": requestId,
                          "code": code]

        guard let request = URLRequestManager.getRequest(url, parameters: parameters) else { return }

        Alamofire.request(request).responseJSON { [weak self] response in

            print("--- Verify SMS API ----")
            print("Response: \(response)")

            if let json = response.result.value as? [String:AnyObject],
                let status = json["status"] as? String {

                // if status is zero, then success; if not something
                // went wrong
                if Int(status) == 0 {
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true)

                    }
                }
            }
        }
    }
```

The code is similar to the first request. In this code snippet, we parse the response for a successful verification. If the status returned in the response is zero, the user is authenticated. If not, then the user must start all over again.

### Cancellation

Last but not least is cancellation. Cancellation is programmed in a similar manner:

```swift
    func cancelRequest() {

        guard let requestId = requestId else { return }

        let parameters = ["request_id": requestId]
        let url = "https://nexmo-verify.glitch.me/cancel"

        guard let request = URLRequestManager.getRequest(url, parameters: parameters) else { return }

        Alamofire.request(request).responseJSON { response in

            print("--- Cancel Request API ----")
            print("Response: \(response)")

            if let json = response.result.value as? [String:AnyObject],
                let status = json["status"] as? String {

                if Int(status) == 0 {
                    print("Request Cancelled Successfully")
                }
            }
        }
    }
```

## What's Been Achieved and Learned?

You now have a verified number and double checked that your user is in possession of the device's number—and you did all of this with Nexmo's API!

With this implementation, you only know from the client side that the number is verified. In a real world app, you would need to tell your backend that the number is verified. You could accomplish that in two ways, by calling that update on the success flow from either the client or your own callbacks.

If you'd like to see the final product, you can download the completed project [here](https://github.com/nexmo-community/verify-ios-demo/tree/final).

## What's Next?

If you'd like you can implement the rest of the endpoints in the Verify API. Note that this will require you to add more endpoints in the API proxy server.

You can also add additional endpoints to cover the Number Insights API. This will also require you to add more endpoints in the API proxy server.

There's also an Android version of this post. [Read more from our developer advocate Chris Guzman.](https://www.nexmo.com/blog/2018/05/10/add-two-factor-authentication-to-android-apps-with-nexmos-verify-api-dr/)