---
title: How To Build a Voicemail with ASP.NET Core and NancyFX
description: Learn how to build a voicemail using Nexmo Voice API and ASP.NET
  Core and start programatically accepting recorded voice messages right away.
thumbnail: /content/blog/how-to-build-a-voicemail-with-asp-net-core-and-nancyfx-dr/csharp-voicemail.png
author: bibi
published: true
published_at: 2019-07-08T15:00:04.000Z
updated_at: 2021-04-28T07:54:13.481Z
category: tutorial
tags:
  - asp.net
  - voice-api
comments: true
redirect: ""
canonical: ""
---
Have you ever wondered if Meg Ryan would rather listen to Tom Hanks voice instead of simply reading messages?

In my opinion, "Call me Maybe" sounds more exciting than "You've got mail".

So if like me, you'd like to provide someone - your customers perhaps - with a phone number where they can leave you a message, you create your own voicemail powered by [Nexmo Voice APIs](https://developer.nexmo.com/voice/voice-api/overview). 

<h2>Learning Objectives</h2>

In this tutorial, we will:

* Create an ASP.NET Core app.

* Use NancyFX with ASP.NET Core.

* Create a Nexmo voice application.

* Create and return NCCOs.

* Run and test the code using Ngrok.

<h2>Prerequisites</h2>

* Visual Studio 2017 or higher.



