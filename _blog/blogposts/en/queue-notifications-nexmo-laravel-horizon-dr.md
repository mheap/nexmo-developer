---
title: Queue Wait Time Notifications with Nexmo and Laravel Horizon
description: In this tutorial from Taylor Otwell and Nexmo learn how to
  configure Laravel Horizon to send an SMS when our queue wait time is above a
  given threshold
thumbnail: /content/blog/queue-notifications-nexmo-laravel-horizon-dr/Queue-wait-time-notifications.png
author: taylorotwell
published: true
published_at: 2018-11-13T17:28:37.000Z
updated_at: 2021-05-04T14:08:00.937Z
category: tutorial
tags:
  - php
  - laravel
  - sms-api
comments: true
spotlight: true
redirect: ""
canonical: ""
---
Web applications need to perform computationally-expensive, time-consuming tasks like sending emails, processing uploaded files, or calling APIs. Performing these tasks during a user's web request can make your web application feel slow and clunky, which is frustrating for users.

So, instead of performing these tasks during a web request, they can be added to a job queue that is processed later by queue "workers". Out of the box, the Laravel framework includes support for queued jobs and starting workers to process those jobs. In addition, the [Laravel Horizon](https://laravel.com/docs/horizon) package augments the Laravel queue system by adding a user interface for queue monitoring, worker load balancing, and more. Horizon utilizes [Redis](https://redis.io), a powerful open-source datastore, to track pending, processed, and failed jobs, as well as metrics such as average job processing time and queue wait time.

However, once your application is leveraging background queues, traffic spikes can cause jobs to quickly accumulate in the queue. If you do not have enough workers assigned to that queue, jobs will have a long wait on the queue before they are processed.

Nexmo to the rescue! By leveraging events and notification services built-in to Laravel Horizon, we can instruct Horizon to send an SMS message to our phone when our queue wait time is above a given threshold that we specify.

## Nexmo Client Installation & Configuration

First, let's configure the Nexmo service for our application. Laravel's notification services already have built-in support for sending SMS messages using Nexmo. However, we need to add a few lines of configuration to our `config/services.php` configuration file:

```
'nexmo' => [
    'key' => env('NEXMO_KEY'),
    'secret' => env('NEXMO_SECRET'),
    'sms_from' => 'virtual-phone-number',
],
```

Once these configuration options have been added to your `config/services.php` configuration file, you should ensure that the `NEXMO_KEY` and `NEXMO_SECRET` environment variables are added to your application's `.env` file. These configuration values can be retrieved from your [Nexmo account settings](https://dashboard.nexmo.com/settings?utm_campaign=dev_spotlight&utm_content=wait_time_laravel_taylorotwell).

In addition, the `sms_from` configuration value should be changed to match the number of one of your Nexmo virtual numbers. This is the phone number that your SMS messages will be sent from.

Next, we need to install the `nexmo/client` package into our application using Composer. We can do this using the "composer require" command in our terminal:

```
composer require nexmo/client
```

Great! We've installed and configured the Nexmo client. Next, let's install Horizon.

## Laravel Horizon Installation & Configuration

To install Laravel Horizon, we'll use Composer to install the `laravel/horizon` package:

```
composer require laravel/horizon
```

After Composer is finished installing Horizon, we need to publish Horizon's configuration files. We can do this using Laravel's `vendor:publish` Artisan CLI command:

```
php artisan vendor:publish --provider="Laravel\Horizon\HorizonServiceProvider"
```

Horizon is now installed! But, before moving on, you should ensure that the `default` driver configuration in your `config/queue.php` configuration file is set to `redis`.

## Configuration Wait Time Thresholds

Next, we're ready to configure our queue wait time threshold. If our queue wait time exceeds this threshold, we want to receive an SMS message alerting us of the situation. The `wait` configuration option within the `config/horizon.php` configuration file allows us to specify our maximum queue wait time threshold in seconds. By default, this threshold is set to 60 seconds; however, you are free to modify this value based on the needs of your application.

```
'waits' => [
    'redis:default' => 60,
],
```

## Configuring The Nexmo SMS Notification

Finally, we're ready to instruct Horizon to actually send the SMS message when the queue wait time threshold is exceeded. Within the `boot` method of our application's `AppServiceProvider` class, let's add the following line of code:

```
\Laravel\Horizon\Horizon::routeSmsNotificationsTo(
    'your-phone-number'
);
```

Of course, `your-phone-number` should be replaced with the phone number that the wait time SMS notification should be sent to.

That's it! When our application's queue wait time is exceeded, we'll receive an SMS via Nexmo alerting us of the long wait time. In response, we can quickly increase our queue worker capacity and resolve the problem!

A demo application that utilizes Horizon and Nexmo is [available on my GitHub](https://github.com/taylorotwell/nexmo-horizon-demo).