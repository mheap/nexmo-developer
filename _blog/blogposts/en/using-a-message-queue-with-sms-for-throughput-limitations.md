---
title: Using a Message Queue With SMS For Throughput Limitations
description: Throughput limitation on SMS and slow request times add challenges
  for bulk sending. Learn how to address these factors with a message queue like
  AWS SQS.
thumbnail: /content/blog/using-a-message-queue-with-sms-for-throughput-limitations/Blog_Send-Outgoing-SMS_1200x600.png
author: adamculp
published: true
published_at: 2020-05-28T13:32:21.000Z
updated_at: 2021-05-05T13:00:22.779Z
category: tutorial
tags:
  - node
  - python
  - sms-api
comments: true
redirect: ""
canonical: ""
---
In some countries, throughput limitation on SMS and slow request times (sometimes as low as one request per second) add challenges for bulk sending. One way to navigate these limitations is by using a message queue, such as [AWS SQS](https://aws.amazon.com/sqs/).

For this example, you create a serverless microservice on [AWS Lambda](https://aws.amazon.com/lambda/) using this [Python application available on Github](https://github.com/nexmo-community/sms-aws-sqs-python-sender) that uses [Flask](https://flask.palletsprojects.com/en/1.1.x/), and [Serverless](https://serverless.com/framework/docs/getting-started/). The application serves two purposes: It adds messages to [AWS SQS](https://aws.amazon.com/sqs/) and then facilitates the actual sending through [Vonage SMS](https://www.vonage.com/communications-apis/sms/) as requested.

## Prerequisites
* [Python 3.8](https://www.python.org) (update `serverless.yml` if higher version is desired)
* Pip
* [Node.js](https://nodejs.org/en/) and npm
* [AWS CLI](https://aws.amazon.com/cli/)
* [Serverless Framework](https://serverless.com/framework/docs/getting-started/)

<sign-up></sign-up>

## Setup Instructions
Clone the [nexmo-community/sms-aws-sqs-python-sender](https://github.com/nexmo-community/sms-aws-sqs-python-sender) repo from GitHub, and navigate into the newly created directory to proceed.

### Environment
Rename `.env.default` to `.env` and add values to `VONAGE_API_KEY` and `VONAGE_API_SECRET` provided on your [Vonage API Dashboard](https://dashboard.nexmo.com/).

### AWS Setup
You need to create [AWS credentials](https://www.serverless.com/framework/docs/providers/aws/guide/credentials/) as indicated by Serverless. Update the `.env` file with these.

Also, create a new [SQS FIFO queue](https://aws.amazon.com/sqs/) using the default settings, and update `.env` with the SQS queue URL. FIFO ensures messages get sent in the order they were stored.

### Usage
To start, create a `virtualenv` from within the project root to contain the project. Then, activate it as follows:

```bash
virtualenv venv --python=python3
source venv/bin/activate
```

Next, initialize npm and follow the prompts selecting the defaults, unless you desire to change any of them. Also, use npm to install needed dependencies for DEV to enable Serverless and Lambda to work with the Flask app.

```bash
npm init
npm install --save-dev serverless-wsgi serverless-python-requirements
```

Now you can use pip to install the required Python dependencies. The dependencies are in the requirements.txt, so instruct pip to use it.

```bash
pip install -r requirements.txt
```

#### Running Local
Should you wish to run the app locally and test things out, before deploying to AWS Lambda, you can serve it with the following command:

```bash
sls wsgi serve
```

By default, this serves the app at http://localhost:5000. You hit `Ctrl+c` to close it down.

#### Deploy to Lambda
With all the above finished successfully, you can now use Serverless to deploy the app to AWS Lambda.

```bash
sls deploy
```

> IMPORTANT: This application does not contain any authentication for use. Therefore, ensure you add authentication in front of it to prevent public usage. By leaving it open to the public, it could result in usage charges at AWS and Vonage.

#### Available Endpoints
There are 3 URL endpoints available with this client:

1 GET request to `/`

* Doesn't perform any actions, but provides a quick way to test

2 POST request to `/add`

* This action stores the message in SQS.
* Pass a POST with a JSON body like the following. Substitute the placeholders, indicated with `<>` with your data.
* The result contains the SQS `MessageId`.

```json
{
    "from": "<your_name_or_number>",
    "message": "<sms_message_contents>",
    "to": "<recipients_number>"
}
```

3 GET request to `/process`

* Kicks off the sending process.
* Retrieves messages from the SQS FIFO queue.
* Connects to Nexmo, and sends the SMS message.

```text
location=None, media_mode=relayed, archive_mode=manual
```

##### Examples:
Go to the URL provided by the deploy process. Below are some examples of what sample requests may look like: (Your URL may vary.)

GET `https://7ulasfasdasdfw4.execute-api.us-east-1.amazonaws.com/dev/`

The `/` endpoint returns the generic message.

POST `https://7ulasfasdasdfw4.execute-api.us-east-1.amazonaws.com/dev/add`

The `add` endpoint returns the SQS `MessageId`.

GET `https://7ulasfasdasdfw4.execute-api.us-east-1.amazonaws.com/dev/process`

The `process` endpoint returns a message indicating a successful send.

#### Deactivating Virtualenv
To exit the virtualenv, you can deactivate it when desired.

```bash
deactivate
```

> NOTE: Depending on OS, you may need to prepend `virtualenv` to the command above.

## Next Steps
In this example, the application contains a `/process` endpoint callable with an HTTP GET request at scheduled intervals. Alternatively, the code in `/process` could be put in a separate Lambda function and called directly from CloudWatch scheduled events instead of an HTTP GET request.

If you have any questions or run into troubles, you can reach out to [@VonageDev](https://twitter.com/vonagedev) on Twitter or inquire in the [Vonage Community](http://vonage-community.slack.com) Slack team. Good luck.