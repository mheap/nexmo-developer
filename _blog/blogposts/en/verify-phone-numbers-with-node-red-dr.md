---
title: Verify Phone Numbers with Node-RED
description: In this tutorial we'll have a look at the Nexmo Verify API with
  Node-RED and explore a handy way of validating your users' phone numbers.
thumbnail: /content/blog/verify-phone-numbers-with-node-red-dr/verify-featured-image.png
author: julia
published: true
published_at: 2019-09-25T08:00:13.000Z
updated_at: 2021-05-11T09:55:54.200Z
category: tutorial
tags:
  - verify-api
  - node
comments: true
redirect: ""
canonical: ""
---
In [previous tutorials](https://www.nexmo.com/blog/tag/node-red) you've learnt about the Nexmo SMS and Voice APIs, you've gotten comfortable with sending and receiving messages and calls, and hopefully, you've also had a chance to experiment and play around with customizing these experiences in Node-RED.

In this tutorial, we'll look at the [Verify API](https://developer.nexmo.com/verify/overview) and explore a handy way of validating your users' phone numbers.

Many apps on-board users with not much more than a phone number in order to keep the process as simple as possible, and they need to use that identifier for authentication later on.

So let’s take a look at how we can do that, as well as ensure that there are no duplicate accounts and that the users are indeed reachable on the phone numbers provided by them.

## Prerequisites

Before getting started, you’ll need a few things:

* [Node.js](https://nodejs.org/en/) and [Node-RED](https://nodered.org/docs/getting-started/installation) installed on your machine

<sign-up></sign-up>

### Getting Your Credentials

In order to interact with the Verify API, you'll need to make note of a couple of things. Once you've created a Nexmo account, go to the [dashboard](https://dashboard.nexmo.com) to find your API key and secret. You'll be using these credentials later on to authenticate with the API.

### Setting Up Your Node-RED Editor

First, you’ll need to [install](https://nodered.org/docs/getting-started/installation) the runtime and editor. This could be done either on your local machine, on a Single Board Computer (eg Raspberry Pi), or a number of cloud-hosted options.

This example will be using your local machine, so once you've installed Node-RED globally, type the command below in your terminal to get started.

```bash
$ node-red
```

You can then access the Node-RED editor by pointing your browser at <http://localhost:1880>.

Once you have your editor open, you'll need to install the Nexmo nodes. You can do this under the *Manage palette* menu, by searching for the `node-red-contrib-nexmo` package and clicking install. 

![install node red](/content/blog/verify-phone-numbers-with-node-red/install-nexmo-nodered.gif "install node red")

Next, repeat the previous step for the `node-red-dashboard` package as well.

After restarting Node-RED, you should now see all of the Nexmo and Dashboard nodes appear on the left side of your screen, among the other default nodes in the node palette.

## User Interface

For this tutorial you'll need a simple user interface to collect user input. There are a couple of ways you could go about this, including writing your own HTML and CSS, but a much quicker alternative is using the Node-RED dashboard nodes.

#### What you'll need:

* A text field collecting the user's **phone number**
* A text field collecting the **PIN code**
* A **Cancel Verification** button
* A **Call Me** button - this will give the user the option to request a phone call on top of an SMS, as a means of receiving the PIN code.

Speed up the process by *Importing from Clipboard* the snippet below, or experiment with the dashboard nodes for yourself.

```json
[
    {
        "id": "463e8e92.d82a78",
        "type": "tab",
        "label": "Verify Demo",
        "disabled": false,
        "info": ""
    },
    {
        "id": "fb7955ef.0e5fd8",
        "type": "ui_form",
        "z": "463e8e92.d82a78",
        "name": "",
        "label": "Verify your phone number:",
        "group": "91563061.fc448",
        "order": 1,
        "width": 0,
        "height": 0,
        "options": [
            {
                "label": "eg. 447401234567",
                "value": "number",
                "type": "text",
                "required": true
            }
        ],
        "formValue": {
            "number": ""
        },
        "payload": "",
        "submit": "Send me a code",
        "cancel": "delete",
        "topic": "",
        "x": 430,
        "y": 140,
        "wires": [
            []
        ]
    },
    {
        "id": "b60bf0b2.9a839",
        "type": "ui_button",
        "z": "463e8e92.d82a78",
        "name": "",
        "group": "91563061.fc448",
        "order": 2,
        "width": "0",
        "height": "0",
        "passthru": false,
        "label": "Call me",
        "tooltip": "",
        "color": "",
        "bgcolor": "",
        "icon": "",
        "payload": "",
        "payloadType": "str",
        "topic": "",
        "x": 520,
        "y": 580,
        "wires": [
            []
        ]
    },
    {
        "id": "b182a10d.c8f08",
        "type": "ui_button",
        "z": "463e8e92.d82a78",
        "name": "",
        "group": "91563061.fc448",
        "order": 3,
        "width": 0,
        "height": 0,
        "passthru": false,
        "label": "Cancel Verification",
        "tooltip": "",
        "color": "",
        "bgcolor": "red",
        "icon": "",
        "payload": "",
        "payloadType": "str",
        "topic": "",
        "x": 550,
        "y": 760,
        "wires": [
            []
        ]
    },
    {
        "id": "a2251664.3ba2f",
        "type": "comment",
        "z": "463e8e92.d82a78",
        "name": "Start Verification - Collect phone number to be verified",
        "info": "",
        "x": 520,
        "y": 80,
        "wires": []
    },
    {
        "id": "7185f18d.87142",
        "type": "comment",
        "z": "463e8e92.d82a78",
        "name": "Check if received code matches the generated one",
        "info": "",
        "x": 510,
        "y": 280,
        "wires": []
    },
    {
        "id": "7f30e.60359cf28",
        "type": "comment",
        "z": "463e8e92.d82a78",
        "name": "Next Verification - Escalate to TTS Call",
        "info": "",
        "x": 610,
        "y": 520,
        "wires": []
    },
    {
        "id": "c46fa301.4eb0d8",
        "type": "comment",
        "z": "463e8e92.d82a78",
        "name": "Cancel Verification",
        "info": "",
        "x": 550,
        "y": 700,
        "wires": []
    },
    {
        "id": "ab7fb094.d7d1f8",
        "type": "ui_form",
        "z": "463e8e92.d82a78",
        "name": "",
        "label": "Check code:",
        "group": "91563061.fc448",
        "order": 4,
        "width": 0,
        "height": 0,
        "options": [
            {
                "label": "Enter the PIN code you received",
                "value": "code",
                "type": "text",
                "required": true
            }
        ],
        "formValue": {
            "code": ""
        },
        "payload": "",
        "submit": "submit",
        "cancel": "delete",
        "topic": "",
        "x": 390,
        "y": 340,
        "wires": [
            []
        ]
    },
    {
        "id": "91563061.fc448",
        "type": "ui_group",
        "z": "",
        "name": "Verify Demo Input Fields",
        "tab": "fdce8e2a.f4364",
        "disp": false,
        "width": "8",
        "collapse": false
    },
    {
        "id": "fdce8e2a.f4364",
        "type": "ui_tab",
        "z": "",
        "name": "Verify Demo",
        "icon": "dashboard",
        "disabled": false,
        "hidden": false
    }
]
```

When you're ready, your editor should look similar to this:

![verify UI template](/content/blog/verify-phone-numbers-with-node-red/verify-ui-template.png "verify UI template")

To see your UI, navigate to `http://127.0.0.1:1880/ui`. 

![verify UI](/content/blog/verify-phone-numbers-with-node-red/verify-ui.png "verify UI")

## Verifying your user

Once we've collected a user's phone number, we can start the verification process by sending a verify request to the Verify API. 

### Start Verification

To start a verification, you'll need a **`sendverify`** node wired to the form capturing the user's phone number. By default, this will send a short custom text and a PIN code in an SMS message to the user's phone number, followed by two text-to-speech phone calls in case they fail to submit the received code.

Open up the **`sendverify`** node properties by double-clicking on it. There you'll find the three required fields that you'll need to fill in: `Nexmo Credentials`, `To {}` and `Brand {}`.

Note the `{}` next to the labels, which means that those fields will support [Mustache Templating](https://mustache.github.io/) and you will be able to pass in values dynamically.

From the `Nexmo Credentials` drop-down select *Add new nexmobasic* and click the edit button. You will then be prompted to provide your `API Key` and `API Secret` to authenticate with the Verify API - both of these can be found in your [Nexmo Dashboard](https://dashboard.nexmo.com).

Once you're done, click **add**. Now next to the `Nexmo Credentials` label you'll see a [config node](https://nodered.org/docs/user-guide/editor/sidebar/config), this will be storing your credentials going forward.

Next, you'll have to pass your user's phone number into the `To {}` field. If you imported the UI snippet above, this will be `{{msg.payload.number}}`, since we specified in the first **`form`** node that the input value is to be collected in the `number` key of `msg.payload`. You can change this by opening up the **`form`** node properties and choosing a different `Name`.

Finally, you can personalize the verification request SMS body under `Brand {}` to help users identify your company or application name. It takes an 18-character alphanumeric string that will be prepended to the PIN number generated by the Verify API.

For example: "Your Acme Inc PIN is ..."

![send verify configuration](/content/blog/verify-phone-numbers-with-node-red/verify-sendverify-config.gif "send verify configuration")

The **`sendverify`** node outputs the API response received from Nexmo, containing a `request_id` and a `status` parameter. Find out more about the status codes in the [Verify API Reference](https://developer.nexmo.com/api/verify#verify-request).

The `request_id` will be used for all following steps, so we have to make it accessible by all other nodes in the current flow. To do this, connect a **`change`** node to **`sendverify`**, open up its node properties and set `flow.request_id` to `msg.payload.request_id`.

![verify set request ID](/content/blog/verify-phone-numbers-with-node-red/verify-set-requestid.png "verify set request ID")

To have a bit more insight into what's happening, you can also wire a **`debug`** node into **`sendverify`**. This way you can follow the API response in the debug sidebar.

### Check PIN Code

The request has successfully been accepted by Nexmo, your user has received a verification code and has already submitted it through the corresponding form. Success? Almost.

Now we have to figure out if the submitted code is indeed the one generated and sent by the Verify API.

For this step we'll need the **`checkverify`** node, which will take as input the *Request ID* and the *Code* supplied by the user, compare the two, then output the API response into `msg.payload`.

After dragging it into your workspace, wire it to the form capturing the PIN code submitted by the user, then connect a **`debug`** node after it to see the response object in the debug sidebar.

Open up the **`checkverify`** node properties. From the `Nexmo Credentials` drop-down select the config node created by **`sendverify`**, fill in the `Request ID {}` field with `{{flow.request_id}}` and pass the code submitted by your user into the `Code {}` field.

If you imported the UI snippet above, this will be `{{msg.payload.code}}`, since we specified in the second **`form`** node that the input value is to be collected in the `code` key of `msg.payload`. You can change this by opening up the **`form`** node properties and picking a different `Name`.

![check verify](/content/blog/verify-phone-numbers-with-node-red/verify-checkverify.gif "check verify")

Congrats!🎉 Your Verify flow is up and running, go to `http://localhost:1880/ui` and give it a try!

After submitting the received PIN code, go back to your Node-RED Editor and have a closer look at the debug sidebar.

![send check debug](/content/blog/verify-phone-numbers-with-node-red/verify-send-check-debug.png)

The response object will contain details about your request including `status`, which indicates whether it has been successful or not. If the PIN submitted by the user matches the one generated by the Verify API, `status` will have a value of `"0"`.

#### Check Verification Status

Although the user's phone number has been successfully validated, there is no sign of this event besides the debug sidebar at this moment.

To define what is to happen after the verification process has ended, we can use the `status` property of `msg.payload` to separate the different scenarios.

You might want to grant access to this user to a certain webpage or application, save the successfully verified user's details into a database, or let them know what the result was and prompt them to try again in case it had failed. It really all depends on your use case and why you are trying to verify your users in the first place.

To keep things simple, we are going to evaluate the `status` property, then based on its value let the user know whether the verification has been successful or not. If you'd like to be more precise with your error messages, feel free to add more routes for other [status codes](https://developer.nexmo.com/api/verify#verifyCheck) as well.

To do this, we'll need:

* a **`switch`** node to check the value of `msg.payload.status`
* a **`notification`** dashboard node to inform the user
* two **`change`** nodes to prepare the message the **`notification`** node is going to display - one in case of success and one in case of a failed attempt.

Add these nodes into your workspace and connect them as seen in the picture below.

![check verify switch](/content/blog/verify-phone-numbers-with-node-red/verify-checkverify-switch.png "check verify switch")

Now, let's have a closer look at each of these nodes:

#### `switch`

The **`switch`** node routes messages based on their property values or sequence position. In this case, we're looking to create two routes based on the value of `msg.payload.status.`

When a message arrives, the node will evaluate each of the rules defined in its node properties, and forward the message to the corresponding outputs of any matching rules.

First, double-click on the **`switch`** node to access its properties. In the `Property` field replace "payload" with "status", so that it's `msg.payload.status` that gets evaluated.

Next, we have to define rules based on its value.
Click on the **add** button to add a second rule, as we will be needing two:

1. success: in the first rule, select "==" from the first drop-down and write a "0" in the text field next to it;
2. failure: in the second rule, select "!=" from the first drop-down and write a "0" in the text field next to it. This will cover all cases when the verification is not a success.

![verify switch config](/content/blog/verify-phone-numbers-with-node-red/verify-switch-config.png)

Note how the rules have a `-> 1` and a `-> 2` sign next to them. This indicates that if the first statement is true, nodes connected to the first output will be triggered. In all other cases, the ones wired into the second output will be set off.

#### `notification`

The **`notification`** node shows `msg.payload` as a pop-up notification or an *OK/Cancel* dialog message on the user interface. You can choose the type of notification from the `Layout` drop-down in the node properties, and in case of a pop-up, you can also configure its position.

Set the duration in the `Timeout (S)` field by entering the number of seconds you wish to keep it visible on the UI.

If you'd like to set a title, you can do so in the `Topic` field, or in case a `msg.topic` is available it will be used as the title.

It's possible to further customize the experience by defining a border colour, either in the `Border` field or by passing it in dynamically in `msg.highlight`. 

![check verify notification](/content/blog/verify-phone-numbers-with-node-red/verify-checkverify-notification.png)

#### `change`

In the **`change`** nodes we'll be using the `Set` operation to specify the values of `msg.payload` and `msg.highlight`.

Let's open up the node properties of the first **`change`** node (make sure it's wired into the first output of the **`switch`** node, our success scenario). Set `msg.payload` to a success message like "Successful verification!", click the **add** button to define a second rule, and set `msg.highlight` to "green".

![verify success change](/content/blog/verify-phone-numbers-with-node-red/verify-success-change.png)

Repeat the same steps for the second **`change`** node, but this time give `msg.payload` "Verification failed!" as value and set `msg.highlight` to "red". Also, make sure it's connected into the second output of the **`switch`** node.

![verify fail change](/content/blog/verify-phone-numbers-with-node-red/verify-fail-change.png)

Hit **Deploy** and give it another try! Now, when the verification process completes, you'll see a pop-up appear with the result!

### Next Verification

Once the verification process has started, Nexmo will make three attempts at delivering the PIN code to the submitted phone number: an SMS message and two text-to-speech(TTS) phone calls.

There are times when a phone call is the better option, be it for accessibility reasons or out of pure personal preference. It's always a nice touch to give our users the option to choose an alternative delivery method, so let's have a look at implementing a button that would escalate the verification process to a TTS call instantly.

In the provided flow template, find the **Call Me** button and connect a **`nextverify`** node into it. Open up the **`nextverify`** node properties, select your `Nexmo Credentials` from the drop-down menu and fill in the `Request ID {}` field with `{{flow.request_id}}`.
You might want to also consider adding a **`debug`** node for a bit more insight on your end, and a **`change`** node followed by a **`notification`** node to let the user know what's going on - just like you did at the previous step, but it's completely optional.

![next verify](/content/blog/verify-phone-numbers-with-node-red/verify-nextverify.gif)

### Cancel Verification

In an ideal world we would stop here, but something always comes up, doesn't it? You've made a mistake while filling in a form and hit submit - too late to change your mind and hit that **Delete** now, the verification has already started.

You might think you could just wait it out and try again once it's failed. Yes, that works as well, but it's not an ideal way to go about it. Besides giving a frustrating experince to your users, think about the poor unsuspecting soul that ends up getting two phone calls in addition to that initial verification message - at 2am. Oops.

Fortunately, there's a quick and easy way of implementing a **Cancel Verification** button.

If you imported the provided UI snippet, all you need to do is connect a **`cancelverify`** node into the **Cancel Verification** button's output, open up the **`cancelverify`** node properties, select your `Nexmo Credentials` from the drop-down menu and fill in the `Request ID {}` field with `{{flow.request_id}}`.

You could also add a **`debug`** node to see the response object in the debug sidebar, and a **`change`** node followed by a **`notification`** node to let the user know it has successfully been cancelled.

![cancel verify](/content/blog/verify-phone-numbers-with-node-red/verify-cancelverify.gif)

Now hit that **Deploy** button and test it out! Keep in mind that for a cancel request to be valid, it has to be initiated at least 30 seconds after the phone number has been submitted. Still plenty of time to avoid that TTS call being initiated!

Et voilà! With your safety guard in place, you can now sleep better at night - and so can all the unsuspecting strangers you'll be verifying as well. Good job!

![verify flow](/content/blog/verify-phone-numbers-with-node-red/verify-flow.gif)

### Extra Credit - Search Verification

You can already follow the flow of the verification process in the debug sidebar, since every return object received from the Nexmo API is logged by a debug node, and it provides valuable insight into what's happening.

Sometimes the debug area can get a little crowded, making it hard to pinpoint the piece of information you're looking for. Besides that, you might want to check on your verification in between events, not having to wait for the next one to occur in order for another return object to pup up. It might have already completed, but you're not exactly sure whether it failed or completed successfully.

The good news is, there's a **`searchverify`** Nexmo node that takes care of all these concerns. Being triggered by, let's say, an **`inject`** node, it will output all available information about a past or current verification request identified by a `request_id`.

Add a **`searchverify`** node to your workspace, wire it between an **`inject`** and a **`debug`** node. In the **`searchverify`** node properties select your `Nexmo Credentials` from the drop-rown menu and fill in the `Request ID {}` field with `{{flow.request_id}}` to get details about the current verification. You could also paste in a specific `request_id` in this field, in case you wanted to check on a verification that took place before the current one.

Now when you look at the debug sidebar, after taking your app for a spin, you'll notice that every time you click on the **`inject`** node's button in your editor it will return an object with all available details about the request in question. Have a closer look at the response fields and head over to the [Nexmo API Reference](https://developer.nexmo.com/api/verify#verifySearch) to find out more about each of them.

![search verify](/content/blog/verify-phone-numbers-with-node-red/verify-searchverify.png)

### Where next?

* Nexmo Verify [API Reference](https://developer.nexmo.com/api/verify#verify-request)
* Verify [Documentation](https://developer.nexmo.com/verify/overview)

Try another tutorial:

* [How to Stream Audio into a Call with Node-RED](https://www.nexmo.com/blog/2019/07/15/stream-audio-node-red-dr)
* [How to Make Text-to-Speech Phone Calls with Node-RED](https://www.nexmo.com/blog/2019/06/14/make-text-to-speech-phone-calls-node-red-dr/)
* [How to Receive Phone Calls with Node-RED](https://www.nexmo.com/blog/2019/05/09/receive-phone-calls-node-red-dr/)
* [Announcing the Nexmo Node-RED Package](https://www.nexmo.com/blog/2019/02/21/nexmo-node-red-package-dr/)
* [How to Send SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/17/send-sms-messages-node-red-dr/)
* [How to Receive SMS Messages with Node-RED](https://www.nexmo.com/blog/2019/04/24/receive-sms-messages-node-red-dr/)