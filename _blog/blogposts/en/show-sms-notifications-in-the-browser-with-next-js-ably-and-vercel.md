---
title: Show SMS Notifications in the Browser with Next.JS, Ably, and Vercel
description: Use the Vonage SMS API, the Ably realtime messaging platform,
  Next.js and Vercel to receive SMS messages in the browser in realtime as they
  are received.
thumbnail: /content/blog/show-sms-notifications-in-the-browser-with-next-js-ably-and-vercel/ably_vonage_1200x600.png
author: jo-frank
published: true
published_at: 2021-04-27T13:17:18.578Z
updated_at: 2021-04-26T16:03:02.879Z
category: tutorial
tags:
  - ably
  - vercel
  - nextjs
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
The [Vonage SMS API](https://developer.vonage.com/messaging/sms/overview) allows you to send and receive text messages worldwide using a virtual number that you can rent from Vonage.  

In this tutorial, you'll use the Vonage SMS API, the Ably realtime messaging platform, Next.js and Vercel to receive SMS messages in the browser in realtime as they are received.

Follow along to learn how to:

* [Create a brand new Next.js application](#newnextjsapp)
* [Create an Ably account and get an API key](#ablycreds)
* [Create a Next.js Vercel Serverless API](#ablyandvercel)
* [Get a virtual phone number using Vonage](#buynumber)
* [Configure Vonage to forward SMS data as a webhook](#receivesms)
* [Use React Functional components and React Hooks with Ably](#reactandably)
* [Host your app on Vercel](#hosting)

### Dependencies

<sign-up number></sign-up>

To build this app, you will also need:

* **An Ably account** for sending messages: [Create an account with Ably for free](https://www.ably.io/signup).
* **A Vercel Account** for hosting on production: [Create an account with Vercel for free](https://vercel.com/signup).
* **Node 12** (LTS) or greater: [Install Node](https://nodejs.org/en/).

### <a name="ablycreds">Local Dev Pre-requirements</a>

You'll need an API key from Ably to authenticate with the Ably service. To get an API key, once you have [created an Ably account](https://www.ably.io/signup):

1. Visit your [app dashboard](https://www.ably.io/accounts/any) and click on "Create New App".
2. Give the new app a name
3. Copy the Private API key once the app has been created. Keep it safe, as this is how you will authenticate with the Ably service.

Vercel provides some Next.js command-line tools to help us. They don't need to be installed on your system as they're executed using `npx`.

## WebSockets in Vercel with Ably

![Vercel and Websockets](https://cdn.glitch.com/0cb30add-c9ef-4c00-983c-e12deb0d4080%2Fvercel-websockets.png?v=1610475709091)

Vercel is a hosting platform built from the ground up to host Next.js apps and Serverless Functions. It allows users to deploy [Serverless Functions](https://vercel.com/docs/serverless-functions/introduction), which are essentially just blocks of code that respond to an HTTP request.\
However, these functions have a maximum execution timeout, which means that it is impossible to maintain a WebSocket connection this way. 

This is where Ably comes in. The client can connect to an [Ably Channel](https://www.ably.io/documentation/realtime/channels) and send and receive messages on it to add Realtime functionality to your app by managing your WebSocket connections for you. We'll go over how to build an app that uses realtime functionality in this walkthrough. If you want to learn more about WebSockets in Next.js and Vercel, check "[Building a realtime chat app with Next.js and Vercel](https://ably.com/blog/realtime-chat-app-nextjs-vercel)".

## Building the Realtime Sms App

#### <a name="newnextjsapp">To Create the Starter App:</a>

1. In your terminal, type `npx create-next-app` to create an empty Next.js app.
2. Create a file called `.env` in the root of the directory; this is where we'll put the project's environment variables.
3. Add your Ably API key to the .env file:

```
ABLY_API_KEY=your-ably-api-key:goes-here
```

4. Navigate to your Next.js application directory and type into the console:

```bash
npm run dev
```

The Next.js dev server will spin up, and you'll see an empty Next.JS starter app. You'll build our sms-in-the-browser app on top of this.

## Realtime Pub/Sub Messaging With Ably

This app uses [Ably](https://www.ably.io/) for [pub/sub messaging](https://www.ably.io/documentation/core-features/pubsub) between the users. Pub/Sub stands for Publish and Subscribe, and it is a popular pattern used for realtime data delivery. The app will send, or `publish`, messages over an [Ably Channel](https://www.ably.io/channels). The clients using the app will be `subscribed` to the channel and will be able to receive the messages.

### Authentication with the Ably Service

Vercel Next.js apps don't run traditional "server-side code". However, you can add JavaScript files to `/pages/api/*`, and the Vercel deployment engine will treat each one as an API endpoint and manage them as serverless functions for you.

For local development, the Next.js tools run these functions in a Node server, so they work as you would expect in your local dev environment. You're going to add a Next.js / Vercel serverless function to the starter code that you created earlier to authenticate your app with Ably and make it possible to start sending and receiving messages over the Ably service.

### <a name="ablyandvercel">Writing the Serverless Function to Connect to Ably</a>

You'll need to install the [Ably npm package](https://www.npmjs.com/package/ably/v/1.2.5-beta.1) (it's essential you're running Ably 1.2.5+ for this app, for compatibility with Vercel). 

In the terminal, in the root of your new app, run:

```bash
npm install ably@1.2.5-beta.1
```

Next, create a file called `./pages/api/createTokenRequest.js` into which add the following code:

```js
import Ably from "ably/promises";

export default async function handler(req, res) {
    const client = new Ably.Realtime(process.env.ABLY_API_KEY);
    const tokenRequestData = await client.auth.createTokenRequest({ clientId: 'ably-nextjs-demo' });
    res.status(200).json(tokenRequestData);
};
```

This serverless function uses the Ably SDK to create a `tokenRequest` with your API key. You will use this token later - it allows you to keep your "real" API key safe while using it in the Next.js app.\
By default, this API is configured to be available on `http://localhost:3000/api/createTokenRequest`.
You're going to provide this URL to the Ably SDK in your client to authenticate with Ably.

## <a name="receivesms">Receiving an SMS Using Vonage and Vercel</a>

Vonage allows you to configure mobile phone numbers in their API dashboard. When an SMS is received, it will trigger your API.

To do this, you need to add a `Vercel Serverless function` to our Next.js app. This serverless function will get called by Vonage each time an SMS is received (once you set up a phone number!). You need to put some code in this function to unpack the SMS message, then send it to your React app using an `Ably channel`.

This process is quite similar to the setup for your Ably `createTokenRequest`. 

Create a file called `./pages/api/acceptWebhook.js` into which add the following code:

```js
import Ably from "ably/promises";

export default async function handler(req, res) {

    // Unpack the SMS details from the request query string
    const incomingData = getSmsDetails(req, res);

    // If the request was invalid, return status 400.
    if (!incomingData.success) {
        res.status(400).end();
        return;
    }

    // Create an Ably client, get your `sms-notifications` channel
    const client = new Ably.Realtime(process.env.ABLY_API_KEY);
    const channel = client.channels.get("sms-notifications");

    // Publish your SMS contents as an Ably message for the browser
    await channel.publish({ name: "smsEvent", data: incomingData });

    // Return the received data as a 200 OK for debugging.
    res.send(incomingData);
    res.status(200).end();
};

function getSmsDetails(req, res) {

    const params = req.query;

    if (!params.to || !params.msisdn) {
        console.log('This is not a valid inbound SMS message!');
        return { success: false };
    }

    return {
        success: true,
        messageId: params.messageId,
        from: params.msisdn,
        text: params.text,
        type: params.type,
        timestamp: params['message-timestamp']
    };
}
```

We're going to move back to the app for now, but we'll come back to this function at the end once the app is deployed to `Vercel` and your function has a `public url`.

## Reacting to SMS Messages with the SmsComponent

Pages in `Next.js` are React components, so the `pages/index.js` home page is the React component that contains the page layout.

This is the default page generated by `create-next-app`; you'll add your component to this - the app logic is contained inside `SmsComponent.jsx`.

Start off by referencing the imports you'll need at the top of the file:

```jsx
import React, { useEffect, useState } from 'react';
import { useChannel } from "./AblyReactEffect";
import styles from './SmsComponent.module.css';
```

Then define the function that will be exported as a React component.

```jsx
const SmsComponent = () => {
    
  let messageEnd = null;

  const [receivedMessages, setMessages] = useState([]);
```

and use your first `react hook`:

```jsx
  const [channel, ably] = useChannel("sms-notifications", (message) => {
    const history = receivedMessages.slice(-199);
    setMessages([...history, message]);
  });
```

`useChannel` is a [react-hook](https://reactjs.org/docs/hooks-intro.html) style API for subscribing to messages from an Ably channel. You provide it with a channel name and a callback to be invoked whenever a message is received.

Next, you're going to format the data for the screen so that each message can be displayed, along with the time it arrived and the sender's phone number.

```jsx
   const messages = receivedMessages.map((message, index) => {
    console.log(message);
    let from = [message.data.from.slice(0, 2) + " " + message.data.from.slice(2, 6) +  " " + message.data.from.slice(6, 9) + " "+ message.data.from.slice(9)];
    let date = new Date(message.data.timestamp);
    let day = date.toDateString().replace(/^\S+\s/,'');
    let time = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

    return (
      <div key={index} className={styles.message}>
        <span className={styles.from}>{from}</span>
        <span className={styles.when}>{day}, {time}</span>
        <span className={styles.text}>{message.data.text}</span>
      </div>
    );
  });
```

Finally, create your component and return it:

```jsx
  return (
    <div className={styles.chatHolder}>
      <h1 className={styles.title}>Text Messages</h1>
      <div className={styles.chatText}>
        {messages}
        <div ref={(element) => { messageEnd = element; }}></div>
      </div>
    </div>
  )
}
```

Right at the bottom of the file, the function is exported as `SmsComponent` so that it can be referenced in the Next.js index page.

### <a name="reactandably">Using Ably Correctly in React Components</a>

One of the trickier parts of using Ably with React Functional Components is knowing when and where to create the instance of the SDK and when and where to connect to your channel(s). You will want to avoid instancing the SDK when the component is rendered, as this could make multiple connections and burn through your Ably account limits.

To make sure that the app handles component redrawing, mounting and unmounting correctly - `AblyReactEffect` exports a [React Hook](https://reactjs.org/docs/hooks-intro.html) to interact with the Ably SDK.

React hooks can seem a little unusual the first time you use them. A hook is a function which:

* Executes the functionality that you'd expect `componentDidMount` to run
* Returns *another* function that will be executed by the framework where `componentDidUnmount` would be called
* Performs any other behaviour it needs to

This React Hook is built upon `useEffect`. When referenced, it creates an instance of the Ably SDK (it does this only once) which is configured to use the `URL` of your Serverless function to `createTokenRequest` for authentication:

```js
import Ably from "ably/promises";
import { useEffect } from 'react'

const ably = new Ably.Realtime.Promise({ authUrl: '/api/createTokenRequest' });
```

Instancing the Ably library outside the scope of the component means it is only created once and will keep your limit usage down.

Next, you need to create the function you're going to export, your hook, to use it in your component.
Let's call it `useChannel`; it will require the channel name and a callback as arguments. Each time `useChannel` is called, you [`get` the requested channel](https://www.ably.io/documentation/realtime/channels#obtaining-channel) from the Ably-JS SDK and prepare the hook functions.

* **onMount** is the code run each time your component is rendered. Inside onMount, you will subscribe to the specified channel, triggering `callbackOnMessage` whenever a message is received. 
* **onUnmount** is the code run whenever the component is unmounted before it is re-rendered. Here you will unsubscribe from the channel, which will stop accidental multiples of connections, again saving our account limits.
* **useEffectHook** is a function that calls these functions correctly, returning onUnmount for React to use.

The exported Hook in `AblyReactEffect.js` will look like this: 

```js
export function useChannel(channelName, callbackOnMessage) {
    const channel = ably.channels.get(channelName);

    const onMount = () => {
        channel.subscribe(msg => { callbackOnMessage(msg); });
    }

    const onUnmount = () => {
        channel.unsubscribe();
    }

    const useEffectHook = () => {
        onMount();
        return () => { onUnmount(); };
    };

    useEffect(useEffectHook);

    return [channel, ably];
}
```

The `useChannel` Hook returns both the current Ably channel and the Ably SDK for the calling code to use to send messages. This hook encapsulates Ably pub/sub for React functional components in one place, so you don't need to worry about it elsewhere, and the code that uses it can process the messages it receives.

### Making Everything Look Beautiful With Module CSS - `SmsComponent.module.css`

When writing the chat component, you might have noticed that `Next.js` has some compiler enforced conventions that dictate where you keep your CSS and how to import it.

For this app, create a CSS file with the same name as the `.jsx` file, just with the extensions `.module.css`; this keeps the management of the component easier. If you want to delete this component in the future, it is nice and simple to remove its CSS as well.  

Once created, it can be imported into the component:

```js
import styles from './SmsComponent.module.css';
```

When creating a CSS class on a JSX element, use the following syntax on the element:

```js
 className={styles.yourClassName}
```

and the accompanying CSS would look like this:

```css
.yourClassName {
  styles: gohere;
}
```

## <a name="hosting">Hosting on Vercel</a>

We're using `Vercel` as our development server and build pipeline.

> The easiest way to deploy Next.js to production is to use the Vercel platform from the creators of Next.js. Vercel is an all-in-one platform with Global CDN supporting static & Jamstack deployment and Serverless Functions.
> <cite>-- [The Next.js documentation](https://nextjs.org/docs/deployment)</cite>

To deploy your new sms-in-the-browser app to Vercel, you'll need to:

1. Create a [GitHub account](https://github.com/) (if you don't already have one)
2. [Push your app to a GitHub repository](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/creating-a-new-repository)
3. [Create a Vercel account](https://vercel.com/signup)
4. Create a new Vercel app and import your app from your GitHub repository. (This will require you to authorise Vercel to use your GitHub account)
5. Add your `ABLY_API_KEY` as an environment variable
6. Watch your app deploy
7. Visit the newly created URL in your browser!

## <a name="buynumber">Setting Up an SMS Number for Your App</a>

To receive SMS messages, you'll need to rent a virtual phone number from Vonage and configure it.

First, log in to your Vonage account by visiting the [dashboard](http://dashboard.nexmo.com/).
Once you've created and verified your account, you can buy a number by going to Numbers => Buy Numbers. Search for a number that works for you and add some credits to pay for the number.

Once you've purchased your number, you need to configure the `SMS Inbound Webhook URL`.

Do this by going to Numbers => Your Numbers => Clicking the pen icon.

You'll be greeted with a modal dialog box, and you need to put your `acceptWebhook` API URL into the box.

If your Vercel app is called `your-vercel-app`, the webhook URL would be `https://your-vercel-app.vercel.app/api/acceptWebhook`.

## Make It Yours!

[This demo](https://github.com/ably-labs/sms-in-the-browser) is open-source, fork it and make it your own. Don't forget to show us what you build [@ablyRealtime](https://twitter.com/ablyrealtime).

If you're looking for ways to extend this project, you could consider:

* Building a televoting app
* Adding a database to store messages
* Adding the ability to send a response text.

## Let us Know

If this tutorial was helpful, or you're using Next.js and Ably in your project, we'd love to hear about it. Drop us a [message on Twitter](https://twitter.com/ablyrealtime) or email us at [devrel@ably.io](mailto:devrel@ably.io).