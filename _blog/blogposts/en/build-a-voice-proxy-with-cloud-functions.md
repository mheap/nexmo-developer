---
title: Build a Voice Proxy With Cloud Functions
description: Leverage the the event-driven architecture of Google Cloud
  Functions to build a Voice Proxy or masked calling service with a single HTTP
  function.
thumbnail: /content/blog/build-a-voice-proxy-with-cloud-functions/voice-proxy_1200x600.png
author: julia
published: true
published_at: 2021-07-27T09:47:47.641Z
updated_at: 2021-07-26T18:14:03.739Z
category: tutorial
tags:
  - serverless
  - nodejs
  - cloud-functions
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Voice Proxy—or masked calling—protects users' private details by providing an intermediary phone number. This way, neither the caller nor the callee see each other's real phone numbers. 
It's common practice with delivery and ridesharing services like Deliveroo and Uber, but it comes in handy in a variety of small business scenarios as well. 

In this tutorial, we're going to build one of my favourite use cases: a virtual business phone.

We'll cover two call directions:

1. You're calling a client through your Vonage number: capture destination number via DTMF and connect.
2. Someone else is calling your Vonage number: connect them to your personal number.  

All we need to make it work is a virtual Vonage number and a small serverless function handling webhooks.

We'll use [Google Cloud Functions](https://cloud.google.com/functions), Google's Function-as-a-Service (FaaS) offering for a faster way to build in the Cloud.

With these event-driven serverless functions, you're looking at managed compute, auto-scaling, and pay-per-use metered to the nearest 100 milliseconds. The developer experience is simple and intuitive, allowing you to focus on the code while Google Cloud handles the operational infrastructure.

You can think of Cloud Functions as building blocks that quickly extend your cloud services with code. They run in response to events delivered via HTTP or emitted by other Google Cloud Platform services, making them an excellent fit for event-based architectures, data processing, and Cloud automations.

In this example, we're writing an HTTP function that gets triggered by HTTP requests received from the Vonage Voice API, taking advantage of the event-based architecture of Google Cloud Functions.

## Prerequisites

