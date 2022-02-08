---
title: How to Handle User Input With ASP.NET Core
description: Learn how to handle an inbound call then respond to user input
  using ASP.NET Core and Vonage Voice API.
thumbnail: /content/blog/how-to-handle-user-input-with-asp-net-core-dr/How-to-handle-User-Input-with-ASP.NET-Core.png
author: bibi
published: true
published_at: 2019-01-10T10:06:55.000Z
updated_at: 2021-05-11T10:09:00.368Z
category: tutorial
tags:
  - dotnet
  - voice-api
comments: true
redirect: ""
canonical: ""
---
*This is the fourth tutorial on how to use Voice APIs with ASP.NET series.* In the previous tutorial, we learnt [how to Receive a Phone Call with Vonage Voice API, ASP.NET Core, and NancyFX](https://learn.vonage.com/blog/2018/11/21/how-to-receive-a-phone-call-with-nexmo-voice-api-asp-core-core-and-nancyfx-dr/). This is a great start, but in a real life scenario we expect some sort of interaction with the caller. Maybe they will be prompted to pick an option or enter a PIN. We need a way to handle user input. 

That's exactly the aim of this tutorial; we will create an ASP.NET app that handles inbound voice calls and respond to user input using the [Vonage Voice API](https://developer.vonage.com/voice/voice-api/overview).

## Learning objectives

In this tutorial, we will: 

* Create an ASP.NET Core app. 
* Use NancyFX with ASP.NET Core. 
* Create a Vonage voice application. 
* Receive inbound calls within the app. 
* Create and return NCCOs. 
* Handle user input. 
* Run and test the code using Ngrok.

## Prerequisites

<sign-up></sign-up>

* Visual Studio 2017.  
* A project setup for this tutorial series, which you can find on [Github](https://github.com/nexmo-community/nexmo-dotnet-quickstart/tree/ASPNET/NexmoDotNetQuickStarts). 
* Optional: [The Vonage CLI](https://github.com/Vonage/vonage-cli).

## Configuration

To use [The Vonage Voice API](https://developer.vonage.com/voice/voice-api/overview), we need to create [a voice application](https://developer.vonage.com/application/overview). The configuration steps are detailed in [the “Nexmo Voice API with ASP.NET: Before you start” post](https://www.nexmo.com/blog/2017/07/28/nexmo-voice-api-asp-net-configure-dr/). 
Once the configuration is done successfully, we are ready to receive an inbound call and handle user input with The Vonage Voice API!

## Receiving a phone call and handling input with ASP.NET


When a call is received, the Vonage Voice API will make a request to your application to figure out how to respond. 
In this post, we will be using Text-To-Speech to greet the caller, and the `input` action to collect DTMF input from the caller. 

[DTMF](https://developer.vonage.com/voice/voice-api/guides/dtmf) (Dual Tone Multi Frequency) is a form of signalling used by phone systems to transmit the digits `0-9` and the `*` and `#` characters. Typically a caller presses these buttons on their telephone keypad and the phone then generates a tone made up of two frequencies played simultaneously (hence Dual Tone). 

To capture DTMF in our application, we are going to use [NancyFX](https://github.com/NancyFx/Nancy) alongside our ASP.NET Core project. First of all, we need to add Nancy to our project :
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
The next step is to create a Nancy module in which we set up a route to `/webhook/answer` which will respond with the `ncco` returned by `GetDTMFNCCO()`
```csharp
using Nancy;
using Newtonsoft.Json.Linq;

namespace NexmoVoiceASPNetCoreQuickStarts
{
    public class VoiceModule : NancyModule
    {
        public VoiceModule()
        {
            Get["/webhook/answer"] = x => GetDTMFNCCO();
        }

        private string GetDTMFNCCO()
        {
            dynamic TalkNCCO = new JObject();
            TalkNCCO.action = "talk";
            TalkNCCO.text = "Hello. Please press any key to continue.";

            JArray jarrayObj = new JArray();
            jarrayObj.Add(TalkNCCO);

            dynamic InputNCCO = new JObject();
            InputNCCO.action = "input";
            InputNCCO.maxDigits = "1";
            InputNCCO.eventUrl = $"{Request.Url.SiteBase}/webhook/dtmf";

            jarrayObj.Add(InputNCCO);

            return jarrayObj.ToString();

        }
    }
}
```
The above code will do the following: 

When a call is received, Vonage will prompt the user to press any key by reading out the text "Hello. Please press any key to continue.". When the user presses a key, we pass that input to `webhook/dtmf` where it will be handled properly. 
To handle the DTMF, we need to tell the Nancy module how to respond once the request is received. In this case, we will simply read back to the caller which key they pressed.
```csharp
public class VoiceModule : NancyModule
{
    public VoiceModule()
    {
        Get["/webhook/answer"] = x => GetDTMFNCCO();
        Post["/webhook/dtmf"] = x => GetDTMFInput();
    }
    private string GetDTMFNCCO()
    {
        dynamic TalkNCCO = new JObject();
        TalkNCCO.action = "talk";
        TalkNCCO.text = "Hello. Please press any key to continue.";

        JArray jarrayObj = new JArray();
        jarrayObj.Add(TalkNCCO);

        dynamic InputNCCO = new JObject();
        InputNCCO.action = "input";
        InputNCCO.maxDigits = "1";
        InputNCCO.eventUrl = $"{Request.Url.SiteBase}/webhook/dtmf";

        jarrayObj.Add(InputNCCO);

        return jarrayObj.ToString();

    }

    private string GetDTMFInput()
    {
        dynamic TalkNCCO = new JObject();
        TalkNCCO.action = "talk";
        TalkNCCO.text = $"You pressed {Request.Query["dtmf"]} ";

        JArray jarrayObj = new JArray();
        jarrayObj.Add(TalkNCCO);

        return jarrayObj.ToString();

    }
}
```
We are done! To test this sample app, some more configuration steps are required. 

If you've been following up so far, you've already configured your Vonage account and created a voice app as shown in [this post](https://learn.vonage.com/blog/2017/07/28/nexmo-voice-api-asp-net-configure-dr/). We need to link this app to the Vonage phone number that we are going to call. If you don't have a number, you can purchase one [using the dashboard](https://dashboard.nexmo.com/buy-numbers) or the CLI:
```javascript
vonage numbers:search US
vonage numbers:buy <PHONE_NUMBER> US
```
Similarly to link the number, you can [use the dashboard](https://dashboard.nexmo.com/your-numbers) or the CLI:

```javascript
vonage link:app --number=PHONE_NUMBER APP_ID
```
We need to tell Vonage which URL to make a request to when a call is received - this is called the `answer_url`. For me, this URL is [http://localhost:63286/webhook/answer](http://localhost:63286/webhook/answer) and that's only running locally. To expose our webhook answer URL, we will use [Ngrok](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/).
```csharp
ngrok http 63286 
```
We now have a new url (mine is http://5e18af56.ngrok.io) that can be used as the `answer_url` for the voice application. Update your application with your new `answer_url`. It should look like `http://[id].ngrok.io/webhook/answer`Tada! Run the app and give it a go by calling the Vonage number you purchased.

## Learn more

### API References and Tools

* [Application API](https://developer.vonage.com/application/overview).
* [Voice API](https://developer.vonage.com/voice/voice-api/overview). 
* [Nexmo REST client for .NET](https://github.com/Nexmo/nexmo-dotnet).



### Vonage Getting Started Guides for ASP.NET

* [How to Send SMS Messages with ASP.NET](https://learn.vonage.com/blog/2020/07/09/how-to-send-an-sms-with-asp-net-core-mvc/). 
* [How to Receive SMS Messages with ASP.NET](https://learn.vonage.com/blog/2017/03/31/recieve-sms-messages-with-asp-net-mvc-framework-dr/). 
* [How to Get an SMS Delivery Receipt in ASP.NET](https://learn.vonage.com/blog/2017/07/21/get-sms-delivery-receipt-asp-net-mvc-dr/). 
* [How to make a Text-to-Speech phone call with ASP.NET](https://learn.vonage.com/blog/2017/07/28/text-to-speech-phone-call-dr/). 
* [How to play Audio to a Caller in ASP.NET](https://learn.vonage.com/blog/2017/11/29/how-to-play-audio-to-a-caller-in-asp-net-core-dr/). 
* [How to Receive a Phone Call with Nexmo Voice API, ASP.NET Core and NancyFX](https://learn.vonage.com/blog/2018/11/21/how-to-receive-a-phone-call-with-nexmo-voice-api-asp-core-core-and-nancyfx-dr/). 
* [Getting Started with Nexmo Number Insight APIs and ASP.NET](https://learn.vonage.com/blog/2018/05/22/getting-started-with-nexmo-number-insight-apis-and-asp-net-dr/).