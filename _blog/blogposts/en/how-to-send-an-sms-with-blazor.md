---
title: How to Send an SMS With Blazor
description: Follow this step-by-step tutorial to learn how to send an SMS with
  Blazor and the Vonage SMS API.
thumbnail: /content/blog/how-to-send-an-sms-with-blazor/Blog_Blazor_SMS_1200x600.png
author: stevelorello
published: true
published_at: 2020-07-08T07:15:14.000Z
updated_at: 2021-05-05T09:28:13.059Z
category: tutorial
tags:
  - dotnet
  - sms-api
comments: true
redirect: ""
canonical: ""
---
[Blazor](https://dotnet.microsoft.com/apps/aspnet/web-apps/blazor) is the latest in a series of what I'd call "magnificent" developer-friendly web frameworks that .NET has built. In this tutorial, we'll be reviewing how to send an SMS using Blazor and the Vonage [SMS API](https://developer.nexmo.com/messaging/sms/overview).

### Jump Right to the Code

All of the code from this tutorial is located in [GitHub](https://github.com/nexmo-community/send-an-sms-with-blazor).

## Prerequisites

* You'll need the latest version of the [.NET Core 3.1 SDK](https://dotnet.microsoft.com/download/dotnet-core/3.1)
* You'll need either Visual Studio 2019, Visual Studio for Mac, or Visual Studio Code⁠—I will be using VS Code for this demo

<sign-up></sign-up>

## Create the App

Navigate to wherever you want to build the app and run the following command in your terminal:

```sh
dotnet new blazorserver -o SendSmsBlazor
```

This will create a blazor server app for you called `SendSmsBlazor.` cd into this directory and enter the command `code .` to Launch VS Code. For Visual Studio users, you can just open the sln file.

## Add The Vonage Nuget Package

Fire up a terminal in VSCode and run:

```sh
dotnet add package Vonage
```

This will install the Vonage package to the project.

## Create Your SmsService

We will have to inject an SMS service into our razor page, so let's create a SmsService. 

Add a new file under the `Data` folder called `SmsService.cs.` If you're using VS Code, this is just going to create a blank file, so add the following to it.

```csharp
using Microsoft.Extensions.Configuration;
using Vonage.Messaging;
using Vonage.Request;

namespace SendSmsBlazor.Data
{
    public class SmsService
    {

    }
}
```

### Add a Constructor

Inside the `SmsService` class, we must inject a configuration object. The config will contain our API key and API secret, which we'll configure a bit later. For the moment, all you need to do is add a new property inside the `SmsService` class called `Configuration` of type `IConfiguraiton` and add a Constructor taking an `IConfiguration` object, which will simply assign our `Configuration` property to that object.

```csharp
public IConfiguration Configuration { get; set; }
public SmsService(IConfiguration config)
{
    Configuration = config;
}
```

### Write Your SendSms Method

Inside the `SmsService`, we're going to add a `SendSms` method. That method will take three strings: `to`, `from`, and `text` which will contain the number the message is going to, the Vonage API number the message is coming from, and the text of the message.

All that's left to do from this service's perspective is:

1. Pull the API key and secret out of the configuration
2. Create a SmsClient
3. Send the SMS

All of this can be accomplished with the following:

```csharp
public SendSmsResponse SendSms(string to, string from, string text)
{
    var apiKey = Configuration["VONAGE_API_KEY"];
    var apiSecret = Configuration["VONAGE_API_SECRET"];
    var creds = Credentials.FromApiKeyAndSecret(apiKey,apiSecret);
    var client = new SmsClient(creds);
    var request = new SendSmsRequest
    {
        To= to,
        From = from,
        Text = text
    };
    return client.SendAnSms(request);
}
```

## Configure SmsService as Injectable

Now that we have the service built, we need to make sure that we can inject it into our razor page. To do this, we need to go into `Startup.cs` and find the `ConfigureServices` function. Add the following line to the end of this function, and the service will be injectable:

```csharp
services.AddSingleton<SmsService>();
```

## Add Frontend

We're going to use the `Pages/Index.razor` for our frontend, so just open it up and delete everything below line 2.

### Dependency Inject SmsService

The first thing we need to do here is pull in our `SmsService`. To that end, add a `using` and an `inject` statement, like so:

```csharp
@using SendSmsBlazor.Data
@inject SmsService SmsService
```

### Add C# Code to Send the Message

One of the really neat things about Blazor is that it allows you to run C# code in the browser—all we need is an `@code{}` block, and we're good to go. By doing this we are making an anonymous class in-line, so we will add a `To`, `From`, `Text`, and `MessageId` to this anonymous class and add a method called `SendSms` which will actually call our SmsService. This is going to look like this:

```csharp
@code{
    private string To;
    private string From;
    private string Text;
    private string MessageId;
    private void SendSms()
    {
        var response = SmsService.SendSms(To, From, Text);
        MessageId = response.Messages[0].MessageId;
    }
}
```

### Add Input Fields and Send Button

Now that we have all this out of the way, we're going to add a few input fields. The `To`, `From`, and `Text` fields will be populated by binding them to these input fields with the `@bind` attribute. At the bottom, just above the button, we will display the sent `MessageId` by referencing it in a paragraph tag. Finally, we'll add a button to the bottom that will call the `SendSms` button in our anonymous class when clicked. Add the following between the `@code` block and the `@inject` block:

```html
<h1>Send an SMS!</h1>

Welcome to your new app Fill out the below form to send an SMS.
<br />
to:
<input id="to" @bind="@To" class="input-group-text" />
from:
<input id="from" @bind="From" class="input-group-text" />
text:
<input id="text" @bind="Text" class="input-group-text" />
<p>@MessageId</p>
<button class="btn btn-primary" @onclick="SendSms">Send SMS</button>
```

### Configure the App

The last thing we must do before running our server is to configure it. If you'll recall, you set an `IConfiguration` object in the `SmsService.` All you need to do is open `appsettings.json` and add two properties to the configuration `VONAGE_API_KEY` and `VONAGE_API_SECRET.` Set those to the API key and API secret values in the [Dashboard](https://dashboard.nexmo.com/).

## Running our app

With all this done, just return to your terminal and run the following command.

```sh
dotnet run
```

Your application will tell you what port it's listening on—for me it's port 5001, so I'd navigate to `localhost:5001`, fill out the form, and hit SendSms. You'll see the SMS on the number you sent to, with the Message-ID from the SMS appearing just below the text field.

## Resources

The code for this demo can be found in [GitHub](https://github.com/nexmo-community/send-an-sms-with-blazor).