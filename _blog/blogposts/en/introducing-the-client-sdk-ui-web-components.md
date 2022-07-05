---
title: Introducing the Client SDK UI Web Components
description: Introduction of a set of Web Components built to integrate and make
  it easier to work with the Client SDK with some sample examples.
thumbnail: /content/blog/introducing-the-client-sdk-ui-web-components/client-sdk-ui-web-components_1200x627.png
author: dwanehemmings
published: true
published_at: 2021-04-23T09:53:11.739Z
updated_at: 2021-04-16T18:12:30.034Z
category: announcement
tags:
  - WebComponent
  - ClientSDK
  - UI
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
For a little while, there have been a lot of [Web Component-related posts](https://learn.vonage.com/authors/dwanehemmings/) created on this site, from building a Web Component to using that same component in different frameworks and libraries. All of that has led to the announcement of the [Vonage Client SDK UI Web Components](https://github.com/nexmo-community/clientsdk-ui-js)!

## What?

We have been building Web Components that are integrated with the [Vonage Client SDK](https://developer.nexmo.com/client-sdk/overview) that can be used with or without JavaScript frameworks or libraries. The growing list of components can be found in the [GitHub repository](https://github.com/nexmo-community/clientsdk-ui-js).

## Why?

The goal of the Vonage Client SDK UI Web Components is to abstract or at least minimize the work a developer needs to integrate our Client SDK into their application. Imagine creating a fully functional chat application by placing UI components in the layout you choose. Just pass in the Conversation and each Web Component handles its responsibilities. Can’t picture it, no worries, here’s an actual image:

![Screenshot of a chat application built with the Vonage Client SDK UI Web Components with the sections highlighted and labeled with the components.](/content/blog/introducing-the-client-sdk-ui-web-components/wc-chat-layout-highlight.jpg "Sample Chat Application built with the Vonage Client SDK UI Web Components")

For example, to create your own sample chat app, use this [Glitch project](https://glitch.com/edit/#!/remix/boggy-luminous-fish?path=README.md).

## How?

Since the [Vonage Voice API](https://developer.nexmo.com/voice/voice-api/overview) has become General Availability, here is how to integrate the Keypad Web Component into our existing [Making an in-app voice call tutorial](https://developer.nexmo.com/client-sdk/tutorials/app-to-phone/introduction/javascript) - the only change comes in the [Create a client side application](https://developer.nexmo.com/client-sdk/tutorials/app-to-phone/client-sdk/app-to-phone/main-screen/javascript) step. 

Replace the current code for the `client_js.html` file with this:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <!-- import Web Components -->
  <script src="https://unpkg.com/@webcomponents/webcomponentsjs@latest/webcomponents-loader.js"></script>
  <script type="module" src="https://unpkg.com/@vonage/vc-keypad@latest/vc-keypad.js?module"></script>
  
  <script src="./node_modules/nexmo-client/dist/nexmoClient.js"></script>
  <style>
    input, button { font-size: 1rem; }
    #hangup { display:none; }
  </style>
</head>
<body>
  <h1>Call Phone from App</h1>
  <vc-keypad placeholder="i.e. 14155550100" actionText="Call" cancelText="Hang up"></vc-keypad>
  <div id="status"></div>
  <script>
    const USER_JWT = "PASTE YOUR JWT HERE";
    const keypadRef = document.querySelector("vc-keypad");
    const statusElement = document.getElementById("status");

    new NexmoClient({ debug: true })
      .createSession(USER_JWT)
      .then(app => {
        keypadRef.addEventListener("digits-sent", event => {
          console.log(event.detail.digits);
          if (event.detail.digits !== ''){
            app.callServer(event.detail.digits);
            keypadRef.createAction();
          } else {
            statusElement.innerText = 'Please enter your phone number.';
          }
        });

        app.on("member:call", (member, call) => {
          keypadRef.addEventListener("action-ended", event => {
            call.hangUp();
          });
        });

        app.on("call:status:changed",(call) => {
          statusElement.innerText = `Call status: ${call.status}`;
          if (call.status === call.CALL_STATUS.COMPLETED){
            keypadRef.cancelAction();
          }
        });
      })
      .catch(console.error);
    </script>
</body>
</html>
```

> Note: Don't forget to re-add the generated user JWT.

The client webpage should look something like this:

![Screenshot of the Making an in-app voice call tutorial with the Vonage keypad Web Component integrated](/content/blog/introducing-the-client-sdk-ui-web-components/app-to-phone-with-keypad.jpg "Using the Vonage keypad Web Component in the Making an in-app voice call tutorial")

A React implementation of the Keypad Web Component is covered in this [blog post](https://learn.vonage.com/blog/2020/10/07/using-web-components-in-a-react-application-dr/).

## When?

An early working version is now available in a [Vonage Community GitHub repository](https://github.com/nexmo-community/clientsdk-ui-js). We welcome contributions, ideas, and feedback so, please take a look.
