---
title: Handle Keypad Input (DTMF) with PHP
description: Learn how to handle keypad input (DTMF) with PHP
thumbnail: /content/blog/handle-user-input-with-php-dr/keypad-input-php.png
author: martyn
published: true
published_at: 2018-08-10T13:59:06.000Z
updated_at: 2021-04-19T14:12:53.806Z
category: tutorial
tags:
  - php
  - voice-api
comments: true
redirect: ""
canonical: ""
---
In this tutorial, we're going to go through everything you need to know to set up a PHP application that can receive inbound calls and capture user input entered via the keypad.

By following this tutorial you will end up with a simple application that can be extended to include more complex, interactive elements and give you a head start building interactive menus for your callers.

The code for this tutorial can be found on [GitHub](https://github.com/nexmo-community/nexmo-php-quickstart/tree/master/voice/user-input-dtmf-slim).

## Prerequisites

TL;DR - You'll need the following things:

- A phone number that isn't already associated with another app
- PHP (>5.6), [Composer](https://getcomposer.org/) & the [Slim framework](https://www.slimframework.com/)
- [ngrok](https://ngrok.com/)

<sign-up number></sign-up>

Here's the long version:

If you want to follow along then you'll need a Nexmo account to get started, so sign up now if you don't have one already.

Receiving a phone call with Nexmo is charged at €0.0045/min and you will have to rent a number for people to call. We'll cover doing that later.

The example code uses the [Slim framework](https://www.slimframework.com/) for handling requests. We've chosen this because of its simplicity and readability but, if you're familiar with PHP and would like to handle this in a different way, you are welcome to use something different. You'll need to install Slim using [Composer](https://getcomposer.org/) so make sure you have that set up as well.

The code you will create is expected to work with any version of PHP 5.6 or above.

Our recommended way of working with Nexmo, from an administration point of view, is to use our command line tool, [Nexmo-CLI](https://developer.nexmo.com/tools).

In order to make the code on our local machine accessible to the outside world, we're going to use [ngrok](https://ngrok.com), so ensure you have that installed as well.

## Receiving the inbound call

When Nexmo receives a call on a number you have rented, an HTTP request is made to a URL (a 'webhook', that you specify) that contains all of the information needed to receive and respond to the call. This is commonly called the _answer URL_.

We'll also be collecting DTMF input from our callers. DTMF stands for _Dual Tone Multifrequency_ and, in the case of this tutorial, occurs when a user presses a number on their keypad.

Whenever a DTMF input is collected from the user, this is sent to a different URL in your app which we'll also have to specify.

Next, we will begin by writing the code needed to handle these requests.

To install Slim using Composer run the following command inside the project folder in your terminal:

```bash
composer require slim/slim "^3.0"
```

Next up, in your main folder, create a new file called `index.php` and add the following code to it:

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
            'text' => 'Please enter a digit'
        ],
        [
            'action' => 'input',
            'maxDigits' => 1,
            'eventUrl' => [
                $uri->getScheme().'://'.$uri->getHost().'/webhooks/dtmf'
            ]
        ]
    ];

    return $response->withJson($ncco);
});

$app->run();
```

With this code we're setting up a new URL in our app, `webhooks/answer`, that will respond to any incoming calls to your phone number with the directions provided in the `$ncco` array.

The `$ncco` will perform these steps once the call is answered:

1. Read out the text 'Please enter a digit'
2. Capture the digit entered by the caller
3. Pass input that was captured over to the route that handles the input, `/webhooks/dtmf`

## Handle the user input

Let's add the code to handle incoming DTMF in `index.php`:

After the code we entered above, and before `$app->run();` add the following:

```php
$app->post('/webhooks/dtmf', function (Request $request, Response $response) {
    $params = $request->getParsedBody();

    $ncco = [
        [
            'action' => 'talk',
            'text' => 'You pressed '.$params['dtmf']
        ]
    ];

    return $response->withJson($ncco);
});
?>
```

This route's function will perform the following steps:

1. Receive the input from `/webhooks/answer`
2. Parse the request body into a variable, `$params`
3. Create a new `$ncco` array that speaks back to the caller and tells them which number they pressed.

For reference, your final `index.php` file should look exactly like [this one](https://github.com/nexmo-community/nexmo-php-quickstart/blob/master/voice/user-input-dtmf-slim/index.php).

Now, you're set up and ready to run the code, you can do that by entering the following command in your terminal:

```bash
php -t . -S localhost:3000
```

This will start a server and route any traffic to `http://localhost:3000` through to your `index.php` file.

## Expose your app with ngrok

In order to allow Nexmo to make requests to your app, you need to expose the code running on your local machine to the world.

ngrok is our tool of choice for this, and we've provided a great [introduction to the tool](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) that you can read to get up to speed if you haven't used it before.

Once you have ngrok installed, run `ngrok http 3000` to expose your application to the internet. You’ll need to make a note of the `ngrok` URL generated as we’ll need to provide it to Nexmo in the next step (it’ll look something like `http://45hfh5.ngrok.io`).

## Buy a number and create an app

With the code completed, and our app available to the world, we now need to get ourselves a phone number and link this code, that will be running locally, to it.

Let's start by purchasing a number via the Nexmo CLI:

```bash
nexmo number:buy  --country_code US
```

You can use a different country code if you want to. Make a note of the number you purchase, as we'll need it for the next step.

We now need to create a Nexmo application, which is a container for all the settings required for your application. In this case, we need to tell Nexmo which URL to make a request to when an incoming call is received (the `answer_url`), and where to send any event information about the call (the `event_url`, you can find out more about events in the [Call Flow](https://developer.nexmo.com/voice/voice-api/guides/call-flow#events) documentation).

Use the Nexmo CLI to create your application making sure you substitute `<your_ngrok_url>` with your own generated URL that ngrok gave you earlier:

```bash
nexmo app:create "DTMFInput" <your_ngrok_url>/webhooks/answer <your_ngrok_url>/webhooks/events
```

The response you'll get back will contain a huge private key output and, above that, an application ID. You can ignore the private key as it isn't necessary for handling inbound calls.

Make a note of the application ID (which looks like this: `e7a25242-77a1-42cd-a32e-09febcb375f4`) and then link it to your new number:

```bash
nexmo link:app <your_nexmo_number> <your_application_id>
```

That's everything needed to associate the code above with your Nexmo app and number. You can test it out by dialling the number you purchased and following the steps that are magically spoken to you on the other end of the line!

## Conclusion

In just thirty lines of PHP, you now have an app that can receive an incoming call and collect DTMF input from the caller. How could you expand this from here?

If you want to learn more about what is possible with inbound voice calls, and how you can make them more complex by adding features such as recording audio, you can learn more about how to operate your NCCOs in the [NCCO reference](https://developer.nexmo.com/api/voice/ncco).

As always, if you have any questions about this post feel free to email devrel@nexmo.com or [join the Nexmo community Slack channel](https://developer.nexmo.com/community/slack), where we’re waiting and ready to help.

