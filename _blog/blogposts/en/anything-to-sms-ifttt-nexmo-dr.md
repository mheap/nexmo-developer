---
title: Anything-to-SMS with IFTTT and Nexmo
description: Receive SMS alerts for almost anything; new emails, calendar
  events, weather alerts and more. Learn how with Nexmo SMS API, IFTTT and
  serverless PHP
thumbnail: /content/blog/anything-to-sms-ifttt-nexmo-dr/anything-to-sms-widescreen.png
author: lornajane
published: true
published_at: 2018-09-18T16:45:47.000Z
updated_at: 2021-05-03T21:26:50.334Z
category: tutorial
tags:
  - php
  - sms-api
comments: true
redirect: ""
canonical: ""
---
SMS alerts are a very convenient way to convey small amounts of information in a way that works for most people in most places. I use them both to alert users of my applications and also for my own convenience. In today's post, I'm making use of [IFTTT](https://ifttt.com) (IF This Then That), a tool to link more or less anything to more or less anything else. If that sounds like an extravagant claim, just look at their homepage:

![IFTTT homepage with a wide choice of applets integrating various services](/content/blog/anything-to-sms-with-ifttt-and-nexmo/ifttt-home-1200x600.png "IFTTT homepage")

Today's example is a very simple one using incoming email as the "event" that triggers an SMS, but I've also used IFTTT with calendars, various IoT sensors and webhooks so the possibilities are endless. If you haven't played with IFTTT for any reason, then I'd thoroughly recommend it as a fun way to link up systems that don't already know how to talk to one another.

## Set up the SMS-sending code

I don't need a server to send SMS, instead I'll use a serverless function. Serverless is a way of deploying independent functions to the cloud and running them on demand. Most of the platforms are a pay-as-you-go model with a generous free tier, making this a very cost-effective way to run this low-volume application. If you're new to serverless, check out some of these excellent introduction resources:

* [Five minute introduction to serverless development with OpenWhisk](https://medium.com/openwhisk/five-minute-intro-to-open-source-serverless-development-with-openwhisk-328b0ebfa160)
* [An introduction to serverless and FaaS](https://medium.com/@BoweiHan/an-introduction-to-serverless-and-faas-functions-as-a-service-fb5cec0417b2)
* [Introducing Functions as a Service](https://blog.alexellis.io/introducing-functions-as-a-service/)

The example here uses PHP code and the [IBM Cloud Functions](https://www.ibm.com/cloud/functions) platform, but the idea would work just as well in another programming language or using another serverless platform (if there's a particular technology combination you'd like to see an example of, tell us on [twitter](https://twitter.com/nexmodev) and we'll see what we can do).

The setup will look something like this:

![email, arrow to IFTTT, arrow to cloud function, arrow to Nexmo, arrow to mobile phone](/content/blog/anything-to-sms-with-ifttt-and-nexmo/serverless-ifttt.png "serverless IFTTT")

IFTTT reacts to new email, sending a webhook to the serverless function. That function in turn calls Nexmo's API to send an SMS to the desired phone number. To set this up, you need to deploy the serverless function and then configure IFTTT to send data to it.

### Before you start

You will need:

* A Vonage account
* An IBM Cloud account (or another installation of Apache OpenWhisk)
* The [`ibmcloud` tool with `cloud-functions` plugin](https://console.bluemix.net/docs/openwhisk/bluemix_cli.html#cloudfunctions_cli) (or `wsk` tool for an alternative Apache OpenWhisk installation)

With all those in place, we can begin!

<sign-up></sign-up>

### Get the code

Everything you need is in a handy GitHub repository here: <https://github.com/nexmo-community/email-to-sms>.  Clone this to your local machine (it's not a lot of files, it just saves on copy-and-pasting)

Copy `.env-example` to `.env` and add the values for your Nexmo account (get these from the [dashboard](https://dashboard.nexmo.com)) and the number you want to send an SMS to.

Here's the code in the serverless function that we're about to deploy. I always think it's prudent to read code before running it.

```php
<?php

require "vendor/autoload.php";

function main($params) {
    $body_data = base64_decode($params['__ow_body']);

    $client = new Nexmo\Client(new Nexmo\Client\Credentials\Basic(
        $params['apikey'],
        $params['apisecret']
    ));

	$response = $client->message()->send([
		'to' => $params['tonumber'],
		'from' => 'Email relay',
		'text' => $body_data
	]);
}
```

The `$params` argument to `main()` contains both the incoming body data and the values from `.env` that you set earlier; we can use these values in our code. The code here uses the [Nexmo PHP library](https://github.com/nexmo/nexmo-php) to create a `Nexmo\Client` object that then builds and sends an SMS containing the text from the IFTTT webhook.

### Install the dependencies

Before we can use the Nexmo PHP library, we need to install it using [Composer](https://getcomposer.org).

Each serverless action can have its own dependencies. For the `send_sms` action used here, the dependencies are described in `send_sms/composer.json`. We can install the dependencies by running the command `composer install` from inside the `send_sms` directory.

Once the dependencies are there (you should see a `send_sms/vendor/` folder appear), then we're ready to deploy.

### Deploy the serverless function

Deploy by running the script `./deploy.sh`. Here's that script so you can see what happens - or has already happened if you already ran the command.

```sh
#!/bin/bash

. .env

ibmcloud wsk package update email-to-sms -p apikey $NEXMO_API_KEY -p apisecret $NEXMO_API_SECRET

cd send_sms
zip -rq send_sms.zip index.php vendor
ibmcloud wsk action update email-to-sms/send-sms --kind php:7.1 --web raw -p tonumber $TO_NUMBER send_sms.zip
cd ..
```

What's happening here? Well, something like:

1. Get the environment variables from the `.env` file we configured above.
2. Create the package that our serverless function (usually called an "action" in serverless terminology) will be added to. Set the API credentials that will be needed.
3. Create a zip file with the `index.php` file and also the contents of the `vendor/` folder since we're using an extra library.
4. Deploy the function/action into the package. Since it's a zip file, I set the `--kind` parameter to tell OpenWhisk which runtime to use. The `--web raw` parameter makes the action web-enabled, so we can make web requests to it, but doesn't try to automatically process and extract incoming variables. The `-p` sets a parameter - this case the number to send to. For this example, all the messages will be sent to the same phone number but depending on your use case it might make more sense to pass this in with the webhook.

That function now exists in the cloud. You can check everything worked with a command like this:

```
ibmcloud wsk action list
```

Next, ask the action what URL it has:

```
ibmcloud wsk action get --url sms-by-email/send_sms
```

The response will be a URL - copy it quick! You're about to use it setting up the next part ...

## Setting up the trigger

I'm using Gmail as the input as an easy way of demonstrating everything working. There is an excellent selection of gmail options available to choose from:

![mail options include new mail, mail with attachments, mail from someone in particular, and many more](/content/blog/anything-to-sms-with-ifttt-and-nexmo/choose-gmail-trigger.png "Choose Gmail trigger")

I chose the first option to include all mail. Now it gets more interesting as we configure the resulting action.

## Setting up the webhook

For the resulting action, choose the Webhook:

![choose the webhook as the action](/content/blog/anything-to-sms-with-ifttt-and-nexmo/choose-webhook-action-1200x600.png "Choose webhook action")

And then, using the URL you copied earlier, we can go ahead and configure the webhook:

![Set up the webhook by adding the URL, a POST method, and the text to send](/content/blog/anything-to-sms-with-ifttt-and-nexmo/configure-webhook-1200x600.png "Configure Webhook")

The URL should already be in your clipboard and this example expects a `POST` method as is common for webhooks. Set the content type to `application/json` and then configure the Body as you wish, for example mine looks like this:

```
{{FromName}} sent: {{Subject}}
```

> For this demo, the webhook will accept any and all data sent to it which is very easy to get going but is not wise for production. We'd recommend using an approach such as a [shared secret](https://en.wikipedia.org/wiki/Shared_secret) so that you can verify the webhook is coming from where you think it is.

## Try what you made

At this point, everything should be ready. So turn up the volume on your phone, email yourself, and wait for the SMS alert!

Using this approach, perhaps with different triggers or sending different data through to the serverless function, you can connect more or less anything to SMS with IFTTT as the "glue". Let us know what you build, we love to hear your stories.

## Where next?

Here's a few related resources that you might like to read next:

* [Nexmo SMS](https://developer.nexmo.com/messaging/sms/overview#getting-started) Starting simple: the docs for Nexmo SMS API and code examples in a selection of programming languages (and cURL, in case we're missing yours)
* [SMS Fortune Cookies](https://www.nexmo.com/blog/2018/08/14/serverless-sms-nexmo-ibm-dr/) Another example project using serverless. This one receives SMS as well as sending it and is written in JS.
* Take your SMS implementation to the next level and work with [delivery reciepts](https://www.nexmo.com/blog/2018/08/14/serverless-sms-nexmo-ibm-dr/).