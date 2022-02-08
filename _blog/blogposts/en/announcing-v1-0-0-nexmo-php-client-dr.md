---
title: Announcing v1.0.0 of the Nexmo PHP Client Library!
description: Announcing the v1.0.0 release of the Nexmo PHP Client library
thumbnail: /content/blog/announcing-v1-0-0-nexmo-php-client-dr/nexmo-php-release.png
author: mheap
published: true
published_at: 2017-08-29T09:42:30.000Z
updated_at: 2021-05-14T10:48:06.454Z
category: release
tags:
  - php
comments: true
redirect: ""
canonical: ""
---
After a heroic effort from [Tim](https://github.com/tjlytle) and some work from [Michael](https://github.com/mheap) to get it over the line, we’re proud to announce that we've just tagged version 1.0 of the Nexmo PHP client library - it’s just one `composer require` away!

```bash
composer require nexmo/client
```

### The Tech

Built on top of Zend Diactoros and Guzzle, it's a PSR-7 compliant HTTP client for the Nexmo API. Initially, it supports our core services such as [SMS](https://developer.nexmo.com/messaging/sms/overview), [voice calls](https://developer.nexmo.com/voice/voice-api/overview), [Verify](https://developer.nexmo.com/verify/overview) and [virtual number provisioning](https://developer.nexmo.com/account/guides/numbers) and we’ll be working to add coverage for the remaining products over the next month.

Whether you're a developer that loves entities and type hints, or if you'd rather pass everything around as an array, the library has something for you. Each of our entities implements ArrayAccess to read data and accepts arrays as parameters when creating and updating entities.

```
$client = new \Nexmo\Client(new Nexmo\Client\Credentials\Basic('API_KEY', 'API_SECRET'));

$message = $client-&gt;message()-&gt;search('MESSAGE_ID');

// Read the message ID using a getter or using `ArrayAccess`
echo $message-&gt;getNetwork().PHP_EOL;
echo $message['network'];
```

### Examples

Interacting with the Nexmo API is especially easy when using our PHP client library. You can send an SMS, make a voice call and use Verify to validate a user’s number, all in less than ten lines of code each!

#### How to send an SMS

```php
$client = new \Nexmo\Client(new Nexmo\Client\Credentials\Basic('API_KEY', 'API_SECRET'));

$client-&gt;message()-&gt;send([
'from' =&gt; '14155550101',
'to' =&gt; '14155550100',
'text' =&gt; 'A text message sent using the Nexmo SMS API'
]);
```

#### How to make a voice call

```php
$keypair = new \Nexmo\Client\Credentials\Keypair(file_get_contents(PRIVATE_KEY), APPLICATION_ID);

$client = new \Nexmo\Client($keypair);

$client-&gt;calls()-&gt;create([
'to' =&gt; [['type' =&gt; 'phone', 'number' =&gt;'14155550100']],
'from' =&gt; ['type' =&gt; 'phone', 'number' =&gt;'14155550101'],
'answer_url' =&gt; ['https://nexmo-community.github.io/ncco-examples/first_call_talk.json'],
]);
```

#### How to use 2FA to verify a user's identity

```php
$client = new Nexmo\Client(new Nexmo\Client\Credentials\Basic(API_KEY, API_SECRET));

$verification = $client-&gt;verify()-&gt;start([
'number' =&gt; '14155550100',
'brand' =&gt; 'My App'
]);

// The user submits a form via POST that contains the
// code they received in the `verification_code` input
$client-&gt;verify()-&gt;check($verification, $_POST['verification_code']);
```

### Bonus points
If you’re a Laravel user, we have an extra special treat for you. As well as our standalone library, we have [nexmo/laravel](https://github.com/nexmo/nexmo-laravel) which is a Laravel service provider for the Nexmo PHP client. If you’re running Laravel 5.5 or above, the library will automatically register itself as a provider, allowing you to use the facade straight away.

Once you’ve installed `nexmo/laravel` and [configured your API key and secret](https://github.com/nexmo/nexmo-laravel#configuration) via `.env`, sending an SMS is as simple as this:

```php
Nexmo::message()->send([
'to' => '14155550100',
'from' => '14155550101',
'text' => 'Using the facade to send a message.'
]);
```

### Get involved!

Whether you've used Nexmo via SMS notifications in Laravel (yep, we power those!), you've built an enormous logistics system or anything in between; we'd love to hear about it. Even better if it's open source and we can point to it as an example of how to leverage the power of Nexmo to get the job done.

If you're interested in getting involved in the client library development it's as easy as finding a use case you have that we don't support yet and opening an issue. We can work together to spec out and build support in to the client (we'll even help you write the tests!)