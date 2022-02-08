---
title: Build a Facebook Messenger Bot with Messages API and Dialogflow
description: "Learn how to implement a Facebook Messenger bot on your Facebook
  page using the Vonage Messages API and the Google Dialogflow service. "
thumbnail: /content/blog/build-a-facebook-messenger-bot-with-messages-api-and-dialogflow/dialogflow_facebook-messenger.png
author: martyn
published: true
published_at: 2018-10-16T14:46:18.000Z
updated_at: 2021-12-07T08:23:16.061Z
category: tutorial
tags:
  - chatbots
  - javascript
  - messaging-api
comments: true
redirect: ""
canonical: ""
---
*Post updated by[ Amanda Cavallaro](https://learn.vonage.com/authors/amanda-cavallaro/)*

In this tutorial, you are going to learn how to implement a Facebook Messenger bot on your Facebook page using the [Vonage Messages API](https://developer.vonage.com/messages/overview) and the [Google Dialogflow](https://dialogflow.com) service.

This example is going to take inbound messages sent either via the 'Send Message' button on a Facebook page, or via the Facebook Messenger app. Both will work just fine.

Messages will be routed through our app to the Google Dialogflow service which will generate responses to questions and then send these back via the Vonage Messages API.

In this example, we're using the [prebuilt *Small Talk* agent](https://cloud.google.com/dialogflow/es/docs/agents-small-talk) in Dialogflow that will respond with chirpy answers to inbound questions and is great for development purposes.

You can download and run this code for yourself from the [nexmo-community/nexmo-messages-facebook-dialogflow](https://github.com/nexmo-community/nexmo-messages-facebook-dialogflow) repository on GitHub.

## Prerequisites

You'll need to create accounts to run this for yourself, so make sure you have the following set up:

* A Facebook account with a brand/business page you can use for testing
* A [Google Dialogflow](https://dialogflow.com) account
* [Ngrok](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) (so the outside world can access the app on your local machine)
* The [Vonage Command Line Interface](https://github.com/Vonage/vonage-cli)

<sign-up number></sign-up>

The code for this example is built using [Node.js](https://nodejs.org) and the [Koa framework](https://koajs.com). It will work on any version of Node.js 7.6.0 or above.

You can check your version of Node by running `node -v` on your command line. If the number is 7.6.0 or higher then you're good to go. If it isn't then there are some extra steps that Koa would like you to take (see the installation section of [this page](https://koajs.com/#introduction)).

## Create the Skeleton Application

In order to receive messages coming in from Facebook, you need to have two webhooks set up that allow the app to receive data about messages and delivery statuses.

We'll start by building the basic application with these two routes.

In a new folder, initalise a new Node.js application by running

```bash
npm init -y
```

Next, install the dependencies for the project:

```bash
npm i koa koa-route koa-bodyparser @vonage/server-sdk@beta dialogflow
```

Additionally, we'll be using the excellent [Nodemon](https://github.com/remy/nodemon) and [DotEnv](https://github.com/motdotla/dotenv) packages to keep our app up and running whilst changes are made so you don't have to keep restarting it. Install these as `devDependencies`.

```bash
npm i -D nodemon dotenv
```

Finally, add a little folder structure by creating `routes` and `controllers` folders in the root of your directory.

```bash
mkdir routes controllers
```

### Create the Koa Server

[Koa](https://koajs.com) is a framework for Node.js written by the creators of [Express](https://expressjs.com/). It's lightweight and comes with only a basic set of features out of the box which makes it perfect for creating a small webhook server like the one we need here.

Create the main file for the server by adding a new file in your root directory called `server.js`.

In this new file, add the following code:

```javascript
const Koa = require('koa');
const router = require('koa-route');
const bodyParser = require('koa-bodyparser');
const routes = require('./routes');
const port = process.env.PORT || 3000;

// Set up a new Koa app and tell it to use
// the bodyParser middleware for inbound requests
const app = new Koa();
app.use(bodyParser());

// Routes
app.use(router.post('/webhooks/status', routes.status));
app.use(router.post('/webhooks/inbound', routes.inbound));

// Have the app listen on a default port or 3000
app.listen(port, () => console.log(`App is waiting on port ${port}`));
```

The `routes` constant is used to store and access the routes in the application:

```javascript
const routes = require('./routes');
```

We're also going to need a new file in the `routes` folder called `index.js`. Go ahead and create that, and add the following code:

```javascript
const routes = {
  inbound: async ctx => {
    // Get the detail of who sent the message, and the message itself
    const { from, message } = ctx.request.body;
    console.log(from, message);
    ctx.status = 200;
  },
  status: async ctx => {
    const status = await ctx.request.body;
    console.log(status);
    ctx.status = 200;
  }
};

module.exports = routes;
```

With that in place, run the following command to start up the server:

```bash
nodemon server.js
```

The app will launch on port `3000`.

Use Ngrok to open up this port to the world and make note of the URLs it produces for you.

![Ngrok output](https://cl.ly/962fe109ab90/Image%202018-10-15%20at%201.52.51%20pm.png)

[Here is a handy guide to working with Ngrok](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) if you haven't used it before.

TLDR? You can start up Ngrok (if installed) by running this command:

```bash
ngrok http 3000
```

## Create a Messages & Dispatch Application

Set up a new Messages & Dispatch application via the [Vonage Dashboard](https://dashboard.nexmo.com/messages/create-application).

Make sure that you append `/webhooks/inbound` and `/webhooks/status` to the URL you get from Ngrok when you paste them into the form (like in the image below).

![Webooks](/content/blog/build-a-facebook-messenger-bot-with-messages-api-and-dialogflow/webhooks.png)

Remember to also click the *Generate public/private key pair* link. This will download a file called `private.key`.

Locate the `private.key` file on your system and move it to the root folder for your application.

Finalise the app set up by clicking the *Create Application* button and you're done with config.

Make a note of your Application ID, you'll need it in the next step.

## Connect the Messages API to Facebook

In order for Facebook to be aware of your newly created app, you need to connect them together.

First, you'll need to create a [JSON Web Token](https://en.wikipedia.org/wiki/JSON_Web_Token) to authorise Facebook to use your application, you can do this with the [Vonage CLI](https://github.com/Vonage/vonage-cli).

Open your terminal and ensure that you are at the root of your application folder.

Using the [Vonage CLI](https://github.com/Vonage/vonage-cli) run the following command:

```bash
JWT="$(vonage jwt --key_file=private.key --app_id=VONAGE_APPLICATION_ID)"
```

Be sure to replace `VONAGE_APPLICATION_ID` with the ID of the application you just created.

Running this command will result in a big string of letters and numbers - this is your JSON Web Token. Copy the whole thing.

You can then view the JWT with:

```bash
echo $JWT
```

To connect your Facebook page to your app, we've created a handy page:

[Connect Facebook Page](https://dashboard.nexmo.com/messages/social-channels/facebook-connect)

Complete the following steps:

* Login with your Facebook credentials.
* Select the Facebook page you want to connect to your Vonage app.
* Click *Complete Setup.*

If all is well, you'll see a green dialog pop up congratulating you on your success, and letting you know the ID of your Facebook page.

Make a note of this ID.

You can verify the content of your JWT by using [jwt.io](https://jwt.io).

*Note: If any element of this wasn't clear, there's a [guide to creating JWTs for use in this context](https://developer.vonage.com/messages/tutorials/send-fbm-message/introduction#generate-a-jwt) in our Facebook Messenger tutorial.*

## Test the Connection

Your application is now connected to your Facebook page.

With your server still running, and Ngrok still exposing it to the world, head over to your Facebook page and locate the messaging button.

![Facebook Messenger Button](https://cl.ly/f38ca8b97869/Image%202018-10-15%20at%2011.41.51%20am.png)

Click it to open the messaging window and start sending some wonderful missives. Alternatively, just start with *'Hello'*.

Any message you send will be passed along to the Inbound Webhook you specified in your application set up. This maps directly to the `inbound` function in the `routes.js` file.

Currently, the `inbound` function is set to log the `from` and `message` portion of what is being sent from Facebook out to the console.

You should see your messages appearing in the console.

![Messages appearing in the console](https://cl.ly/214e6369e5cd/Image%202018-10-15%20at%2011.53.28%20am.png)

## Send the Messages to Dialogflow

Now that your stunning wordplay is being received by the application, it's time to send it over to Dialogflow to get some equally pithy responses back.

In the `controllers` folder, create a new file called `dialogflow.js` and add the contents of the JavaScript file [controllers/dialogflow.js](https://raw.githubusercontent.com/nexmo-community/nexmo-messages-facebook-dialogflow/master/controllers/dialogflow.js).

The exported function in the file achieves the following:

* An async function called `dialogflowHandler` is instantiated and it accepts a param called `query`.
* An object called `request` is created, containing all the keys that Dialogflow expects.
* The request object is sent to Dialogflow.
* The reply from the Small Talk agent, contained within `result[0].queryResult.fulfillmentText` is returned.

```javascript
const dialogflowHandler = async query => {
  // Create a text query request object
  const request = {
    session: sessionPath,
    queryInput: {
      text: {
        text: query,
        languageCode: languageCode
      }
    }
  };

  // Send the text query over to Dialogflow and await the result
  // using .catch to throw any errors
  const result = await sessionClient
    .detectIntent(request)
    .catch(err => console.error('ERROR:', err));

  // Pick out the response text from the returned array of objects
  const reply = await result[0].queryResult.fulfillmentText;

  // Return the reply
  return reply;
};

module.exports = dialogflowHandler;
```

To make use of this `dialogflowHandler` function, open the `routes/index.js` file and require it at the top:

```javascript
const dialogflowHandler = require('../controllers/dialogflow');
```

Modify the `inbound` function so it looks like this:

```javascript
inbound: async ctx => {
  const { from, message } = await ctx.request.body;

  console.log(from, message);

  const dialogflowResponse = await dialogflowHandler(message.content.text);

  console.log(dialogflowResponse);

  ctx.status = 200;
};
```

Send a new message (something akin to 'Hello!') from your Facebook page (or via your Facebook Messenger app).

This time you'll see the incoming message being logged to the console, as well as the response coming back from Dialogflow.

![Reponse from Dialogflow](https://cl.ly/16d34b88573e/Image%202018-10-15%20at%2012.25.39%20pm.png)

*Note: If you need help setting up Dialogflow, follow the [SmallTalk Prebuilt Agent](https://cloud.google.com/dialogflow/es/docs/agents-small-talk) guide.*

## Send the Reply Using the Messages API

You're almost close to completion. Here is what has been achieved so far.

* Set up the Koa server ✔️
* Set up a new Vonage App ✔️
* Connected the app to a Facebook Page ✔️
* Test for incoming messages ✔️
* Send incoming messages to Dialogflow and get a response ✔️

The final piece in this puzzle is to take the response that Dialogflow returns and send it back to the user as a reply to their message.

The [Vonage Messages API](https://developer.vonage.com/messages/overview) will handle all of this for us.

Create a new file in the `controllers` folder called `vonage.js` and populate it with the contents of this file:  [controllers/vonage.js](https://github.com/nexmo-community/nexmo-messages-facebook-dialogflow/blob/master/controllers/vonage.js).

The main function being exported in this file is called `messageResponder`.

This function uses the [Vonage Node.js Client Library](https://github.com/Vonage/vonage-node-sdk/tree/beta) to send a message back to the user.

The function is passed an object called `message` that will contain the `id` of the user to send the reply to, and the `dialogflowResponse` (the text to send in the message).

```javascript
const messageResponder = async message => {
  vonage.channel.send(
    { type: 'messenger', id: message.id }, // Who the message goes to
    { type: 'messenger', id: FBID }, // Your FBID - who the message comes from
    {
      content: {
        type: 'text',
        text: message.dialogflowResponse
      }
    },
    (err, data) => {
      console.log(data.message_uuid);
    }
  )
};
```

To make use of this `messageResponder` function import it in the `routes/index.js` file:

At the top of the file, underneath the `require` statement for the `dialogflow.js` file created earlier, add the following:

```javascript
const messageResponder = require('../controllers/vonage');
```

Then, in the `inbound` function, add the following code just above the `ctx.status = 200` line:

```javascript
messageResponder({ ...from, dialogflowResponse });
ctx.status = 200;
```

As you can see, we're passing an object into `messageResponder` and using the [spread operator](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Spread_syntax) to combine the contents of the `from` object with the response we got from Dialogflow.

This will make the object being passed to the function look like this:

```javascript
{
  type: 'messenger',
  id: '111111111111',
  dialogflowResponse: 'Greetings!'
}
```

The `id` in this instance is the ID of the user on Facebook that sent the message, so it will be different from the one above.

## The Moment of Truth

The stage is set. With that final file, the loop has been closed and any incoming message should now receive a reply straight back.

Once again, send a message from your Facebook page. The response from Dialogflow should now pop up in the same window!

## Conclusion

The prebuilt *Small Talk* agent is great for testing but the next step here would be to actually build an agent of your own that can relay some knowledge that is of some worth to the user.

For more information on getting up and running with building Dialogflow agents, check out some of these articles:

* [Build an agent from scratch using best practices](https://dialogflow.com/docs/tutorial-build-an-agent)
* [Bitesize videos from Google](https://dialogflow.com/docs) on building Dialogflow agents
* [Building Your Own Chatbot Using Dialogflow](https://tutorials.botsfloor.com/building-your-own-chatbot-using-dialogflow-1b6ca92b3d3f)

With the code from this tutorial, you have the link between Facebook and Dialoglow already in place so you can go ahead and build the mightiest agent of all time.