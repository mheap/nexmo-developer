---
title: Nexmo .NET Client SDK v4.0.0 Is Now Ready for Installs
description: A new version of the Nexmo .NET/C# package is now available, find
  out what the changes are and what they mean for your projects.
thumbnail: /content/blog/nexmo-dotnet-4-release-dr/net-sdk-v4.png
author: bibi
published: true
published_at: 2019-06-25T16:59:26.000Z
updated_at: 2021-05-13T21:05:44.489Z
category: release
tags:
  - csharp
  - dotnet
comments: true
redirect: ""
canonical: ""
---

We are pleased to announce that the [Nexmo .NET client library v4.0.0](https://github.com/Nexmo/nexmo-dotnet) is now available via the NuGet Package Manager Console.

If you're ready to get right into the good stuff, you can go ahead and install it now.

```bash
Install-Package Nexmo.Csharp.Client -Version 4.0.0
```

## What's New

The biggest part of this release is that we now support the new [Nexmo Application API](https://developer.nexmo.com/application/overview).

A Nexmo application contains the security and configuration information you need to connect to Nexmo endpoints and easily use our products.

Despite the fact Application API v2 is backwards compatible with v1, we had to make the hard decision of breaking backwards compatibility with our .NET client library to be able to provide a good quality code.

Some of the properties are also different between the two versions, instead of specifying the `type` of the application as was the case with V1, with V2, we specify the `capabilities` of the app instead.

The application API allows you to create, update or delete an application. You can also retrieve information about a specific application using its ID or list all the applications you've already created giving you greater programmatic control over all your Nexmo applications.

For example to create a new app :

```csharp
Client = new Client(creds: new Nexmo.Api.Request.Credentials
{
    ApiKey = "NEXMO_API_KEY",
    ApiSecret = "NEXMO_API_SECRET",
});

var result = Client.ApplicationV2.Create(new AppRequest
{
    Name = "NEW APP V2"
});
```

To retrieve an application:

```csharp
var result = Client.ApplicationV2.Get("APP_ID");
```

## Get Involved

To all our contributors who tried out the client lib and pointed out issues to be fixed and improvements to be made, to those who suggested new features to help them with their projects, thank you, we shipped v4.0.0 thanks to all of you.

Please keep giving [feedback](https://github.com/Nexmo/nexmo-dotnet/issues) and we will continue to implement [new functionality](https://github.com/Nexmo/client-library-specification) and improved experiences for you.

Now get it installed!
