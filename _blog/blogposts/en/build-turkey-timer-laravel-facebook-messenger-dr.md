---
title: Building a Turkey Timer with Laravel, Facebook Messenger and Vonage
description: In this tutorial, we look at building a recipe chat-bot for
  Facebook messenger, WhatsApp, or Viber with Laravel PHP and the Vonage
  Messages API.
thumbnail: /content/blog/build-turkey-timer-laravel-facebook-messenger-dr/Blog_Timer-Lavavel-FB_1200x600.png
author: mheap
published: true
published_at: 2018-12-14T17:46:54.000Z
updated_at: 2021-05-21T04:56:09.187Z
category: tutorial
tags:
  - php
  - messages-api
comments: true
redirect: ""
canonical: ""
---
This year I’ve been asked by my mother-in-law to help her cook Christmas dinner for the family. I’m really looking forward to it, but with a new puppy in the house and a young nephew I can see myself getting distracted and forgetting to put the potatoes in the oven at the right time!

To help with this, I decided to write a small Laravel application that maintains a collection of recipes. You send it a message with the name of a recipe via WhatsApp, Facebook or Viber. It retrieves the list of steps each recipe requires and sends you the next step when it's time to do it. You can relax, safe in the knowledge that everything in the kitchen is under control and when it's time for human intervention, you'll be notified!

Here's the application in action:

![Turkey Timer Demo](/content/blog/building-a-turkey-timer-with-laravel-facebook-messenger-and-vonage/turkey-timer-demo.gif "Turkey Timer Demo")

