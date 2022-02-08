---
title: OpenAPI-led Development at Nexmo
description: OpenAPI is a standard format for describing APIs. It makes it
  easier for machines and humans to know the capabilities and format of a
  particular API.
thumbnail: /content/blog/openapi-led-development-at-nexmo/OpenAPI2_1200x675.png
author: alyssa-mazzina
published: true
published_at: 2018-11-05T17:01:25.000Z
updated_at: 2021-05-04T03:48:40.321Z
category: community
tags:
  - open-api
comments: true
redirect: ""
canonical: ""
---
At Nexmo, we’ve adopted an OpenAPI-led development process. Here’s why.

## Avoiding UML Hell

History has taught us that software development suffocates under the weight of overwrought specifications. 

Andy Hunt, co-author of the Agile Manifesto, [tells the story](https://www.outsystems.com/blog/software-twinkie-talking-enterprise-apps-agile-andy-hunt.html) of a project he worked on in the 1990s. After two and a half years, and several million dollars, the project’s architect had produced a room full of UML diagrams but not a single line of code was deployed. 

Today, we carefully balance the need for up-front specs with the understanding that often it’s only in writing the code itself that we discover the true nature of the problem we’re solving. 

It turns out, though, that the balance between specs and discovery is different for public APIs than it is when we’re building other kinds of software. And at Nexmo that led us to change how we develop new APIs: the first thing we do when developing a new service is to create an OpenAPI spec. That gives us benefits in developer experience, human versus machine readability, automation, and more.

## Developer Experience

APIs are public contracts. When we build and launch something like our [Messages API](https://developer.nexmo.com/messages/overview), we’re making a deal with our customers: if you make API call X with data Y then our platform will do Z. 

That makes building a public API essentially the same as creating a standard. Think about SVG. It’s a standard for vector graphics. The standard and the various implementations of that standard exist as separate things. If I write a library that generates SVG files, then I shouldn’t have to care about the implementation details of whatever software will later read that file. 

Too often, APIs are shaped by the underlying implementation—what Joel Spolsky calls [leaky abstractions](https://www.joelonsoftware.com/2002/11/11/the-law-of-leaky-abstractions/)—or by design decisions taken on the fly. Starting by creating an OpenAPI spec means that we can make intentional design decisions that are one-step removed from the detail of what’s going on underneath. In turn, that leads to a consistent, intuitive developer experience. 

One unexpected benefit is that creating OpenAPI specs uncovers potential usability issues. We’ve found that if it’s hard to model an API in an OpenAPI spec, that tends to mean that the API itself will be hard to use. That has pushed us to rethink some less than optimal API designs that might otherwise have made it to production.

## Humans and Machines

Taylor Barnett of Stoplight.io describes OpenAPI specs as “[a development contract, a bridge between teams](https://devrel.net/developer-experience/going-to-infinity-and-beyond-documentation-with-openapi).” Even though humans write the code, APIs explicitly act as interfaces between machines.

OpenAPI-spec-led development makes the API into much more than just the interface between two bits of code. It turns the API into a source of agreement between people. Technical writers can use it to kick-start documentation efforts, developer advocates to explain it to external developers, product managers to maintain it as source of truth regarding the API’s capabilities.

As [documented by Kin Lane](https://apievangelist.com/2018/03/26/nexmo-manages-their-openapi-30-definition-using-github/), companies are increasingly publishing their OpenAPI specs to GitHub as a public statement of an API’s design. With one document, we can make a machine-readable and human-readable statement of how the API should behave. From there, developers can see what the expected behavior is and reason about the API’s capabilities.

## Automation

OpenAPI specs hold the promise of enabling all sorts of automation. The potential is to be able to automatically generate client libraries, mock end-points, tests, and documentation. 

![A rendered API in Nexmo Developer](/content/blog/openapi-led-development-at-nexmo/automationscreenshot.png "Screenshot of API")

At Nexmo, we’re at the start of that journey. Today, we’re autogenerating API reference docs and some tests. In particular, we’ve found that having an OpenAPI spec up-front has made it easier to create smoke tests. 

Our OpenAPI specs define the API’s expected inputs and outputs, including error messages. We can use that spec to automatically generate smoke tests that provide intentionally incorrect data and then checks to ensure the expected error message is returned.

## Single Source of Truth

Ultimately, the biggest benefit of all is that by starting with an OpenAPI spec, we have a single source of truth. Rather than having API designs in different formats and in different locations (wikis, Google Docs, etc), the spec is now just a standard part of the development process and created using standard development tools. 

That single spec is a way to tell ourselves and our colleagues when development is complete and to tell external developers what to expect. In some sense, the spec is the API and the implementation is just that.

## Start of the Journey

We’re at the start of our OpenAPI-first journey. We’ve trialed the process with two APIs so far—[Redact](https://developer.nexmo.com/api/redact) and [Secret Management](https://developer.nexmo.com/api/account/secret-management)—but all of our APIs have full, public OpenAPI specifications and we plan to shift all of our development to the spec-first model.

From our work so far, we’re certain that this will lead to higher quality API implementations, time saved, and deeper understanding. We’re excited to see how this will improve the quality of APIs across the industry.