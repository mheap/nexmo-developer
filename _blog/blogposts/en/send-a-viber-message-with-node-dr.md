---
title: How to Send a Viber Message with Node.js
description: Find out how to send Viber messages using Node.js combined with the
  Vonage Messages API Sandbox to get you up and running quickly.
thumbnail: /content/blog/send-a-viber-message-with-node-dr/Blog_Viber_Node-js_1200x600.png
author: garann-means
published: true
published_at: 2020-04-22T13:48:26.000Z
updated_at: 2021-04-29T09:45:26.006Z
category: tutorial
tags:
  - node
  - viber
  - messages-api
comments: true
redirect: ""
canonical: ""
---
If you or your customers are in a country where Viber is the default messaging platform, you'll want your organization to be able to communicate using the service too. You might perform core work via text message or just want to send out notifications. Whatever the complexity, you can add Viber communication to your Node.js app. To see how it works without applying for a [Viber business profile](https://developer.nexmo.com/messages/concepts/viber), you can use [Vonage's Viber sandbox](https://learn.vonage.com/blog/2020/04/08/introducing-the-messages-api-sandbox).


## Prerequisites


For this example, you'll use the lightweight [axios](https://github.com/axios/axios) client to make a POST request. You get access to everything else you need from the Messages API, via the sandbox. So to start, you only need:

- [Node](https://nodejs.org/) and npm
- A whitelisted [Viber](https://www.viber.com/en/) number to test with


<sign-up number></sign-up>

## Set up Your Sandbox


If you haven't already, navigate to [Messages and Dispatch &gt; Sandbox](https://dashboard.nexmo.com/messages/sandbox) in your dashboard to set up your sandbox. The quickest way is to take your device with Viber installed and center the camera on the QR code supplied. Sending the custom message generated will whitelist your number. If the QR code doesn't work with your setup, you can also join the whitelist via email.  


## Set up Axios


You can use axios pretty much out of the box, but you will need to install it. Create a file called `app.js` in a new directory or a directory you use for experiments. In the same directory, install axios:


```text
> npm install axios -s
```


Begin your code in `app.js` by creating an axios client:


```javascript
const axios = require('axios');
```


## Provide Your Data


The data you need to provide is all visible in the cURL command in your dashboard. You'll need a username and password, the Viber ID to send the message from, and the whitelisted number to send the message to. 


You can copy the username and password from the masked value following the `-u` flag. You may recognize them as your API key and secret, and you can also copy them from the Getting Started page in the dashboard. The from ID is also shown in the cURL command, and the to number is your own whitelisted number:


```javascript
var user = '12ab3456';
var password = '123AbcdefghIJklM';
var from_id = `12345`;
var to_num = '441234567890';
```


So you're not just sending static text, you can append the day of the week to your message. Create a few variables to store it for use in your data. Or, even better, substitute some dynamic data from your own use case or application:


```javascript
const weekdays = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday'
];
var today = weekdays[new Date().getDay()];
```


## Make the Request


Axios will provide the default settings for your POST request if you supply the URL and data. The data object is the same data from the cURL command in the dashboard. If you want to send a test message that's more relevant to your use case, you can switch it up inline. You can also provide an options object, which will hold your authorization credentials. 

Once the request completes, the next callback will receive the response. From that you can check the status code and any data that came back. In this case, you should get a message UUID. You can also catch any errors that might occur and log them to the console:


```javascript
axios.post('https://messages-sandbox.nexmo.com/v0.1/messages',{
    "from": { "type": "viber_service_msg", "id": from_id },
    "to": { "type": "viber_service_msg", "number": to_num },
    "message": {
      "content": {
        "type": "text",
        "text": "Hello from Vonage! Happy " + today
      }
    }
  },{
    auth: {
      username: user,
      password: password
    }
  })
  .then(function (response) {
    console.log('Status: ' + response.status);
    console.log(response.data);
  })
  .catch(function (error) {
    console.error(error);
  });
```


## Try It Out


From the directory where you created your file, run:


```text
> node app.js
```


You should receive your test message in Viber on the device you whitelisted. To see the whole example together, you can check out the [code on Github](https://github.com/nexmo-community/send-viber-with-node).




