---
title: Announcing the Vonage PHP Server SDK Version 3.0 Release
description: The Vonage PHP Server SDK Version 3.0 is here. Find out what's new!
thumbnail: /content/blog/announcing-the-vonage-php-server-sdk-version-3-0-release/php_sdk-updates.png
author: james-seconde
published: true
published_at: 2022-01-27T11:31:46.398Z
updated_at: 2022-01-26T10:02:41.773Z
category: release
tags:
  - php
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---

For developers that have been following the recent roadmap of the [Vonage PHP Server SDK](https://github.com/Vonage/vonage-php-sdk-core), this release should look much as expected. In our previous [significant release](https://learn.vonage.com/blog/2020/08/03/announcing-the-php-server-sdk-version-2-2-0-release/), former maintainer [Chris Tankersley](https://ctankersley.com/) explained the goal of simplifying the library, and I have continued that work.

This major release does, however, take into consideration a [change in team and therefore ownership](https://learn.vonage.com/blog/2021/10/11/james-seconde-joins-the-developer-relations-team/) of the SDK and therefore does not remove *every* deprecation. Coming in fresh to these libraries brings various challenges, such as understanding approaches previously taken as well as needing to meet the needs of our developers when it comes to the evolution of the SDK. Some of the more complex 'under the hood' behaviour has been left as is, with the notices still present. These will still be removed, but at a later time.

## Major Changes

#### PHP Support

From this release onwards, the library will track the [PHP language release lifecycle](https://www.php.net/supported-versions.php). As such, PHP8.1 is now supported, and support for versions 7.2 and 7.3 have been dropped.

#### Branching Strategy
Although the majority of end-users will not be affected by this change, it significantly alters how the repository is structured for those that wish to contribute to this open-source library. The new workflow, designed to fall into line with [other Vonage Server SDKs](https://github.com/Vonage), looks like the following:

* `main` branch (renamed from version branches such as `3.X`/`2.X`)
* `dev` branch
* Pull requests are taken off `main`, and merged to `dev` as the target
* merges from `dev` to `main` are considered release merges, and therefore will result in a git tag that will push to Packagist.

#### Removal of Array Access

The biggest code change to the library is almost all array accessors, which were marked as deprecated, have now been removed. Previously all entities used the `ArrayAccess` interface to implement various core PHP functions like `offsetExists()` and `offsetSet($offset, value)`. These caused unnecessary complexity, especially as some entities actually proxied the value into a `request` object.

Now that these have been removed, you use getters and setters instead. For example:

Previous
```php
$balance = new Vonage\Account\Balance('12.99', false);
$balanceValue = $balance['balance']

```

New
```php
$balance = new Vonage\Account\Balance('12.99', false);
$balanceValue = $balance->getBalance();
```

If there are getters or setters missing, you can add some extra code to make your code backward compatible - all entities implement the `ArrayHydrateInterface`. This means you can still access objects as arrays cast to new variables by using the `toArray()` and `fromArray()` methods. For example:

```php
// this will error
$balance = new Vonage\Account\Balance('12.99', false);
$balanceValue = $balance['balance']

// this will fix it
$balance = new Vonage\Account\Balance('12.99', false);
$balanceArray = $balance->toArray();
$balanceValue = $balanceArray['balance']
```

#### Removal of `jsonSerialize` and `jsonUnserialize`

Almost all of the entities also used the `jsonSerialize` and `jsonUnserialize`  interfaces. Most of these have been removed, as the original thinking to be able to customise what data structures are serialized and unserialized are not required. To unserialize an object, the `ArrayHydrateInterface` methods are used instead.

#### Removal of `Call` module

The `Vonage\Call` client was already marked for removal, so this has now happened. This functionality has been replaced with the `Vonage\Voice` client and its associated entities, the usage of which is already documented with examples in the Readme.

Here is a "before and after example" of its use:

```php
// old
$call = new Vonage\Call\Call();
$call->setTo('14843331234')
     ->setFrom('14843335555')
     ->setWebhook(Vonage\Call\Call::WEBHOOK_ANSWER, 'https://example.com/answer')
     ->setWebhook(Vonage\Call\Call::WEBHOOK_EVENT, 'https://example.com/event');

$client->call()->create($call);

// new
$outboundCall = new \Vonage\Voice\OutboundCall(  
    new \Vonage\Voice\Endpoint\Phone('14843331234'),  
    new \Vonage\Voice\Endpoint\Phone('14843335555')  
);  

$outboundCall  
    ->setAnswerWebhook(  
        new \Vonage\Voice\Webhook('https://example.com/answer')  
    )  
    ->setEventWebhook(  
        new \Vonage\Voice\Webhook('https://example.com/event')  
    )  
;  
  
$response = $client->voice()->createOutboundCall($outboundCall);
```

#### Removal of `User` module

The library originally had an incomplete implementation of a feature that was in the beta stage of the release cycle. This feature has now been dropped, and therefore the library has dropped support for it. There is no alternative functionality to replace this if it has been used, but as it was incomplete and marked for removal there should not be any impact in terms of using the SDK.

## Minor Changes
These are changes that are very much "under the hood", behind the service layer of the library that is designed to be developer-facing. For transparency, I'm going to document a few of these changes.

#### Removal of incomplete and skipped tests
A number of tests were marked as incomplete or skipped, with given reasons. Given the change of maintainer, and some historical context/domain knowledge lost as the code changes hands, I have made the decision to clean the code by deleting them. There are two justifications for this:
1. The code being tested might have changed context or state i.e. a feature that now behaves differently in our APIs.
2. We have an aim to increase code coverage to near 100% this year, and as such nothing will be left out that these tests might have set out to cover.

#### PSR/Container 2.0 support
For continuously released, modern PHP Frameworks such as Laravel and Symfony, PSR-11 support for v2.0 of the service container has been added with no impact.

#### `Basic::getCountryPrefix()` return value
Previously this method would return an integer. This value is stored as a string from the API response made to populate it, and could possibly contain special characters. Given this, it has been changed to return a string.

#### KeyPair changes
The `Vonage\Client\Credentials\Keypair()` object has a new method, `getKey()`, to get the `key`. This was added to support some additional testing of the JWT functionality.

#### `psr/log` support
Similar to the support version bump for the container, `psr/log` v.2.0 is now supported.

#### Change in `Application\Client` behaviour
When creating an `Application\Client`, a shim exists for backward compatibility that allows the object to be created without an implementable `HydratorInterface` object. This shim has now been removed.

#### Thanks for your support!
My thanks go to Daniel Miedzik, Github user `iceleo-com`, and Fabien Salathe for contributions towards this release. There will be noticeable changes, some of which we've already begun to implement, with regards to the maintenance of this library, such as keeping the issues list documented with appropriate labelling and speeding up response times. Our aim is to also move to more regular releases, in line with a more "CI" approach.

When we have removed the final marked deprecations in a future release, we're going to take steps to simplify the library further to encourage contributions from outside Vonage. After all, our libraries are Open Source!