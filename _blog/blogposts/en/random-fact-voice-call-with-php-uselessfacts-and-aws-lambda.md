---
title: Random Facts Voice Call With PHP, Uselessfacts and AWS Lambda
description: Learn how to use PHP and AWS Lambda thanks to Bref, by using
  Vonage's API to handle outgoing voice calls and returning a random fact to the
  caller
thumbnail: /content/blog/random-facts-voice-call-with-php-uselessfacts-and-aws-lambda/useless-facts_php_1200x600.png
author: greg-holmes
published: true
published_at: 2021-04-13T12:47:47.755Z
updated_at: 2021-04-13T12:47:48.391Z
category: tutorial
tags:
  - voice-api
  - php
  - aws
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Have you wanted to run a service without needing to create and maintain a server? Whether this to be a function triggered at set intervals or a specific action triggers this function?

In this tutorial, we will create a PHP application and host it on AWS Lambda, listening for a specific webhook URL to be triggered when the someone calls a specific phone number. The application will then confirm the caller's number and convert a random fact from text to speech for the caller to hear. The random facts get retrieved from an API called [Random Useless Facts](https://uselessfacts.jsph.pl/).

## Prerequisites

* An [AWS Account](https://aws.amazon.com/)
* [Serverless](https://www.serverless.com/framework/docs/getting-started/) installed locally
* [PHP](https://www.php.net/docs.php) installed locally
* [Composer](https://getcomposer.org/) installed locally

<sign-up number></sign-up>

## Getting Started

### Install the Dependencies

First, you'll need to create a directory for your project, then, in your Terminal, navigate to this directory and run the following command to initialise your Composer project:

```bash
composer init
```

Once you've finished with that step, run the command below to install the required third-party libraries. These libraries are:

* the Slim PHP Framework, 
* Slim's PSR-7 which contains Response and Request interfaces we'll need, 
* GuzzleHttp to make API requests in retrieving random facts,
* Bref to bring support for PHP on AWS Lambda,
* Vonage's PHP client to correctly handle incoming webhook requests for a voice call.

```bash
composer require slim/slim:"4.*" slim/psr7 guzzlehttp/guzzle:"^7.0" bref/bref vonage/client
```

Now that you've installed the third-party libraries, it's time to make use of one of these. In your Terminal, run the following command to initialise a Bref project, be sure to accept all the defaults provided:

```bash
vendor/bin/bref init
```

This will create two new files:

* `index.php` will contain the code for the application
* `serverless.yml` will contain the configuration requirements for deploying the application to AWS

### Write the Code

In your code editor, open the newly created `index.php` file. Remove the contents of this file as we're going to be rewriting everything.

The first thing to add to the file is the imports for the classes used from the third-party libraries we installed in the previous step. Copy the following into your `index.php` file:

```php
<?php

use GuzzleHttp\Client;
use Laminas\Diactoros\Response\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;
use Vonage\Voice\NCCO\Action\Talk;
use Vonage\Voice\NCCO\NCCO;
use Vonage\Voice\Webhook\Answer;
use Vonage\Voice\Webhook\Factory;

require __DIR__ . '/vendor/autoload.php';
```

We need to create the Slim application in our `index.php` file and an empty GET endpoint with the URI being `/webhooks/answer`. To do this, add the following to the file:

```php
$app = AppFactory::create();

$app->get('/webhooks/answer', function (Request $request, Response $response, array $args) {

});

$app->run();
```

The `/webhooks/answer` endpoint will be configured in your Vonage dashboard later as a way for your virtual phone number to get instructions on what to do when a call is made.

Next, we need to create the functionality that will allow us to receive the data transmitted to the webhook, parse the `from` phone number, make a GET request to the [random fact generator](https://uselessfacts.jsph.pl/random.json?language=en), create and return a call control object (NCCO) to the caller. The code below carries out all of this functionality described, so add this into your `$app->get('/webhooks/answer'` function:

```php
// Convert the contents of the `$request` sent in the `GET` request into a Voice Webhook Object.
/** @var Answer $call */
$call = Factory::createFromRequest($request);
// Take the `from` phone number and add spaces so it can be read properly in the voice call
$fromSplitIntoCharacters = implode(" ", str_split($call->getFrom()));

// Create a new GuzzleHttp client ready to make a `GET` request
$client = new Client();
// Make a `GET` request for a random useless fact in English
$response = $client->get('https://uselessfacts.jsph.pl/random.json?language=en');
// Convert the response JSON into a PHP Array
$responseArray = json_decode($response->getBody(), true);

// Initialise the Call Control Object ready to take actions to return back to the caller
$ncco = new NCCO();
$ncco
    // Create the first Talk Action thanking the caller and reading out their number back to them
    ->addAction(
        new Talk('Thank you for calling from ' . $fromSplitIntoCharacters)
    )
    // Create the second Talk Action reading the caller their random fact.
    ->addAction(
        new Talk('Your fact is: ' . $responseArray['text'])
    );

// Returns a Json Response of the NCCO containing the two Talk Actions.
return new JsonResponse($ncco);
```

### Deploy the Code

To deploy the code to AWS Lambda, in your Terminal, run the following command:

```bash
serverless deploy
```

When the deployment is successful, you'll see an output similar to the example shown in the image below. The output may be slightly different depending on the values in your `serverless.yml` file, though. Make sure to keep note of the URL found in the `endpoints:` section.

![Output showing a serverless deployment](/content/blog/random-fact-voice-call-with-php-uselessfacts-and-aws-lambda/serverless-deployment-success.png)

### Create an Application

We now need an application in with Vonage in order to enable our virtual phone number to know which endpoint it needs to request when a call is made. Create an application in your [Dashboard](https://dashboard.nexmo.com/) under "Your Applications" and give your new application a name.

Add Voice capabilities to the application and configure the URLs using the Lambda URL you copied earlier in the previous step. For the Answer URL, use `[paste lambda url]/webhooks/answer` and for the Event URL `[paste lambda url]/webhooks/event`.

Now, click the `Link` button next to your recently purchased Vonage virtual number to link your new application to the phone number.

You've purchased a Vonage virtual number, created a Vonage Application, and written the code to handle the voice webhook events. It's time to test your project in action!

## Test It

To test your project once you've deployed it to AWS Lambda call your virtual number and hear the voice reading back your phone number followed by a random fact.

## What Now?

You've now successfully created and deployed a PHP application to AWS Lambda which listens to a webhook waiting for your virtual number to receive a phone call.

Here are some links to other tutorials we've using serverless functions:

* [Build a Basic Video Call Platform with Netlify Functions](https://learn.vonage.com/blog/2020/05/22/build-a-basic-video-call-platform-with-netlify-functions/)
* [Build a Serverless Eurovision Voting System with Node.js and Vonage](https://learn.vonage.com/blog/2020/06/17/build-a-serverless-eurovision-voting-system-with-node-js-and-vonage/)
* [Multi-Channel Tone Analysis in PHP with Amazon Comprehend](https://learn.vonage.com/blog/2020/07/02/multi-channel-tone-analysis-in-php-with-amazon-comprehend/)

As always, if you have any questions, advice or ideas you’d like to share with the community, then please feel free to jump on our [Community Slack workspace](https://developer.nexmo.com/community/slack), or you can contact me directly on [Twitter](https://www.twitter.com/greg__holmes). I'd love to hear how you've gotten on with this tutorial and how your project works.
