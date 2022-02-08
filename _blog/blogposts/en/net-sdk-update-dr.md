---
title: .NET SDK Update
description: .Net SDK latest release and bug fixes
thumbnail: /content/blog/net-sdk-update-dr/E_NET-SDK-Update_1200x600.png
author: stevelorello
published: true
published_at: 2019-11-19T09:50:22.000Z
updated_at: 2021-05-13T13:35:48.482Z
category: release
tags:
  - dotnet
comments: true
redirect: ""
canonical: ""
---
The last couple of months have been a bit of a whirlwind here at Nexmo as I've been working on fixing bugs and upgrading the .NET SDK for you all.

More will be coming in the future, but we've cut a few new releases over the past couple of months, and I'd like to take some time out to tell you all about them.

## Releases

### 4.0.1

In 4.0.1 we added the workflow ID parameter to verify requests. This version enables you, when sending off a [Verify](https://developer.nexmo.com/verify/overview) request to specify what process you want Nexmo to use for verification.

Those workflows are as follows—note that for our purposes an SMS message is an SMS text message and TTS refers to a text-to-speech voice call:

* "1" - SMS -&gt; TTS -&gt; TTS
* "2" - SMS -&gt; SMS -&gt; TTS
* "3" - TTS -&gt; TTS
* "4" - SMS -&gt; SMS
* "5" - SMS -&gt; TTS
* "6" - SMS
* "7" - TTS

For further info please check out the Verify Workflows [documentation](https://developer.nexmo.com/verify/guides/workflows-and-events). Additionally, you can read the [Flexible Workflows for Verify API](https://www.nexmo.com/blog/2019/10/02/flexible-workflows-for-verify-api-dr) article on how workflows take shape. Happy verifying!

### 4.1.0

* As of the 4.1.0 release the [Application V2 API](https://developer.nexmo.com/api/application.v2) in the SDK is fully functional!

* As of the 4.1.0 release the [Redact library](https://developer.nexmo.com/api/redact) is now available in .NET please see our [code snippets](https://developer.nexmo.com/redact/code-snippets/redact-using-id/dotnet) for details.

* 4.1.0 also introduces the [get recording API](https://developer.nexmo.com/voice/voice-api/guides/recording) to the .NET SDK to see the [code snippets](https://developer.nexmo.com/voice/voice-api/code-snippets/download-a-recording/dotnet) for usage details.

### 4.1.1

* Release 4.1.1 straightens out a bunch of dependencies in the [NuGet](https://www.nuget.org/) package—that would have been transparent to most folks but needed to be addressed.

### 4.1.2

* 4.1.2 adds full support for the signing of SMS messages and the validation of signed SMS messages. See our [guide](https://developer.nexmo.com/concepts/guides/signing-messages/dotnet) on leveraging this capability.

### 4.2.0

This version supports a fairly major upgrade to the SDK. We now have strongly typed NCCOs and webhook events! There is no longer a need to dynamically produce your own JSON when sending us NCCO's or to figure out on your own what the structure of an event looks like.

To create your NCCO simply create a series of actions, construct an NCCO object with those actions, and invoke NCCO.ToString() to create your ncco.

```csharp
var talkAction = new TalkAction()
{
    Text= "Thank you for calling. You will now be joined into the conference",
    VoiceName = "Kimberly"

};

var conversationAction = new ConversationAction()
{
    Name ="A_Conference",
    Record = "True",
    EventMethod = "POST",
    EventUrl = new []{ $"{SiteBase}/webhook/record" }
};
var ncco = new Ncco(talkAction,conversationAction);

return ncco.ToString();
```

If you would like to make an outbound call with one of these strongly typed NCCOs now you can! I know many of you are still using the old CallCommand Object that just accepted a `JObject`, that `JObject` is still acceptable. You now have the option of setting a `NccoObj` rather than the `Ncco` in the CallCommand to use a strongly typed NCCO. Like so:

```csharp
var talkAction = new TalkAction() { Text = "This is a text to speech call from Nexmo" };
var ncco = new Ncco(talkAction);

var results = client.Call.Do(new Call.CallCommand
{
    to = new[]
    {
        new Call.Endpoint {
            type = "phone",
            number = TO_NUMBER
        }
    },
    from = new Call.Endpoint
    {
        type = "phone",
        number = NEXMO_NUMBER
    },

    NccoObj = ncco
});
```

### 4.2.1

With 4.2.1 it's now possible to track in progress NCCOs straight out of the box with the Nexmo .NET SDK.

We fixed a bug where the incorrect RSA provider was being used on newer versions of .NET core off of windows platforms. I want to give a big shout out to one of our community contributors _Fauna5_ for their pull request for this!

Feel free to follow the .NET SDK on [GitHub](https://github.com/Nexmo/nexmo-dotnet) for real time updates.

If you have any questions, issues, or concerns please feel free to raise them there or find me `@Steve Lorello` in our [Community Slack Channel](https://developer.nexmo.com/community/slack) and I'll be more than happy to help.

