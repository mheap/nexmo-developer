---
title: Make and receive phone calls in Android apps with Firebase
description: This tutorial shows how to make a Android app that can make
  outbound phone calls and receive incoming phone calls Firebase Functions,
  JavaScript and Kotlin.
thumbnail: /content/blog/make-and-receive-phone-calls-in-android-apps-with-nexmo-in-app-voice-and-firebase-dr/Nexmo-FIrebase-Android-App-Voice.png
author: chrisguzman
published: true
published_at: 2018-07-03T15:39:14.000Z
updated_at: 2021-05-20T09:44:29.156Z
category: tutorial
tags:
  - android
  - firebase
comments: true
redirect: ""
canonical: ""
---
With [Nexmo In-App Voice](https://developer.nexmo.com/stitch/in-app-voice/overview), you can easily make and receive phone calls with the Nexmo Stitch Android SDK and WebRTC technology. In this tutorial we'll show you how to make a simple Android app that can make outbound phone calls and receive incoming phone calls. This functionality could be used where customers want to make and receive calls to customer service, without leaving the app.

To get the app up and running, we'll use [Firebase Functions](https://firebase.google.com/docs/functions/) to host the [NCCO](https://developer.nexmo.com/voice/voice-api/guides/ncco) and return a [JWT](http://jwt.io/) for users to login with.

To follow along with this blog post, you should have some knowledge of JavaScript and be able to build an Android app using Kotlin. 

## Before we get started

There are a few things you’ll need before we get started.

* [Firebase Account](https://firebase.google.com/)
* Vonage Account

<sign-up></sign-up>

## Set up the Firebase Function.

First, we'll want to create a new directory for our Firebase functions project and to store our config files.

<pre class="lang:default highlight:0 decode:true " >
mkdir firebase-functions-nexmo-in-app-calling
cd firebase-functions-nexmo-in-app-calling
</pre>

Now that a new directory has been made, we can follow the for [setup instructions provided by Firebase](https://firebase.google.com/docs/functions/get-started) and create a new project. 

<pre class="lang:default highlight:0 decode:true " >
npm install -g firebase-tools
firebase login
firebase init functions
</pre>

For this project I chose to use JavaScript instead of TypeScript. 

If like me, you were not able to create a firebase function project from the command line you can visit the [Firebase Console](https://console.firebase.google.com) to create a new project, then run `firebase use --add` from your command line.

## Edit the Firebase Functions

You can see the final version of the methods we'll use for the Firebase Functions in the [repo for this demo on GitHub.](https://github.com/nexmo-community/In-App-Voice-Calling-Firebase-Android/tree/master/functions) In short we need three endpoints:

1. An Answer URL that will host the NCCO
2. An Event URL to capture events from the Voice API
3. A URL to return a JWT for users to login with

To edit the Firebase functions, we'll need to edit the `index.js` file in the new `functions/` directory that firebase created after we ran `firebase init functions`

Let's start by taking a look at the Answer method

```js
exports.answer = functions.https.onRequest((request, response) => {
  //use the `to` query parameter that Nexmo gives us to make a call.
  //if `to` is null, then we are receiving a call.
  var to = request.query.to
  var from = request.query.from

  var ncco = [];

  if (to) {
    ncco.push(
      {
        action: "talk",
        text: "Thank you for calling, you are now being connected."
      },
      {
        "action": "connect",
        "from": functions.config().nexmo.from_number,
        "endpoint": [
          {
            "type": "phone",
            "number": `${to}`
          }
        ]
      }
    )
  } else {
    ncco.push(
      {
        action: "talk",
        text: "You are being connected to the Customer."
      },
      {
        "action": "connect",
        "from": from,
        "endpoint": [
          {
            "type": "app",
            "user": "Customer"
          }
        ]
  
      })
  }
  response.json(ncco);
});
```

Since Nexmo's Voice API uses one answer URL per application, we can dynamically show the NCCO for accepting an inbound call if the `to` query parameter is null. If the `to` query parameter is *not* null, then we'll show the NCCO for making an outbound phone call.

Our endpoint for providing a JWT for users is fairly straightforward. We'll use the [Nexmo Node library](https://github.com/Nexmo/nexmo-node) to generate a JWT. In order to use the library we'll need to install the package.

<pre class="lang:default highlight:0 decode:true " >
#Ensure you're in the /functions directory where the package.json and index.js files are
npm install nexmo
</pre>

After installing the library, you can ensure everything is working correctly by inspecting the `package.json` file. It should look like so:

```json
  "dependencies": {
    "firebase-admin": "~5.12.1",
    "firebase-functions": "^1.0.3",
    "nexmo": "^2.3.2"
  }
```

Once the Nexmo Node library is installed, we can use it in the jwt endpoint like so to return a valid `user_jwt`.

```js
exports.jwt = functions.https.onRequest((request, response) => {
    response.json({
      user_jwt: Nexmo.generateJwt("private.key", {
        application_id: functions.config().nexmo.application_id,
        sub: "Customer",
        exp: new Date().getTime() + 86400,
        acl: adminAcl
      })
    });
});
```

Now that we've created our Firebase functions, we will create a Vonage application.

## Deploy the Firebase function

Now that the Firebase Functions have been written, we can deploy the Firebase project. After deploying the Functions, Firebase will give us the URLs for our answer and event endpoints. We can use these URLs to create our Vonage application.

<pre class="lang:default highlight:0 decode:true " >
#Ensure you're in the firebase-functions-nexmo-in-app-calling/ directory we created at the beginning of this tutorial
firebase deploy --only functions

✔  functions[answer]: Successful create operation.
Function URL (answer): https://your-project-name.cloudfunctions.net/answer
✔  functions[event]: Successful create operation.
Function URL (event): https://your-project-name.cloudfunctions.net/event
✔  functions[jwt]: Successful create operation.
Function URL (jwt): https://your-project-name.cloudfunctions.net/jwt
</pre>

## Set up the Vonage Application.

To create an application, first Install the Vonage CLI globally with this command:

```
npm install @vonage/cli -g
```

Next, configure the CLI with your Vonage API key and secret. You can find this information in the [Developer Dashboard](https://dashboard.nexmo.com/).

```
vonage config:set --apiKey=VONAGE_API_KEY --apiSecret=VONAGE_API_SECRET
```

Now we'll use the answer and event URL that Firebase provided us in the previous section.

```
# Ensure you're in the firebase-functions-nexmo-in-app-calling/ directory we created at the beginning of this tutorial
vonage apps:create 
✔ Application Name … ruling_narwhal
✔ Select App Capabilities › Voice
✔ Create voice webhooks? … yes
✔ Answer Webhook - URL … https://your-project-name.cloudfunctions.net/answer
✔ Answer Webhook - Method › POST
✔ Event Webhook - URL … https://your-project-name.cloudfunctions.net/event
✔ Event Webhook - Method › POST
✔ Allow use of data for AI training? Read data collection disclosure - https://help.nexmo.com/hc/en-us/articles/4401914566036 … no
Creating Application... done
Application Name: ruling_narwhal
```

Your private key gets saved in the functions directory you created. The key will have the same name as your project.

Record the application ID and save the private key in the "functions" directory. I recommend you add the `your_private_key_name.key` and `.nexmo-app` files with your credentials to your `.gitignore`.

Following best practices, we'll store some environment variables Firebase config via the firebase CLI. The Firebase docs contain an [overview about environment configuration.](https://firebase.google.com/docs/functions/config-env)

Now we need to store the Vonage application ID in the firebase config via the firebase CLI.

<pre class="lang:default highlight:0 decode:true " >
firebase functions:config:set nexmo.application_id="aaaaaaaa-bbbb-cccc-dddd-0123456789ab"
</pre>

*Note: Firebase requires config variable keys to be lowercase, so we'll use snake case for our variable names.*

If you wish, you could upload the private key string found in the `.nexmo-app` file from your Vonage application as a firebase config variable instead of uploading the entire `your_private_key_name.key` file to the firebase functions.

## Link a phone number and user to our application

Now that our functions have been written, we need to buy a number so that our users can make outbound calls from that number and receive inbound calls in their Android app whenever someone dials that number. We also have to link the number to our Vonage app.

You can rent a number from Vonage by using the following command (replacing the country code with your code). For example, if you are in the USA, replace `GB` with `US`:

```bash
vonage numbers:search US
vonage numbers:buy [NUMBER] [COUNTRYCODE]
```

Now link the number to your app:

```
vonage apps:link --number=VONAGE_NUMBER APP_ID
```

## Set up the Android project

If you'd like to view the finished project for our Android app you can [view the source code on GitHub.](https://github.com/nexmo-community/In-App-Voice-Calling-Firebase-Android/tree/master/in-app-voice-android-demo)

First we need to add the necessary libraries. We're going to use the Nexmo Stitch Android SDK, Retrofit, and Retrofit's Moshi Converter.

```groovy
dependencies {
  implementation 'com.nexmo:stitch:1.8.0'
  implementation 'com.squareup.retrofit2:retrofit:2.4.0'
  implementation "com.squareup.retrofit2:converter-moshi:2.4.0"
}
```

We'll use [Retrofit](https://github.com/square/retrofit) to make a `GET` request the Firebase function's JWT endpoint that Firebase CLI provided us.

```java
//FirebaseFunctionService.kt
interface FirebaseFunctionService {
    @GET("jwt")
    fun getJWT(): Call<UserJWT>
}


//RetrofitClient.kt
var retrofitClient = Retrofit.Builder()
        .baseUrl("https://your-project-name.cloudfunctions.net/")
        .addConverterFactory(MoshiConverterFactory.create())
        .build()

var retrofitService = retrofitClient.create<FirebaseFunctionService>(FirebaseFunctionService::class.java)
```

## Add the Login Activity

Having set up Retrofit, we can use it to retrieve a JWT from the JWT Firebase function endpoint in the `LoginActivity`. Here I'll show the [happy path](https://en.wikipedia.org/wiki/Happy_path) when we retrieve the user JWT and use it to login to the Nexmo Stitch Android SDK. [The layout for this Activity is available in GitHub](https://github.com/nexmo-community/In-App-Voice-Calling-Firebase-Android/blob/master/in-app-voice-android-demo/app/src/main/res/layout/activity_login.xml).

```java
class LoginActivity : BaseActivity(), RequestHandler<User>, Callback<UserJWT> {
    override fun onCreate(savedInstanceState: Bundle?) {
        ...
        loginBtn.setOnClickListener {
            login()
        }
    }

    private fun login() {
        showProgress(true)
        retrofitService.getJWT().enqueue(this)
    }

    //Successfully retrieved a JWT from the Firebase Function endpoint
    override fun onResponse(call: Call<UserJWT>?, response: Response<UserJWT>?) {
        val jwt = response?.body()?.user_jwt
        client.login(jwt, this)
    }

    //User successfully logged in with the Nexmo Stitch SDK
    override fun onSuccess(result: User?) {
        goToCallActivity()
    }

}
```

## Add the Call Activity

We'll add a simple layout for inputting phone numbers, starting, and ending phone calls. [The layout for this Activity is available in GitHub](https://github.com/nexmo-community/In-App-Voice-Calling-Firebase-Android/blob/master/in-app-voice-android-demo/app/src/main/res/layout/activity_call.xml).
 Like before I'll show the happy path of making and receiving a call.

```java
class CallActivity : BaseActivity(), RequestHandler<Call> {
    private var currentCall: Call? = null
    private lateinit var client: ConversationClient

    override fun onCreate(savedInstanceState: Bundle?) {
        ...
        client = Stitch.getInstance(this).conversationClient

        attachIncomingCallListener()
        callControlBtn.setOnClickListener { callPhone() }
    }

    private fun attachIncomingCallListener() {
        //Listen for incoming calls
        client.callEvent().add({ incomingCall ->
            logAndShow("answering Call")
            //Answer an incoming call
            incomingCall.answer(object : RequestHandler<Void> {
                override fun onError(apiError: NexmoAPIError) {
                    logAndShow("Error answer: " + apiError.message)
                }

                override fun onSuccess(result: Void) {
                    currentCall = incomingCall
                    attachCallStateListener(incomingCall)
                    showHangupButton()
                }
            })
        })
    }

    private fun attachCallStateListener(incomingCall: Call) {
        //Listen for incoming member events in a call
        val callEventListener = ResultListener<CallEvent> { message ->
            logAndShow("callEvent : state: " + message.state + " .content:" + message.toString())
        }
        incomingCall.event().add(callEventListener)
    }


    private fun callPhone() {
        val phoneNumber = phoneNumberInput.text.toString()

        client.callPhone(phoneNumber, object : RequestHandler<Call> {
            override fun onError(apiError: NexmoAPIError) {
                logAndShow("Cannot initiate call: " + apiError.message)
            }

            override fun onSuccess(result: Call) {
                currentCall = result
                showHangupButton()

                when (result.callState) {
                    Call.CALL_STATE.STARTED -> logAndShow("Started")
                    Call.CALL_STATE.RINGING -> logAndShow("Ringing")
                    Call.CALL_STATE.ANSWERED -> logAndShow("Answered")
                    else -> logAndShow("Error attaching call listener")
                }

            }
        })
    }

}
```

As you can see the Nexmo Stitch SDK handles the hard work of placing and answering phone calls.

## How does it work?

### Receive a Phone Call

When a user makes a phone call to the number we bought in the previous section, Nexmo will look up the NCCO in our Answer URL at https://your-project-name.cloudfunctions.net/answer. The NCCO will look like this:

```json
[  
   {  
      "action":"talk",
      "text":"You are being connected to the Customer."
   },
   {  
      "action":"connect",
      "endpoint":[  
         {  
            "type":"app",
            "user":"Customer"
         }
      ]
   }
]
```

This NCCO will direct the call to the "Customer" user we created in our app with the Stitch SDK. The app will handle answering the call by attaching the Call Listener in `attachIncomingCallListener()` For the sake of simplicity, we'll automatically answer the call, but you could implement a UI and logic to allow the user to answer or [`reject()`](https://developer.nexmo.com/sdk/stitch/android/reference/com/nexmo/sdk/conversation/client/Call.html#reject(com.nexmo.sdk.conversation.client.event.RequestHandler%3Cjava.lang.Void%3E)) the call.

### Make a Phone Call

If the user choose to make a call, we'll handle that in the `callPhone()` method. For example if our method was called like so:

```java
client.callPhone("14155550100", callback)
```

Then the [`client.callPhone(phoneNumber, callback)` method](https://developer.nexmo.com/sdk/stitch/android/reference/com/nexmo/sdk/conversation/client/ConversationClient.html#callPhone(java.lang.String,%20com.nexmo.sdk.conversation.client.event.RequestHandler%3Ccom.nexmo.sdk.conversation.client.Call%3E)) in the Nexmo Stitch Android SDK will use the Stitch API to make `GET` a request to your answer url https://your-project-name.cloudfunctions.net/answer with the following query parameters:

<pre class="lang:default highlight:0 decode:true " >
?from=16625461410\
&to=14155550100\
&conversation_uuid=CON-4e977dab-2abc-42b5-bf64-d468d4763e54\
&uuid=0666edbe58077d826944a7c1913da2b0
</pre>

We can use the `to` parameter to dynamically return a NCCO that tells Nexmo which phone number to call. The Stitch API will see the following NCCO response:

```json
[  
   {  
      "action":"talk",
      "text":"Thank you for calling, you are now being connected."
   },
   {  
      "action":"connect",
      "from":"12013753230",
      "endpoint":[  
         {  
            "type":"phone",
            "number":"14155550100"
         }
      ]
   }
]
```

In this case, the `from` number is the number that we rented from Nexmo and set as the `nexmo.from_number` with Firebase config variables. The value in `number` key in the `endpoint` array is the number that our user wants to call.

## Try it for yourself

[The repo for this sample project](https://github.com/nexmo-community/In-App-Voice-Calling-Firebase-Android) contains the source code for both the Firebase Functions and the Android Sample app. Clone the project for yourself to check it out!

## What's next?

Now that you've learned how to make and receive phone calls with [Nexmo In-App Voice](https://developer.nexmo.com/stitch/in-app-voice/overview) you can also learn more about [In-App Messaging](https://developer.nexmo.com/stitch/in-app-messaging/overview). 

For more in depth details of what the Nexmo Stitch Android SDK covers, you can read the [SDK documentation online](https://developer.nexmo.com/sdk/stitch/android/reference/packages.html).

Our [Voice API](https://developer.nexmo.com/voice/voice-api/overview) also offers other possibilities beyond just connecting and receiving calls! Visit our documentation to learn more about recording calls, playing audio stream to calls, and more.