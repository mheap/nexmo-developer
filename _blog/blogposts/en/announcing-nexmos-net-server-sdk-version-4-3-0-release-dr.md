---
title: Announcing Nexmo’s .NET Server SDK Version 4.3.0 Release
description: .NET SDK release feature JWT generation and owned number listing capabilities
thumbnail: /content/blog/announcing-nexmos-net-server-sdk-version-4-3-0-release-dr/E_NET-SDK-Update_1200x600.png
author: stevelorello
published: true
published_at: 2020-01-15T15:21:50.000Z
updated_at: 2021-04-27T15:18:03.607Z
category: release
tags:
  - dotnet
  - sdk
  - ""
comments: true
redirect: ""
canonical: ""
---
We are pushing out a new version of the .NET server SDK—version 4.3.0. This new version has two new core features.

## Generate JWTs From the Nexmo SDK

You can now create your own JWTs directly from the SDK. This can be very useful when using one of the beta SDKs (e.g. Messages and Dispatch) as it avoids the need to implement your own JWT generation logic.

To do this—simply invoke it like so:

```csharp
Jwt.CreateToken(NEXMO_APPLICATION_ID, NEXMO_PRIVATE_KEY)
```

If you've followed some of my recent posts:

* [Santa's Nexmo Helper](https://www.nexmo.com/blog/2019/12/19/santas-nexmo-helper-c-advent-series-dr)
* [Facebook what kind of dog is that?](https://www.nexmo.com/blog/2019/10/31/how-to-add-machine-learning-to-facebook-messenger-dr)

You'll be able to circumvent the JWT process entirely by simply using the SDK.

## List Your Owned Numbers from the Nexmo SDK

Now you can list your owned number using the Nexmo SDK easily with the following code:

```csharp
var response = client.Number.ListOwnNumbers(new Number.SearchRequest() 
{
    pattern = NUMBER_SEARCH_CRITERIA,
    search_pattern = NUMBER_SEARCH_PATTERN
});
```

This allows you to monitor and manage your own numbers directly from Nexmo rather than having to purchase and save your numbers.

## More to Come

There's much more to come, but until then, feel free to follow the .NET SDK in GitHub: https://github.com/Nexmo/nexmo-dotnet - for real-time updates. If you have any questions, issues, or concerns please feel free to raise them there or find me @Steve Lorello in our [community slack](https://developer.nexmo.com/community/slack) and I'll be more than happy to help.