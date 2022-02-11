---
title: Screenshot and Save a Chatlog with Conversation API and Cloudinary
description: Build an app to take a screenshot of your desktop and Nexmo
  Conversation API chat and save that image in the cloud for easy future access
  in Cloudinary API
thumbnail: /content/blog/screenshot-and-save-a-chatlog-with-conversation-api-and-cloudinary-dr/E_Screenshot-and-Save_1200x600.png
author: laurenlee
published: true
published_at: 2019-11-29T13:50:18.000Z
updated_at: 2021-05-24T11:31:58.172Z
category: tutorial
tags:
  - cloudinary
  - conversation-api
comments: true
redirect: ""
canonical: ""
---
Imagine that in a moment of brilliance, after collaborating with teammates online, you’ve created and designed something rather impressive and now, before it flees from your memory, you need to quickly save the idea!

OR imagine that you’re chatting with a customer service help agent or bot at your favorite company. Wouldn’t it be helpful to be able to show them EXACTLY what was happening on your screen?

Do these scenarios sound familiar? *Well, you’re in luck!* Because the [Cloudinary API](https://cloudinary.com/documentation/solution_overview) allows you to swiftly upload a screenshot to the cloud, annotate the image to include key important details, as well as organize the file into tagged folders.

Combining with the Nexmo [Conversation API](https://developer.nexmo.com/conversation/overview), which offers multi-channel communication, you can quickly share your Cloudinary screenshots via chat, video, or messaging with your colleagues or customer service agent!

## Let’s Build an App

Today, in collaboration with the Cloudinary API, we’ll build an app that will allow you to take a screenshot of your desktop and a Nexmo Conversation chatlog, annotate the image with important contextual details of the conversation, and save and organize that image in the cloud for easy future access!

### The Flow of the App

<youtube id="xQWffc7bBZY"></youtube>

Within an open chatlog, if either the customer or the agent enters the word "screenshot" into the log, a screenshot is captured. That image is then annotated with key information made available from the [Nexmo Conversation API](https://developer.nexmo.com/conversation/overview) and subsequently is tagged by Cloudinary and uploaded into a folder within your portal for quick and easy access anywhere you are!

## Prerequisites

* [Cloudinary account](https://cloudinary.com/users/register/free?utm_source=nexmo&utm_medium=referral&utm_campaign=nexmo_blog&utm_term=cloudinary-api)

  <sign-up></sign-up>

This tutorial expands upon a recent blog post on [how to build an on-page live chat app](https://www.nexmo.com/blog/2019/10/18/how-to-build-an-on-page-live-chat-dr). We will add to the code that can be remixed on Glitch [here](https://glitch.com/~hoomin-chatbox).

If you would like to run it locally as opposed to using Glitch, clone [this repo](https://github.com/nexmo-community/cloudinary-conversation-API-collab) and use [Ngrok](https://ngrok.com/) to run your [webhook](https://developer.nexmo.com/concepts/guides/webhooks) server locally.

If you are not familiar with Ngrok, please refer to our [Ngrok tutorial](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) before proceeding.

Building off of the prior tutorial, your `.env` file should already be populated with your Nexmo credentials (API key, secret, application ID, private key, and support agent user ID). But if not, go ahead and follow the instructions detailed [here](https://www.nexmo.com/blog/2019/10/18/how-to-build-an-on-page-live-chat-dr).

### Add Your Cloudinary Credentials

Navigate to [Cloudinary](https://cloudinary.com/console) and sign up for a free account. Save your given Cloud Name, API key, and secret and add those to your .env file.

```
CLOUD_NAME="YourCloudName"
CLOUD_API_KEY="1234567890"
CLOUD_API_SECRET="abCdeFghIjkLmnOpqrsTuvWxyZ"
```

*Alternatively: you can use the Environment Variable `CLOUDINARY_URL` found underneath your API Secret in the console.*

### Add Cloudinary to the Code

To begin, install Cloudinary as a dependency as well as an npm library called `desktop-screenshot`.

```bash
npm install cloudinary desktop-screenshot
```

At the top of your `server.js` file, call those two:

```javascript
var cloudinary = require("cloudinary").v2;
var screenshot = require("desktop-screenshot");
```

Then set up the config for Cloudinary by referencing the credentials you just added to your `.env` file:

```javascript
cloudinary.config({
  cloud_name: process.env.CLOUD_NAME,
  api_key: process.env.CLOUD_API_KEY,
  api_secret: process.env.CLOUD_API_SECRET
});
```

All of the handlers in the `server.js` file will remain the same except for `"/webhooks/event"`. We will call the Cloudinary API within this handler.

### Take the Screenshot

The scenario now is to imagine that when a user enters the text ‘screenshot’ in the chat, an image of the desktop is taken. It then is uploaded to Cloudinary and is organized within a tagged folder within Cloudinary's portal.

Within the `app.route("/webhooks/event").post` handler, a simple `if statement` is used to kick off that logic:

```javascript
if (req.body.body.text == "screenshot") {
  screenshot("screenshot.png", function(error, complete) {
    if (error) console.log("Screenshot failed", error);
    else console.log("Screenshot succeeded");
  });
}
```

Here, the npm library `desktop-screenshot` is called, and the image is saved as "screenshot.png" locally.

Next, within that `if statement`, let’s upload that image to your Cloudinary portal:

```javascript
cloudinary.uploader.upload(
  "screenshot.png",
  {
    tags: "screenshot",
    overlay: {
      font_family: "Arial",
      font_size: 50,
      text:
        "Conversation: " +
        req.body.conversation_id +
        "Timestamp: " +
        req.body.timestamp
    }
  },
  function(error, result) {
    console.log(result, error);
  }
);
```

The referenced id and timestamp are made available via Nexmo’s Conversation API and are contextually stored within the application and user’s history.

The screenshot file is also modified with an overlay added on top of it to include the conversation ID as well as a timestamp before it is uploaded to Cloudinary. The added tag organizes the file to a particular folder called "screenshot."

![cloudinary files](/content/blog/screenshot-and-save-a-chatlog-with-conversation-api-and-cloudinary/screen-shot-2019-11-25-at-10.18.35-am.png "cloudinary files")

## Go Forth From Here

This tutorial covers just a few use cases for both Cloudinary and Nexmo. There really is so much that could be done both to the image and within the conversation. Today we’ve covered how to take a screenshot of your desktop and a Nexmo Conversation chatlog, annotate the image with important contextual details of the conversation, and save and organize that image in the cloud for easy future access.

With Cloudinary, you can do so much more to the image; You could manipulate it by cropping, enhancing, or collaging many images all into one. Go check out [the docs](https://cloudinary.com/documentation) and share with us what creative things you come up with!

And with the Nexmo [Conversation API](https://developer.nexmo.com/conversation/overview), you can combine all styles of communication, such as chat, voice, video, and messaging between multiple members all to be contextually saved within a single communication event. We encourage readers to go forth and play, explore, and create with the Conversation API and to share back with us your inventions and discoveries!

Check out this [GitHub repo](https://github.com/nexmo-community/cloudinary-conversation-API-collab) to see the final version of this Cloudinary/Nexmo app! 

*Special thanks to 🌟[Tessa Mero](https://twitter.com/TessaMero)🌟 over at [Cloudinary](https://cloudinary.com/) for collaborating on this tutorial!*