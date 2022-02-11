---
title: Converting Your Test Suite to PEST
description: This article will look into changing your test PHP syntax to PEST,
  and attempt to automate switching
thumbnail: /content/blog/converting-your-test-suite-to-pest/shifting-to-pest.png
author: james-seconde
published: true
published_at: 2022-01-14T10:54:30.520Z
updated_at: 2021-12-16T16:47:16.326Z
category: tutorial
tags:
  - php
  - testing
  - laravel
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Changing the way I write code through Test-Driven Development quite frankly changed my abilities as a programmer. Suddenly I could write services and functionality with confidence - it's a mystery to me why so many companies *still* "Do not have the time to do testing." For a long time, [PHPUnit](https://phpunit.de/) has been the de-facto tool of choice when writing TDD PHP.

A new project has come along recently that could change that. There's [good documentation](https://pestphp.com/docs) and a [meetup community](https://www.youtube.com/playlist?list=PLsGrIkNZ8eVk0RAThd7Ed6cdBvl5JW-GA) being built around it that shows itself to be an attractive option to developers. I am of course referring to PEST, so I thought I'd give it a spin on our own [Vonage PHP SDK](https://github.com/Vonage/vonage-php-sdk-core). 

### The Current Suite

Our Vonage PHP SDK has been comprehensively maintained through the years, and as such contains a full test suite. While it's not "enterprise level" in its scope, it is nevertheless a useful exercise to test PEST in.

The current suite on [this branch](https://github.com/SecondeJK/vonage-php-sdk-core) has 831 passing tests which run 4039 assertions. There are 9 skipped tests and 15 incomplete tests. Out total execution time is 13:54 in PHP8.

![Screenshot of total tests showing 9 skipped and 15 incomplete tests.](/content/blog/converting-your-test-suite-to-pest/screenshot-2021-12-13-at-11.10.30.png "Screenshot of total tests showing 9 skipped and 15 incomplete tests.")

For the record, it runs pretty decently and one of those tests is actually a timeout test which bumps up the time. The aim here isn't to actually improve the runner, but change it to see what happens. Our first port of call is to [install PEST](https://pestphp.com/docs/installation) and run it. One of the most important features of PEST to note is that *it is completely backwards compatible with PHPUnit*, and so can be used interchangeably regardless of the syntax you're using. This allows for us to install PEST, run it to see the results and potentially try and implement the recent [parallel testing](https://pestphp.com/docs/plugins/parallel) feature.

To install PEST, I run the following in the command line:

```bash
composer require pestphp/pest
```

It seems deceptively easy that one composer command later, I can run PEST. It's worth noting, however, that this repository it will run on already has requirements - one of these requirements is a minimum PHP version of 7.3. PEST already has a minimum required version of PHP to be 7.3 and above, so there's no tinkering required to get up to date.

Time to run PEST and see what happens:

```bash
./vendor/bin/pest
```

The first thing you'll notice is that PEST uses an output format similar to the `--testdox` argument to format PHPUnit's output. It's output is pretty nice:

![Test screenshot, showing a time of 13.21 seconds.](/content/blog/converting-your-test-suite-to-pest/screenshot-2021-12-13-at-12.01.27.png "Test screenshot, showing a time of 13.21 seconds.")

Hmm, so 13.28 seconds huh? Well, that is actually faster just on the runner alone. What if we try and use PEST's parallel feature? It comes as a separate package, so let's go get it:

```bash
composer require pestphp/pest-plugin-parallel
```

And now to run it:

```bash
./vendor/bin/pest -parallel
```

And... oh. Well, it looks like our luck has run out:

![Screenshot of a PHP bug.](/content/blog/converting-your-test-suite-to-pest/screenshot-2021-12-13-at-12.23.22.png "Screenshot of a PHP bug.")

A quick bit of Googling reveals that we have a bug in PHP itself for this, as documented in PHPUnit's issue log:

[https://github.com/sebastianbergmann/phpunit/issues/4305](https://github.com/sebastianbergmann/phpunit/issues/4305)

I guess that's the price we pay for being a bit bleeding edge.

![Photo of frustrated person looking at their laptop screen.](/content/blog/converting-your-test-suite-to-pest/elisa-ventur-bmjaxaz6ads-unsplash-1-.jpg "Photo of frustrated person looking at their laptop screen.")

### PHPUnit Syntax vs. PEST

I've been playing with the test runner, but not actually shown the code or explained what PEST's actual purpose is.

Laravel core member [Nuno Madro](https://twitter.com/enunomaduro) created PEST as a new framework modelled on the syntax of the [Jest](https://jestjs.io/) Javascript framework. It's very much in keeping with the current trend of PHP (and especially Laravel) to move to more closure-based, functional syntax akin to the way Javascript is written. This makes logical sense then, that your PHP backend tests for your full stack web application are written in a similar syntax to your front end tests. Here's a "before and after" example from the Vonage PHP SDK:

```php
class NumberTest extends VonageTestCase  
{  

 /**  
 * @var Number;  
 */
 protected $number;  
  
 public function setUp(): void  
 {  
	$this->number = new Number('14843331212');  
 }  
 
 public function testNumberConstructor(): void  
 {   
	$this->assertEquals('14843331212', $this->number->getNumber());  
 }
```

We're using a couple of common patterns here - the magic method `setUp()` runs before the tests are executed, and then we use `assertEquals()` which is a helper class from the PHPUnit `TestCase` (in our example, `VonageTestCase` extends off it higher up).

Now, to show you the same test, but written in PEST syntax:

```php
use Vonage\Numbers\Number;  
  
beforeEach(function () {  
   $this->number = new Number();  
});  
  
test('number constructor', function () {  
   expect($this->number->getNumber())->toEqual('14843331212');  
});
```

This is a pretty good example of where the PHP ecosystem is, in general, looking towards Javascript for new ideas - as you can see, the PEST syntax is very similar to JEST. It also shows one of PEST's core values, which is to have more fluid method chaining in the API to write less code, which is a very Laravel-like approach in philosophy. We now have a higher order `beforeEach()` with a closure inside it that will be run before each test, and now the classic PHP function structures from PHPUnit have been replaced with more functional style syntax. This example also shows how the [Expectation API](https://pestphp.com/docs/expectations) is designed to chain assertions in a human readable way with method names such as `expect(true)->toBe(value)` or `expect($variable)->toBeArray()`.

### OK, so automation?

I'll be honest here, this did not go the way I wanted it to. I will, however, show you why.

It came to my attention [from Twitter](https://twitter.com/laravelshift/status/1443644297685962753) that it could actually be possible to use a tool to automatically convert your PHPUnit suite to PEST, regardless of whether the code is in Laravel or not. So, I headed off to [Pest Converter](https://laravelshift.com/phpunit-to-pest-converter) and [set up a respository and branch to try it out on](https://github.com/SecondeJK/vonage-php-sdk-core/tree/pest-shift) When run, Shift will create a new branch off the base one you provide and create logical step commits to move across the syntax. One of the things that needed to be done first was to change the `test/` folder to `tests/` so that the converter knows where to look for your tests.

However, when running PEST after the conversion:

![Screenshot showing Pest\Exceptions\TestCaseClarrOrTrailNotFound.](/content/blog/converting-your-test-suite-to-pest/screenshot-2021-12-13-at-09.01.43.png "Screenshot showing Pest\Exceptions\TestCaseClarrOrTrailNotFound.")

Hmm. So, not smooth sailing then. It's worth noting that I had no idea what to expect for a couple of reasons:

* The Vonage PHP SDK is framework-agnostic
* It depends on the [Prophesize](https://github.com/phpspec/prophecy) library
* A number of PHP traits are used that make the test suite slightly more complex

Rather than using traditional composition, PEST has a different pattern to configuration. PEST has a `pest.php` configuration file that allows you to specify helper functions, traits and common methods such as `RefreshDatabase`. You can also specify which folders you want the classes to be applied to like so:

`uses(\VonageTest\HTTPTestTrait::class)->in('Secrets');`

The reason that the PEST converter cannot resolve these is a number of edge cases. One thing pointed out by Laravel Shift's [Jason McCreary](https://twitter.com/gonedark) in our support conversations is that some tests set an Application container into `$this->app`, which conflicts with the application infrastructure of Laravel (seeing as it doesn't know if you have a Laravel app or not).

### Conclusions

OK, so while the PEST Converter found it difficult to automate moving the tests across, it leads me to two conclusions:

* Laravel Shift, the creators of the Pest Converter are already looking at the edge cases in our library that I used and working on how to handle them, but more importantly
* *Don't run the converter if your test suite is complex or over-engineered - fix that first*

Like with anything, there are risks of undertaking major refactoring through automation. In our case, the risk was that we're dealing with a raw PHP library with no framework. However, Shift works on updating via a target branch, then creating the Shift branch off it to minimise risk. If it doesn't run, don't merge it! You also have the option of using the [Human Shift](https://laravelshift.com/human-shifts) service, which will inevitably result in a fully converted suite.

What I would advise is that if you have a Symfony or Laravel app, this convertor is absolutely designed with these cases in mind, so the Shift will be pretty solid.

Should you adopt PEST? As always, that's up to you. If you want to keep on the bleeding edge of things that are changing in PHP then this is certainly an attractive option. Keep in mind though that the way PEST structures its syntax is naturally in line with Laravel's approach to API flows, so it does have the potential to confuse your developers if you use something else popular like Symfony, CakePHP or Drupal.