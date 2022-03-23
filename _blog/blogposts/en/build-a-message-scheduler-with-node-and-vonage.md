---
title: Build a Message Scheduler with Node and Vonage
description: Learn how to create a message scheduler with Node and Vonage
thumbnail: /content/blog/build-a-message-scheduler-with-node-and-vonage/message-scheduler.png
author: cory-althoff
published: true
published_at: 2022-03-18T11:32:27.535Z
updated_at: 2022-03-15T23:57:46.360Z
category: tutorial
tags:
  - messaging-api
  - node
  - javascript
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Here at Vonage, we’ve written many articles on how to send an SMS message. However, sometimes you don’t want to send an SMS message this instant: you want to send it in the future. In this tutorial, you will learn how to schedule an SMS message to send in the future using the Vonage Messages API and Node.

 Are you ready to get started?

Let’s build it!

## Prerequisites

<sign-up number></sign-up>

To follow along with this tutorial, you need a Vonage account. You also need Node, which you can [download here.](https://nodejs.org/en/download/)

## Initial Set-Up

To get started, the first thing you need to do is install the following modules: 

```
node install express @vonage/server-sdk node-cron @vonage/cli -g
```

Express is the web framework we will use to build our app. We will use the Vonage library to send our SMS message, we will use node-cron to create a cron job to send it in the future, and the Vonage CLI to create a Vonage app. 

Use the Vonage CLI to enter the following command with your Vonage API key and secret. You can find this information in the Developer Dashboard.

```
vonage config:set --apiKey=VONAGE_API_KEY --apiSecret=VONAGE_API_SECRET
```

Next, create a new directory for your project and CD into it:

```
mkdir my_project
CD my_project
```


Now, use the CLI to create a Vonage application.

```
vonage apps:create
✔ Application Name ... new_app
✔ Select App Capabilities > Messages
✔ Create messages webhooks? ... No
✔ Allow use of data for AI training? Read data collection disclosure  ... yes

Application created: 34abcd12-ef12-40e3-9c6c-4274b3633761
```


You'll want to save the Application ID: you'll need it later.

Now you need a number so you can receive calls. You can rent one by using the following command (replacing the country code with your code). For example, if you are in Great Britain, replace US with GB:

```
vonage numbers:search US
vonage numbers:buy [NUMBER] [COUNTRYCODE]
```


Now link the number to your app:

```
vonage apps:link --number=VONAGE_NUMBER APP_ID
```

## Building the Back-End

Now, we are ready to start writing the code for our app. 

CD into the directory you created your Vonage app in and create a `.env` file. 

Add the following information: 

```
FROM=<your_vonage_number>
API_KEY=<your_vonage_API_key>
API_SECRET=<your_vonage_API_secret>
APPLICATION_ID=<your_vonage_application_ID>
PRIVATE_KEY=<your_vonage_private_key_file_name>
```

Next, create a new JavaScript file and import the libraries you need for this project.

```javascript
express = require('express')
const Vonage = require('@vonage/server-sdk')
cron = require('node-cron')
const bodyParser = require('body-parser')
const path = require('path');
```


Create an Express app like this:

```javascript
app = express()
```


Now, add the middleware your app needs to handle POST requests:

```javascript
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({
    extended: true
}))
app.use(express.static('public'))
```


Add this code to set up the Vonage Messages API:

```javascript
const vonage = new Vonage({
    apiKey: process.env.API_KEY,
    apiSecret: process.env.API_SECRET,
    applicationId: process.env.APPLICATION_ID,
    privateKey: process.env.PRIVATE_KEY
})
```


Next, define a function to serve index.html when you go to your web app’s homepage.

```javascript
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '/index.html'))
})
```


Now, we need an endpoint to send our SMS messages. 

Add the following code to your app:

```javascript
app.post('/api/sms', (req, res) => {
    res.send(200)
    const triggerTime = new Date(req.body['meeting-time'])
    let task = cron.schedule('* * * * * *', () => {
        if (new Date() > triggerTime) {
            vonage.message.sendSms(process.env.FROM, req.body['number'], req.body['message'], (err, responseData) => {
                if (err) {
                    console.log(err);
                } else {
                    if (responseData.messages[0] === "0") {
                        console.log("Message sent successfully.");
                    } else {
                        console.log(`Message failed with error: ${responseData.messages[0]['error-text']}`);
                    }
                }
            })
            task.stop()
        }
    });
})
```

This code accepts a POST request with a time (when to send the SMS message), the number to send the message to, and the message to send and sends it to the recipient at the scheduled time using `node-cron` to schedule the message.

Node-chron accepts two parameters: the time to do something and a function containing the code of what to do. 

The code above sends an SMS message using Vonage’s Messaging API and the data from the POST request. 

Finally, add this line of code to the end of your file so your server will listen on port 5000.  

```javascript
app.listen('5000')
```

You can now run your server by running the code in this file. 

Nothing happens yet, though, because we need to create our front-end. 

## 
Building the Front-End


Create a new file called index.html and add the following:

```html
<!DOCTYPE html>
<html lang='en'>
  <head>
    <meta charset='UTF-8'>
    <title>Message Scheduler</title>
    <link rel='stylesheet' href='style.css'>
  </head>
  <body>
    <h1>Message Scheduler </h1>
    <form action='/api/sms' method='POST'>
      <label for='time'>Start date:</label>
      <br>
      <input type='datetime-local' id='time' name='meeting-time' value='2022-03-03sT00:00' min='2022-03-03sT00:00' max='2023-06-14T00:00'>
      <br>
      <label for='number'>Number:</label>
      <br>
      <input id='number' name='number'>
      <br>
      <label for='message'>Message:</label>
      <br>
      <input id='message' name='message'>
      <br>
      <input type='submit' value='Submit' id='submit'>
    </form>
  </body>
</html>
```


At the top of your HTML file, you import style.css, which contains CSS to make this page look better.

```html
<link rel='stylesheet' href='style.css'>
```


The rest of this HTML creates a form that collects a date and time (when to send your text), a phone number (who to send it to), and a message (the message to send). 

This code is simple because we took advantage of JavaScript’s built-in calendar. 

When you submit the form, it sends all of the information it collected from the user to the back-end, which schedules the text message to send.  

When you run the JavaScript file you created earlier and navigate your local server at http://127.0.0.1:5000, you should see the form we created.

When you fill out the form and press submit, your text message should send at the scheduled time. 

## Final Thoughts

I hope this tutorial helped you learn more about the Vonage Messages API and how to schedule SMS messages.

Make sure to follow us on Twitter and join our Slack channel for more information.

Thanks for reading!