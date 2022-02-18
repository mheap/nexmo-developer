---
title: Adding 2FA to a React App Using Firebase Function
description: This post covers how to verify your user's authenticity with
  Firebase functions from a React application using the Verify API from Vonage
  API service.
thumbnail: /content/blog/adding-2fa-to-a-react-app-using-firebase-function/E_Verify-with-React-Firebase_1200x600.png
author: kellyjandrews
published: true
published_at: 2020-04-01T12:06:34.000Z
updated_at: 2021-05-18T13:05:01.231Z
category: tutorial
tags:
  - firebase
  - node
  - verify-api
comments: true
redirect: ""
canonical: ""
---
If you're like me, you probably have a few "smart" devices around your home. There are multiple ways to interact and control these devices, but I wanted to be able to control them with text messages and eventually voice as well.  

So I set out to build some tooling in Firebase to get me going.  The first step I wanted to take, however, was securing the phone numbers that have access, and I thought it would be a perfect time to try out the Verify API. It's admittedly a bit over-the-top since this isn't a distributed app, but for safety, a phone number must go through the verification process to access my devices.  

<sign-up number></sign-up>

## Verify API

The [Verify API](https://developer.nexmo.com/verify/overview) is a way to confirm that the phone belongs to the user.  Performing the verification helps protect against spam and suspicious activity, as well as validating ownership.  

The API itself has quite a lot packed into it. Its [configuration options](https://developer.nexmo.com/verify/guides/changing-default-timings) let you build the [exact workflow](https://developer.nexmo.com/verify/guides/workflows-and-events) that works for your system. As an example, the default workflow sends an SMS with a PIN code, waits 125 seconds, then calls with a Text-to-Speech event, waits 3 additional minutes, then calls again and waits 5 minutes before expiring the request altogether.

I like having this level control over something like this as it allows me to be very specific about how I can interact with my users. In my particular instance, I kept it very simple and did just one SMS message that expired in two minutes, since I wanted this mostly for my own purposes.

```js
    let opts = {
      number: context.params.phoneNumber,
      brand: "Total Home Control",
      workflow_id: 6,
      pin_expiry: 120
    };
```

If you want to get started with the Verify API, you can sign up for a [Vonage](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav) account today to get going.

## Firebase Functions

Since I decided on using [Firebase](https://firebase.google.com/) and [Firestore](https://firebase.google.com/products/firestore), setting up some [Cloud Functions](https://firebase.google.com/products/functions) to interact with the data and the Verify API was my next step. Each time a new phone number was created, I wanted to send it a verification code and then have a function to check the code.  

### Promises, Promises

When you first learn Cloud Functions, you may try some [simple operations](https://firebase.google.com/docs/functions/get-started) and build your confidence,  which is what I did. After going through some of the simple functions first, I figured I'd be able to build this out fairly quickly.  

And I was wrong.  One detail I completely overlooked is that callback methods do not evaluate in the Cloud Function environment the way they do in other environments. Once there is a returned value or promise, the CPU stops. Since the Nexmo JavaScript SDK is running on callback methods, it stops processing.

Not knowing this had to be one of the more frustrating problems I've run into in a long time.  The timing of everything was weird because the call back would run when I tried again, causing me to think I wasn't waiting long enough or the latency was terrible.  

Once I sorted that out, I realized I needed to [create Promise wrappers](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises) for the SDK methods, and everything worked perfectly. If you want some useful tips & tricks, I recommend reading [this Firebase documentation guide.](https://firebase.google.com/docs/functions/tips)

### Requesting the Verify Code

The Verify request method in the [Nexmo JavaScript SDK](https://developer.nexmo.com/sdk/stitch/javascript/) is quite minimal code, as the framework there makes it simple to do most everything. The first thing I had to do was wrap it in a promise.

```js
function verifyRequest(opts) {
  return new Promise((resolve, reject) => {
    nexmo.verify.request(opts, (err, res) => {
      if (err) reject(err);
      resolve(res);
    })
  });
}
```

Creating this wrapper allows the callback method to run and return as a Promise resolution, instead of being ignored.

With this method, I could now create a Firebase function to run when the app added a new number to Firestore.

```js
exports.requestVerify = functions.firestore.document('/phoneNumbers/{phoneNumber}')
  .onCreate((entry, context) => {
    let opts = {
      number: context.params.phoneNumber,
      brand: "Total Home Control",
      workflow_id: 6,
      pin_expiry: 120
    };

    return verifyRequest(opts)
      .then((res) => {
        console.log(res);
        return admin.firestore().doc(`/phoneNumbers/${context.params.phoneNumber}`).update({ req_id: res.request_id })
      })
      .then((res) => console.log(res))
      .catch((err) => console.error(err));
  });

```

With the Verify API, we need to keep track of the `request_id` to use in the check process. I use this to indicate that the verification process started but not yet completed.  

### Checking the Verify Code

Same as the previous example, the SDK method needs to first be wrapped as a Promise. 

```js
function verifyCheck(opts) {
  return new Promise((resolve, reject) => {
    nexmo.verify.check(opts, (err, res) => {
      if (err) reject(err);
      resolve(res);
    })
  });
}
```

Once the user receives it, the React application asks for the code and then calls the function directly from the application, passing the `request_id`, and the `code`. 

```js
exports.checkVerify = functions.https.onCall((data) => {
  let opts = {
    request_id: data.req_id,
    code: data.code
  };

  return verifyCheck(opts)
    .then((res) => {
      if (res.status === "0") {
        return admin.firestore().doc(`/phoneNumbers/${data.phoneNumber}`).update({ req_id: null, verified: true });
      }
    })
    .then((res) => console.log(res))
    .catch((err) => console.error(err));
});
```

As long as the code checks out, the document updates to include a `verified` flag, and the process is over.  There are error status responses to check for and respond to accordingly—for example, if the code has timed out. My app currently assumes it passes.


### React App

I won't spend too much time explaining all the code I wrote for my app, but the highlights are adding the data, and then calling the Firebase function from the frontend.

In my app, I have a form to add a new number, consisting of just the phone number field. On submission, it merely adds it to the database. I've also set up a Firebase context file that sets the connections between my app and Firebase, so I can easily import everything I need.

```js
import { db, fb } from '../../context/firebase';

//-----//

function _handleSubmit(e) {
  e.preventDefault();

  let data = {
    owner: fb.auth().currentUser.uid,
    verified: false,
  };

  return db.collection('phoneNumbers').doc(phoneNumber).set(data);
}

//-----//
```

The verification is nearly the same form with a similar submit method.

```js
import { functions } from '../../context/firebase';

//-----//

function _handleSubmit(e) {
  e.preventDefault();
  var checkVerify = functions.httpsCallable('checkVerify');
  checkVerify({ code: code, req_id: value[0]?.data().req_id, phoneNumber: value[0]?.id }).then(function (result) {
    //close the form
  });
}

//-----//
```

The Firebase SDK provides a `functions` export to let you use `httpsCallable()` and name the function. Instead of needing to write any HTTP requests and waiting on those, this simplifies the process.


## Wrap Up

The Verify API is simple to use, and with Firebase and React you can quickly write the code needed to validate your users and their phone numbers. Feel free to try it out. You can sign up for a [Vonage](https://dashboard.nexmo.com/sign-up) account, and if you need some credits to get you started send us an email at devrel@vonage.com.

You can find my [https://github.com/kellyjandrews/smart-home-app](sample application code here). The app I built is more of a personal app for me, but feel free to have a look and use anything you might find useful.  Over the next month or so, I'll be adding some additional functionality to the app as well—first is opening and closing my garage door.
