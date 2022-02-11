---
title: Build a Conference Call with the Nexmo Voice API and PHP
description: In this tutorial you will learn how to build a conference call
  "conversation" for multiple participants using PHP and Nexmo.
thumbnail: /content/blog/build-a-conference-call-with-php-dr/php-conference-call-1.png
author: lornajane
published: true
published_at: 2019-05-08T10:27:52.000Z
updated_at: 2021-05-13T20:18:35.510Z
category: tutorial
tags:
  - php
  - voice-api
comments: true
redirect: ""
canonical: ""
---

Today's post will show you how to set up a conference call using Nexmo, so you can distribute a phone number and everyone who calls it will be connected to the same conference call. It's an ideal feature for a regular team meeting or another telephonic get-together. We'll be using PHP for the code examples, using no particular framework, and the code if you want it is available [on GitHub](https://github.com/nexmo-community/php-conference-call).

## Prepare Your Dependencies


<sign-up number></sign-up>

Start a new PHP project and add the [Nexmo PHP library](https://github.com/nexmo/nexmo-php) as a dependency.

```
composer require nexmo/client
```

## Answering an Incoming Call with PHP

For this example, users will call a Nexmo number, and your application code will respond to that incoming call. Nexmo does this by using a Nexmo Call Control Object, or NCCO. First, we'll have a spoken text-to-speech greeting, then the user will join the conference call.

To achieve this, we'll add an `answer.php` file into a `public/` directory (this is our webroot) and have it return the NCCO. The NCCO is JSON, so the PHP also needs to include an appropriate `Content-Type` header:

```php
<?php

// return an NCCO to greet users and connect them into the conference call

$json = '[
    {
        "action": "talk",
        "text": "Thank you for joining the call today. You will now be added to the conference.",
        "voiceName": "Nicole"
    },
    {
        "action": "conversation",
        "name": "weekly-team-meeting"
    }
]
';

header("Content-Type: application/json");
echo $json;
```

The `$json` variable holds the NCCO that you will return to Nexmo's server to instruct how an incoming call will be handled. This example has a "talk" action that greets the user and then a "conversation" action to add the user into the conference call. This code uses `header()` to get PHP to send the `Content-Type` header and then the JSON itself.

> If you're curious what else you can do with an NCCO, you can find the [NCCO reference documentation](https://developer.nexmo.com/voice/voice-api/ncco-reference) on our Developer Portal.

## Serve the Response

At this point, you can start to test the moving parts of the application. Start the PHP webserver from the `public/` directory:

```
cd public/
php -S localhost:8080
```

Check that your application returns the NCCO correctly when you make a request to `http://localhost:8080/answer.php` using your favourite HTTP client (cURL, Postman or even your browser would be good tools to use here).

## Make the Code Publicly Available

For Nexmo to be able to tell your application about an incoming call, it needs to be able to reach it, so this code needs to be publicly available. One option is to deploy it to a server somewhere, but for development purposes, I prefer to use [Ngrok](https://ngrok.com) to expose my local development platform. Once you have the webserver running (mine is on port 8080), run ngrok like this:

```
ngrok http 8080
```

This will give you a dashboard showing a link to the web interface (very useful, click it), the https URL of your tunnel (copy this, we'll need it in a moment), and a section that will show the requests arriving when you make some.

Try out your new tunnel by checking making a call to your application over it—you can replace `http://localhost:8080` with your ngrok https URL and try the request to `/answer.php` again.

## Set Up a Number to Call

> This section shows buying and configuring a number using the CLI tool because that's how I usually work. If you prefer, you can also do these steps using the [account dashboard](https://dashboard.nexmo.com).

First, we'll need a number to call. I'm in the UK so I'll use `GB` as the country code in my search:

```
nexmo number:search GB
```

This command returns a list of available numbers; copy the one you want and then paste it into the next command:

```
nexmo number:buy [number]
```

The other thing needed is an application: this holds the configuration for the calls and can be linked to the number(s) you want to use. This separation is very useful if you want to have numbers in different geographies calling into the same conference call.

Applications use public/private keys; in this example you are simply receiving an incoming call so the private key isn't used, but this example shows how to save it as `private.key` anyway since if you build something more sophisticated you will need it and be glad you saved it! Creating the application needs you to give it a name and configure some important webhook endpoints:
 - The answer URL will be the `answer.php` endpoint you created already.
 - The event URL ... let's call it `event.php` and create it in the next section?

Here is the command to create the application, replace your Ngrok URLs before you run it!

```
nexmo app:create PHPConfCall [ngrok_url]/answer.php [ngrok_url]/event.php --keyfile private.key
```

This command outputs the UUID of the application that it created. The final step here is to link this application to the number you bought. The command for that looks like this (again, replace the placeholders as appropriate).

```
nexmo link:app [number] [application UUID]
```

.... I think you made it! Call the number and see if you hear the greeting; if so, ask someone else to call and enjoy a natter :)

If it doesn't work first time, don't worry. Next is to build the event handling so that you can see what's going on—and if there are errors, this is how you will see them.

## Handle Call Events

To keep things really simple, the application expects its event URL to be at `/event.php`—and if you tested this already then you have seen some failing requests arriving there.

To create a very simple event handler, create a file `public/event.php` and add the following code:

```
<?php

$post_params = json_decode(file_get_contents("php://input"), true);
$input_params = $_GET;

if (is_array($post_params)) {
    $input_params = array_merge($input_params, $post_params);
}

if (isset($input_params['status'])) {
    error_log("Status: " . $input_params['status']);
}
error_log("Event data: " . json_encode($input_params));
```

It's possible to configure the event URL to use either `GET` or `POST` requests so this code will handle either! It's very simple and writes the data to the error_log, so if you're using the local PHP webserver as I did in this example, you will see the events in the output of the webserver process. In a real-world application you can link your event URL to something more formal; for example try the [voice event logger project](https://github.com/Nexmo/voice-event-logger) we built as a starting point.

## Get The <del>Party</del> Conference Call Started

If you didn't try it already, then go ahead and call your Nexmo number. Then invite your friends, family, and colleagues to do the same. You'll see the events during the calls arriving to `event.php` and also the various calls being answered with calls to `answer.php`.

## Your Next Move?

There are a few things you might like to do next, how about:

* Look at the [NCCO documentation](https://developer.nexmo.com/voice/voice-api/ncco-reference) for how to record the calls, play hold music, or have a particular moderator for the call.
* View the code for this project [on GitHub](https://github.com/nexmo-community/php-conference-call).
* Check out our other [code snippets for working with Nexmo Voice API](https://developer.nexmo.com/voice/voice-api/code-snippets/before-you-begin).
* Go a step further and try the [Interactive Voice Response tutorial](https://developer.nexmo.com/tutorials/interactive-voice-response) (it also uses PHP!).