* [Google Cloud Platform](https://console.cloud.google.com/) account—Sign up or log in with Google; you'll get $300 worth of credit to start with. This is a generous amount that should last you a while for testing and learning purposes.
* Basic understanding of [Node.js](https://nodejs.org/en/) and [Express](https://expressjs.com/).

<sign-up number></sign-up>

## Set Up Google Cloud Functions

### Create a New Google Cloud Project

First, create a new Project if you haven't already. These projects form the basis for creating, enabling, and using all Google Cloud services.

Go to the **[Manage Resources](https://console.cloud.google.com/cloud-resource-manager)** page of the Cloud Console and click *Create Project*. Find more details about creating and managing resources in the [Google Cloud guide](https://cloud.google.com/resource-manager/docs/creating-managing-projects#console).

### Create a Cloud Function

Next, select **[Cloud Functions](https://console.cloud.google.com/functions)** from the Navigation menu, then click [Create Function](https://console.cloud.google.com/functions/add).

There are a couple of fields to be configured:

1. Give your function a *name*.
2. Select a *Region*. I went with `europe-west-2` because I'm close to London. If you're unsure which one works best for you, check out the [list of available regions](https://cloud.google.com/compute/docs/regions-zones#available).
3. Set the *trigger type* to `HTTP`, as we're writing an HTTP function.
4. Check "Allow unauthenticated invocations" and "Require HTTPS".

Once you're done, copy the generated URL and click *Save*.

![Create function config page](/content/blog/build-a-voice-proxy-with-cloud-functions/create-function-first-page.png "Create function config page")

Next, expand the *RUNTIME, BUILD AND CONNCETIONS SETTINGS* and scroll down to the *Runtime environment variables*. We'll need to set two phone numbers as environment variables, both in E. 164 international format. For example, 447700900123 (UK) or 14155550101 (US).

* `YOUR_VONAGE_NUMBER`: one of your Vonage virtual numbers. Find one in your [Vonage Dashboard](https://dashboard.nexmo.com/your-numbers) or [buy one](https://dashboard.nexmo.com/buy-numbers).
* `YOUR_PHONE_NUMBER`: your personal phone number that you'll use for testing.

![Set environment variables](/content/blog/build-a-voice-proxy-with-cloud-functions/environment-variables.png "Set environment variables")

Click *Next*, and that's the config done; now on to the code!

Make sure you select **Inline Editor** as *Source Code*, the latest Node.js as *Runtime*, and enable any APIs the platform may warn you about.

![Cloud Functions Inline Editor warning about installing Cloud Build](/content/blog/build-a-voice-proxy-with-cloud-functions/enable-cloud-build.png "Cloud Functions Inline Editor warning about installing Cloud Build")

The inline code editor shows a generated boilerplate function using Express.js request and response objects. We'll replace this with our function. Just bear in mind that if you change the function name, you'll need to update the *Entry point* as well.

## Create a Voice-Enabled Vonage Application

A [Vonage API application](https://developer.vonage.com/application/overview) holds the security and config information needed to connect to Vonage endpoints and use the Vonage APIs. Each Vonage application created can support multiple capabilities; however, we only need Voice functionality for now. 

Let's create one using the [Vonage Dashboard](https://dashboard.nexmo.com/applications/new). Navigate to *Your applications -> [Create a new application](https://dashboard.nexmo.com/applications/new)*.

Switch on Voice capabilities, then provide your generated Cloud Functions URL in the `Answer URL` field. Mine looks like this: `https://europe-west2-my-proxy-calling-project.cloudfunctions.net/proxy-call`.  
We won't be implementing an event webhook, for now, so feel free to use `http://example.com/event` in that field.

When finished, click on *Generate new application.*

![Create Voice-enabled Vonage Application](/content/blog/build-a-voice-proxy-with-cloud-functions/create-vonage-application.png "Create Voice-enabled Vonage Application")

On the next page, you'll see a list of the virtual numbers you have available in your account. Click the *Link* button next to any that you'd like to attach to this application. You'll be calling this number to test your application, so start with a local one. Alternatively, if no list shows up or you can't see any suitable ones, you can also [buy more numbers](https://dashboard.nexmo.com/buy-numbers). 

![Link virtual Vonage number to Vonage Application](/content/blog/build-a-voice-proxy-with-cloud-functions/vonage-link-number.png "Link virtual Vonage number to Vonage Application")

If you link a different number than the one you set in the runtime environment, make sure you update the value of `YOUR_VONAGE_NUMBER` in the Cloud Console UI.

## Controlling the Call Flow

Now that you've configured a Vonage Application, Vonage will make a GET request to your `Answer URL` whenever someone calls your linked virtual number. Vonage expects a [Call Control Object](https://developer.vonage.com/voice/voice-api/ncco-reference) (NCCO) to be returned, a set of instructions on how the call flow should be executed.  

An NCCO is presented as a valid JSON array containing one or more actions. In this example, we'll use a couple of different ones:

* the `talk` action to play text-to-speech messages into the call
* the `input` action to capture user input by detecting DTMF tones (button presses)—[DTMF input](https://developer.vonage.com/voice/voice-api/guides/dtmf)
* the `connect` action to connect caller and callee.

## Building the Cloud Function

As we're going to have three cases, we also need to return three different NCCOs accordingly. 

We need to cover three cases:
1. Someone else is calling your Vonage number -> connect them to your phone number
2. You are calling your Vonage number:

   2.1. You haven't yet provided DTMF payload -> capture DTMF input

   2.2. DTMF payload is available -> connect call to DTMF payload (destination phone number) 

Return to the Google Cloud Console and replace the boilerplate code with the following.

```js
// Get environment variables
const YOUR_VONAGE_NUMBER = process.env.YOUR_VONAGE_NUMBER;
const YOUR_PHONE_NUMBER = process.env.YOUR_PHONE_NUMBER;


exports.helloWorld = (req, res) => {
    // Check if there's DTMF payload in the request body
    if (req.body.dtmf) {
        // (2.2) Connect call to the number in the DTMF payload
    ])
    } else {
        // Check if you're the caller
        if (req.query.from === YOUR_PHONE_NUMBER) {
            // (2.1) Capture destination number via DTMF input
        } else {
            // (1) Connect caller to your phone number
        }
    }
};
```

Let's have a look at each of these sections.

### 1. Receive a Phone Call: Connect Caller

First, if someone else calls your virtual number, you'd want the call to be connected to your actual phone number. This is achieved using a `connect` action and, optionally, a `talk` action to let the caller know they are being connected. 

In this case, you need to return the following NCCO:

```javascript
res.json([{
        action: 'talk',
        text: 'Please wait while we connect you.'
    },
    {
        action: 'connect',
        from: YOUR_VONAGE_NUMBER,
        endpoint: [{
            type: 'phone',
            number: YOUR_PHONE_NUMBER
        }]
    }
])
```

The above snippet is more than enough for this use case, but you can further configure both of these actions if you'd like. Head over to the [NCCO Reference](https://developer.vonage.com/voice/voice-api/ncco-reference#connect) to read about all available options.

### 2. Make a Phone Call

Next, we need to handle the case when you are calling your Vonage number, providing the destination number using your handset's keypad (DTMF input), then being connected to the number you just provided.  

This scenario happens in two steps.

#### 2.1 Capture DTMF Input

First, we need to return an NCCO containing an `input` action to capture the digits. Let's add a `talk` action as well, to include instructions.

The `talk` action is just like the one in the previous step, also optional.

The `input` action needs to be of type `['dtmf']`. Speech recognition is also available; read more about this action in the [NCCO Reference](https://developer.vonage.com/voice/voice-api/ncco-reference#input).  

We also need to change the default [DTMF Input Settings](https://developer.vonage.com/voice/voice-api/ncco-reference#dtmf-input-settings) to make them suitable for capturing a phone number.  

* `timeOut` is the number of seconds before the caller's activity is sent to the `eventUrl` after their last action. It's three by default, but let's go with the maximum `10` to give us a little wiggle room.
* `maxDigits` is the number of digits the user can press, four by default. `15` digits will accommodate phone numbers in [E. 164](https://developer.nexmo.com/voice/voice-api/guides/numbers) international format, which is the formatting Vonage uses for phone numbers. For example, a UK number would have the format 447700900123.
* `submitOnHash` allows the caller's activity to be sent to the `eventUrl` after pressing the # key. If # is not pressed, the result is submitted after `timeOut` seconds. False by default, so make sure you set it to `true`.

```javascript
res.json([{
        action: 'talk',
        text: 'Please enter a phone number in international format, omitting the leading plus sign. End with the pound key.'
    },
    {
        action: 'input',
        type: ['dtmf'],
        dtmf: {
            timeOut: 10,
            maxDigits: 15,
            submitOnHash: true
        },
        eventUrl: ["https://europe-west2-my-proxy-calling-project.cloudfunctions.net/proxy-call"]
    }
])
```

#### 2.2 Connect Call to DTMF Input

Once the digits have been captured, Vonage will make another request—POST by default—to our endpoint with a DTMF payload in the request body. Then, a second NCCO with a `connect` action needs to be returned to get you connected to the destination number.

```javascript
res.json([{
        action: 'talk',
        text: 'Connecting'
    },
    {
        action: 'connect',
        from: YOUR_VONAGE_NUMBER,
        endpoint: [{
            type: 'phone',
            number: req.body.dtmf.digits
        }]
    }
])
```

This Call Control Object is similar to the first one, except we're setting the destination number dynamically. `req.body.dtmf.digits` contains the DTMF payload; see the input [Webhook Reference](https://developer.vonage.com/voice/voice-api/webhook-reference#input) for more details on the DTMF Capturing Results.

## The Finished Product

Finally, let's bring all moving parts together! Slotting the three snippets we've discussed into the initial function results in the following code:

```javascript
// Get environment variables
const YOUR_VONAGE_NUMBER = process.env.YOUR_VONAGE_NUMBER;
const YOUR_PHONE_NUMBER = process.env.YOUR_PHONE_NUMBER;

exports.helloWorld = (req, res) => {
    // Check if there's DTMF payload in the request body
    if (req.body.dtmf) {
        // (2.2) Connect call to the number in the DTMF payload
        res.json([{
                action: 'talk',
                text: 'Connecting'
            },
            {
                action: 'connect',
                from: YOUR_VONAGE_NUMBER,
                endpoint: [{
                    type: 'phone',
                    number: req.body.dtmf.digits
                }]
            }
        ])
    } else {
        // Check if you're the caller
        if (req.query.from === YOUR_PHONE_NUMBER) {
            // (2.1) Capture destination number via DTMF input
            res.json([{
                    action: 'talk',
                    text: 'Please enter a phone number in international format, omitting the leading plus sign. End with the pound key.'
                },
                {
                    action: 'input',
                    type: ['dtmf'],
                    dtmf: {
                        timeOut: 10,
                        maxDigits: 15,
                        submitOnHash: true
                    },
                    eventUrl: ["https://europe-west2-my-proxy-calling-project.cloudfunctions.net/proxy-call"]
                }
            ])
        } else {
            // (1) Connect caller to your phone number
            res.json([{
                    action: 'talk',
                    text: 'Please wait while we connect you'
                },
                {
                    action: 'connect',
                    from: YOUR_VONAGE_NUMBER,
                    endpoint: [{
                        type: 'phone',
                        number: YOUR_PHONE_NUMBER
                    }]
                }
            ])
        }
    }
};
```

When you're ready, click *DEPLOY*. It might take a minute or so for the deployment to happen, be patient. :) Once a green checkmark appeared next to your function, you're ready to test it out! 

![Function deployed](/content/blog/build-a-voice-proxy-with-cloud-functions/function-delpoyed.png "Function deployed")

Your call forwarding service is live, so give it a call! Even better, have a friend ring your virtual number—this way, you can test both call directions.

## Where Next?

Congratulations! You've just built a proxy-calling service with one small Google Cloud Function!  

Ready to take it further? Do you have a use case that requires call recording? Allow multiple numbers to use the service? Accept both speech and DTMF input?

Have a look at the resources below and think about how you can expand on it. Let us know how you get on, and we'd love to hear your thoughts!

### Resources

* [Voice API Overview](https://developer.vonage.com/voice/voice-api/overview)
* [NCCO Reference](https://developer.vonage.com/voice/voice-api/ncco-reference)
* [Voice API Webhooks Reference](https://developer.vonage.com/voice/voice-api/webhook-reference)
* [Voice API Reference](https://developer.vonage.com/api/voice?theme=dark)
* [Automatic Speech Recognition](https://developer.vonage.com/voice/voice-api/guides/asr)
* [DTMF Signals](https://developer.vonage.com/voice/voice-api/guides/dtmf)
* [Google Cloud Functions](https://cloud.google.com/functions)
* [Using Environment Variables](https://cloud.google.com/functions/docs/configuring/env-var#cloud-console-ui)

In the future, you might want to develop and test your functions locally. Check out the Cloud Functions [Local Development guide](https://cloud.google.com/functions/docs/running/overview) to find out how to get started.