In this post I’ll be working with Facebook, but it’s easy to extend to WhatsApp and Viber too as we’ll be using the [Vonage laravel-notification package](https://github.com/Nexmo/laravel-notification).

## Laravel and Vonage Project Setup

There’s quite a lot of setup required for this project, so to avoid taking you until New Year to read this I've jumped straight to the Vonage-specific code in this post. If you are interested, here’s the process I went through to set up the application (each item links to a commit that contains a longer description of the work done):

* [Update the project to use a `sqlite` database](https://github.com/nexmo-community/turkey-timer-laravel/commit/dda69c12f5b0d8f5669408e874214889b55d9b11)
* [Create a model, migration and controller for `Recipe`](https://github.com/nexmo-community/turkey-timer-laravel/commit/21135f25c6b03ff72965798bf1a779567cc05a0f)
* [Create a model and migration for `Timings` within a `Recipe`](https://github.com/nexmo-community/turkey-timer-laravel/commit/c6938a9aaf7542eec16aef52e5d2157d19551796)
* [Add seed data to the database for testing purposes](https://github.com/nexmo-community/turkey-timer-laravel/commit/c7b41eeb76f64d09f6750be1bb10921778169c91)

It’s a pretty simple application that has user management and the ability to show a recipe and it’s associated timings. It’s a standalone application with no dependency on Vonage at the moment. However, we want to be able to receive messages to our Facebook page, so I need to do a little more configuration. To make the application work, I need to [link my Facebook page to a Vonage account](https://developer.nexmo.com/messages/concepts/facebook#link-your-facebook-page-to-your-nexmo-account), [create and configuring an application](https://developer.nexmo.com/messages/building-blocks/create-an-application#how-to-create-a-messages-and-dispatch-application-using-the-dashboard) so that Vonage knows where to send the webhook requests to and [expose my application to the internet using ngrok](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/) so that Vonage can reach it.

> If you’d like to try building this yourself, join the [Vonage Community Slack](https://developer.nexmo.com/community/slack) workspace and we can work through the required steps together

In the rest of this post, we’re going to be adding the ability for users to send a message to us with a recipe name and have the application respond with the actions that need performing at the correct time.

## Handling Inbound Facebook Messages

When I created my Vonage application, I had to provide two URLs; one that will be called when I receive a message from a user and another which receives status updates from Vonage. I’ve chosen `/webhooks/inbound-message` for receiving messages and `/webhooks/message-status` for the status updates. As Vonage will send a request from outside the application I’ve had to disable [CSRF](https://www.owasp.org/index.php/Cross-Site_Request_Forgery_(CSRF)) checking in `app/Http/Middleware/VerifyCsrfToken.php`:

```php
protected $except = [
    '/webhooks/*'
];
```

Now that Vonage can access my webhook, it’s time to handle those inbound requests. I used `make:controller` to generate a new `WebhooksController` and updated `routes/web.php` to point the above URLs to this controller:

```php
Route::post('/webhooks/inbound-message', 'WebhooksController@inboundMessage')->name('webhooks.inbound');
Route::post('/webhooks/message-status', 'WebhooksController@messageStatus')->name('webhooks.status');
```

The final thing to do is implement the `WebhooksController`. For now I’m logging the inbound request so that I can see the format of the request that Vonage sends:

```php
namespace App\Http\Controllers;
use Illuminate\Http\Request;

class WebhooksController extends Controller
{
    public function inboundMessage(Request $request) {
        \Log::debug('Inbound Message', $request->all());
    }

    public function messageStatus(Request $request) {
        \Log::debug('Message Status', $request->all());
    }
}
```

After making these changes, I sent a message from my personal account to my Facebook page and the following entry appeared in the Laravel log file:

```
{
  "message_uuid": "f4fcc665-7b71-4291-a079-505154e28c36",
  "to": {
    "id": "987654210987654",
    "type": "messenger"
  },
  "from": {
    "id": "123456789012345",
    "type": "messenger"
  },
  "timestamp": "2018-12-12T11:36:44.663Z",
  "direction": "inbound",
  "message": {
    "content": {
      "type": "text",
      "text": "Christmas Dinner"
    }
  }
}
```

Excellent! The user sent me a message and my application received it as intended. Now that we can receive messages it’s time to start sending back responses.

> The changes made in this section are shown in [this commit](https://github.com/nexmo-community/turkey-timer-laravel/commit/12d84352ea121a742ce8ba2ed8de0b5a39470d4b)

## Creating a Laravel Notification

To send updates back to the user at the correct time we’re going to be using the Laravel queue system’s `delay` functionality.  Before we can do that, we need to enable the `queue` functionality in Laravel. We’re going to use the `database` driver as it won’t be particularly high throughput and using the database removes the need for additional dependencies such as Redis. We can configure this setting in the `.env` file:

```
QUEUE_CONNECTION=database
```

Once that’s done, I created the table to store the jobs by running `php artisan queue:table && php artisan migrate`.

With all of the admin out of the way, it’s time to start building our notifications. I’ll need to send a simple sentence whenever a condition is triggered. I could have created one notification per message, but in the interest of speed I created a single notification that accepts a string at `app/Notifications/FreeText.php` with the following contents:

```php
namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Contracts\Queue\ShouldQueue;

class FreeText extends Notification implements ShouldQueue
{
    use Queueable, ShouldQueue;

    protected $text;
    protected $channel;

    public function __construct($text, $channel)
    {
        $this->text = $text;
        $this->channel = $channel;
    }

    public function via($notifiable)
    {
        return [];
    }
}
```

This defines a notification, but our application doesn’t know how to send it yet. We need to populate the `via` method and implement any `to*` methods on the notification.  To send these notifications we’re going to be using the [nexmo/laravel-notification](https://github.com/Nexmo/laravel-notification) package which allows us to implement the following methods on our notification:

* `toNexmoWhatsApp`
* `toNexmoFacebook`
* `toNexmoViberServiceMessage`
* `toNexmoSms`

We’re going to implement and `toNexmoFacebook` by adding the following to the notification:

```php
public function toNexmoFacebook($notifiable)
{
    return (new \Nexmo\Notifications\Message\Text)
        ->content($this->text);
}
```

In addition to implementing these methods, we need to tell Laravel how to route the message. Usually you’d use the `$notifiable` entity passed to the method to determine how the user wants to be contacted. In this case, we’re going to reply on the channel that we received the message on. This channel is passed in to the notification’s constructor. This is what my `via` method looks like with those changes:

```php
public function via($notifiable)
{
    return [$this->channel];
}
```

There is one last thing to do before this will all start working, and that’s to provide some Vonage authentication credentials and configuration for sending via Messenger. If you want to do the same, [create an application](https://dashboard.nexmo.com/messages/applications) on the Vonage dashboard and add the following to your `.env` file:

```
NEXMO_APPLICATION_ID="YOUR_APPLICATION_ID"
NEXMO_PRIVATE_KEY=./private.key
NEXMO_FROM_MESSENGER="FACEBOOK_PAGE_ID"
```

> The changes made in this section are shown in [this commit](https://github.com/nexmo-community/turkey-timer-laravel/commit/51af543c1a2c484926a6d1325b84d8baea5d067d)

## Sending Updates to Facebook

Now that we’ve done all of the hard work, the last thing to do is send the actions that need to be carried out to cook the recipe. 

Upon receiving a message from a user we need to extract the channel the message was sent on, and the ID of the user that sent us the message. Once we have that, we can create a new [On-Demand Notification](https://laravel.com/docs/5.7/notifications#on-demand-notifications) using this information:

```php
// The incoming message contains the platform + contact details that
// we need to reply with, so configure a notification route with those
// details
$from = $request->input('from');

// The Vonage Messages API returns messenger, but our channel names are all prefixed with nexmo-
$channel = 'nexmo-' . $from['type'];
$sender = Notification::route($channel, $from['id']);
```

At this point we can send any text we like to the user. The first thing we need to check is if the message they sent us contains a recipe name. If does not, we send them a message saying that we couldn’t find that recipe.

```php
// Try and find the recipe name that was sent to us
$recipeName = $request->input('message.content.text');
$recipe = \App\Recipe::where('name', $recipeName)->first();
if (!$recipe) {
    $sender->notify(new FreeText(
        "I couldn't find that recipe",
        $channel
    ));
    return;
}
```

If we get past this block of code then we have a valid recipe, and it’s time to schedule some notifications! Each set of timings on a recipe has an `action` and a `start_time` in seconds, starting at zero. Fortunately Laravel allows us to delay a notification by a number of seconds from now, making it the perfect fit for our use case.

The final part of our `inboundMessage` method needs to iterate over every `timing` and schedule a new notification:

```php
foreach ($recipe->timings()->get() as $t) {
    $sender->notify((new FreeText(
        $t->action,
        $channel
    ))->delay($t->start_time));
}
```

Putting it all together, our `inboundMessage` method looks like the following:

```php
public function inboundMessage(Request $request) {
    \Log::debug('Inbound Message', $request->all());

    $from = $request->input('from');

    // The Vonage API returns messenger, but our channel names are all prefixed with nexmo-
    $channel = 'nexmo-' . $from['type'];
    $sender = Notification::route($channel, $from['id']);

    // Try and find the recipe name that was sent to us
    $recipeName = $request->input('message.content.text');
    $recipe = \App\Recipe::where('name', $recipeName)->first();
    if (!$recipe) {
        $sender->notify(new FreeText(
            "I couldn't find that recipe",
            $channel
        ));
        return;
    }

    // If we get this far, we have a recipe! Time to schedule some notifications
    foreach ($recipe->timings()->get() as $t) {
        $sender->notify((new FreeText(
            $t->action,
            $channel
        ))->delay($t->start_time));
    }
}
```

> The changes made in this section are shown in [this commit](https://github.com/nexmo-community/turkey-timer-laravel/commit/c8719fbcb0ad4d54332115e8ee2d7beec4e9eb25)

## Running the Application

Now that everything’s been built it’s time to run the final application! Here’s a quick checklist of everything I needed to do to get things working:

1. Run `php artisan serve`
2. Make sure `ngrok http 8000` is running so that Vonage can make calls to my application
3. Run `php artisan queue:work` to watch for jobs being inserted in to the database
4. Visit my Facebook page and send it a recipe (in this case, `Christmas Dinner`!)
5. Sit back and relax, knowing that I’ll get a message when there’s something I need to do

If you’d like to see the complete project for this post you can [find it on Github](https://github.com/nexmo-community/turkey-timer-laravel).  If you want to run it yourself, you’ll need to:

1. Link a Facebook page to Vonage
2. Create a new Vonage application and associate your page with that application
3. Configure your webhooks
4. Clone the repo
5. Update `.env` with your Vonage credentials
6. Run `composer install`
7. Run `php artisan migrate && php artisan db:seed`
8. Run `php artisan serve` and `php artisan queue:work` in separate terminals
9. Send your Facebook page a message

## Where Next?

Well, that was fun! Not only did I get to try out the [Vonage Messages API](https://developer.nexmo.com/messages/overview) but I learned a lot about Laravel notifications (including how to build [new channels](https://github.com/Nexmo/laravel-notification)). As an added bonus, I’ll even have a little helper reminding me when things need to happen on Christmas Day!