---
title: Asynchronous PHP With Revoltphp & Vonage Voice API
description: Think async PHP doesn't exist? It sure does, and now it's native!
thumbnail: /content/blog/asynchronous-php-with-revoltphp-vonage-voice-api/revolt-php_voiceapi.png
author: james-seconde
published: true
published_at: 2021-11-12T07:27:21.379Z
updated_at: 2021-11-08T20:08:25.796Z
category: tutorial
tags:
  - php
  - voice-api
comments: false
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
It may surprise some readers that asynchronous PHP is nothing new. PHP5.5 introduced generators way back in 2014 which set us on this path, and since then we have seen the creation of [amphp](https://amphp.org/), [ReactPhp](https://reactphp.org/), and [OpenSwoole](https://www.swoole.co.uk/).

## Hello, fibers!

PHP developers tend not to think in terms of async programming due to the nature of the request/response lifecycle (with the encapsulated state) we are comfortable working with. Something has happened that might just change that though: [the introduction of native fibers to PHP8.1](https://wiki.php.net/rfc/fibers). While fibers may not be "true" async execution while runtimes like [node.js](https://nodejs.org/en/) and [Go](https://golang.org/) are, it certainly can give you a massive performance boost if executed without any blocking I/O.

## Hello, RevoltPhp!

A new project has been created off the back of the release of PHP8.1, [RevoltPhp](https://revolt.run/), which is a collaboration from the creators of amphp & ReactPhp, aiming to bring their experience in co-routines to utilise the new fibers feature. While it's best to think of it as more an "underlying library" for a framework to use on top of it (concepts such as Read/Writeable Stream callbacks can be pretty difficult to navigate), I'm going to show you a small taster of how you can learn this concept.

## Emergency! Asset out of containment!

![Dinosaurs roaming freely out of their pens!](/content/blog/asynchronous-php-with-revoltphp-vonage-voice-api/mehmet-turgut-kirkgoz-15zmeuktjm-unsplash.jpg)

OK, what I mean is that I'm going to introduce our use case, but I like being a tad dramatic at times. Let's say we have our real-world dinosaur park. The workforce needs to be notified when a furious, human-eating lizard escapes out of its pen. Thing is, the communications system was written in <insert your favourite PHP framework of choice>, and therefore is technically in a blocking I/O language. You need to use Vonage to call 2000 park workers simultaneously with a text-to-voice warning, right? Let's get to making an asynchronous code thread.

## Setting up: PHP 8.1, Composer, Slim, ngrok, Vonage, RevoltPhp

#### PHP 8.1

You'll need PHP 8.1 for this, which has not officially been released. Mac users can find it under [shivammathur's homebrew repository](https://github.com/shivammathur/homebrew-php), Linux users can find it on [ondrej's apt PPA](https://launchpad.net/~ondrej/+archive/ubuntu/php/), and Windows users can find it on the QA section of [PHP for Windows](https://windows.php.net/qa/).

#### Composer

We need composer, PHP's de-facto dependency manager, so [follow the installation instructions for that here](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-macos) if you've not already got it.

#### Project space

The following requirements will need your project space, so create a new directory where the code will sit and use composer to create a `composer.json` configuration. Do this by running the following in your blank directory:

`composer init`

#### Slim Framework

To have a truly non-blocking Event Loop *and* have HTTP request handling, you'd want to use something like [ReactPhp's HTTP client](https://reactphp.org/http/). For this example though, we need some routes open for the Voice API handling, and [Slim](https://www.slimframework.com/) is a quick way to do this. To get it, we use composer:

`composer require slim/slim`

We also need a PSR-7 compliant library to handle requests/responses (I've gone with Guzzle's, but several options are available):

`composer require guzzlehttp/psr7`

#### ngrok

If you've not come across [ngrok](https://ngrok.com) before, it's a super useful tool for creating secure URL tunnels into your localhost. We'll need this for Vonage's webhooks to work. Check out the [installation instructions here](https://ngrok.com/download) and create yourself an account.

#### Vonage Voice API

Vonage provides a fully-featured API for sending and receiving calls, so we're going to use the core [PHP SDK](https://github.com/Vonage/vonage-php-sdk-core) to send outbound calls. Install it with composer:

`composer require vonage/client-core`

### RevoltPhp

Finally, we need to get the Event Loop from RevoltPhp. It's currently still pre-release, so you'll need to specify the dev branch:

`composer require revolt/event-loop:dev-main`

## Setting up Vonage Applications & Numbers

To create outbound calls to warn the blissfully ignorant park workers of the danger at bay, you'll need to set up your Vonage account accordingly.

<sign-up number></sign-up>

Create a new application with Voice capability enabled and download the application keys.

## Make that call!

OK, let's get going on the Slim application. Create a directory in your project route named `/public` and create a new php file in it named `index.php`. Our file will look like this:

```php
<?php
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;
use Vonage\Client;
use Vonage\Client\Credentials\Keypair;
use Vonage\Voice\Endpoint\Phone;
use Vonage\Voice\OutboundCall;
use Vonage\Voice\Webhook;

require __DIR__ . '/../vendor/autoload.php';

$keypair = new Keypair(
    file_get_contents('../revolt_php_example.key'),
    '940597b9-7f52-416f-8fd4-a19e0f689602'
);

$vonage = new Client($keypair);

$faker = Faker\Factory::create('en_GB');

$phoneNumbers = [];

for ($i = 1; $i < 1201; $i++) {
    $phoneNumbers[] = $faker->phoneNumber();
}

$app = AppFactory::create();

$app->get('/code32', function (Request $request, Response $response) use ($phoneNumbers, $vonage) {
    foreach ($phoneNumbers as $outboundNumber) {

        $outboundCall = new OutboundCall(
            new Phone($outboundNumber),
            new Phone('999999')
        );

        $outboundCall
            ->setAnswerWebhook(
                new Webhook('/webhook/answer', 'GET')
            )
            ->setEventWebhook(
                new Webhook('/webhook/event', 'GET')
            );

        $vonage->voice()->createOutboundCall($outboundCall);
    }

    $response->getBody()->write('Park employees notified.' . PHP_EOL);

    return $response;
});

$app->run();
```

There's a lot to digest here, so let's break it down.

Firstly we're setting up our Vonage client with our applicaton credentials we created earlier using a `Keypair` object and reading in the SSH key you downloaded as the first argument, with the application ID as the second:

```php
$keypair = new Keypair(
    file_get_contents('../my-example-app.key'), //  <- SSH key downloaded from Vonage dashboard and put in the root directory
    '9999999-7f52-416f-8fd4-a19e0f689602' // <- application key here
);

$vonage = new Client($keypair);
```

Next, we simulate a payload of phone numbers to call by using the [faker](https://github.com/FakerPHP/Faker/) library, set to a variable named `$phoneNumbers`.

```
$faker = Faker\Factory::create('en_GB');

$phoneNumbers = [];

for ($i = 1; $i < 2001; $i++) {
    $phoneNumbers[] = $faker->phoneNumber();
}
```

Faker allows you to set a locale, so in this case, I chose UK numbers by setting it to 'en_GB'. If you want to set a different locale, [have a look at the faker documentation here](https://fakerphp.github.io/).

We're using a classic `for` loop to create the phone numbers into an array here, so we now have 2000 phone numbers ready to get their dino warnings. How do we do it? With a `foreach` loop in the endpoint:

```php
$app->get('/code32', function (Request $request, Response $response) use ($phoneNumbers, $vonage) {
    foreach ($phoneNumbers as $outboundNumber) {

        $outboundCall = new OutboundCall(
            new Phone($outboundNumber),
            new Phone('MY_VIRTUAL_NUMBER') // <- this is a dummy phone number, make it your virtual number on your app
        );

        $outboundCall
            ->setAnswerWebhook(
                new Webhook('/webhook/answer', 'GET')
            )
            ->setEventWebhook(
                new Webhook('/webhook/event', 'GET')
            );

        $vonage->voice()->createOutboundCall($outboundCall);
    }

    $response->getBody()->write('Park employees notified.' . PHP_EOL);

    return $response;
});
```

> This tutorial is simulating an example, so don't run this live! The reason
> is that 2000 fake phone numbers will be generated, and Vonage will attempt
> to phone them all!

So, we have an endpoint to hit on our app. It will loop through all the phone numbers to call, but there are two things needed to complete our **synchronous** warning. Do you see that `setAnswerWebhook()` method in the code above? Well, once we make that outbound call, Vonage needs to know what to do with it. This is where ngrok and our webhooks come in.

## Wiring the calls

Ngrok will open a tunnel up and give you a URL to localhost when you launch it. PHP has a built-in web server, so we'll use that for localhost and then fire ngrok to open the tunnel. While in the `public` directory we created, start the built-in PHP web server:

```
php -S 0.0.0.0:8000 -t .
```

Port 8000 is now opened up on our machine, so enter the following to get ngrok to tunnel it:

```
ngrok http 8000
```

All being well, you'll get a response like this:

![Screenshot of ngrok running as a process](/content/blog/asynchronous-php-with-revoltphp-vonage-voice-api/screenshot-2021-11-09-at-20.33.37.png)

The URL it gives you will need to be added to your Vonage application. Navigate to your Vonage application on your dashboard, and hit edit. In the Edit Application panel you can set the voice webhooks for incoming calls; take the ngrok URL and add the paths we've put placeholders in when setting the webhooks in our PHP code. For example, if ngrok created the URL `https://aef9-82-30-208-179.ngrok.io`, we would change our webhook URLs to

* https://aef9-82-30-208-179.ngrok.io/webhooks/answer
* https://aef9-82-30-208-179.ngrok.io/webhooks/event

Here is where you edit them in the Vonage dashboard:

![Screenshot of the web voicehooks section in the Vonage dashboard](/content/blog/asynchronous-php-with-revoltphp-vonage-voice-api/screenshot-2021-11-09-at-20.56.31.png)

Then we change our PHP code for our route would now look like this when setting the webhooks:

```
$baseUrl = 'https://aef9-82-30-208-179.ngrok.io'

$outboundCall
    ->setAnswerWebhook(
        new Webhook($baseUrl . '/webhook/answer', 'GET')
    )
    ->setEventWebhook(
        new Webhook($baseUrl . '/webhook/event', 'GET')
    );
```

## Setting the warning

We're going to issue our dino warning with a new route that the answer webhook is pointing to. To use Vonage text-to-speech, we use what is called an `NCCO object`, which is a fancy term for a JSON object that controls what to do with the call. Add the following route to your `index.php`:

```
$app->get('/webhook/answer', function (Request $request, Response $response) {
    $ncco = [
        [
            'action' => 'talk',
            'language' => 'en-GB',
            'style' => 1,
            'text' => 'This is a code 32. Asset #784 is out of containment.'
        ]
    ];

    $response->getBody()->write(json_encode($ncco));

    return $response
        ->withHeader('Content-Type', 'application/json');
});
```

The NCCO object is given as a JSON response to the webhook, so Vonage knows what to do with it - in this case, the `language` and `style` of your choosing will read out the `text` you give it as you choose.

## Back to Async vs. Sync

We have an endpoint for our outbound calls, we have a reply to give when people answer the emergency call. But, the point of this article was about asynchronous code, right? Our emergency endpoint, when hit at runtime, will synchronously loop through each number and phone it; that's PHP. So, now it's time for fibers.

## Introducing RevoltPhp

RevoltPhp's Event Loop will continue executing any work until there is no more work to do, and hand back control to the parent thread (this is usually the termination of the application because for a non-blocking I/O PHP app we want the `EventLoop` to *never* run out of work).

In our case, our outbound calls are currently synchronous and blocking within the `foreach` loop. We want to notify all 2000 park employees at once before the inevitable chaos ensues.

RevoltPhp's Event Loop defines six core callbacks that the `EventLoop` class will execute:

* **Defer**

> The callback is executed in the next iteration of the event loop. If there are defers scheduled, the event loop won’t wait between iterations.

* **Delay**

> The callback is executed after the specified number of seconds. Fractions of a second may be expressed as floating-point numbers.

* **Repeat**

> The callback is executed after the specified number of seconds, repeatedly. Fractions of a second may be expressed as floating-point numbers.

* **Stream readable**

> The callback is executed when there’s data on the stream to be read, or the connection is closed.

* **Stream writable**

> The callback is executed when there’s enough space in the write buffer to accept new data to be written.

* **Signal**

> The callback is executed when the process received a specific signal from the OS.

OK, so we need to create callbacks within our route. From our requirements, we're going to need the `repeat` callback. Here's what it looks like:

```php
$app->get('/code32', function (Request $request, Response $response) use ($phoneNumbers, $vonage) {
    EventLoop::repeat(0, function ($callbackId) use ($phoneNumbers, $vonage): void {
        static $i = 0;

        if (isset($phoneNumbers[$i])) {
            $outboundCall = new OutboundCall(
                new Phone($phoneNumbers[$i]),
                new Phone('MY_VIRTUAL_NUMBER') // <- this is a dummy phone number, make it your virtual number on your app
            );
            $baseUrl = 'https://aef9-82-30-208-179.ngrok.io'

            $outboundCall
                ->setAnswerWebhook(
                    new Webhook($baseUrl . '/webhook/answer', 'GET')
                )
                ->setEventWebhook(
                    new Webhook($baseUrl . '/https://aef9-82-30-208-179.ngrok.io/webhook/event', 'GET')
                );

            $vonage->voice()->createOutboundCall($outboundCall);
            $i++;
        } else {
            EventLoop::cancel($callbackId);
        }
    });

    EventLoop::run();

    $response->getBody()->write('Outbound calls sent.' . PHP_EOL);

    return $response;
});
```

**Woah!** So what is this?

## The Event Loop

`EventLoop::run();` will continue to work *as long as it has work*. So, what we're doing is creating a workload with the static callback creation `EventLoop::repeat()`. Here are the main parts to it:

* The first argument to the callback is 0, as this is a float for the interval we want between iterations. No delays please, we have dinos on the loose!
* The second is our callback generation - we get the `callbackID` for fiber management.
* The `$static` variable keeps a counter of how many callbacks are being created. It's being used as an index for the `$phoneNumbers`, so once we have no more data, `isset($phoneNumbers[$i])` is false and so we cancel the Event Loop with our callback ID for reference.

That's the code part, but what's going on under the hood? Finally, we get to:

## Asynchronous PHP

Unlike traditional PHP synchronous operations, from the moment the Event Loop is run, the encapsulated `repeat` callbacks get spread across PHP's runtime fibers. That's 2000 calls fired with fibers instead of being executed synchronously. What is interesting from the PHP developers' point of view is that this has been done without some of the common engineering approaches of spreading the load, such as using [Laravel](https://laravel.com/docs/8.x/queues) Job/Queue worker or a Serverless architecture with [Bref](https://bref.sh/) tied to [Google Cloud Compute](https://cloud.google.com/compute) or [AWS Lambda](https://aws.amazon.com/lambda/). These are all perfectly good approaches, but the main point here is that our approach **is plain PHP**.

Thanks to Vonage and RevoltPhp, we call all be safe a little quicker, thanks to the tireless efforts of our park staff getting that asset back into containment as fast as possible.