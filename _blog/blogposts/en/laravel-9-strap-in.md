---
title: "Laravel 9: Strap In!"
description: Another milestone hit in the Laravel journey. Find out what's new in Laravel 9!
thumbnail: /content/blog/laravel-9-strap-in/laravel-9.png
author: james-seconde
published: true
published_at: 2022-02-25T10:25:32.234Z
updated_at: 2022-02-23T15:13:53.848Z
category: tutorial
tags:
  - php
  - laravel
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
It's been in the works for a year, and on the 8th of February, it finally shipped: Laravel 9 is here! In this article we'll go through a few new features, but rather than a "list of things", I'm going to provide some commentary and extra context on the changes that have caught my eye.

### The Big Stuff

There are no big architectural changes or changes to set backwards-compatibility alarm bells off (having said that, this is a major release and therefore contains breaking changes in line with [semver](https://semver.org/)). There are, however, some big changes outside the code. Let's go through them:

#### Release Cycle

One of the biggest changes within Laravel recently was Taylor Otwell's announcement that they were moving to a yearly release cycle. This makes sense, given that it allows the core team more time to check dependency upgrades within either the Symfony ecosystem or community-created dependencies. Talking of Symfony:

#### Symfony Mailer

Symfony Mailer has replaced Swift Mailer. On the subject of Symfony, I had a very interesting conversation with the folks at SensioLabs during PHPUK on the subject of Laravel and Symfony's interactions with each other. Some developers may like to think of themselves as brand ambassadors to one or the other, and think that is the norm "take sides", but as seen from the `artisan cli`, Symfony Mailer and other chunks of Laravel it is clear that the two frameworks work together far more than people trying to be divisive might know. It's worth remembering that both [Fabien Potencier](https://twitter.com/fabpot) and [Taylor Otwell](https://twitter.com/taylorotwell) both contribute code to each other's organisations, and that the PHP ecosystem as a whole has modern relevance and direction because of it.

#### PHP8

I remember watching [Jenny Wong](https://twitter.com/miss_jwo) from Human Made give a talk on WordPress security, and how rolling out [Jetpack](https://jetpack.com/) was an essential tool for the WordPress ecosystem, albeit with very low adoption rates. One of the biggest vulnerabilities facing PHP is the unwillingness of developers to bump their PHP versions. Over 50% of the WordPress scene at that point in time was running software on PHP versions that were not even supported.

So, it's a massive boost to see that Laravel is bumping required PHP versions in line with the core PHP lifecycle. It gives access to a whole new host of API features, but more importantly forcing a minimum version of PHP8 means you get the Just-In-Time (JIT) runtime compiler, and thus Laravel benefits from a significant performance boost.

With a new minimum requirement, you might get caught out on your server stack. If it's a serious pain because you have existing application deployments, I'd highly recommend using [Laravel Shift](https://laravelshift.com/) to automatically migrate your projects.

#### Flysystem

One of the -best- features as a developer being introduced to Laravel was how the `Storage` facade wrapped around Frank De Jong's Flysystem. The ability to switch up a filesystem driver from local to an AWS S3 bucket by switching up drivers:

`Storage::disk('local')->put('something.jpg', 'Images');`
`Storage::disk('s3')->put('something.jpg', 'Images');`

Flysystem 3.0.0 was released on the 14th of January and includes version bumps inline with Laravel's minimum requirement for PHP8 (for Flysystem 8.0.2 specifically) and API enhancements around directory navigation such as `FilesystemReader::directoryExists('Storage\Images')`

Laravel 9 now uses Flysystem 3.

### The Smaller Stuff

These are tweaks and additions that are a bit smaller, but nevertheless, add up to a great package of new features.

#### Route Controller Grouping

I'll admit that I am very particular when it comes to organising routes in web applications. I think this comes from the experience of seeing massive route files with over a thousand entries with little structure to how they are ordered. The way I like to approach routing is to use directory structures for individual controllers, loaded in by the Routes Service provider.

I already code routes as named groups, but the difference here is that the closure will allow you to bind a group to a specific controller. This won't make a difference if you take the approach of invokable controllers (a whole lot more files, but potentially looser coupling), but if you do have something like a REST API that does standard CRUD operations for instance - this looks lovely in the code. Take for example this controller:

```php
Class ReportController extends Controller
{
	public function index(){}
	public function store(){}
	public function delete(){}
	public function show(){}
}
```

Now, with Controller Grouping you can wrap the controller methods in the routes file:

```php
Route::controller(ReportController::class)->group(function () {
	Route::get('/reports', 'index');
	Route::post('/reports', 'store');
	Route::delete('/reports/{id}', 'delete');
	Route::get('/reports/{id}', 'show')
}
```

#### Route List CLI output

Talking of routes, the output of `routes:list` has been changed, to a much more developer-friendly view:

![Screenshot of the new route list output from Laravel's console](/content/blog/laravel-9-strap-in/screenshot-2022-02-23-at-12.33.32.png)

#### Forced Scope Bindings

This is one neat little change that ties up model relationships within route binding in a far more clear implementation. Previously, you could achieve a forced scope binding by adding a custom key within a child record:

```php
Route::get('/users/{user}/reports/{report:id}', function (User $user, Report $report) {
	return $report;
})
```

Without using that custom key, no model relationships would be enforced, which meant as long as the user and report are valid keys it would return that `$report` example entity even if it did not have a relationship (e.g. `Model::hasOne(User::class)`)

Now we have a method that enables this logic in a far more explicit way:

```php
Route::get('/users/{user}/reports/{report}', function (User $user, Report $report) {
	return $report;
})->scopeBindings();
```

#### Enums

PHP8.1 shipped with the new `enums` class, which can be treated as an object with statically called return values or can be a "backed enumeration" that contains a value. [I saw Derek Rethans introduce this feature on stage at PHPUK 2022](https://twitter.com/SecondeJ/status/1494251518249287682), and I must say from our perspective at Vonage that it might prove to be extremely useful. As we deal with voice calls and messaging, many of these features implemented in the [PHP SDK](https://github.com/Vonage/vonage-php-sdk-core) have static properties to define and retrieve state (i.e. the status of this SMS is "0"). Enums have the potential to have an associated type, rather than an extensive list of static properties.

With the introduction of Enums, a couple of Laravel 9 features have been written to take advantage of this.

##### Attribute cast Enums

I have worked on a project where this would have really, really saved a whole lot of headaches. Everything in a pretty sizeable MySQL database extended off an "Event" base class/database table, with the extended entities being restricted by MySQL enums. Sounds OK, right? When we expanded the platform, a new enum would need to be added, triggering a reindex in one table with several hundred million records. It fell over, every time.

Consider how you'd write a migration for an enum table column:

```php
$table->enum('eventType', ['SpotifyEvent', 'VideoEvent', 'AppleEvent'])
```

OK, so each time you add a new enum, a new migration needs to be done, plus you have to update the Model.

In Laravel 9, you can specify an enum class instead, keeping the logic in your backend code rather than your database. While it's a disadvantage from the database point of view with inefficient storage, it does make arguably more readable code. So, your migration would be a varchar column instead:

```php
$table->string('eventType')->default('SpotifyEvent');
```

And your logic would sit within a backed enum class that is referenced inside the Model `$casts` array:

```php
enum EventType: string {
	case SpotifyEvent = 'spotify';
	case VideoEvent = 'video';
	case AppleEvent = 'apple';
}

class EventEntry extends Model
{
	protected $casts = [
		'eventType' => EventType::class
	];
}
```

So that ties our casting to and from the database: you can try it out with tinker:

```php
php artisan tinker

\App\Model\EventEntry::first()->eventType->value;
```

And your string value will come back. `eventType` will actually return an enum object, so this is why we need to add the `value` attribute in order to get out the backed property.

##### Route binding with Enums

You can also use enum classes within route binding. Say you want to restrict the following route:

```php
Route::get('events/eventType');
```

You can now bind the enum class, like so:

```php
Route::get('/events/{eventType}', function (EventType $eventType) {
	return $eventType->value;
});
```

#### Testing Coverage

Getting back into Xdebug to use it in my day-to-day development toolchain [was kind of a revelation ](https://www.youtube.com/watch?v=app2UUq5Xsk) after years of using `die()` and `dd()` debugging. As I started work on our PHP SDK, I saw that our CI uses [CodeCov](https://about.codecov.io/) to ensure Pull Requests cannot be merged without sufficient coverage within the test suite. Coverage comes courtesy of Xdebug, so you need to enable coverage in your .ini file firstly:

`xdebug.mode=develop,debug,coverage`

Now, if you run `artisan test --coverage`, it will give you a report including coverage of your application:

![Screenshot of the new test coverage output from Laravel's console](/content/blog/laravel-9-strap-in/screenshot-2022-02-23-at-14.58.50.png)

Pretty neat huh?

#### And What's Next?

This version marks another milestone in Laravel's journey, but what is truly astonishing is the extended ecosystem built around it - Vapor, Breeze, Octane, Sail, Horizon... the list goes on. What I find exciting about the ever-growing list of Laravel projects is its inclusion into [the PHP Foundation](https://opencollective.com/phpfoundation), created in the wake of [Nikita Popov's retirement from PHP core development](https://blog.jetbrains.com/phpstorm/2021/11/the-php-foundation/). Alongside Symfony, it's pretty clear that the immortal line "[PHP is Dead](https://medium.com/swlh/stop-saying-php-is-dead-9489ed7dc25e)" couldn't be further from the truth.