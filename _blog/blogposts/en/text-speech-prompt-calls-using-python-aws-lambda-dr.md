---
title: Text to Speech with Prompt Calls, Using Python on AWS Lambda
description: In this Nexmo Voice API tutorial, you will learn how to use Python
  on AWS Lambda to place a text to speech call that plays a message to a
  recipient and then asks them to enter some digits on their keypad. You will
  then get a callback to a URL you specify once the interaction has completed.
thumbnail: /content/blog/text-speech-prompt-calls-using-python-aws-lambda-dr/ttsblog.jpeg
author: sammachin
published: true
published_at: 2018-02-16T14:14:06.000Z
updated_at: 2021-05-12T19:28:10.403Z
category: tutorial
tags:
  - voice-api
  - aws
comments: true
redirect: ""
canonical: ""
---
The Nexmo [Voice API](https://www.nexmo.com/products/voice) offers great flexibility in the call scenarios you can activate, however in order to do this you often need to make several interactions with the API. For some scenarios, you may want to have a single API call from your business logic that invokes a series of interactions with the Voice API. This is an ideal scenario to build a serverless application that you can then call and let it deal with the Voice API interactions.

In this example we will show you how to place a Text to Speech call which will play a message to a recipient then ask them to enter some digits on their keypad, perhaps to confirm a PIN number, you will then get a callback to a URL you specify once the interaction has completed. This is very similar to the deprecated TTS Prompt API that Nexmo offered but giving you greater flexibility.

Currently, the application will call a number, play an initial message and then wait for the user to enter the pin that you specify, if they get the pin wrong they are played an error message and then allowed to retry, up to 3 attempts are allowed although this could be edited in your code.

If they fail to enter the correct PIN on the 3rd attempt the call will be terminated with no message.

If they successfully enter the PIN, they will be played another message and then the call will terminate.
Once the call has ended, you will receive a callback to your webhook with the transaction ID of the call and the outcome of the PIN entry attempts.

[View the source code on GitHub](https://github.com/nexmo-community/voice-ttsprompt-lambda)

## Prerequisites

For this tutorial, you will:

* Need an AWS Account (you can run this on the Lambda free tier)
* Have the [AWS CLI tool](https://aws.amazon.com/cli/) and [Chalice](http://chalice.readthedocs.io/en/latest/) installed and configured on your machine
* Create a Nexmo Voice Application and save the private key to a local file named `private.key`, along with a note of the Application ID

<sign-up number></sign-up>

## Deployment

To deploy the function to your own AWS account:

Firstly clone the Git repo to your local machine:

`git clone https://github.com/nexmo-community/voice-ttsprompt-lambda.git`

Switch into the folder:

`cd voice-ttsprompt-lambda`

Deploy the function to AWS:

`chalice deploy`

You will see the following output as your function is deployed, confirm 'Y' that you want to add the execution policy

```
Initial creation of lambda function.
Updating IAM policy.

The following actions will be added to the execution policy:

dynamodb:PutItem
logs:PutLogEvents
dynamodb:CreateTable
logs:CreateLogStream
dynamodb:GetItem
logs:CreateLogGroup

Would you like to continue? [Y/n]: y
Creating deployment package.
Initiating first time deployment...
Deploying to: api
https://910e9mcan2.execute-api.us-east-1.amazonaws.com/api/
```

The final line is the base URL of your newly deployed function, make a note of this you can retrieve this at any time with the command `chalice url`

### Setup

There is very little that needs to be configured as Chalice takes care of most of the AWS configuration on the first deploy. However, you will need to create the DynamoDB table that is used to store the call state.
You do this with an HTTP GET request to the `/setup` URL of your function.

## Invoking

You can now invoke your new function with a single HTTP POST request to your base URL with `/call` on the end.
You need to pass in the following parameters

| Parameter       | Value                                                   | Example                     |
| --------------- | ------------------------------------------------------- | --------------------------- |
| to              | The number to be called in e.164 format                 | 14155550100                 |
| from            | The Nexmo number on your account to use for CallerID    | 14155550101                 |
| text            | The initial message played to the called party          | "Enter your pin"            |
| pin_code        | The PIN that the user should enter                      | 1234                        |
| callback        | The URL on your server where the result should be sent  | http://example.com/callback |
| callback_method | The HTTP method used for your callback webhook          | GET or POST                 |
| bye_text        | The message to be played on a successful pin entry      | "Thank you, goodbye"        |
| failed_text     | The message to be played on an incorrect pin with retry | "Incorrect, try again"      |

### Authentication

The Lambda application does not hold any of your Nexmo credentials instead these are passed in at the time you invoke the function and are only used for that request.

There are two ways you can do this, either by generating a Nexmo JWT with our libraries and putting that in the request headers or by just posting the private key and applicationID as part of a cURL request. It is recommended that you use the JWT method of authentication.

### cURL (Private key auth)

Edit the URL to match the one you were given when you deployed your function

```
curl -X "POST" "https://910e9mcan2.execute-api.us-east-1.amazonaws.com/api/call" \
--data-urlencode "private_key=`cat private.key`" \
-d "app_id=684027bc-a2e7-48b1-b4bd-adc02324e09c" \
-d "to=447970513607" \
-d "from=447520616161" \
-d "text='Enter the PIN'" \
-d "pin_code=1234" \
-d "callback=https://2bwz8nkbmfgc.runscope.net/callback" \
-d "callback_method=post" \
-d "bye_text='Thank You'" \
-d "failed_text='Try again'"
```

### Python (JWT)

Edit the URL to match the one you were given when you deployed your function.

You will need the Nexmo python library: install it with `pip install nexmo`

```
# you need the Nexmo client lib to generate your JWT
import nexmo
import requests

client = nexmo.Client(application_id=APP_ID, private_key=PRIVATE_KEY, key='dummy', secret='dummy')
headers = client._Client__headers()
data = {
'to': 'TO_NUMBER',
'from': 'CALLERID_NUMBER',
'text': 'Enter the pin',
'pin_code' : '1234',
'callback' : 'https://example.com/callback',
'callback_method' : 'post',
'bye_text' : 'thankyou',
'failed_text' : 'try again'
}
response = requests.post("https://910e9mcan2.execute-api.us-east-1.amazonaws.com/api/call", json=data, headers=headers)
```

For either method, the response will be a JSON object containing a transaction ID ('tid') this is the reference for the call and will be used in the callback with the result.

Example Response:
`{
"tid": "6a2827c9-4c68-46fc-b179-115f055dc0eb"
}`

## Callbacks

When the call has been completed the Lambda function will make a callback request to a webhook you specify when you invoked it—this will contain details of the call and the result:

| Parameter | Value                             | Example                              |
| --------- | --------------------------------- | ------------------------------------ |
| to        | The number called in e.164 format | 14155550100                          |
| tid       | The transaction ID                | 6a2827c9-4c68-46fc-b179-115f055dc0eb |
| status    | The result                        | ok                                   |

The following possible status values could be returned:

* `ok`: the call completed and the user entered the correct PIN
* `failed`: the call completed but the user failed to enter the correct PIN
* `error`: the call was not completed

## Next steps

You can modify the code to adjust parameters such as the number of retries the user gets on the pin or perhaps you want to change the `voiceName` used in the prompts.

The details of each of your calls will be stored in AWS DynamoDB, you may want to clean up these entries from time to time depending on your requirements.