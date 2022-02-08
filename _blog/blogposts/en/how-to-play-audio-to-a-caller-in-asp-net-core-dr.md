---
title: How to Play Audio to a Caller in ASP.NET Core
description: In this tutorial, you will learn how to play audio to a caller in
  an ASP.NET web application using an ASP.NET Core project and the Vonage Voice
  API.
thumbnail: /content/blog/how-to-play-audio-to-a-caller-in-asp-net-core-dr/play-audio-asp-net-core.png
author: bibi
published: true
published_at: 2017-11-29T16:17:12.000Z
updated_at: 2021-05-12T18:44:16.139Z
category: tutorial
tags:
  - voice-api
  - dotnet
comments: true
redirect: ""
canonical: ""
---
*Welcome to the second tutorial in our* how to use Voice APIs with ASP.NET *series. To check out other tutorials, please go to the* Learn more *section at the end of this post.*

In the previous post, we learnt how to [make a text-to-speech phone call in an ASP.NET web application](https://learn.vonage.com/blog/2017/07/28/text-to-speech-phone-call-dr/). In this post, we will learn how to play audio to a caller. Sounds like fun, right? But that’s not all. We will also discover how to dynamically create Vonage Call Control Objects (NCCOs) in code and use them within our app. Bonus: We will be using an ASP.NET Core project for this demo.

Let’s get started!

![are you ready gif](/content/blog/how-to-play-audio-to-a-caller-in-asp-net-core/are-you-ready.gif "are you ready gif")

## Prerequisites for using Vonage Voice API with ASP.NET

* Visual Studio 2017
* A project set-up for this tutorial series, which you can find on [Github](https://github.com/nexmo-community/nexmo-dotnet-quickstart/tree/ASPNET/NexmoVoiceASPNetCoreQuickStarts)
* Optional: [The Vonage CLI](https://github.com/Vonage/vonage-cli)

<sign-up number></sign-up>

## Configuration

Since you may or may not have read the first tutorial in this series—which you should, btw—let’s go through what we need before diving into the code. 

To be able to use [The Vonage Voice API](https://developer.vonage.com/voice/voice-api/overview), you'll need a voice application to store configuration data and generate a public/private key pair. 

How to do so? Don’t worry, I’ve got you covered. The [Vonage Voice API with ASP.NET: Before you start](https://learn.vonage.com/blog/2017/07/28/nexmo-voice-api-asp-net-configure-dr/) post has a great outline of all the necessary configuration steps.

In your project, in the appsettings.json file, make sure to initialize Vonage with your API credentials as well as the App ID and private key you just created.

Now, let’s write some code!

![wonder woman gif](/content/blog/how-to-play-audio-to-a-caller-in-asp-net-core/lets-write-code.gif "wonder woman gif")

## Creating a stream NCCO

As mentioned at the beginning of this post, when the user answers the call, we want to play an audio file to them. The NCCO file available at our answer_url contains this information. To execute this action, the NCCO must be valid and have the right action. [The action required to send the audio file to a call or conversation is stream](https://developer.vonage.com/voice/voice-api/ncco-reference#stream).

For this demo, we will only need to specify streamUrl, which is the array containing the audio file. The latter must be an mp3 or wav. We do provide a sample [stream NCCO](https://raw.githubusercontent.com/nexmo-community/ncco-examples/4f29c8f50a8cdc5bf1b34116b699000339498e9f/first_call_speech.json); you can use it to try this demo. But for real-life scenarios, you may want to create your own. 

Under NexmoVoiceASPNetCoreQuickstarts, add a new folder called Helpers, and then add a new class NCCOHelpers.cs to this folder. We will create all the NCCOs we need in this folder. For the sake of simplicity, we will save our NCCO files directly under wwwroot. 

![ncco helpers](/content/blog/how-to-play-audio-to-a-caller-in-asp-net-core/ncco-helpers.png "ncco helpers")

As explained in the configuration steps, adding the following line to the Configure method in Startup.cs will allow us to serve up the NCCO json file. 

```csharp
app.UseStaticFiles();
```

Using tools like [ngrok will make it reachable by the Vonage API](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/).

![ngrok status](/content/blog/how-to-play-audio-to-a-caller-in-asp-net-core/ngrok-status.png "ngrok status")

Within NCCOHelpers.cs, we will add a method called CreateStreamNCCO, in which we will dynamically create a JObject representing the stream NCCO.

```csharp
public void CreateStreamNCCO(string rootpath, string[] streamUrl, int level, bool bargeIn, int loopTimes)
{
   dynamic StreamNCCO = new JObject();
   StreamNCCO.action = "stream";
   StreamNCCO.streamUrl = new JArray { streamUrl };
   StreamNCCO.level = level;
   StreamNCCO.bargeIn = bargeIn;
   StreamNCCO.loop = loopTimes;

   SaveFile(rootpath, "StreamNCCO.json", StreamNCCO);
}
```

Then we save that object as a JSON file under wwwroot.

```csharp
private void SaveFile(string rootpath, string filename, dynamic StreamNCCO)
{
   var pathToFile = Path.Combine(rootpath, filename);
   using (StreamWriter s = File.CreateText(pathToFile))
     {
        s.Write(StreamNCCO.ToString());
     }
}
```

Later on, we will be using CreateStreamNCCO to allow users to create their own stream NCCO via the website. 

## Playing audio in the call

Under NexmoVoiceAspNetCoreQuickstarts, we created [a controller called VoiceController.cs](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoVoiceASPNetCoreQuickStarts/Controllers/VoiceController.cs) in which we will create [an action method called PlayAudioToCaller](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoVoiceASPNetCoreQuickStarts/Controllers/VoiceController.cs).

Above the method, add a HttpGetAttribute to allow the user to navigate to the corresponding view.

```csharp
[HttpGet]
public ActionResult PlayAudioToCaller()
{
  return View();
}
```

Under the Voice Views folder, create a new view `PlayAudioToCaller.cshtml`. Within [this view](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoVoiceASPNetCoreQuickStarts/Views/Voice/PlayAudioToCaller.cshtml), we will add two forms:

1. The first will allow us to create a stream NCCO. 
2. The second will be used to make the phone call.

Back to the VoiceController. Make sure you have the following \`using\` statement on the top of the file.

```csharp
using Vonage
```

Inside the constructor, we will pass the hosting environment, which will be used to specify the root path to where we will save the NCCO file.  We will also instantiate the NCCO helpers class.

```csharp
private readonly IHostingEnvironment _hostingEnvironment;
private NCCOHelpers _nccohelper;

public VoiceController(IHostingEnvironment hostingEnvironment)
{
  _hostingEnvironment = hostingEnvironment;
  _nccohelper = new NCCOHelpers(); 
}
```

Add an [action method named CreateStreamNCCO](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoVoiceASPNetCoreQuickStarts/Controllers/VoiceController.cs#L112-L119) with the following parameters: 

* string\[] streamUrl : an array containing a single url to the audio file to stream.
* int level=0 : the audio level. This is defaulted to zero.
* bool bargeIN defaulted to false.
* int loop =1 so the audio is only repeated once.
  Inside this method, we will call the CreateStreamNCCO method from the NCCO helpers class. 

```csharp
[HttpPost]
public ActionResult CreateStreamNCCO(string\[] streamUrl, int level=0, bool bargeIN = false, int loop =1)
{
  _nccohelper.CreateStreamNCCO(_hostingEnvironment.WebRootPath, streamUrl, level, bargeIN,    loop); 
   ViewData\["NCCOButtonText"] = "NCCO Created";
  return View("PlayAudioToCaller");
}
```

Add another [action method named PlayAudioToCaller](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoVoiceASPNetCoreQuickStarts/Controllers/VoiceController.cs#L73-L101) with a string parameter: `to`. Within this method, you will make a call using the parameter as the `to`. The `from` number is your Nexmo virtual number (retrieved from the appsettings.json), the answer_url is the stream NCCO whether you choose to use Nexmo’s community NCCO example mentioned above or the NCCO you created and made reachable via ngrok. 

```csharp
public ActionResult PlayAudioToCaller(string to)
{
   var NEXMO_FROM_NUMBER = Configuration.Instance.Settings\["appsettings:NEXMO_FROM_NUMBER"];
   var NEXMO_TO_NUMBER = to;
   var NEXMO_CALL_ANSWER_URL = "https://raw.githubusercontent.com/nexmo-community/ncco-examples/gh-pages/first_call_speech.json";

   var results = Call.Do(new Call.CallCommand
            {
                to = new\[]
                {
                    new Call.Endpoint {
                        type = "phone",
                        number = NEXMO_TO_NUMBER
                    }
                },
                from = new Call.Endpoint
                {
                    type = "phone",
                    number = NEXMO_FROM_NUMBER
                },
                answer_url = new\[]
                {
                    NEXMO_CALL_ANSWER_URL
                }
            });
            
     return RedirectToAction("Index", "Home");
}
```

Now, let's run the app and make a phone call.

When it is successful, it retrieves the [NCCO](https://developer.vonage.com/voice/voice-api/ncco-reference) from your webhook, the audio will be played, and then the call is terminated.
<img class="alignnone size-full wp-image-12934" src="https://www.nexmo.com/wp-content/uploads/2017/08/done.gif" alt="" width="80%"/>

## Learn more

**API references and tools**

* [Application API](https://developer.vonage.com/application/overview)
* [Voice API](https://developer.vonage.com/voice/voice-api/overview)
* [Vonage SDK for .NET](https://github.com/Vonage/vonage-dotnet-sdk)

**Vonage Getting Started Guide for ASP.NET**

* [How to Send SMS Messages with ASP.NET MVC Framework](https://www.nexmo.com/blog/2017/03/23/send-sms-messages-asp-net-mvc-framework-dr/)
* [How to Receive SMS Messages with ASP.NET MVC Framework](https://www.nexmo.com/blog/2017/03/31/recieve-sms-messages-with-asp-net-mvc-framework-dr/)
* [How to Make a Text-to-speech Phone Call in ASP.NET](https://www.nexmo.com/blog/2017/07/28/text-to-speech-phone-call-dr/)