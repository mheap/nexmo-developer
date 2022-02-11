---
title: Build a Conference Call with the Vonage Voice API and ASP.NET Core
description: Step by step guide on how to build a conference call "conversation"
  for multiple participants using ASP.NET Core and Vonage's Voice API.
thumbnail: /content/blog/build-a-conference-call-with-nexmo-voice-api-and-csharp-dr/csharp-conference-call-1.png
author: bibi
published: true
published_at: 2019-05-16T09:46:00.000Z
updated_at: 2021-12-09T15:00:00.000Z
category: tutorial
tags:
  - dotnet
  - voice-api
  - csharp
comments: true
redirect: ""
canonical: ""
---
This is the sixth tutorial on how to use Voice APIs with ASP.NET series. In the previous tutorial, we learnt [how to forward a call via voice proxy with ASP.NET Core](https://learn.vonage.com/blog/2019/04/18/forward-a-call-via-voice-proxy-with-asp-net-core-dr/). In today's tutorial, we will learn how to set up a conference call so multiple people can join the same call.

## Learning objectives

In this tutorial, we will:

* Create an ASP.NET Core app.
* Use NancyFX with ASP.NET Core.
* Create a Vonage voice application.
* Create and return NCCOs.
* Run and test the code using Ngrok.

## Prerequisites

* Visual Studio 2017 or higher.
* A project that was created for this tutorial series, which you can find on [Github](https://github.com/Vonage/vonage-dotnet-code-snippets/tree/ASPNET/NexmoDotNetQuickStarts).
* Optional: The [Vonage CLI](https://github.com/Vonage/vonage-cli).

<sign-up></sign-up>

## Configuration

To use [The Vonage Voice API](https://developer.vonage.com/voice/voice-api/overview), we need to create [a voice application](https://developer.vonage.com/application/overview).

The configuration steps are detailed in the [Vonage Voice API with ASP.NET: Before you start](https://learn.vonage.com/blog/2017/07/28/nexmo-voice-api-asp-net-configure-dr/) post.

Once the configuration is created successfully, we can move on to setting up a conference call.

## Building a Conference Call

When a user calls the Vonage number, the Vonage Voice API will make a request to the application to figure out how to respond using a [Vonage Call Control Object (NCCO)](https://developer.vonage.com/voice/voice-api/ncco-reference).

The user will be greeted then will join the conference call.

For that purpose, we are going to use [NancyFX](https://github.com/NancyFx/Nancy) alongside our ASP.NET Core project.

First of all, we need to add Nancy to our project:

```csharp
PM> Install-Package Nancy
PM> Install-Package Microsoft.AspNetCore.Owin
```

To allow Nancy to handle any HTTP requests, we need to tell ASP.NET Core to use Nancy via `Owin` in the `Configure` method of `Startup.cs`.

```csharp
using Microsoft.AspNetCore.Builder;
using Nancy.Owin;

namespace NexmoVoiceASPNetCoreQuickStarts
{
    public class Startup
    {
        public void Configure(IApplicationBuilder app)
        {
            app.UseOwin(x => x.UseNancy());
        }
    }
}
```

The next step is to create a Nancy module in which we create a route to `/webhook/answer` which will respond with the `ncco` returned by `GetConferenceCallNCCO()`

```csharp
using Nancy;
using Vonage.Voice.Nccos;

namespace NexmoDotnetCodeSnippets.Modules
{
    public class ConferenceCallModule : NancyModule 
    {
        public ConferenceCallModule()
        {
            Get("/webhook/answer/", x => {
                var response = GetConferenceCallNCCO();
                response.ContentType = "application/json";
                return response;
            });
            Post("/webhook/event", x => Request.Query["status"]);
        }

        private Response GetConferenceCallNCCO()
        {
            var ncco = new Ncco();
            ncco.Actions.Add(new TalkAction
            {
                Text = "Hello. You will now be added to the conference call.",
                Language = "en-US",
                Style = 2
            });

            ncco.Actions.Add(new ConversationAction
            {
                Name = "conference-call"
            });

            return Response.AsJson(ncco);
        }
    }
}
```

The above code will do the following:

When a call is received, the user will hear "Hello. You will now be added to the conference call." then they will be added to the conference call.

Multiple callers can be added to the conference until they all have disconnected.

We are done! To test this sample app, some more configuration steps are required.

## Linking Your App to Vonage

If you've been following along so far, you've already configured your Vonage account and created a voice app as shown in [this post](https://learn.vonage.com/blog/2017/07/28/nexmo-voice-api-asp-net-configure-dr/). We need to link this app to a Vonage phone number that we are going to call.

If you don't have a number, you can purchase one [using the dashboard](https://dashboard.nexmo.com/buy-numbers) or the by using the [Vonage CLI](https://github.com/Vonage/vonage-cli):

```bash
vonage numbers:search US
vonage numbers:buy [NUMBER] [COUNTRYCODE]
```

Similarly to link the number, you can [use the dashboard](https://dashboard.nexmo.com/your-numbers) or the CLI:

```bash
vonage apps:link --number=VONAGE_NUMBER APP_ID
```

We need to tell Vonage which URL to make a request to when a call is received - this is called the `answer_url`. For me, this URL is <http://localhost:63286/webhook/answer> and that's only running locally.

To expose our webhook answer URL, we will use [Ngrok](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/).

```bash
ngrok http 63286 
```

We now have a new URL (mine is http://<SUBDOMAIN>.ngrok.io) that can be used as the `answer_url` for the voice application.

Update your application with your new `answer_url`. It should look like `http://subdomain.ngrok.io/webhook/answer`. Run the app and give it a go by calling the TO_NUMBER.

## Learn more

### API References and Tools

* [Application API](https://developer.vonage.com/application/overview).
* [Voice API](https://developer.vonage.com/voice/voice-api/overview).
* [Vonage SDK for .NET](https://github.com/Vonage/vonage-dotnet-sdk).

### Nexmo Getting Started Guides for ASP.NET

* [How to Send SMS Messages with ASP.NET](https://learn.vonage.com/blog/2017/03/23/send-sms-messages-asp-net-mvc-framework-dr/).
* [How to Receive SMS Messages with ASP.NET](https://learn.vonage.com/blog/2017/03/31/recieve-sms-messages-with-asp-net-mvc-framework-dr/).
* [How to Get an SMS Delivery Receipt in ASP.NET](https://learn.vonage.com/blog/2017/07/21/get-sms-delivery-receipt-asp-net-mvc-dr/).
* [How to make a Text-to-Speech phone call with ASP.NET](https://learn.vonage.com/blog/2017/07/28/text-to-speech-phone-call-dr/).
* [How to play Audio to a Caller in ASP.NET](https://learn.vonage.com/blog/2017/11/29/how-to-play-audio-to-a-caller-in-asp-net-core-dr/).
* [How to Receive a Phone Call with Nexmo Voice API, ASP.NET Core and NancyFX](https://learn.vonage.com/blog/2018/11/21/how-to-receive-a-phone-call-with-nexmo-voice-api-asp-core-core-and-nancyfx-dr/).
* [How to handle user input with ASP.NET Core](https://learn.vonage.com/blog/2019/01/10/how-to-handle-user-input-with-asp-net-core-dr/)
* [How to forward a call via voice proxy with ASP.NET Core](https://learn.vonage.com/blog/2019/04/18/forward-a-call-via-voice-proxy-with-asp-net-core-dr/)
* [Getting Started with Nexmo Number Insight APIs and ASP.NET](https://learn.vonage.com/blog/2018/05/22/getting-started-with-nexmo-number-insight-apis-and-asp-net-dr/).