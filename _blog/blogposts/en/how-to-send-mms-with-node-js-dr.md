---
title: How to Send MMS Messages with Node.js
description: The Nexmo Messages & Dispatch API now allows you to send MMS
  (Multimedia Messaging Service) from any US shortcode number you have in your
  dashboard to other numbers within the United States. In this article you will
  learn how to send an MMS using Node.js using the official nexmo-node client
  library. Prerequisites Before you start, […]
thumbnail: /content/blog/how-to-send-mms-with-node-js-dr/send-mms-nodejs.png
author: martyn
published: true
published_at: 2019-03-26T16:01:19.000Z
updated_at: 2021-04-19T13:03:31.132Z
category: tutorial
tags:
  - messaging-api
  - node
comments: true
redirect: ""
canonical: ""
---
The Nexmo Messages & Dispatch API now allows you to send MMS (Multimedia Messaging Service) from any US shortcode number you have in your dashboard to other numbers within the United States.

In this article, you will learn how to send an MMS using Node.js using the official [nexmo-node](https://github.com/Nexmo/nexmo-node) client library.

## Prerequisites

Before you start, make sure you have the following:

- A basic understanding of JavaScript & Node.js
- Node.js installed on your machine
- A fresh US SMS & MMS capable number. You can reference our [Numbers Guide](https://developer.nexmo.com/numbers/guides/numbers) for details on how to buy a number if you don't have one.

<sign-up number></sign-up>

## Getting Started

Before we begin, let's get set up for success by taking care of a few things inside the Nexmo dashboard.

Let's start by creating a new Messages & Dispatch Application. To do this, head to the [Messages & Dispatch section](https://dashboard.nexmo.com/messages/applications) of your admin dashboard and click on *Create Application*.

![](https://cl.ly/2c9355eb99fc/Image%202019-01-14%20at%205.55.31%20pm.png)

Next, you will need to fill out the form with your application name and the required webhook URLs. 

![](https://cl.ly/bcddad2230f1/Screen%20Recording%202019-01-14%20at%2006.04%20pm.gif)

Every Messages & Dispatch application requires you to specify a `Status URL` and an `Inbound URL`. In larger, production-ready applications, you would have these pointing to a URL on your own server. For this tutorial there is no need for that, you'll just need a URL that can respond with a `200 OK` status, you can use a service such as [MockBin](http://mockbin.org) to provide what you need as I did in the example above.

In order to authenticate API requests alongside your API key and API secret you will also need a public/private key pair, which can be automatically generated for you by clicking the *Generate public/private key pair* link.

This will set a public key in the form field, and also download a `private.key` file to your machine. You will need to put this file wherever you will write the code we put together.

Finish up by clicking *Create application.* You will then be asked to select a number to use with this application by clicking the *Link* button next to your number of choice.

The final step can be skipped as *External Accounts* will not be used in this tutorial.

![](https://cl.ly/05692353092f/Image%202019-01-14%20at%206.24.50%20pm.png)

Note down the *Application ID*, it will join your API key, API secret and Private Key in the code we will work on next.

## Sending MMS using Node.js

Now that the admin is complete, let's create a Node.js script that will use the [Nexmo Node.js client library](https://github.com/Nexmo/nexmo-node) to send an MMS to a pre-set number when run.

Start by creating a new folder (and if you haven't already done so, put the `private.key` file generated earlier in it.

Run the following commands to set up a new Node.js application and to install the `nexmo-node` client library:

    npm init -y
    npm install nexmo@beta

Then create a new file called `send-mms.js`, and open it inside your editor.

Initialise a new Nexmo instance:

    const Nexmo = require('nexmo');
    
    const nexmo = new Nexmo({
      apiKey: 'YOUR_API_KEY', // Found in your Nexmo Dashboard
      apiSecret: 'YOUR_API_SECRET', // Found in your Nexmo Dashboard
      applicationId: 'YOUR_APPLICATION_ID', // Generated earlier
      privateKey: 'private.key' // Generated earlier
    });

Finally, add the code to send the MMS message using the Messages & Dispatch API:

    nexmo.channel.send(
      { type: 'mms', number: 'ADD_A_NUMBER_HERE' }, // To
      { type: 'mms', number: 'YOUR_MMS_SHORT_CODE_NUMBER' }, // From
      {
        content: {
          type: 'image',
          image: {
            url: 'https://placekitten.com/200/300', // This is a placeholder image you can use
            caption: 'Kitty says haaaaayy!'
          }
        }
      },
      (err, data) => {
        if (err) {
          console.log(err.body.invalid_parameters);
        } else {
          console.log(data);
        }
      }
    );

The above code sends a single message (a picture of a cat) to any number you add into the first object. If for any reason there is a failure in sending the message, the issues will be logged to the console, otherwise, if everything works as it should then the `message_uuid` will be logged instead.

With that, head to your terminal of choice and run:

    node send-mms.js

## Where To Go From Here

Sometimes, for any number of reasons, an MMS message may not be delivered to a recipient so, as a next step from this project, you could experiment with our [Dispatch API](https://developer.nexmo.com/dispatch/overview) and build a failover mechanism that checks whether the MMS has been delivered, and if not, your app would instead send a standard SMS message with a link to the image you wanted to include.