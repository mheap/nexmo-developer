---
title: Announcing the PHP Server SDK Version 2.2.0 Release
description: I am happy to announce the release of version 2.2.0 of our PHP
  Server SDK for the Vonage APIs. While this is a minor release for the SDK, it
  is packed full of new features from the upcoming version 3.0.0 that we will be
  doing soon. You can start using many new features right away while still
  maintaining access to the SDK's existing capabilities.
thumbnail: /content/blog/announcing-the-php-server-sdk-version-2-2-0-release/Blog_PHP-SDK-Update_1200x600.png
author: christankersley
published: true
published_at: 2020-08-03T15:26:51.000Z
updated_at: 2021-05-05T08:54:44.680Z
category: release
tags:
  - php
  - sdk
  - release
comments: true
redirect: ""
canonical: ""
---
I am happy to announce the release of [version 2.2.0](https://github.com/Nexmo/nexmo-php/releases/tag/2.2.0) of our [PHP Server SDK](https://github.com/Nexmo/nexmo-php) for the Vonage APIs.

While this is a minor release for the SDK, it is packed full of new features from the upcoming version 3.0.0 that we will be doing soon. You can start using many of the new features right away, while still maintaining access to the existing capabilities provided by the SDK.

## Our First Upgrade Release

A huge amount of work has gone into reworking many of the internals of the PHP SDK, but with that refactoring, many of the public method APIs for the SDK will be changing in version 3.0.0.

I also know the pain of having to work with an existing codebase, and finding time to upgrade can be hard. This release is backporting as many of the non-backward-compatibility breaking changes as we could, including the new interface for working with our [legacy SMS API](https://developer.nexmo.com/messaging/sms/overview) and our [Voice API](https://developer.nexmo.com/voice/voice-api/overview). More information about these new namespaces in just a moment.

Version 3.0.0 will also deprecate several features, including many of the ways that data is accessed across many of our APIs.

All of these deprecations are marked in the source code with `@deprecated` annotations, but we've gone a step further and enabled you to see what deprecations you are using in real-time logs.

This is opt-in, so you do not have to worry about a bunch of notices in your production logs. It is also a development feature that you can enable to show things like method signature changes, pointers to new methods or classes to use, and more. All you need to do is enable the `show_deprecations` option when creating the Nexmo Client.

```php
$creds = new \Nexmo\Client\Credentials\Basic(NEXMO_API_KEY, NEXMO_API_SECRET);
$client = new \Nexmo\Client($creds, [
    'show_deprecations' => true
]);
```

Once this is enabled, you can run your application locally and see what deprecation notices appear! Depending on the API you are accessing, you may see a large number of deprecations, but all the deprecation notices should point you to the appropriate fix. Once all the deprecation notices are cleared up, you should also be fully compatible with version 3.0.0, and that upgrade should be seamless!

A more complete list of deprecations exists in the actual [release notes on Github](https://github.com/Nexmo/nexmo-php/releases/tag/2.2.0), but as a quick overview:

* Array access is deprecated across all the service layers, such as `messages()`, `voice()`, `applications()`, etc. These are all replaced with actual search methods.
* Passing a search filter into a service layer, like `applications()`, is deprecated. Please use the dedicated search/get functions for each layer.
* Most entities are no longer array-accessible and should change to use the getter methods.
* Most methods no longer take raw PHP arrays, for type safety. The deprecation notices will point you to the appropriate objects to use.
* The `conversation()` and `user()` service layers are deprecated and will be fully removed in v3.0.0
* The old text-to-speech Voice layer is deprecated and will be fully removed in v3.0.0. 
* SMS searching is deprecated and will be fully removed in v3.0.0.

## Better Debugging Tools

I am super excited about one new feature: better visibility into the requests and responses that happen across the API.

The current SDK, even with 2.2.0, provides some access to the requests and responses that happen, but it can be hard to know what entities have access.

All of the APIs (except `messages()` and `calls()`) now have an embedded API handler that keeps track of the last request and response that was created. You can query the API handler from any service layer namespace with `getApiResource()` and get a [PSR-7 compatible request or response](https://www.php-fig.org/psr/psr-7/). 

```php
$response = $client->sms()->send(
    new \Nexmo\SMS\Message\SMS(TO_NUMBER, NEXMO_NUMBER, 'A text message sent using the Nexmo SMS API')
);

$lastRequest = $client->sms()->getApiResource()->getLastRequest();
$lastResponse = $client->sms()->getApiResource()->getLastResponse();
```

We have deprecated getting the request and responses from entities and exceptions, and recommend moving toward getting this info from the service namespaces. The only exception to this is some of the newer search methods on the service layers, which return a lazy-loading collection. In this case, the API handler of the collection has the request and response.

```php
// Returns a lazy-loaded iterable object
$applications = $client->applications()->getAll();
assert($applications instanceof \Nexmo\Entity\IterableAPICollection);

// Start iterating, which fires off an HTTP request
$application = $applications->current();

// Get the request/response
$lastRequest = $applications->getApiResource()->getLastRequest();
$lastResponse = $applications->getApiResource()->getLastResponse();
```

Some APIs will continue to return arrays in v2.2.0, so check the method signatures or use `instanceof` if you are unsure. In version 3.0.0, almost all search results will have a newer interface.

## The New SMS Layer

Many of our customers use our legacy SMS features. While we work on new APIs like our [Messages API](https://developer.nexmo.com/messages/overview) to provide even more messaging capabilities, that does not mean I want to leave our SMS customers behind.

To that end, the entire SMS layer has been revamped to include strict typing and a fully object-oriented interface. This will cut down on errors made by having to create raw PHP arrays and give a clearer picture of what features are available for messages. I have also tried to keep the simple interface that developers come to expect with our SDK.

```php
// The old messages namespace
$message = $client->message()->send([
    'to' => TO_NUMBER,
    'from' => NEXMO_NUMBER,
    'text' => 'A text message sent using the Nexmo SMS API'
]);

// The new way
$response = $client->sms()->send(
    new \Nexmo\SMS\Message\SMS(TO_NUMBER, NEXMO_NUMBER, 'A text message sent using the Nexmo SMS API')
);
```

The old `messages()` namespace on the Nexmo Client is being fully deprecated in version 2.2.0, and the new `sms()` namespace is available for use. These can be used side-by-side so legacy code can continue to use the older namespace, and new code can use the new `sms()` namespace.

I have also expanded the incoming webhook interface. Just like before, you can parse an incoming request, but now you get back a fully type-hinted `\Nexmo\SMS\Webhook\InboundSMS` object. This should make it much clearer on how to get the incoming data compared to dealing with query parameters or a raw JSON post body, or even an array.

```php
$inboundSMS = \Nexmo\SMS\Webhook\Factory::createFromGlobals();
echo $inboundSMS->getFrom() . PHP_EOL;
echo $inboundSMS->getTo() . PHP_EOL;
echo $inboundSMS->getText() . PHP_EOL;
```

## The New Voice Layer

The Voice API is another one of our most heavily used APIs, and it is another area where I wanted to make sure the interface was as clean as it could be.

To provide a nice clean cut, the `calls()` namespace was just completely deprecated in favor of a brand new interface through the `voice()` namespace.

The idea was the as with the new SMS layer - provide a new, clean interface that makes it easy to do common tasks, while retaining all the power that our Voice API provides and develop this with modern PHP practices. I have waxed on in other posts about some of these interfaces, and this was the perfect chance to sand down some rough edges.

```php
// The old way
$call = $client->calls()->create([
    'to' => [[
        'type' => 'phone',
        'number' => TO_NUMBER
    ]],
    'from' => [
        'type' => 'phone',
        'number' => NEXMO_NUMBER
    ],
    'ncco' => [
        [
            'action' => 'talk',
            'text' => 'This is a text to speech call from Nexmo'
        ]
    ]
]);

// The new way
$outboundCall = new \Nexmo\Voice\OutboundCall(
    new \Nexmo\Voice\Endpoint\Phone(TO_NUMBER),
    new \Nexmo\Voice\Endpoint\Phone(NEXMO_NUMBER)
);
$ncco = new NCCO();
$ncco->addAction(new \Nexmo\Voice\NCCO\Action\Talk('This is a text to speech call from Nexmo'));
$outboundCall->setNCCO($ncco);

$response = $client->voice()->createOutboundCall($outboundCall);
```

Since the new `voice()` layer is all object-oriented there is no need to remember how to build an array structure for any of our NCCOs or even basic calls anymore. All of the options available are exposed as setter methods on the new `\Nexmo\Voice\OutboundCall` object, and the `\Nexmo\Voice\OutboundCall` object has better support for various endpoints.

Working with NCCOs has always been a sore point for me. Even though PHP makes it trivial to turn an array into JSON, remembering all the NCCO options usually sends me to our (admittedly awesome) [documentation](https://developer.nexmo.com/).

The SDK now ships with an NCCO builder so you can build your NCCOs with strongly-typed objects and still just as easily generate JSON for either incoming NCCO requests, or NCCOs you are sending as part of outbound calls.

```php
$ncco = new \Nexmo\Voice\NCCO\NCCO();
$ncco
    ->addAction(
        new \Nexmo\Voice\NCCO\Action\Talk('Welcome to the amazing Nexmo conference call')
    )
    ->addAction(
        new \Nexmo\Voice\NCCO\Action\Conversation('amazing-conference-call')
    )
;

header('Content-Type: application/json');
$json = json_encode($ncco);
echo($json);
```

The [Voice API](https://developer.nexmo.com/voice/voice-api/overview) heavily relies on webhook callbacks, so this release also introduces a much more complete incoming webhook parser. This parser is the same interface as our SMS parser but will return objects relating to the Voice API lifecycle.

```php
$inboundVAPI = \Nexmo\Voice\Webhook\Factory::createFromGlobals();
if ($inboundVAPI instanceof \Nexmo\Voice\Webhook\Event) {
    echo $inboundVAPI->getTo() . PHP_EOL;
    echo $inboundVAPI->getFrom() . PHP_EOL;
    echo $inboundVAPI->getStatus() . PHP_EOL;
    echo $inboundVAPI->getUuid() . PHP_EOL;  
}

if ($inboundVAPI instanceof \Nexmo\Voice\Webhook\Record) {
    echo $inboundVAPI->getRecordingUrl() . PHP_EOL;
}

// And other types can also be returned
```

## Verify Updates

The last major API to get a major refactor is our [Verify](https://developer.nexmo.com/verify/overview) product, under the `verify()` namespace. This refactor was not as major as with SMS and Voice but there are a few new features to be aware of.

The first is a clearer way to create a Verification request. This is now handled by the `\Nexmo\Verify\Request` object, which provides a cleaner interface for starting the verification process.

This object is strongly typed and better exposes what we expect for a verification request, versus the more general-purpose `\Nexmo\Verify\Verification` object. For backward compatibility, a `\Nexmo\Verify\Verification` is still returned, but that will change in v3.0.0.

```php
// The old way
$verification = new \Nexmo\Verify\Verification(NUMBER, BRAND_NAME);
$client->verify()->start($verification);

// The new way
$request = new \Nexmo\Verify\Request(NUMBER, BRAND_NAME);
$response = $client->verify()->start($request);
```

Checking, canceling, and triggering the next event is easier. You no longer need to instantiate a `\Nexmo\Verify\Verification` object or serialize and truck one around via sessions anymore. The `verify()` service layer now handles just accepting the Verify Request ID directly.

```php
// The old way
$verification = new \Nexmo\Verify\Verification(REQUEST_ID);
$result = $client->verify()->check($verification, CODE);

// The new way
$result = $client->verify()->check(REQUEST_ID, CODE);
```

While this is not a major change, v3.0.0 will only accept a string request ID instead of the object, so it is something to be aware of. 

## The Promise of Easier Upgrades

Any code compatible with version 2.1.0 should be immediately compatible with 2.2.0 with no changes. This release will simply give you the chance to make the upgrades in your own time while still being kept as up-to-date as possible.

Going forward, the PHP SDK will continue to be more formal with deprecations and upgrade paths so that you, the developer, get the ability to upgrade to changes as quickly and painlessly as possible.

I look forward to any feedback, and see you soon for the version 3.0.0 release!