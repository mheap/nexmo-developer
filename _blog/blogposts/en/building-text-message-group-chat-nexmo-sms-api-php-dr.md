---
title: Building Text Message Group Chat with the Nexmo SMS API and PHP
description: In this tutorial we're going to build a simple Text Message Group
  Chat using the Nexmo SMS API and the Nexmo PHP Client. We'll use MongoDB as
  our Database.
thumbnail: /content/blog/building-text-message-group-chat-nexmo-sms-api-php-dr/group-chat-sms-terminal.png
author: tjlytle
published: true
published_at: 2016-06-02T15:26:13.000Z
updated_at: 2021-05-13T11:08:18.238Z
category: tutorial
tags:
  - php
  - sms-api
comments: true
redirect: ""
canonical: ""
---
To exercise the new PHP client library a bit, we're going to build a simple SMS group chat where a user's inbound message is sent to all the other members of the chat. You can follow along here and build it with me, or just clone [the Nexmo SMS Group Chat repository](https://github.com/nexmo-community/nexmo-php-sms-group-chat) and see it in action.

I won't judge if you just clone the repo, really, I won't. Much.

### What We're Building

We're going to put together a simple script that:

* Allows users to text `JOIN` and their name (e.g. `JOIN tlytle`) to a phone number where the phone number represents a 'group'.
* Once joined any message a user sends will be relayed to the rest of the group. And users get any message someone else sends.
* If a user decides they no longer want to be a part of the group, sending `LEAVE` will unsubscribe them. 

In a follow-up post we'll also put together a simple web interface where they can see a log of the group's messages.

### Set Up

<sign-up number></sign-up> 

We'll start with the [Nexmo client library](https://github.com/Nexmo/nexmo-php), and a Mongo database. Setting up the database is beyond the scope of this tutorial, but there are a few Mongo hosts with free tiers, and setting up a database on one of them should be pretty straightforward. You'll also need the [Mongo driver for PHP](http://php.net/manual/en/set.mongodb.php) installed.

You can include that and the Nexmo client library with Composer:

```
 $ composer require nexmo/client 1.0.*@beta
 $ composer require mongodb/mongodb
 
```

Defining a simple configuration file will let us keep our API credentials and database connection in a single file.

Here's an example `config.php` to use as a template:

```
<?php
return [
    'mongo' => [
        'uri' => 'mongodb://user:password@host:port',
        'database' => 'groupchat'
    ],
    'nexmo' => [
        'key' => 'key',
        'secret' => 'secret'
    ]
];
```

A very simple bootstrap (`bootstrap.php`) file takes care of autoloading and passes on the configuration file:

```
<?php
$autoloader = require __DIR__ . '/vendor/autoload.php';
$config = require  __DIR__ . '/config.php';
$config['autoloader'] = $autoloader;

return $config;
```

With those two files in place, we're ready to build our group chat application.

### Handling Inbound Text Messages

We'll need a script that accepts [inbound webhooks](https://docs.nexmo.com/messaging/setup-callbacks#setting) from Nexmo, and processes the message. So, create an `public/inbound.php` and within that include `../bootstrap.php`, create a Nexmo client, and a mongo client.

```
<?php
$config = require __DIR__ . '/../bootstrap.php';
$nexmo = new \Nexmo\Client(new \Nexmo\Client\Credentials\Basic($config['nexmo']['key'], $config['nexmo']['secret']));
$mongo = new \MongoDB\Client($config['mongo']['uri']);
$db = $mongo->selectDatabase($config['mongo']['database']);
```

Next, we want to create an inbound message from an inbound request and check that it's valid. The client library provides a simple way to do this. 

```
$inbound = \Nexmo\Message\InboundMessage::createFromGlobals();
if(!$inbound->isValid()){
    error_log('not an inbound message');
    return;
}
```

Now that the file is setup you can head to the [Nexmo dashboard](https://dashboard.nexmo.com), and [point a number to that script](https://docs.nexmo.com/messaging/setup-callbacks#setting) in the `Callback URL` field.

![Phone Number SMS Callback Webhook Settings](/content/blog/building-text-message-group-chat-with-the-nexmo-sms-api-and-php/sms-callback-settings.png)

That configures your Nexmo account to make a webhook request to the script whenever a message is sent to that number. If you're developing locally, you'll need to use something like [ngrok](https://ngrok.com/) to create a local tunnel with a public URL the Nexmo platform can reach. 

Once you've configured the number, you can send it a message - but it won't do anything. So let's reply to the sender with some instructions. The inbound message object created by the client library has a `createReply` method that uses the inbound webhook data to create a reply by flipping the `to` and the `from`. 

```
$nexmo->message()->send($inbound->createReply('Use JOIN [your name] to join this group.'));
```

Now send a message to your Nexmo number, and you should get a nice quick reply.

Because we're using the parameters sent with the inbound webhook, our code does not need to know what number to use as the sender. Why is that important? Now with no additional code or configuration we have a simple autoresponder that supports as many Nexmo numbers - and by extension group chats - as we point to it.

### Processing Commands

Before we can really process any `JOIN` commands, we need to know if the user has already interacted with the system. So it's time to write some queries. We'll set things up with a `users` collection. And we'll expect that each document has the `group` property set to the inbound Nexmo number the message was sent to. The `user` will be set to the user's number (the number the message was sent from).

```
$user = $db->selectCollection('users')->findOne([
    'group' => $inbound->getTo(), // the group's number
    'user'  => $inbound->getFrom() //the user's  number
]);
```

Let's add a simple error log so we can troubleshoot if needed:

```
if($user){
    error_log('found user: ' . $user['name']);
} else {
    error_log('no user found');
}
```

Since there's no data in the database, any message at this point should log `no user found`. Now that we've code in place for use checking, we can start looking for command keywords. 

We'll use the first word to check if the user is sending a command. Because the `JOIN` command expects a name as well, we need to parse the message into a single command as the first word, and an optional argument afterward. Using a regular expression to split on any space, and limiting that to 2 elements gives us what we need. With a parsed command, a `switch` will let us act on that first word:

```
$command = preg_split('#\s+#', $inbound->getBody(), 2);
switch(strtolower(trim($command[0]))){
```

To start, let's check if the expected second argument has been provided as well - at least for new users. If it's not, sending a reply is easy, we'll just move the reply we already have here: 

```
case 'join';
    error_log('got join command');

    if(!$user && empty($command[1])){
        $nexmo->message()->send($inbound->createReply('Use JOIN [your name] to join this group.'));
        break;
    }
```

If it is a new user (no existing user found), and they provided a name (`$command['1']` was not `empty()`) we should setup the basic user data:

```
if(!$user){
    $user = [
        'group' => $inbound->getTo(),
        'user' => $inbound->getFrom(),
        'actions' => []
    ];
}
```

And let's not forget that name. Why do we do it *outside* the new user check? To allow an existing user to update their name using the `JOIN` command, if they provide a new one. Since we're ensuring that new users have that second argument, we know that any new user will have the name set as well:

```
if(isset($command[1])){
    $user['name'] = $command[1];
}
```

Since it's a `JOIN` command, we also need to set the user's status to active, and create a log entry for the action.

```
$user['status'] = 'active';
$user['actions'][] = [
    'command' => 'join',
    'date' => new \MongoDB\BSON\UTCDatetime(microtime(true))
];
```

Now we just need to save (or create) the user. We'll use Mongo's `replaceOne` command and have it insert the document (`upsert`) if needed, and add `break` so we stop processing once the action is taken:

```
$db->selectCollection('users')->replaceOne([
    'group' => $inbound->getTo(), // the group's number
    'user'  => $inbound->getFrom() //the user's  number
], $user, ['upsert' => true]);

error_log('added user');
break;
```

`JOIN`ing gets us halfway there, but we still need to allow users to `LEAVE` a group. Like `JOIN` we'll do a bit of logging and check that the user is actually subscribed - they can't really leave if they're not. If they aren't subscribed, we'll just reply with some help. Which, as we've found out, is pretty easy to do: 

```
case 'leave';
    error_log('got leave command');

    if(!$user){
        $nexmo->message()->send($inbound->createReply('Use JOIN [your name] to join this group.'));
        break;
    }
```

If they are subscribing, we need to update the subscription status and log that the action was taken. That's done by changing the `status` property, and appending a new member to the `actions` array. Of course writing this change to the database is also important:

```
//update the user's status
$user['status'] = 'inactive';
$user['actions'][] = [
    'command' => 'leave',
    'date' => new \MongoDB\BSON\UTCDatetime(microtime(true))
];

//update the database
$db->selectCollection('users')->replaceOne([
    'group' => $inbound->getTo(), // the group's number
    'user'  => $inbound->getFrom() //the user's  number
], $user);
```

Once we've removed the user from the group, we should let them know they've left, and how they can join again in the future:

```
//let them know they've left
$nexmo->message()->send($inbound->createReply('You have left. Use JOIN to join this group again.'));

error_log('removed user');
break;
```

## SMS Group Chat by Relaying Messages

Joining and leaving the group taken care of, we now need to handle a user sending a message, not a command. Any message that isn't a command is a message to the group. The logic here is simple, if the user is subscribed and active, their message should be sent to all the *other* members.

We need to check that the user is able to post a message to the group. If we found a user in the database, it means they were at some time subscribed to the group, but we need to check if they've left. If either case isn't true - they're not found in the database, or they're not active in the group - we'll send a quick helpful reply:

```
default:
    error_log('no command found');

    if(!$user || 'active' != $user['status']){
        $nexmo->message()->send($inbound->createReply('Use JOIN [your name] to join this group.'));
        break;
    }
```

If they are subscribed and active, we create an archive of their message. This contains the text, the group they sent it to, the user themselves (as well as their name, to avoid having to look up the user every time the name is needed), and other meta data. 

We'll also create an empty `sends` array to log the messages sent to the other users in the group:

```
error_log('user is active');

$log = [
    '_id'   => $inbound->getMessageId(),
    'text'  => $inbound->getBody(),
    'date'  => new \MongoDB\BSON\UTCDatetime(microtime(true)),
    'group' => $inbound->getTo(),
    'user'  => $inbound->getFrom(),
    'name'  => $user['name'],
    'sends' => []
];
```

To find all the members that need the message relayed, we query the `users` collection for any users in this specific group that are marked as active. We need to remember to exclude the current user (that's what the `$ne` means, 'not equal'), but it can be handy to remove this for testing purposes:

```
$members = $db->selectCollection('users')->find([
    'group'  => $inbound->getTo(),
    'user'   => ['$ne' => $inbound->getFrom()],
    'status' => 'active'
]);
```

Once we have that list we can iterate over it and send a message to each member. We can pass a simple array to the `send()` method (as well as a `Message` object). That array uses the member's number as the `to`, the group's number as the `from`, and we'll add the name of the user that posted the message to the `text` before sending the message.

That will return a full message object. We could treat as an array, but it's easier to just use the getter methods to add the message id and the member's number to the send log.

```
foreach($members as $member) {
    $sent = $nexmo->message()->send([
        'to'   => $member['user'],
        'from' => $inbound->getTo(),
        'text' => $user['name'] . ': ' . $inbound->getBody()
    ]);

    $log['sends'][] = [
        'user' => $sent->getTo(),
        'id'   => $sent->getMessageId()
    ];
}
```

Once all the message are sent, we add the new message to the log collection on the database, and we're done processing the inbound messages. 

```
    $db->selectCollection('logs')->insertOne($log);

    error_log('relayed message');
    break;
} // end of switch
```

### Next Steps

And with that we've setup a simple script that accepts inbound messages, replies to some of them, and relays others to a group. Centrally the command concept could be extended to more complex and interactive auto-responder bots, the group relay could be turned into two user proxy that only masks the user's numbers, or this could be repurposed as a SMS distribution list that allows anyone to send an inbound message to a group of people.

![Group SMS Chat in the terminal](/content/blog/building-text-message-group-chat-with-the-nexmo-sms-api-and-php/group-chat-sms-terminal.png)

Wherever you take it, processing inbound messages and sending outbound messages is an easy task with the PHP client library and Nexmo's API.

There's also a bit more to this demo (which you can just clone and run if you want), and we'll build a web interface to our group chat in part two of this tutorial.

### Useful Resources

* [Nexmo PHP Client library](https://github.com/Nexmo/nexmo-php)
* [Nexmo Inbound SMS Webhook Docs](https://docs.nexmo.com/messaging/setup-callbacks#setting)
* [Nexmo PHP SMS Group Chat Repo on GitHub](https://github.com/nexmo-community/nexmo-php-sms-group-chat)
* [ngrok local tunnel](https://ngrok.com/)
* [MongoDB Driver](http://php.net/manual/en/set.mongodb.php)
* [Mongo DB PHP Driver](https://github.com/mongodb/mongo-php-library)