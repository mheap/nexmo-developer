---
title: Taking Time for Yourself, Code-Wise
description: What makes a good SDK? This post discusses places to be more modern
  and agile, and updates we have made to provide a better UX for the Vonage
  SDKs.
thumbnail: /content/blog/taking-time-for-yourself-code-wise/Blog_Taking-Time-for-Yourself_1200x600.png
author: christankersley
published: true
published_at: 2020-07-22T14:54:13.000Z
updated_at: 2021-05-04T17:33:47.587Z
category: devlife
tags:
  - sdk
  - devrel
  - developer-experience
comments: true
redirect: ""
canonical: ""
---
Back in March of 2020, I [talked about revisiting our Server Specifications](https://www.nexmo.com/blog/2020/03/09/the-specifications-that-define-us-dr), and that one of my main goals was to make sure that we are providing the best experience possible for the developers that use our SDKs. Updating the server specification allowed our team to open up a bit and build out the SDKs in ways that made sense for the language, and gave each developer the experience they expected.

We came up with goals for the first half of the year around the idea of cleaning up the user experience. This resulted in our language developer advocates going through each of the SDKs, both on the Nexmo and OpenTok namespaces, and finding where we could better align with the new specification. We began to make a list of where we were non-compliant with the specification. That sounds very formal, but what we mean is, did the SDKs align with our new goals? Where do the SDKs not look or feel like a library for Language X?

## One Chance To Make a First Impression

For many developers, their first experience with a Vonage API is through our server or client SDKs. One of the first tasks in their project will be installing our SDK software and bootstrapping it for the first time. From that moment forward, our job is to make it is easy to write software for our platform.

Each language is different, and we understand that. A Java developer has a different set of expectations for writing an application compared to a Ruby developer. Our SDKs should be exposing our APIs in a way that makes sense for the languages that we support. We should be as Pythonic or idiomatic or clean as a developer expects a proper library to be.

Languages also evolve. I am a PHP developer, and a lot of the hate our language gets is based on code with expectations and restrictions from bygone years and versions that are no longer supported. Our SDKs should, and do, evolve with the languages. Developers have expectations on what "modern" code looks like and we should strive to deliver on that.

A major goal of our Server SDK team is to deliver libraries that are up-to-date not only with our products but also with developer expectations. We have always upheld various ideas like test-driven development, high-quality documentation, and attention to detail. We plan on continuing to keep our pulse on the developer and language communities to provide the best developer experience we can.

## What Were We Looking For?

The largest part of the audits revolved around our products' usage and whether or not the SDKs exposed that usage in a clear, obvious manner. Code clarity was a major focus in the new SDK specification and became a significant focus in the audits. 

The audit gave each of our language advocates the time and power to mark where we could do better. None of our SDKs were behind when it came to the support we expected to provide, but each of the SDKs had tweaks and naming changes to public interfaces that would make intentions clearer. 

As a sneak-peek to some upcoming PHP SDK changes, much of the Voice API layer got a rewrite. If you want to make an outbound call, you create an `OutboundCall` object. If you want to generate an NCCO, you can create an `NCCO` object, and add actions to the NCCO. Taking a page out of the "self-documenting code" playbook, a developer should be able to read this code and understand what is going on even if they are not familiar with PHP itself.

```php
$outboundCall = new OutboundCall(new Phone(TO_NUMBER), new Phone(NEXMO_NUMBER));
$ncco = new NCCO();
$ncco->addAction(new Talk('This is a text to speech call from Vonage'));
$outboundCall->setNCCO($ncco);

$response = $client->voice()->createOutboundCall($outboundCall);
```
The idea is not that the old way was hard; it was just not as clear as to what was happening. Renaming methods and classes can be quite a challenge to deal with, but our hope is that many of these changes not only make it easier to understand what our products do but the best way to use them.

This audit also let us find places where one or two SDKs were doing something that should be made global across all the SDKs. One of these options was letting users be able to specify base URLs for the APIs. While this had been a customer request, it turns out some SDKs had already implemented it. The audit gave us a chance to round up these ideas and make sure they were added across all our SDKs.

## Making The Products Better

Many of our language developer advocates that maintain our SDKs are also what we call Product Specialists. Our Product Specialists help work with product managers and the various engineering teams as they build out our API products. As the Product Specialists help to design the product itself, how developers interact with the APIs through the SDKs gets an early look. 

If we find that something might be difficult for a developer to work with, we can make better decisions at either the API or the SDK level to make the developer's life easier. Our job is not just traveling to events and handing out t-shirts—we take all that feedback from developers and let the product managers and engineers know where we can provide a better experience, and help to find solutions. 

The recent [.NET v5.0.0 release](https://www.nexmo.com/blog/2020/06/22/announcing-net-sdk-version-5-0-0) saw many improvements to the SDK. There were some helpful code additions like improved error handling and a more flexible logging system, but the unit tests and code snippets saw a refactor. These changes not only improve our, and by extension, your confidence in the code and changes, the examples became much more clear and concise on how to implement our SDKs.

## We are Here to Serve You

At the end of the day, our job is to advocate for the developers using our software. We are not necessarily advocating for you to use our product, we are the advocate for you, the developer, as a voice inside Vonage. Part of what we do is taking the feedback we get from the developers we meet back and making our products better, but we also have a hand in making sure your experience is as good, and productive, as it can be. We could auto-generate our SDKs and call it a day, but that doesn't help you, the person trying to solve a problem.

By the end of 2020, we will have a lot of exciting updates to the SDKs geared specifically to making development clearer. .NET, Python, and PHP have some wonderful rewrites coming down the pike that helps clean up various experiences. Ruby is continuing the static type checking [introduced in v6.3.0](https://www.nexmo.com/blog/2020/02/26/nexmo-ruby-new-release-host-overriding-dr) along with various general improvements ([v7.0.0](https://www.nexmo.com/blog/2020/04/06/nexmo-ruby-v7-0-0-release-dr) introduced better error handling and clearer class names, so check out that release). 

Feel free to reach out to us with any feedback on our products or the software, demos, or tools we create. We have a [community Slack channel](https://developer.nexmo.com/community/slack) that our language and product advocates help answer questions in the day-to-day. We monitor [Stack Overflow](https://stackoverflow.com/questions/tagged/nexmo) and help provide answers and guidance to the various problems developers face. We respond to e-mails coming into [devrel@vonage.com](devrel@vonage.com) on many different topics about our SDKs and APIs.

We want to give you the tools and support that solve your problem, as quickly and efficiently as possible. 