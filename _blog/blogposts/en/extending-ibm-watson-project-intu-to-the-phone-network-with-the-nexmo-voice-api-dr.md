---
title: Extending IBM Watson Project Intu to the Phone Network
description: This tutorial shows you how to integrate the Nexmo Voice API with
  Project Intu over WebSockets, and enable IBM Watson to talk to you on a mobile
  phone!
thumbnail: /content/blog/extending-ibm-watson-project-intu-to-the-phone-network-with-the-nexmo-voice-api-dr/intu.png
author: tomomi
published: true
published_at: 2017-01-04T17:18:08.000Z
updated_at: 2021-05-17T12:56:47.975Z
category: tutorial
tags:
  - voice-api
  - ibm
  - websockets
comments: true
redirect: ""
canonical: ""
---
You probably already know about the amazing IBM Watson. In case you don't, it is a cognitive technology that can think like a human, using a combination of AI (artificial intelligence) and sophisticated analytical software. With Watson, you can analyze and interpret all of your data, including text, images, audio and video.

Recently at the [Watson Developer Conference](http://www.ibm.com/watson/developer-conference/) in San Francisco, IBM announced the experimental program [Project Intu](https://www.ibm.com/watson/developercloud/project-intu.html), which enables developers to extend cognitive capabilities to new form factors, such as robots, drones, Macs, Raspberry Pi, etc.

We at Nexmo have been working with the team at IBM on an integration of Intu and the PSTN network using the Nexmo Voice API. With this integration, Watson’s capabilities can be extended to reach billions of people who have access only to a telephone!

First, watch this video that shows Watson in action as a concierge! <a href="https://vimeo.com/191573147">Watson Making a Phone Call to Reserve a Table at a Restaurant</a> from <a href="https://vimeo.com/nexmo">Nexmo</a> on <a href="https://vimeo.com">Vimeo</a>.

In this tutorial, I am going to show you how to set up the Nexmo Voice Connector for Project Intu and enable Watson to have a conversation with you over a mobile phone!

### Before You Start

You must have:

* A Mac or Windows laptop ([Detailed specs](https://github.com/watson-intu/self-sdk))
* A microphone (either built-in or external)

This tutorial is also available as a video screencast.<a href="https://vimeo.com/194215252">Getting Started with IBM Watson Project Intu &amp; Integrating It with Voice API</a> from <a href="https://vimeo.com/nexmo">Nexmo</a> on <a href="https://vimeo.com">Vimeo</a>.

<sign-up number></sign-up>

## Hello World with IBM Intu

First, go to the [Intu Gateway](https://rg-gateway.mybluemix.net/) and create an account or log in with your [IBM Bluemix](https://www.ibm.com/cloud-computing/bluemix/) account if you already have one.

![IBM Watson Intu - Gateway](/content/blog/extending-ibm-watson-project-intu-to-the-phone-network/ibm-watson-intu-gateway-login.png)

When you've logged in, you will be asked to create an **Organization Name**. For this demo, use "Nexmo".

![IBM Watson Intu - Registration](/content/blog/extending-ibm-watson-project-intu-to-the-phone-network/ibm-watson-intu-gateway-org.png)

### Downloading Intu

After you've created an organization, you should automatically be taken to the Download page. If not, manually navigate to **DOWNLOADS** and then click "Download Intu Tooling" to download the application to your desktop.

![IBM Watson Intu - Download](/content/blog/extending-ibm-watson-project-intu-to-the-phone-network/ibm-watson-intu-download.png)

Next, extract the Intu-Tooling-OSX64 or Intu-Tooling-Win64 directory, and copy the entire directory into your home directory:

For Windows users: `C:\Users\username` ("username" should read your name)

For Mac users: `/Users/username` ("username" should read your name)

Now, if you're on Windows, double-click to launch **Intu Manager**. For security reasons, Macs won’t allow you to open it by double-clicking. So you Mac users need to right-click to open.

You should see a dialog box.

![IBM Watson Intu - app-dialog](/content/blog/extending-ibm-watson-project-intu-to-the-phone-network/ibm-watson-intu-app-dialog.png)

Select **Windowed** checkbox and click **Play!**

### Installing Intu

Now, you should see the Into Manager screen.

![IBM Watson Intu - app-install](/content/blog/extending-ibm-watson-project-intu-to-the-phone-network/ibm-watson-intu-app-install.png)

Click **Install Intu**. Intu Tooling will start to install, and a new page will open in your browser for you to log in.

After you log in, wait until you see the prompt to return to the Intu Manager application. At that point, return back to the Intu Tooling application.

When you are asked where you want to install Intu, choose on **Local Machine** for this exercise and then click **Next**. Installing Intu takes a few minutes.

The Intu Manager window will display and prompt you to select your Group. Select your organization and then click **Next**. Turn the device on if it is not automatically turned on (shown in green).

![IBM Watson Intu - App launch](/content/blog/extending-ibm-watson-project-intu-to-the-phone-network/ibm-watson-intu-app.png)

When finished installing, you can start talking to Intu. Try "Hi, “How are you doing?” You will hear the Intu greeting.

If you click the button above the device, a wireframe of a brain appears. You will also see a Menu on the bottom left of the window.

![IBM Watson Intu - app brain](/content/blog/extending-ibm-watson-project-intu-to-the-phone-network/ibm-watson-intu-app-brain.png)

Intu is now installed successfully and you’ve connected the Intu Manager to your running instance!

To log out, you can click the **Logout** button from the menu. This will shut down the app. You also need to log off from the terminal to kill the process.

## Customizing Intu to Call Your Phone

Now you are going to need a Nexmo account. [Sign up](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav) if you haven’t got one.

After you sign up and log in, go to **Dashboard** then **Settings** &gt; **API Settings** and get the API Key and API Secret. You’ll need them later.

To add credit to your account and remove Nexmo account restrictions so the Telephony service can automatically provision a U.S. phone number for your device, you need to activate your account with a special coupon code.

Email [devrel@nexmo.com](mailto:devrel@nexmo.com) to ask for a Nexmo coupon for Intu. Be sure to include your Nexmo API Key in the email so that Nexmo can verify your signup.

After you get a coupon from us, activate the coupon code on your Dashboard by clicking the dropdown menu from the top right and selecting **Coupons**. Enter your coupon there and submit.

Go back to **Intu Gateway** at [rg-gateway.mybluemix.net ](https://rg-gateway.mybluemix.net)and navigate to **Manage** > **Services**, then select your organization and a group:

![IBM Watson Intu - manage](/content/blog/extending-ibm-watson-project-intu-to-the-phone-network/ibm-watson-intu-manage.png)

Click **+ Add Service**. You will see the modal dialog box. Fill out each field with these values:

1. Service Name: specify **TelephonyV1**
2. User ID: enter your API key
3. Password: enter your API Secret
4. Service Endpoint: specify: **ws://nexmo-watson.mybluemix.net/ws-embodiment**

Then **Save.**

Make sure TelephonyV1 has been added as a service and then restart the Intu Manager application to enable it.

### Enabling the Telephony Service

Locate the plans directory where you will be modifying your plan. The path should be:

For Mac users: `/Applications/IBM/Self/latest/etc/shared/plans`

For Windows users: `C:\Users\username\AppData\LocalLow\IBM\Self\latest\etc\shared\latest\plans`

Open the **default.json** and browse the JSON to familiarize yourself with it. You will notice there are sets of preconditions (the key is `m_PreConditions`) that must be answered for that plan to execute.

Now, let’s edit the JSON to manually enter your mobile phone number so Watson can call you. Find where it says `outgoing_call` to change the value of the `m_ToNumber`:

```json
"m_Object": {
"Type_": "TelephonyIntent",
"m_TelephonyAction": "PROCESSING",
"m_ToNumber": "151055591234" // your number
},
```

Make sure the number starts with a country code. If you are in the U.S., it should be 1.

Now, restart Intu and then connect to NexmoParent (or your custom group name). This status icon should turn green and a new terminal window will open in the background as Intu starts running.

Ask "Can you call my number?"

Your phone should ring (if you have set everything correctly). Answer the phone and have a conversation. For instance, say "Tell me a joke." Watson will tell you a joke! You can continue the conversation with Watson over your phone!

## Exploring More

There are operational instances you can create and configure in Bluemix to use Intu, such as Conversation, Natural Language Classifier, Speech to Text, and Text to Speech.

To learn more about customizing Intu, as well as trying on other devices such as Raspberry Pi, visit the additional documentation on Watson Intu [documentations on GitHub](https://github.com/watson-intu/self-sdk)!