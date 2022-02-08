---
title: Receive a Phone Call with Vonage Voice API, ASP.NET Core and NancyFX
description: This ASP.NET, Voice API and NancyFX tutorial explains how to create
  an ASP.NET app that handles inbound voice calls and returns a dynamic
  response.
thumbnail: /content/blog/how-to-receive-a-phone-call-with-nexmo-voice-api-asp-core-core-and-nancyfx-dr/Receive-a-phone-call-with-NancyFX.png
author: bibi
published: true
published_at: 2018-11-21T08:58:40.000Z
updated_at: 2021-05-04T14:55:57.128Z
category: tutorial
tags:
  - voice-api
comments: true
redirect: ""
canonical: ""
---
*This is the third tutorial on how to use Voice APIs with ASP.NET series.* 

In previous tutorials, we learned [how to make a Text-to-Speech phone call with ASP.NET](https://learn.vonage.com/blog/2017/07/28/text-to-speech-phone-call-dr/) and [how to Play Audio to a Caller in ASP.NET Core](https://learn.vonage.com/blog/2017/11/29/how-to-play-audio-to-a-caller-in-asp-net-core-dr/). But how about receiving calls? The good news is the Vonage Voice API handles inbound calls as well. 

Inbound calls are calls made to a Vonage number from another regular phone anywhere in the world. Both inbound and outbound calls follow the same call flow once answered. This [call flow](https://developer.vonage.com/voice/voice-api/guides/call-flow) is controlled by [an NCCO](https://developer.vonage.com/voice/voice-api/ncco-reference). 

In this tutorial, we will create an ASP.NET app that handles inbound voice calls and returns a dynamic response.

## Learning objectives

In this tutorial, we will: 

* Create an ASP.NET Core app. 
* Use NancyFX with ASP.NET Core. 
* Create a Vonage voice application. 
* Receive inbound calls within the app. 
* Create and return an NCCO. 
* Run and test the code using Ngrok.

## Prerequisite

* Visual Studio 2017. 
* A project setup for this tutorial series, which you can find on [Github](https://github.com/nexmo-community/nexmo-dotnet-quickstart/tree/ASPNET/NexmoVoiceASPNetCoreQuickStarts). 
* Optional: [The Vonage CLI](https://github.com/Vonage/vonage-cli).

<sign-up></sign-up>

## Configuration

To use [The Vonage Voice API](https://developer.vonage.com/voice/voice-api/overview), we need to create [a voice application](https://developer.vonage.com/application/overview). 

The configuration steps are detailed in [the "Vonage Voice API with ASP.NET: Before you start" post](https://learn.vonage.com/blog/2017/07/28/nexmo-voice-api-asp-net-configure-dr/). 

Once the application is configured successfully, we are ready to receive an inbound call with The Vonage Voice API!

## Receiving a phone call with ASP.NET

When a call is received, the Vonage Voice API will make a request to the application to figure out how to respond to the caller. 

To achieve this, we are going to use NancyFX alongside our ASP.NET Core project. 

[Nancy](https://github.com/NancyFx/Nancy) is a lightweight open-source framework that promotes the "super-duper-happy-path". This means that it has sensible defaults and conventions and tries to stay out of our way as much as possible. 

First of all, we need to add Nancy to our project : 

`csharp PM> Install-Package Nancy PM> Install-Package Microsoft.AspNetCore.Owin` 

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

We are all good to go! The next step is to create a Nancy module to handle any requests to `/webhook/answer`. 

```csharp
using Nancy;

namespace NexmoVoiceASPNetCoreQuickStarts
{
    public class VoiceModule : NancyModule
    {
        public VoiceModule()
        {
            Get["/webhook/answer"] = x => "Hello happy path";
        }
    }
}
```

I'm using Postman to test, and as you can see our `/webhook/answer` route is returning exactly what's expected. 

![asp postman screenshot](/content/blog/receive-a-phone-call-with-nexmo-voice-api-asp-net-core-and-nancyfx/asp-post-webhook-answer-1-.png "asp-post")

This is a great start, but Vonage doesn't know what to do with that string. To properly respond to the call, we need to return an NCCO. 

```csharp
using Nancy;
using Newtonsoft.Json.Linq;

namespace NexmoVoiceASPNetCoreQuickStarts
{
    public class VoiceModule : NancyModule
    {
        public VoiceModule()
        {
            Get["/webhook/answer"] = x => GetInboundNCCO();
        }

        private string GetInboundNCCO()
        {
            dynamic TalkNCCO = new JObject();
            TalkNCCO.action = "talk";
            TalkNCCO.text = "Thank you for calling from " + string.Join(' ', this.Request.Query["from"].ToString().ToCharArray()));
            TalkNCCO.voiceName = "Kimberly";
            
            JArray jarrayObj = new JArray();
            jarrayObj.Add(TalkNCCO);

            return jarrayObj.ToString();

        }
    }
}
```

`GetInboundNCCO()` will create an NCCO object that will use Text-To-Speech to read the caller’s phone number back to them using the `talk` action within the NCCO. 

We are accessing the phone number via the `from` param in the request.

![webhook answer screenshot](/content/blog/receive-a-phone-call-with-nexmo-voice-api-asp-net-core-and-nancyfx/webhook-answer_li.jpeg "webhook answer")

That's all the code we need. To test this properly, some more configuration steps are required. 

If you've been following up so far, you've already configured your Vonage account and created a voice app as shown in [this post](https://learn.vonage.com/blog/2017/07/28/nexmo-voice-api-asp-net-configure-dr/). 

We need to link this app to a Vonage phone number, the number we will be calling. If you don't have a number, you can purchase one using the dashboard or the CLI. `javascript vonage numbers:buy PHONE_NUMBER US` Similarly to link the number, you can use the dashboard or the CLI. 

```javascript
vonage numbers:buy PHONE_NUMBER US
```

Similarly to link the number, you can use the dashboard or the CLI.

```javascript
vonage apps:link --number=PHONE_NUMBER APP_ID
```

We need to tell Vonage which URL to make a request to when a call is received (`answer_url`). For me, this URL is <http://localhost:63286/webhook/answer> and that's only running locally. 

To expose our `answer_url`, we will use our good friend [Ngrok](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/). 

```csharp
ngrok http 63286 -host-header="localhost:63286"
```

This will return a new URL (mine is `http://5e18af56.ngrok.io`) that can be used as the `answer_url` for the voice application. Update your `answer_url` to `http://[id].ngrok.io/webhook/answer` 

Tada! Run the app and give it a go by calling the Vonage number you purchased. It should thank you for calling, then read out your phone number.

## Learn more

### API References and Tools

* [Application API](https://developer.vonage.com/application/overview). 
* [Voice API](https://developer.vonage.com/voice/voice-api/overview).
* [Nexmo REST client for .NET](https://github.com/Nexmo/nexmo-dotnet).

### Nexmo Getting Started Guides for ASP.NET

* [How to Send SMS Messages with ASP.NET](https://learn.vonage.com/blog/2017/03/23/send-sms-messages-asp-net-mvc-framework-dr/). 
* [How to Receive SMS Messages with ASP.NET](https://learn.vonage.com/blog/2017/03/31/recieve-sms-messages-with-asp-net-mvc-framework-dr/).
* [How to Get an SMS Delivery Receipt in ASP.NET](https://learn.vonage.com/blog/2017/07/21/get-sms-delivery-receipt-asp-net-mvc-dr/). 
* [How to make a Text-to-Speech phone call with ASP.NET](https://learn.vonage.com/blog/2017/07/28/text-to-speech-phone-call-dr/).
* [How to play Audio to a Caller in ASP.NET](https://learn.vonage.com/blog/2017/11/29/how-to-play-audio-to-a-caller-in-asp-net-core-dr/). 
* [Getting Started with Nexmo Number Insight APIs and ASP.NET](https://learn.vonage.com/blog/2018/05/22/getting-started-with-nexmo-number-insight-apis-and-asp-net-dr/).