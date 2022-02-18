---
title: Building an SMS to Google Sheets Application with AWS Lambda
description: We show you how to capture SMS Messages sent to a number and log
  those into a google spreadsheet without a dedicated server.
thumbnail: /content/blog/building-sms-google-sheets-application-aws-lambda-dr/aws-lambda.jpg
author: sammachin
published: true
published_at: 2016-05-31T21:07:32.000Z
updated_at: 2021-05-13T10:54:21.032Z
category: tutorial
tags:
  - aws
  - python
  - sms-api
comments: true
redirect: ""
canonical: ""
---
In this tutorial, we'll show how you can capture SMS Messages sent to your own Nexmo number and log those into a Google spreadsheet using an AWS Lambda written in Python. This can be used for capturing feedback, registration for further information, recording votes, or any form of data collection. What's great about this is that you don't need your own dedicated server, just a small chunk of code hosted on AWS Lambda and a Nexmo account.

<sign-up number></sign-up>

We'll cover:

* [Why Lambda?](#why-lambda)
* [Logging Incoming SMS with AWS Lambda](#sms-lambda)
* [Setting Up Google Sheets](#google-sheets)
* [Adding SMS Messages to a Google Sheet](#sms-sheets)

If you just want to dive in, you can always [Grab the Code](#grab-code)!

## Why Lambda?

Serverless technologies are a rapidly emerging trend. Closely related to the concept of microservices, the idea is that instead of building a monolithic application that does everything your business wants you to build a number of discrete smaller applications that each does a single function and then tie those together.

One challenge of building these microservices is that the overhead of running a full server stack (OS, Web Server, Database, Application etc) can add a large amount of work and costs. This is where we are seeing a new trend in cloud computing towards serverless technologies, one of the most interesting of these is [AWS Lambda](http://aws.amazon.com/documentation/lambda/) from Amazon. You can now write a simple function in either Python, Java or Javascript and have that invoked by either an external API call or another part of AWS like a file being uploaded to S3.

As well as removing the requirements to run your own servers you can also keep the costs down; you are only charged for the time your code is executing, in 100ms intervals. This means that for simple functions that handle small amounts of data with very bursty traffic it can work out quite affordable while still having the capacity to handle spikes in traffic. This model makes Lambda an ideal platform to build an application for receiving SMS messages.

<h3><a name="sms-lambda"></a>Logging Incoming SMS with AWS Lambda</h3>
For our demo, we will be writing the application in Python. Lambda allows you to use whatever third-party libraries you wish as part of your application bundle. For the first version, we are simply going to receive an SMS sent to a Nexmo number and log that message in the Lambda logs. The video below will walk you through creating your first Lambda application and setting it up to receive \[webhooks](https://docs.nexmo.com/messaging/setup-callbacks) from the Nexmo API. You will also need a \[Nexmo account](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav) and you will need to buy a number for this.

<iframe width="640" height="447" src="https://player.vimeo.com/video/161185498" frameborder="0" webkitallowfullscreen="webkitallowfullscreen" mozallowfullscreen="mozallowfullscreen" allowfullscreen="allowfullscreen"></iframe>

You can find out more about getting started with AWS Lambda in their [getting started guide](http://docs.aws.amazon.com/lambda/latest/dg/getting-started.html).

Here's a walk-through of the key points from the video:

```py
import json

print('Loading function')

def lambda_handler(event, context):
print("Received SMS: " + json.dumps(event, indent=2))
return "OK"
```

Lambda is configured to call a function named `lambda_handler` and passes it an object called event. This event contains the parameters that we will map through on the API Gateway Integrations Request

```json
{
"type" : "$input.params('type')",
"to" : "$input.params('to')",
"msisdn" : "$input.params('msisdn')",
"messageId" : "$input.params('messageId')",
"message-timestamp" : "$input.params('message-timestamp')",
"text" : "$input.params('text')"
}
```

The `lambda_handler` will simply take that event data and print it to the log as a JSON object, then it will return an `OK` string which will pass through the API gateway and be returned to Nexmo.

### Setting Up Google Sheets

The example above is pretty basic, all we are doing is logging the message to the Lambda logfiles, for a real world example we need to do something a bit more useful.

Let’s take a scenario of an event where you want attendees to be able to provide feedback quickly via SMS. A great way to store and share that information is in [Google Sheets](https://www.google.co.uk/sheets/about/) and lucky for us there’s [an API](https://developers.google.com/sheets/) that will allow us to write directly to the sheet.

<iframe width="640" height="431" src="https://player.vimeo.com/video/161198185" frameborder="0" webkitallowfullscreen="webkitallowfullscreen" mozallowfullscreen="mozallowfullscreen" allowfullscreen="allowfullscreen"></iframe>

In the previous video, we start in the Google developers console (get an account [here](https://console.developers.google.com/)) where you need to create a new project, enable the Drive API for that project and then setup a Service Account Key. This type of access is designed for server to server applications. This is what we'll be using as the Lambda application will connect to Google Docs.

Once that service account key is created you will be provided with a set of credentials downloaded in a JSON file. One of the parameters in there is called `client_email`, this will be in the form of an email address. Make a note of this address.

Login to your [Google Drive](https://www.google.co.uk/drive/) and create a new spreadsheet called `nexmosms`. You need to share it with the address related to the Service Account Key and give edit permissions. Now Lambda is acting like another user that is collaborating on the doc with you.

## Adding SMS Messages to a Google Sheet

Now that we are working with some external API’s our Lambda code needs to be little more complex. We'll now be using some 3rd party libraries which means that we can no longer just write our code in the browser. Instead we need to [create a zipped bundle](http://docs.aws.amazon.com/lambda/latest/dg/lambda-python-how-to-create-deployment-package.html) of our code and the additional libraries we are using.

We skip the video for these coding steps. Instead the detailed steps are below. We'll start off with an empty directory and create a file in there called `lambda_function.py`

```bash
mkdir nexmosms
cd nexmosms
touch lambda_function.py
```

We can install the libraries that we're going to use in our bundle from the command line using the pip package manager. We need to install them to the local folder rather than the regular system path using the `-t` flag and can specify the current directory `pwd` in backticks. So to add the `nexmo` library to the package use the command:

```bash
pip install nexmo -t `pwd`
```

We’ll need to repeat that command for the other libraries we want to use:

```bash
pip install oauth2client -t `pwd`
pip install gspread -t `pwd`
pip install nexmo -t `pwd`
```

Now that we have a folder with our libraries in it we just need to use them in our `lambda_function.py` file:

Our lambda function code is now a little more detailed:

```py
import json
import requests
from time import strftime as timestamp
from oauth2client.service_account import ServiceAccountCredentials
import gspread
import nexmo
from creds import *
```

The first part imports the libraries we need, but you’ll also notice that there is some stuff in there like `time` which we didn’t include in our bundle with pip. This is because Lambda provides everything from [Python 2.7 standard runtime](https://docs.python.org/2/library/).

Next we need to set up access to Google Sheets and also put our Nexmo API Key and API Secret into the file. In the code below replace the X's with your details in the example below.

```py
# Setup access to Google sheets
scopes = ['https://spreadsheets.google.com/feeds']
credentials = ServiceAccountCredentials.from_json_keyfile_name('creds.json', scopes=scopes)
#Nexmo Credentials
nexmo_key = 'XXXXXX'
nexmo_secret = 'XXXXXX"
```

The credentials file that you downloaded when setting up the Google Service Account key should be renamed to `creds.json` and included in the bundle.

And add a function called `addrow` to our bundle that lets us add a row to our Google Sheet:

```py
def addrow(sender, text):
gc = gspread.authorize(credentials)
sheet = gc.open('nexmosms').worksheet("Sheet1")
sheet.append_row([timestamp('%Y-%m-%d %H:%M:%S'), sender, text])
```

This function is passed 2 values, `sender` which will be the mobile number (MSISDN) that sent the message and `text` which is the body of the message. The function creates a `gc` object to represent the connection to Google Sheets, a `sheet` object which will open a doc in that account called `nexmosms` and select the sheet called `Sheet1`. Finally we append a new row to that sheet adding a `timestamp` as the first column, followed by the sender and message text.

We can then update our original Lambda handler to make use of our new function:

```py
def lambda_handler(event, context):
print("Received SMS: " + json.dumps(event, indent=2))
addrow(event['msisdn'], event['text'])
client = nexmo.Client(key=nexmo_key, secret=nexmo_secret)
client.send_message({'from': event['to'], 'to': event['msisdn'], 'text': 'Thanks for your feedback!'})
return "OK"
```

In the above code we still print the received data to the log to help with debugging, but we now also invoke the `addrow` function we just created.

We then use the official [Nexmo Python library](https://github.com/Nexmo/nexmo-python) (that [we released](https://www.nexmo.com/blog/2016/05/30/new-nexmo-python-library-released-pycon/) just in time for PyCon 2016) to send back a response to the originator of the message from the Lambda function. We create a `nexmo.Client` instance and call `client.send_message` setting our `from` number to be the Nexmo number that the user sent the message to. The ‘to’ is the user’s phone number that they sent the message from (MSISDN) and the body of the message `text` just says `Thanks for your feedback!`. Finally we return an `"OK"` to the Nexmo API to clear down the request.

That's it! You can now send an SMS to a Nexmo registered number, and have that text message sent to an AWS Lambda function via a Nexmo webhook. Lambda will log the message contents to a Google Sheet and send a reply.

The following video shows uploading the bundle and a demonstration of the code in action:

<iframe width="640" height="451" src="https://player.vimeo.com/video/164285957" frameborder="0" webkitallowfullscreen="webkitallowfullscreen" mozallowfullscreen="mozallowfullscreen" allowfullscreen="allowfullscreen"></iframe>

## Grab the Code!

You can download a bundle of all the code from my [GitHub](https://github.com/sammachin/LambdaSMSGoogle). Please let me know what you think, I'm [@sammachin on Twitter](https://twitter.com/sammachine).