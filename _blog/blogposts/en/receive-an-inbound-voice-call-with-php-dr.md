---
title: Receive an Inbound Voice Call with PHP
description: Learn how to write a PHP application that handles inbound voice
  calls and returns a dynamic response using the Nexmo Voice API.
thumbnail: /content/blog/receive-an-inbound-voice-call-with-php-dr/inbound-voice-calls.png
author: mheap
published: true
published_at: 2018-06-28T14:39:09.000Z
updated_at: 2021-05-13T11:27:08.204Z
category: tutorial
tags:
  - php
  - voice-api
comments: true
redirect: ""
canonical: ""
---
In our last PHP and voice blog post, we covered how to make an [outbound voice call using Text-To-Speech](/blog/2017/10/20/text-to-speech-voice-calls-with-php-dr/). In this post, we're going to change direction and write an application that handles inbound voice calls and returns a dynamic response.

The source code for this blog post is available [on Github](https://github.com/nexmo-community/nexmo-php-quickstart/tree/master/voice/inbound-calls-slim).

## Prerequisites

<sign-up number></sign-up>

You’ll need PHP installed before working through this post. I’m running PHP 7.2, but the code here should work on PHP 5.6 and above. You'll also need [Composer](http://getcomposer.org/) to download our dependencies.

Finally, you'll need the [Vonage CLI](https://github.com/Vonage/vonage-cli) installed. We'll be using this to configure our Vonage account and purchase a phone number.

## Receiving a phone call with PHP

Before we get into the details about how it all works, we'll start by creating a PHP application to handle incoming voice calls. When a voice call is received, Vonage will make a request to your application to find out how to respond to that call.

We're going to be using the [Slim framework](https://www.slimframework.com/) to handle the incoming request, so let's install it now with `composer`:

```bash
composer require slim/slim "^3.0"
```

Once that has completed, create a new file named `index.php` with the following contents. This will create a new Slim application and register a single endpoint (`/webhook/answer`) that accepts a `GET` request with a `from` query string parameter and returns the `from` value in the body.

```php
<?php
use \Psr\Http\Message\ServerRequestInterface as Request;
use \Psr\Http\Message\ResponseInterface as Response;

require 'vendor/autoload.php';

$app = new \Slim\App;
$app->get('/webhook/answer', function (Request $request, Response $response) {
    $params = $request->getQueryParams();
    return $response->withJson($params['from']);
});

$app->run();
```

Save this file and then open up a new terminal window. Let's start the built in PHP server and serve our application on port 8000.

```bash
php -t . -S localhost:8000
```

If you visit [http://localhost:8000/webhook/answer?from=14155550100](http://localhost:8000/webhook/answer?from=14155550100), you will see the `from` number returned in the response body.

This is a great start, but Vonage won't know what to do if we only respond with the caller's phone number. To tell Vonage how to handle the call, we have to return an [NCCO](https://developer.nexmo.com/api/voice/ncco).

To keep things simple, we'll use Text-To-Speech to read the caller's phone number back to them, digit by digit. First, we split their number in to an array of characters, then join them together using spaces:

```php
$fromSplitIntoCharacters = implode(" ", str_split($params['from']));
```

Next, we define an NCCO that uses the `talk` action to read out these characters:

```php
$ncco = [
    [
        'action' => 'talk',
        'text' => 'Thank you for calling from '.$fromSplitIntoCharacters
    ]
];
```

Then finally, we return this NCCO instead of `$params['from']`:

```php
return $response->withJson($ncco);
```

When we put it all together, `index.php` looks like the following:

```php
<?php
use \Psr\Http\Message\ServerRequestInterface as Request;
use \Psr\Http\Message\ResponseInterface as Response;

require 'vendor/autoload.php';

$app = new \Slim\App;
$app->get('/webhook/answer', function (Request $request, Response $response) {
    $params = $request->getQueryParams();
    $fromSplitIntoCharacters = implode(" ", str_split($params['from']));

    $ncco = [
        [
            'action' => 'talk',
            'text' => 'Thank you for calling from '.$fromSplitIntoCharacters
        ]
    ];

    return $response->withJson($ncco);
});

$app->run();
```

Visit [http://localhost:8000/webhook/answer?from=14155550100](http://localhost:8000/webhook/answer?from=14155550100) again and you will see the following returned:

```json
[
  {
    "action": "talk",
    "text": "Thank you for calling from 1 4 1 5 5 5 5 0 1 0 0"
  }
]
```

Congratulations! You just wrote an application that receives an inbound phone call and responds with some dynamic content. You can customise your response using any of the parameters that Vonage provide, including `to`, `from` and `conversation_uuid`.

## Exposing your application with ngrok

We've built an application that responds how we'd expect, but there's one big problem at the moment. Vonage are supposed to make a request to it when a call is received but it's running on our local machine!

Don't worry though, ngrok can save the day. If you're unfamiliar with ngrok, there's a fantastic [introduction to ngrok](/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) available on the Vonage blog.

Once you have ngrok installed, run `ngrok http 8000` to expose your application to the internet. You'll need to make a note of the `ngrok` URL generated as we'll need to provide it to Vonage (it'll look something like `http://abc123.ngrok.io`).

## Configure your Vonage account

Once your application is exposed to the internet, the final thing to do is hook it up to a Vonage phone number. Let's start by purchasing a phone number using the Vonage CLI. First, search for a number:

```bash
vonage numbers:search US
```

Then buy one of the numbers listed as available:

```bash
vonage numbers:buy <number> US
```

The next step is to create a Vonage application, which is a container for all the settings required for your application. In this case we need to tell Vonage which URL to make a request to when a call is received (`answer_url`), and where to send any event information about the call (`event_url`).

We can use the Nexmo CLI to create an application, making sure to substitute `http://abc123.ngrok.io` for your own generated URL. We provide a name, then an `answer_url` and `event_url` for the application:

```bash
vonage apps:create "InboundCalls" --voice_answer_url=http://abc123.ngrok.io/webhook/answer --voice_event_url=http://abc123.ngrok.io/webhook/event
```

Make a note of your application's ID (it'll look similar to `aaaaaaaa-bbbb-cccc-dddd-0123456789ab`) then carry on reading.

The final thing to do is to link the number you purchased to the application you just created. This will tell Vonage that when a call is received, they should make a `GET` request to the application's `answer_url` to find out how to proceed with the call.

Once again, we can use the Nexmo CLI to do this, replacing the example phone number and application ID with your own:

```bash
vonage apps:link aaaaaaaa-bbbb-cccc-dddd-0123456789ab --number=14155550100
```

That's everything we needed to do for Vonage to associate our PHP application to an incoming phone call. Give it a go now by calling the phone number you purchased.

## Conclusion

Together, we just built an application that can receive an incoming phone call and dynamically generate a response in just 22 lines of code!

If you want to learn more about voice calls with PHP and Vonage, you can find [example building blocks](https://developer.nexmo.com/voice/voice-api/building-blocks/make-an-outbound-call) in Nexmo Developer. Alternatively, if you want to make your inbound call response more complex (e.g. recording the audio from the caller) you can learn more about NCCOs in the [NCCO reference](https://developer.nexmo.com/api/voice/ncco)

As always, if you have any questions about this post feel free to email devrel@nexmo.com or [join the Nexmo community Slack channel](https://developer.nexmo.com/community/slack), where we're waiting and ready to help.