---
title: Sentiment Analysis for Customer Experience With Python and Streamlit
description: Learn how to use Sentiment Analysis to improve your customer
  experience on Facebook with Python and Streamlit
thumbnail: /content/blog/sentiment-analysis-for-customer-experience-with-python-and-streamlit/sentiment-analysis_streamlit_1200x600.png
author: solomon-soh
published: true
published_at: 2021-05-04T09:43:23.529Z
updated_at: 2021-04-19T09:07:41.740Z
category: tutorial
tags:
  - messages-api
  - node
  - python
comments: true
spotlight: true
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Start leveraging on Vonage Messaging API to improve customer service such as collating review feedback from social media platforms such as Facebook.

Sentiment analysis mines insights from customers feedback using natural language processing techniques to determine whether feedback data is positive, negative or neutral. Business leverage on sentiment analysis to monitor product and brand sentiment and also understand what the customer needs.

This tutorial covers the following items:

* Initialise the Messages API Sandbox on Vonage
* Collect data from customers through Facebook 
* Create a bot to handle feedback from customers on Facebook by:
  * Storing this data into a database or text file
  * Returning relevant responses to the customer
* Create a dashboard through Streamlit to understand the sentiments of customers feedback in real-time
* Measure customers sentiments with a positive, negative, neutral scale 
* Analyze customers key pain points with visualization


## Prerequisites