* A project setup for this tutorial, which you can find on [Github](https://github.com/nexmo-community/nexmo-dotnet-quickstart/tree/ASPNET/NexmoDotNetQuickStarts).

* Optional: [The Nexmo CLI](https://github.com/Nexmo/nexmo-cli).
<sign-up></sign-up>



<h2>Configuration</h2>

To use [The Nexmo Voice API](https://developer.nexmo.com/voice/voice-api/overview), we need to create [a voice application](https://developer.nexmo.com/concepts/guides/applications).

The configuration steps are detailed in the [Nexmo Voice API with ASP.NET: Before you start](https://www.nexmo.com/blog/2017/07/28/nexmo-voice-api-asp-net-configure-dr/) post.

Once the configuration is done successfully, we are ready to create a voicemail.

<h2>Creating a Voicemail</h2>

Similar to the previous blog posts in this series, we are going to use [NancyFX](https://github.com/NancyFx/Nancy) along side our ASP.NET Core project.

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

The next step is to create a Nancy module in which we setup a route to `/webhook/answer` which will respond with the `ncco` returned by `GetVoiceMailNCCO()`. For more details on exactly how to write an `ncco` check out the [NCCO reference](https://developer.nexmo.com/voice/voice-api/ncco-reference) in our documentation.

```csharp
using Nancy;
using Newtonsoft.Json.Linq;

namespace NexmoVoiceASPNetCoreQuickStarts
{
    public class VoiceModule : NancyModule
    {
        public VoiceModule()
        {
            Get["/webhook/answer/"] = x => { var response = (Response)GetVoiceMailNCCO();
                                             response.ContentType = "application/json";
                                             return response;
                                           };
        }

        private string GetVoiceMailNCCO()
        {
            dynamic TalkNCCO = new JObject();
            TalkNCCO.action = "talk";
            TalkNCCO.text = "Hello. You have reached Bibi. Please, leave your message after the beep.";
            TalkNCCO.voiceName = "Emma";

            dynamic RecordNCCO = new JObject();
            RecordNCCO.action = "record";
            RecordNCCO.beepStart = true;
            RecordNCCO.eventUrl = "https://example.com/recording";
            RecordNCCO.endOnSilence = 3;


            JArray nccoObj = new JArray
            {
                TalkNCCO,
                RecordNCCO
            };

            return nccoObj.ToString();
        }
    }
}
```

The above code will greet the caller and instruct them when to begin their message.

Once the message is recorded, Nexmo will make a request to the URL in the 'record' action which is 'https://example.com/recording' currently.

Let us fix that by sending the information about the recording to another route `/webhook/voicemail`

```csharp
public VoiceMailModule()
        {
            Get["/webhook/answer/"] = x => { var response = (Response)GetVoiceMailNCCO();
                                             response.ContentType = "application/json";
                                             return response;
                                           };
            Post["/webhook/voicemail/"] = x => { var response = (Response)GetRecording(Request.Query["recording_url"]);
                                                 response.ContentType = "application/json";
                                                 return response;
                                               };
            Post["/webhook/event"] = x => Request.Query["status"];
        }

private Response GetRecording(string url)
        {
            var client = new Client(creds: new Nexmo.Api.Request.Credentials
            {
                ApiKey = "NEXMO_API_KEY",
                ApiSecret = "NEXMO_API_SECRET",
                ApplicationId = "NEXMO_APPLICATION_ID",
                ApplicationKey = "NEXMO_APPLICATION_PRIVATE_KEY"
            });

            var result = client.getRecording(url);
            string documentsPath = Environment.GetFolderPath(Environment.SpecialFolder.Personal);
            string localFilename = "downloaded.mp3";
            string localPath = Path.Combine(documentsPath, localFilename);
            File.WriteAllBytes(localPath, result);
        }
```

Some more configuration steps are still required to be able to test the code.

If you've been following along so far, you've already configured your Nexmo account and created a voice app as shown in [this post](https://www.nexmo.com/blog/2017/07/28/nexmo-voice-api-asp-net-configure-dr/). We need to link this app to a the Nexmo phone number that we are going to call. If you don't have a number, you can purchase one [using the dashboard](https://dashboard.nexmo.com/buy-numbers) or the CLI:

```javascript
nexmo number:buy --country_code US
```

Similarly to link the number, you can [use the dashboard](https://dashboard.nexmo.com/your-numbers) or the CLI:

```javascript
nexmo link:app NEXMO_PHONE_NUMBER NEXMO_APP_ID
```

We need to tell Nexmo which URL to make a request to when a call is received - this is called the `answer_url`. For me, this url is [http://localhost:63286/webhook/answer](http://localhost:63286/webhook/answer) and that's only running locally.

To expose our webhook answer url, we will use [Ngrok](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/).

```bash
ngrok http 63286
```

We now have a new url (mine is http://<SUBDOMAIN>.ngrok.io) that can be used as the `answer_url` for the voice application.

Update your application with your new `answer_url`. It should look like `http://[id].ngrok.io/webhook/answer`
Now, you can run the app.

<h2>Learn More</h2>

<h3>API References and Tools</h3>

* [Application API](https://developer.nexmo.com/concepts/guides/applications).

* [Voice API](https://developer.nexmo.com/voice/voice-api/overview).

* [Nexmo REST client for .NET](https://github.com/Nexmo/nexmo-dotnet).

<h3>Nexmo Getting Started Guides for ASP.NET</h3>

* [How to Send SMS Messages with ASP.NET](https://www.nexmo.com/blog/2017/03/23/send-sms-messages-asp-net-mvc-framework-dr/).

* [How to Receive SMS Messages with ASP.NET](https://www.nexmo.com/blog/2017/03/31/recieve-sms-messages-with-asp-net-mvc-framework-dr/).

* [How to Get an SMS Delivery Receipt in ASP.NET](https://www.nexmo.com/blog/2017/07/21/get-sms-delivery-receipt-asp-net-mvc-dr/).

* [How to make a Text-to-Speech phone call with ASP.NET](https://www.nexmo.com/blog/2017/07/28/text-to-speech-phone-call-dr/).

* [How to play Audio to a Caller in ASP.NET](https://www.nexmo.com/blog/2017/11/29/how-to-play-audio-to-a-caller-in-asp-net-core-dr/).

* [How to Receive a Phone Call with Nexmo Voice API, ASP.NET Core and NancyFX](https://www.nexmo.com/blog/2018/11/21/how-to-receive-a-phone-call-with-nexmo-voice-api-asp-core-core-and-nancyfx-dr/).

* [how to handle user input with ASP.NET Core](https://www.nexmo.com/blog/2019/01/10/how-to-handle-user-input-with-asp-net-core-dr/)

* [Build a Conference Call with the Nexmo Voice API and ASP.NET Core](https://www.nexmo.com/blog/2019/05/16/build-a-conference-call-with-nexmo-voice-api-and-csharp-dr/)

* [Getting Started with Nexmo Number Insight APIs and ASP.NET](https://www.nexmo.com/blog/2018/05/22/getting-started-with-nexmo-number-insight-apis-and-asp-net-dr/).