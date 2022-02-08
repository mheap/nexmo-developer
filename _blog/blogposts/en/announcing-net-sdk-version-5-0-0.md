---
title: Announcing .NET SDK Version 5.0.0
description: Version 5.0.0 of our .NET SDK is the biggest release yet, with some
  significant integration improvements. Take a look at what's new!
thumbnail: /content/blog/announcing-net-sdk-version-5-0-0/Blog_SDK-Updates_1200x600.png
author: stevelorello
published: true
published_at: 2020-06-22T12:31:04.000Z
updated_at: 2021-05-04T15:27:38.183Z
category: release
tags:
  - dotnet
  - sdk
  - sdk-announcements
comments: true
redirect: ""
canonical: ""
---
I'm happy to announce the release of our new [.NET 5.0.0 SDK](https://github.com/nexmo/nexmo-dotnet). This is my first major release since joining the Platform & Developer Experience team at Vonage last year, and I'm excited to share what's new.

## New Features

We've added a few new features to the .NET SDK, here's an enumeration of them.

### Rebuilt SDK Around .NET Conventions

Older iterations of the SDK didn't feel very ".NET", this release fixes that.

* We've abstracted all API Calls behind interfaces allowing easy substitution via dependency injection for your testing. For example, the Legacy SDKs SMS class is replaced by the `ISmsClient` interface, which you can speak through or replace on your own.

* All of the new structures and APIs are now compliant with .NET naming conventions. Additionally, we've introduced many new enums to remove some open string fields.  We preserved the legacy structures but marked them as obsolete as a gentle reminder to update the latest version as this will make upgrading easier.

## New Logging Methodology

A new means of logging has been added to the SDK built around [Microsoft.Extensions.Logging](https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.logging?view=dotnet-plat-ext-3.1). Thus you can configure the logging of the SDK to use whatever logging format you want; you can make it as compliant to your own logs as you'd like, and there's no need to log our SDKs outputs to your log files.

See my [explainer](https://www.nexmo.com/blog/2020/02/10/adaptive-library-logging-with-microsoft-extensions-logging-dr) about how this is structured and how you can get up and logging with your own logs!

## Added Summary Documentation File

The SDK now comes with a summary docs file to make it easier for you to determine how to go about building your applications.

## New Error Handling Methodology

All API calls will throw an exception containing a best-effort description of what went wrong if they encounter an error. This includes all 4xx, 5xx responses, and errors from the [SMS](https://developer.nexmo.com/messaging/sms/overview), [Numbers](https://developer.nexmo.com/numbers/overview), [Number Insight](https://developer.nexmo.com/number-insight/overview), and [Verify](https://developer.nexmo.com/verify/overview) APIs that might respond with a 200 OK response and an error code. All of these exceptions will be of the type `NexmoException` (SubTypes `NexmoSmsResponseException`, `NexmoNumberInsightResponseException`, `NexmoNumberResponseException`, `NexmoVerifyResponseException`) or `NexmoHttpRequestException`.

There are similar errors that will be thrown for the legacy APIs as well.

## Under the Hood

We've also made some significant enhancements under the hood that will be less relevant to interacting with the API but might still be interesting.

### Refactored Internal Request Methods

We've refactored all of the internal `ApiRequest` methods to make them more user friendly and generic. You can have a look [here](https://github.com/Nexmo/nexmo-dotnet/blob/v5.0.0/Nexmo.Api/Request/ApiRequest.cs).

> Note: These methods are not considered part of the public API of the SDK and are subject to change without notice.

### Unit Tests

We've added a whole new suite of unit tests to prevent things from breaking on their way out the door. Unit test coverage went from 33% in 4.4.0 to 87% in 5.0. Virtually everything that is not tested is either legacy or a third party file we've incorporated into the SDK.

## Breaking Changes

We've done our best to ensure that the upgrade path to 5.0 will be as seamless as possible. 

The new structures should not affect current users of the SDK though I would encourage everyone to heed the obsolescence warnings. That said, there are a couple of breaking changes between 4.x and 5.x that you should be aware of.

* We've removed LibLog, thus without action on the developer's part logs will cease to be intermingled with developer's logs.

* New exceptions will be thrown in the case of any error being encountered on an API call, this includes 200 responses with error codes.

## There's More to Come

This new library is a sea change for the .NET SDK, but it's only the beginning. We've much more to come and I'm looking forward to sharing more with you in the future!

Until then, if you have any questions feel free to find us on our [community slack](https://developer.nexmo.com/community/slack).

## Resources

* You can find our NuGet package [here](https://www.nuget.org/packages/Nexmo.Csharp.Client/)
* Our SDK is maintained in [GitHub](https://github.com/nexmo/nexmo-dotnet), please feel free to come and explore, open an issue if you encounter one, or maybe even contribute to the effort!