* [Node.js](https://nodejs.org/en/download/)
* [Python3](https://www.python.org/download/releases/3.0/)

<sign-up></sign-up>

## Creating a Facebook Bot

The Messages API Sandbox allows businesses to send and receive messages through various social channels, such as WhatsApp, Facebook, and Viber. It also allows businesses to send SMS and MMS through this API. In order to send messages through any of the external social channels, you’ll need a business account with each provider and have it connected to your Vonage APIs account.

For this tutorial we’ll be using Facebook, so make sure you have a Facebook account ready to test with.

To start creating our application, in the directory of your project run the following command to initialize the node project, and then install the third party libraries required:

```bash
npm init -y
npm install express body-parser nedb @vonage/server-sdk@beta dotenv
```

The above commands will create `package.json`, `package.lock` files as well as a `node_modules` directory. Within the `package.json` file you’ll see the libraries we’ve just installed such as `express` and `vonage/server-sdk`. An example of what you’ll see is shown below:

```json
{
  "name": "facebook-bot",
  "version": "1.0.0",
  "description": "Sign up for a Vonage API account at https://dashboard.nexmo.com.",
  "main": "index.js",
  "scripts": {
    "serve": "node index.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "@vonage/server-sdk": "^2.10.7-beta",
    "body-parser": "^1.19.0",
    "dotenv": "^8.2.0",
    "express": "^4.17.1",
    "nedb": "^1.8.0"
  },
  "devDependencies": {}
}
```

When a message comes in from Facebook, Vonage will send an HTTP request to a preconfigured webhook URL. Your Node application should be accessible to the internet to receive it, so we recommend using [Ngrok](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr).

In your Terminal, run the following command to launch Ngrok on port `3000` (Please note, the forwarding URL changes each time ngrok is restarted so keep that in mind if you were to restart ngrok):

```bash
npx ngrok http 3000
```

We now need to create an application in the [dashboard](https://dashboard.nexmo.com/applications/new). Make sure to add a name relevant to the purpose of the application, then toggle `Messages` on as this application will need to make use of the Messages API. Then click the button “Generate public and private key”. This will force your browser to download a `private.key` file. Place this within the root directory of your project. Finally, click the `Generate new application` button, this will redirect you to the application show page. Make a copy of the `Application ID` shown on the page as this will also be needed in the code further below.

While you’re on this page, we need to define the webhooks URLs. A webhook is an extension of an API, but instead of your code requesting data from the API platform, Vonage sends the data to you. The data arrives in a web request to your application, which may be the result of an earlier API call (this type of webhook is also called a "callback"), such as an asynchronous request to the Messaging API. Webhooks are also used to notify your application of events such as an incoming message to be stored in a file or send an outgoing message to the app. 

The URLs need to be updated in the [dashboard](https://dashboard.nexmo.com/messages/sandbox) as shown below (Be sure to replace `<ngrok URL>` with your ngrok url):

* Inbound Webhooks: `http://<ngrok URL>/webhooks/inbound`
* Status Webhooks: `http://<ngrok URL>/webhooks/status`

Navigate back to the [Messages Sandbox](https://dashboard.nexmo.com/messages/sandbox) to whitelist your Facebook account with the Facebook Messenger Sandbox. Click `Add to sandbox` and follow the instructions provided on the page. 

Store your credentials into a `.env` file that can be accessed through `index.js`.

```dotenv
VONAGE_API_KEY=###
VONAGE_API_SECRET=###
VONAGE_APPLICATION_ID=e0c5d5d8-###
```

Next, in the `index.js` file, include modules that have been installed previously such as express, Vonage server-sdk as shown in the example below:

```javascript
const app = require('express')()
const bodyParser = require('body-parser')
const nedb = require('nedb')
const Vonage = require('@vonage/server-sdk')
```

Then, we need to create a database with the filename `messages.db`, add the following  line into your `index.js` file:

```javascript
const messages = new nedb({ filename: 'messages.db', autoload: true })
```

We now need to initialize a new Vonage object with our credentials consisting of the API key, API secret, application ID, along with the path and filename of the private.key. We also need to set the host URL of the API to point at the sandbox URL. In your `index.js` file add the following code:

```javascript
const vonage = new Vonage({
  apiKey: process.env.VONAGE_API_KEY,
  apiSecret: process.env.VONAGE_API_SECRET,
  applicationId: process.env.VONAGE_APPLICATION_ID,
  privateKey: './private.key'
}, {
  apiHost: 'https://messages-sandbox.nexmo.com'
})
``` 

We’re going to create a function called `sendMessage`, which will send messages to Facebook in response to the customers’ queries, feedback, or reviews. In the function, which is shown in the example below, there is a `to` and a `from`, which will be instructions to the API. The `to` (or recipient) needs to be the whitelisted Facebook account. Add the function below into your `index.js` file:

```javascript
function sendMessage(sender, recipient, text) {
  const to = { type: 'messenger', id: recipient }
  const from = { type: 'messenger', id: sender }
  const message = { content: { type: 'text', text: text } }
 
  vonage.channel.send(to, from, message, function(error, result) {
    if(error) { return console.error(error) }
    console.log(result)
  })
}
```

In the example above you’ll see `vonage.channel.send`, which sends a message with the parameters of `to`, `from` and message and in the event of an error, returns this error, and will log the error message. 

Next, we’ll need to add the webhook in our application to listen for the path `/webhooks/inbound` in the URL, which will receive messages from the Messages API whenever a Facebook message is received.  It parses and obtains the messenger id of the sender from the body and also the text that is sent, together with the timestamp and insert in the response messages given either a condition of error if-else will be a successful understanding of the users’ feedback. 

If an error occurs, the message sent back to the sender will be “Sorry! Could you repeat?”. On the other hand, should the messenger retrieve and send the message by the customers to the app, it will be stored in `messages.db` while a response of “Thanks for your feedback and review!” will be returned to the users.  So add the following to your `index.js` file:

```javascript
app.post('/inbound', function(request, response) {
  if (request.body.message.content.text.toLowerCase().trim() === 'recap') {
    messages.find({'from.id': request.body.from.id }, function (error, records) {
      if (error) { return console.error(error) }
      const message = records.map(function(record) {
        return record.message.content.text + ' (sent at ' + record.timestamp + ')'
      }).join('\n\n')
      sendMessage(request.body.to.id, request.body.from.id, message)
    })
  } else {
    messages.insert(request.body, function (error, record) {
      if (error) {
        sendMessage(request.body.to.id, request.body.from.id, 'Sorry! Could you repeat?')
        return console.error(error)
      }
      sendMessage(request.body.to.id, request.body.from.id, 'Thanks for your feedback and review!')
    })
  }
 
  response.send('ok')
})
```

Lastly, we need to add another listener for the `/webhooks/status` endpoint, which will return the message  “ok”. We also need to add the listen functionality, which keeps the application running and listening as a webserver on port `3000`. So at the bottom of your `index.js` file add the following:

```javascript
app.post('/status', function(request, response) {
  console.log(request.body)
  response.send('ok')
})
app.listen(3000)
```

Now it’s time to test your application! First you need to run your web application, in your Terminal, run the following command:

```bash
node index.js
```

Now, if you go to [Facebook Messenger](https://www.messenger.com/), find the Vonage Sandbox user and send it a message. You’ll receive a response in Messenger.

## Analyze User’s Feedback

The data from the customers’ Facebook through Vonage sandbox is stored in the `messages.db` file. In a simulated demonstration, a user critiqued the products and services of a bespoke firm and a sample of the data is recorded in the example script below.

```json
{"message_uuid":"e6e659be-3cdb-464f-96ef-8597cb307586","from":{"type":"messenger","id":"3819505444810553"},"to":{"type":"messenger","id":"107083064136738"},"message":{"content":{"type":"text","text":"how terrible can this product be, does not solve my pain point"}},"timestamp":"2021-03-15T08:43:30.993Z","_id":"6TdDhlo8CVxEr7tq"}
{"message_uuid":"7775fa83-f073-481c-8866-c60bca28ec97","from":{"type":"messenger","id":"3819505444810553"},"to":{"type":"messenger","id":"107083064136738"},"message":{"content":{"type":"text","text":"how can there be no response for so long on such bad service"}},"timestamp":"2021-03-15T08:44:37.924Z","_id":"GSVzREWsYllKHOlJ"}
```

We can see that each `message_uuid` is unique for each message sent to the Facebook bot. The `from` and `to` specifies the identity of the customers and bot respectively. The message contains the content which is in a type of text and is simply the feedback provided by the customer. To analyze this feedback, they will be visualized through the python Streamlit framework with libraries such as TextBlob, WordCloud, Matplotlib, and Pandas. Create a new file called `dashboard.py` and add the following code into this new file:

 ```python
import streamlit as st
from textblob import TextBlob
from wordcloud import WordCloud, STOPWORDS, ImageColorGenerator
import matplotlib.pyplot as plt
import pandas as pd
st.set_option('deprecation.showPyplotGlobalUse', False)
```

[Streamlit](https://streamlit.io/) is an open-source app framework for Machine Learning and Data Science teams. [TextBlob](https://textblob.readthedocs.io/en/dev/) is a Python library for processing textual data. It provides a simple API for diving into common natural language processing (NLP) tasks. WordCloud is a technique to show which words are the most frequent among the given text. [Matplotlib](https://matplotlib.org/) is a comprehensive library for creating static, animated, and interactive visualizations in Python. [Pandas](https://pandas.pydata.org/) is a fast, powerful, flexible and easy to use open-source data analysis and manipulation tool, built on top of the Python programming language.

With all these tools, first, we open the data stored in messages.db, read and process every record of feedback collected from all users. We look for the messages/content and remove the timestamp because that is not needed for the analysis of sentiment in the feedback. The processed feedback will be stored in a list. 

The example below carries out the instructions listed above. Add this to the bottom of your `dashboard.py` file:

 ```python
file1 = open('messages.db', 'r')
Lines = file1.readlines()
feedback_list = list()
for line in Lines:
    feedback = line.split(":")[11]
    feedback = feedback.replace('}},"timestamp"',"")
    feedback_list.append(feedback)
``` 

Next, we generate a word cloud to visualize the frequency of the words provided in the feedback by the users. We can see that certain keywords are much more prominent such as “terrible”, “long”, “bad” etc. Wordcloud simply counts how many times each word has appeared in all the sentences of feedback provided by customers. A better way would be to analyze the overall sentiment of the customer. 

We can use TextBlob basic sentiment polarity analysis on the sentence that gives a relatively reliable estimate of the emotive experiences of the customer from their textual feedback and store in a new list of sentiment values. 
Now in your `dashboard.py` add the following code:

```python
sentiment_values = list()
for feedback in feedback_list:
    sentiment_feedback = TextBlob(feedback).sentiment.polarity
    sentiment_values.append(sentiment_feedback)
``` 

Next, we will show the overall sentiment within a range of -1 to 1. For sentiment polarities above 0, the output will be green whereas, for those negative values which mean unhappiness, the sentiment will be shown as red on the webpage. Copy the following into your `dashboard.py` file:

 ```python
st.title("Overall Sentiment")
if average_sentiment > 0:
    colors = 'green'
else:
    colors = 'red'
``` 

Currently, the overall sentiment is -0.417 which suggests that overall a lot of the feedback is not in support of the products and services of the firm. We can see the feedback in a table with each of the feedback sentiments being shown. There are few sentiments of 0 value. This means that the analysis found this feedback to be neutral and cannot understand the negative connotations of the message. We can see that “This product cannot match up…” and “will only use this product if it is given to me free” would suggest negative sentiments yet, the result is neutral or positive. Hence, a more complex model to learn and train can be developed for sentiment analysis for this use case. Moreover, the overall sentiment analysis may not want to be just a simple average but rather potential more complex calculations or a weighted average. 

The Streamlit web dashboard app can be started by initializing the following command. Streamli needs to be installed for the web dashboard to be set up. Other deployment methods in flask or Django work equally as well and can be explored. 

 ```bash
streamlit run dashboard.py
``` 

In conclusion, this tutorial has shown how to set up and connect a Vonage Messages API to Facebook and collect feedback from customers which is then analyzed using sentiment analysis to do real-time monitoring of the sentiments of customers. 
 

