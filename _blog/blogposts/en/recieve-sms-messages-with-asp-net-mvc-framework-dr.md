---
title: How to Receive SMS Messages with ASP.NET MVC Framework
description: This tutorial explains how to receive SMS messages with ASP.NET MVC
  using Vonage's C# Client Library.
thumbnail: /content/blog/recieve-sms-messages-with-asp-net-mvc-framework-dr/sms-receive.png
author: sidharth-sharma
published: true
published_at: 2017-03-31T13:00:30.000Z
updated_at: 2021-05-18T08:21:35.424Z
category: tutorial
tags:
  - dotnet
  - sms-api
comments: true
redirect: ""
canonical: ""
---
My previous tutorial explained how to use the Vonage [C# Client Library](https://github.com/Vonage/vonage-dotnet-sdk) to [send your first SMS message](https://learn.vonage.com/blog/2017/03/23/send-sms-messages-asp-net-mvc-framework-dr/) from an ASP.NET MVC web app. In this follow-up, I continue exploring the Vonage Platform by showing how to receive SMS messages on a Vonage phone number using the C# Client Library.

## Requirements

* Visual Studio 2017 RC
* Windows machine
* A [starter project](https://github.com/Vonage/vonage-dotnet-code-snippets/tree/master/DotNetWebhookCodeSnippets) set up in the previous [blog post](https://learn.vonage.com/blog/2017/03/23/send-sms-messages-asp-net-mvc-framework-dr/)
* [The Vonage CLI](https://developer.vonage.com/application/vonage-cli)

<sign-up number></sign-up>

## Receive Webhooks on Your Localhost with Ngrok

The Vonage SMS API uses webhooks to inform your ASP.NET web application that an incoming text message has been sent to one of your Vonage phone numbers. In order to do this, Vonage needs to be able to make an HTTP request to a public URL. Since we’re developing our app on our local machine, we need to create a local tunnel that gives our machine a public URL. We will be using [ngrok](https://ngrok.com/) to expose the port over the internet to easily communicate with the Vonage platform during this testing phase. This approach saves you from having to deploy your application.

[Download ngrok](https://ngrok.com/download) and run the following command in Command Prompt (replace the port number with the number of the port you wish to run the app on).

```sh
ngrok http 8080 -host-header="localhost:8080"
```

![Ngrok URL](/content/blog/how-to-receive-sms-messages-with-asp-net-mvc-framework/ngrokurl.png)

The command above allows your local server (running on the port above) to have a public URL that will be used to forward the incoming texts (HTTP requests) back to your local server. The host header needs to be specified to make sure the host header of the application and ngrok match and to ensure the requests will not be rejected.

## Diving Into Code

In the previous tutorial, we created an ASP.NET MVC project and added another controller called `SMSController.cs`. Next, we created two action methods. One method was to present the view for the details of the SMS (destination number and message text) and the other was to retrieve the values from the form and send an SMS. 

Continuing the project from the [previous blog post](https://learn.vonage.com/blog/2017/03/23/send-sms-messages-asp-net-mvc-framework-dr/), let's create an [action method](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/488a97c576c882aeef8a7cf327bade27750f4856/NexmoDotNetQuickStarts/Controllers/SMSController.cs#L40-L62) called ‘Receive’ in `SMSController.cs`. This path will be receiving the inbound SMS data as we will be setting the Vonage webhook (later in this tutorial) to our ngrok URL with the route of ‘SMS/Receive’. 

Add \[FromUri] in the parameter to read the incoming SMS. In order to be able to use \[FromUri], you need to install the following package: `Microsoft.AspNet.WebApi.Core`. Above this method, add an HTTPGetAttribute to restrict the method to accepting only GET requests. If the value for response.to (the Vonage phone number) and msidsn (the sender) are not null, print out the message to the output window using `Debug.WriteLine`. Else, the endpoint was hit as a result of something other than an incoming SMS. (This can happen when you first set up your webhook. We’ll see this shortly.)

```dotnet
[System.Web.Mvc.HttpGet]
public ActionResult Receive([FromUri]SMS.SMSInbound response)
{
    if (null != response.to && null != response.msisdn)
    {
        Debug.WriteLine("-------------------------------------------------------------------------");
        Debug.WriteLine("INCOMING TEXT");
        Debug.WriteLine("From: " + response.msisdn);
        Debug.WriteLine(" Message: " + response.text);
        Debug.WriteLine("-------------------------------------------------------------------------");
        return new HttpStatusCodeResult(200);
    }
    else {
        Debug.WriteLine("-------------------------------------------------------------------------");
        Debug.WriteLine("Endpoint was hit.");
        Debug.WriteLine("-------------------------------------------------------------------------");
        return new HttpStatusCodeResult(200);
    }
}
```

## Run the ASP.NET Web App

In the Solution Explorer, expand the project and click **Properties**. Click the **Web** tab and change the **Project URL** to the same port you are exposing via ngrok. Finally, run the project.

![Project settings](/content/blog/how-to-receive-sms-messages-with-asp-net-mvc-framework/projectsettings.png)

## Set the SMS Callback Webhook URL for Your Vonage Number

Now use the Vonage CLI to create a Vonage app and a webhook for it.

Install the Vonage CLI globally with this command:

```
npm install @vonage/cli -g
```

Next, configure the CLI with your Vonage API key and secret. You can find this information in the [Developer Dashboard](https://dashboard.nexmo.com/).

```
vonage config:set --apiKey=VONAGE_API_KEY --apiSecret=VONAGE_API_SECRET
```

### Create a Voice Application

Create a new directory for your project and CD into it:

```
mkdir my_project
CD my_project
```

Now, use the CLI to create a Vonage application. 

```sh
vonage apps:create
✔ Application Name … your_app_name
✔ Select App Capabilities › Messages
✔ Create messages webhooks? … yes
✔ Inbound Message Webhook - URL … https://www.example.ngrok.io/SMS/Recieve
✔ Inbound Message Webhook - Method › GET
✔ Status Webhook - URL … https://example.com/webhook_name
✔ Status Webhook - Method › POST
✔ Allow use of data for AI training? Read data collection disclosure - https://help.nexmo.com/hc/en-us/articles/4401914566036 … yes
```

Now you need a number so you can receive calls. You can rent one by using the following command (replacing the country code with your code). For example, if you are in the USA, replace `GB` with `US`:

```bash
vonage numbers:search US
vonage numbers:buy [NUMBER] [COUNTRYCODE]
```

Now link the number to your app:

```
vonage apps:link --number=VONAGE_NUMBER APP_ID
```

## Receive an SMS with ASP.NET

You are ready to go! With your ASP.NET web app running, open up the output window in Visual Studio. Send an SMS to your Vonage phone number and you will see the incoming texts coming through! Your ASP.NET web app is able to receive SMS messages that are sent to your Vonage phone number via an inbound webhook!

Feel free to reach out via [e-mail](mailto:sidharth.sharma@nexmo.com) or [Twitter](https://twitter.com/doesdotnet) if you have any questions!

### Helpful Links

* [Vonage SMS REST API](https://docs.nexmo.com/messaging/sms-api)
* [Vonage C# Client Library](https://github.com/Nexmo/nexmo-dotnet)
* [Vonage ASP.NET MVC Quickstart](https://github.com/nexmo-community/nexmo-dotnet-quickstart)