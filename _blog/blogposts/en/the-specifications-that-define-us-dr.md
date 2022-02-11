---
title: The Specifications That Define Us
description: Standards are one of the best ways for teams to communicate, and a
  great way for newcomers to understand how something works.
thumbnail: /content/blog/the-specifications-that-define-us-dr/E_The-Specifications-That-Define-Us_1200x600.png
author: christankersley
published: true
published_at: 2020-03-09T13:09:44.000Z
updated_at: 2021-05-18T13:37:28.037Z
category: tutorial
tags:
  - community
comments: true
redirect: ""
canonical: ""
---
As a developer, I am lazy. If someone has built software that solves a problem I have, I want to use it. I should be able to hit the ground running and quickly get up to speed with a new library without much interference. 

As Initiative Lead for Nexmo's Server SDK team, one of my goals has been to make sure that we are providing the best experience possible for the developers that use our SDKs. What is the point of an SDK if using it is as painful as digging through documentation and making raw HTTP requests? Our team wants to make sure you can get your job—making software—done quicker.

Recently, the team got together and decided to look over the existing Server SDK Specs (formerly called Client SDK Specs) to see how they were holding up. The specifications had been written back in 2016 as Nexmo started to think more critically about how we wrote our software. In 2020, we now maintain six different language SDKs, with each language having its own quirks. What do we need to do differently today than years ago?

## Less RFC, more Flexible

The first order of business was scrapping much of the RFC-inspired language. The reasoning was pretty simple—RFCs provide a known structure and verbiage that has been agreed upon. Thanks to [RFC 2119](https://tools.ietf.org/rfc/rfc2119.txt), words like `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, and others all have their own specific definitions and set expectations on how RFCs will be written. If someone was creating a new specification document, these words would make total sense.

Four years and five more SDKs later, the document had become fairly strict concerning not only functionality, but also direct implementation. It detailed not just behavior, but also how the API clients should be structured. This caused a natural split in how some SDKs were designed and forced other SDKs to do things in a not very language-natural way. Should a Ruby SDK look and act like a NodeJS library?

Probably not.

So we've removed much of the language around specific language constructs, but have kept in the [overarching goals and aims of various ideas](https://github.com/Nexmo/client-library-specification/blob/master/SPECIFICATION.md#general-principles) that we feel make an SDK easy to use. Errors and Exceptions still follow the idea that a library should throw explicit Server or Response exceptions, while the directions around naming things have been reduced to "here are a list of verbs you should use." The specification no longer dictates direct invocations of methods but suggests consistent naming. 

The specification is much less interested in making the SDKs a homogenous experience and now pushes a directive of matching language expectations and best practices. Over time this means our public SDK APIs will be changing, but changing into something you as a developer of Language X expects. We want the SDKs to provide an experience you would get with any well-constructed library from your language.

## Abstract Away the HTTP-ness

The awesome thing about Nexmo is that anyone can immediately start to use our API just by hitting a web address. The internet has helped make it possible to quickly interact with machines across the world using a standard protocol, HTTP, and a simple textual interface through JSON and XML. We can wire together various services like never before.

But why, when you need to play text-to-speech into a call, are we having you do a `$talk->put()`? Semantically, it makes no sense.

Yes, Nexmo provides an awesome API, but when you are creating your software you should not really care what we are. If you want to play text-to-speech into a call, `$call->playTextToSpeech("Hello World")` is so much more clear on its intentions. This may make an HTTP `PUT` request to do the work, but there is not a reason we need to name our methods after HTTP methods.

We have cleaned up the [verbs and naming conventions](https://github.com/Nexmo/client-library-specification/blob/master/SPECIFICATION.md#global-verb-definitions-for-convenience-methods) to a list of actions you would be taking to get work done, not to write an HTTP client with. Developers use SDKs to abstract away the third-party services they use, so we should help continue that abstraction with our naming conventions. At the end of the day, no one cares whether we used a `PUT` or a `POST` to do something, they just want to find and perform an action.

## Convenience Above All Else

I want to make sure that not only do our SDKs provide for all the different ways you can interact with our platform, but also that the interface is easy to understand and easy to use. Our SDKs should be helping you fix your problem by being explicit about the work being done while helping take care of the boilerplate that can come with doing work. 

If we go back to our example of playing text-to-speech into an existing call, our current way is a bit obtuse from a clarity and semantics standpoint. Finding out how to do something in our SDK should be explicit, but also quick to do. I do not want a developer coming back to their code in six months and trying to figure out why `talk()` returns an object instead of performing an action. I want the developer to easily read their own code and know exactly what is happening at all times.

```php
// Current, pull a Talk object out of a specific call
$talk = $client->calls['abcd-123']->talk();
// Set the text
$talk->setText(TEXT);
// PUT the text back to the API
$talk->put();

// In the future, we will just find a specific call
$call = $client->calls()->find('abcd-123');
// And play Text to Speech into it
$call->playTextToSpeech("All your base are belong to us");
```

## The Future

The Server SDK team is currently going through all of our mainline SDKs ([NodeJS](https://github.com/Nexmo/nexmo-node), [Java](https://github.com/Nexmo/nexmo-java), [Python](https://github.com/Nexmo/nexmo-python), [.NET](https://github.com/Nexmo/nexmo-dotnet), [Ruby](https://github.com/Nexmo/nexmo-ruby), and [PHP](https://github.com/Nexmo/nexmo-php)) and giving them a once over against the new specification. We have some exciting changes coming as we focus on the developer experience with our SDKs, and we want to provide all of our customers the same ease of use they have always expected with our SDKs in a more modern, clean way.

As always, we love to hear feedback from our customers. We build this software to make your lives easier. If you see us at a conference or a meetup, let us know how we are doing! Is there something you would like to see in our SDKs? Reach out to us on [Github](https://github.com/nexmo) and let us know if there are features you are lacking. 
