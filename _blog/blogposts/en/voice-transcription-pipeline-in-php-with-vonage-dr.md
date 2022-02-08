---
title: Voice Transcription Pipeline in PHP With Vonage
description: Create a collection of serverless functions in PHP to process
  Vonage Voice calls using Amazon Transcribe and store the transcripts in
  database.
thumbnail: /content/blog/voice-transcription-pipeline-in-php-with-vonage-dr/Blog_Voice-Transcription-Pipeline_1200x600.png
author: adamculp
published: true
published_at: 2020-06-19T15:27:51.000Z
updated_at: 2021-05-04T14:15:28.482Z
category: tutorial
tags:
  - serverless
  - php
  - transcription
comments: true
redirect: ""
canonical: ""
---
In this post, you'll create a voice transcription pipeline. The objective is to use [Amazon Transcribe](https://aws.amazon.com/transcribe/) to process an entire conversation into channels and then insert the results into an [RDS](https://aws.amazon.com/rds/) MySQL database instance. To accomplish this will take two [AWS Lambda](https://aws.amazon.com/lambda/) functions: an [HTTP application](https://github.com/nexmo-community/voice-channels-aws-transcribe-php) to retrieve an MP3 file and submit to Amazon Transcribe, and a [callback function](https://github.com/nexmo-community/aws-voice-transcription-rds-callback-php) upon completion of the transcription to store the results into a MySQL database.

## Prerequisites

* PHP 7.4 (update `serverless.yml` for other versions)
* Composer installed [globally](https://getcomposer.org/doc/00-intro.md#globally)
* [Node.js](https://nodejs.org/en/) and npm
* [Serverless Framework](https://serverless.com/framework/docs/getting-started/)
* [AWS account](https://aws.amazon.com/)

<sign-up number></sign-up>

## Setup Instructions

Clone the [nexmo-community/voice-channels-aws-transcribe-php](https://github.com/nexmo-community/voice-channels-aws-transcribe-php) repo from GitHub, and navigate into the newly created directory to proceed.

### Use Composer to Install Dependencies

This example requires the use of Composer to install dependencies and set up the autoloader.

Assuming you have Composer [installed globally](https://getcomposer.org/doc/00-intro.md#globally), run:

```
composer install
```

### AWS Setup

You will need to create [AWS credentials](https://www.serverless.com/framework/docs/providers/aws/guide/credentials/) as indicated by `Serverless`.

Also, create a new [AWS S3 bucket](https://aws.amazon.com/s3/) and make note of the URL for later use.

### Link the App to Vonage

#### Create a Vonage Application Using the Command Line Interface

Install the CLI by following [these instructions](https://github.com/vonage/vonage-cli#installation). You'll use this to create a new Vonage Voice application that also sets up an `answer_url` and `event_url` for the app running in AWS Lambda:

```
vonage apps:create aws-transcribe --voice_answer_url=https://<your_hostname>/webhooks/answer --voice_event_url=https://<your_hostname>/webhooks/event
```

*NOTE: You'll be using `<your_hostname>` as a placeholder in this command. Later, after you know the URLs provided by deploying to AWS Lambda, you'll need to update these pieces of the URLs via the [Vonage API Dashboard](https://dashboard.nexmo.com/applications/) settings for your application.*

IMPORTANT: This will return an application ID and a private key. The application ID will be needed for the `vonage apps:link` command as well as the `.env` file later. A file named `private.key` will be created in the same location/level as `server.js`, by default.

### Obtain a New Virtual Number

If you don't have a number already in place, obtain one from Vonage. This can also be achieved using the CLI by running this command:

```
vonage numbers:search US
```

And purchasing one of the available numbers given back by running:

```
vonage numbers:buy <number>
```

### Link the Virtual Number to the Application

Finally, link the new number to the created application by running:

```
vonage apps:link YOUR_APPLICATION_ID --number=<number>
```

### Update Environment

Rename the provided `.env.dist` file to `.env` and update the values as needed:

```env
APP_ID=voice-aws-transcribe-php
LANG_CODE=en-US
SAMPLE_RATE=8000
AWS_VERSION=latest
AWS_S3_ARN=<aws_s3_arn>
AWS_S3_BUCKET_NAME='<bucket_name>'
AWS_S3_RECORDING_FOLDER_NAME='<aws_s3_bucket_folder_name>'
VONAGE_APPLICATION_PRIVATE_KEY_PATH='./private.key'
VONAGE_APPLICATION_ID=<application_id>
```

*NOTE: All placeholders noted by `<>` need to be updated.*

### Serverless Plugin

Install the [serverless-dotenv-plugin](https://www.serverless.com/plugins/serverless-dotenv-plugin/) with the following command:

```bash
npm i -D serverless-dotenv-plugin
```

### Deploy to Lambda

With all the above updated successfully, you can now use `Serverless` to deploy the app to [AWS Lambda](https://aws.amazon.com/lambda/).

```bash
serverless deploy
```

*Note:* Make sure to visit the [Vonage API Dashboard](https://dashboard.nexmo.com/applications/) and update the `answer` and `event` URLs for your application with what is provided by the deployment.

## Migrate Transcription to a Database

If you only require the transcription, all is done. However, to automate migrating the transcription results to the database will require another function to be deployed. Clone this [nexmo-community/aws-voice-transcription-rds-callback-php](https://github.com/nexmo-community/aws-voice-transcription-rds-callback-php) repo to another location and follow the instructions in the README to get it up and running. The instructions are identical to what was done above for the first function.

### Create The Trigger

After adding the second function, you can navigate to [CloudWatch](https://aws.amazon.com/cloudwatch/) in your [AWS Console](https://console.aws.amazon.com/) and select *Events* and *Get Started* to create a new Event Rule.

Set the Rule as follows:

* Event Pattern
* Build event pattern to match events by service
* Service Name = Transcribe
* Event Type = Transcribe Job State Change
* Specific status(es) = COMPLETED
* As the Target select the Lambda function #2 created above
* Scroll down and click *Configure Details*.
* Give the rule a meaningful name and description, and enable it.
* Click *Create rule* to complete it.

Now you're ready to test.

### Usage

With the deployment completed, you should be able to place a call to your virtual number from any phone. You will hear a message about being connected, and then the recipient number will be called.

After you hang up, the MP3 file will be retrieved from Vonage and uploaded to AWS S3. Following that, a transcription job will be started. The job can be monitored in the AWS Console website after login.

Upon completion of the transcription, CloudWatch will trigger the Lambda function to parse the transcription and insert to the database.

## Next Steps

If you have any questions or run into troubles, you can reach out to [@VonageDev](https://twitter.com/vonagedev) on Twitter or inquire in the [Vonage Developer Community](http://vonage-community.slack.com) Slack team. Good luck.