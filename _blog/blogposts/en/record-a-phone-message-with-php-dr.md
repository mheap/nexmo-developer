---
title: Record a Phone Message with PHP
description: Learn how to create an application that will allow you to record a
  voice call message.
thumbnail: /content/blog/record-a-phone-message-with-php-dr/record-a-phone-message.png
author: martyn
published: true
published_at: 2018-08-14T22:49:18.000Z
updated_at: 2021-04-19T14:09:45.846Z
category: tutorial
tags:
  - php
  - voice-api
comments: true
redirect: ""
canonical: ""
---
Recording a phone message is the key first step in building a fully fledged voice mail system. In this tutorial, we'll go through the steps required to set up a phone number with the ability to record an incoming call using PHP and the Nexmo command line interface.

The code for this tutorial can be found in our [PHP Building Blocks](https://developer.nexmo.com/voice/voice-api/building-blocks/record-a-message) section.

## Prerequisites

You'll need the following things:

- A phone number that isn't already associated with another app
- PHP (>5.6), [Composer](https://getcomposer.org/) & the [Slim framework](https://www.slimframework.com/)
- [ngrok](https://ngrok.com/)

<sign-up number></sign-up>

The code you will create is expected to work with any version of PHP 5.6 or above.

Our recommended way of working with Nexmo, from an administration point of view, is to use our command line tool, [Nexmo-CLI](https://developer.nexmo.com/tools).

In order to make the code on our local machine accessible to the outside world, we're going to use [ngrok](https://ngrok.com), so ensure you have that installed as well.

## Receiving and recording a phone message

Start by installing Slim into your working folder if you haven't already done so.

```bash
composer require slim/slim "^3.9"
```

You'll need just one PHP file for this example, so create one called `index.php` in your working folder and open it in your editor of choice.

Add the following code to your `index.php`:

```php
<?php
use \Psr\Http\Message\ServerRequestInterface as Request;
use \Psr\Http\Message\ResponseInterface as Response;

require 'vendor/autoload.php';

$app = new \Slim\App;

$app->get('/webhooks/answer', function (Request $request, Response $response) {
  $uri = $request->getUri();
  $ncco = [
      [
          'action' => 'talk',
          'text' => 'Please leave a message after the tone, then press #. We will get back to you as soon as we can'
      ],
      [
          'action' => 'record',
          'eventUrl' => [
              $uri->getScheme().'://'.$uri->getHost().'/webhooks/recording'
          ],
          'endOnSilence' => '3',
          'endOnKey' => '#',
          'beepOnStart' => true
      ],
      [
          'action' => 'talk',
          'text' => 'Thank you for your message. Goodbye'
      ],

  ];

  return $response->withJson($ncco);
});

?>
```

Let's walk through what is happening here:

1. The incoming call will be routed through to `/webhooks/answer`, then the NCCO will take over.
2. The NCCO reads a message to the caller.
3. Then the callers message is recorded.
4. The recording data is passed to a new `eventUrl`, in this case `/webhooks/recording`.
5. A message is spoken, letting the user know their message was received, and then the NCCO hangs up.

You'll notice that it is the `$ncco` array that handles most of the work in this function.

NCCO stands for Nexmo Call Control Object and is a JSON array that you use to control the flow of a Voice API call.

You can dig deeper into the functionality of the NCCO, and learn more about how to extend the capabilities of your app by reading the [reference documentation](https://developer.nexmo.com/voice/voice-api/ncco-reference).

## Handle the recorded message

In the code above, the NCCO has a record action with an `eventUrl` in it, which has been set to `/webhooks/recording`. This is where all the data about the recording, including the location of the recorded file, will be sent.

However, right now it doesn't exist, so below the `/webhooks/answer` route, and before `$app->run();`, add this new code:

```php
$app->post('/webhooks/recording', function (Request $request, Response $response) {
    $params = $request->getParsedBody();
    error_log($params['recording_url']);
    return $response->withStatus(204);
});
```

Let's walk through this route and its function:

1. It receives a POST request with a JSON object containing all kinds of info about our recording.
2. It logs the URL of the recording that was made.
3. Responds with the status 204, so the NCCO doesn't keep trying to send this over and over again.

## Running the code

Now, you're set up and ready to run the code. You can do that by entering the following command in your terminal:

```bash
php -t . -S localhost:3000
```

This will start a server and route any traffic to `http://localhost:3000` through to your `index.php` file.

## Expose your app with ngrok

In order to properly test this code, and allow Nexmo to make requests to your app, you need to expose the code running on your local machine to the world.

[ngrok](https://ngrok.com/) is our tool of choice for this, and we've provided a great [introduction to the tool](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) that you can read to get up to speed if you haven't used it before.

Once you have ngrok installed, run `ngrok http 3000` to expose your application to the internet. Make a note of the `ngrok` URL generated as you’ll need to provide it to Nexmo in the next step (it’ll look something like `http://45hfh5.ngrok.io`).

## Buy a number & connect your app

With the code completed, and your app available to the world, you now need to get yourself a phone number and link your app to it.

Start by purchasing a number via the Nexmo CLI:

```bash
nexmo number:buy  --country_code GB
```

You can use a different country code if you want to. Make a note of the number you purchase, as you'll need it for the next step.

Next, use the Nexmo CLI to create your application making sure you substitute `<your_ngrok_url>` with the newly generated URL that ngrok gave you earlier:

```bash
nexmo app:create "RecordMessage" <your_ngrok_url>/webhooks/answer <your_ngrok_url>/webhooks/events
```

The response you'll get back will contain a huge private key output and, above that, an _application ID_.

Make a note of the application ID (which looks like this: `e7b25242-77a1-42cd-a32e-09fbbcb375f4`) and then link it to your new number using this command:

```bash
nexmo link:app <your_nexmo_number> <your_application_id>
```

Now you code is connected to the number! You can test it out by dialling the number you purchased and following the steps that are magically spoken to you on the other end of the line!

Check your console output after you finish recording your message. There you'll see the `recording_url`. If you want to then download this, take a look a the [Download a recording](https://developer.nexmo.com/voice/voice-api/building-blocks/download-a-recording) building block and add that additional code to your app.

## Conclusion

Once you know how to record messages, you can quickly extend this code into a more fully fledged voicemail system by writing the `recording_url` to a database and adding a simple front end to allow users to listen to messages.

You could also extend the app to send an SMS message notification to someone when a new message is recorded, or even email the recordings to a predetermined email address.

As ever, this is just the start. Feel free to ask questions, or share what you've been building in the [Nexmo Community Slack channel](https://developer.nexmo.com/community/slack), or directly with us on [devrel@nexmo.com](mailto://devrel@nexmo.com).
