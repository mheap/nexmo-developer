---
title: "Vonage Voice API with ASP.NET: Before You Start"
description: Before you start! Everything you need to know to set up and
  configure a new Vonage Voice API project to work with ASP.NET MVC.
thumbnail: /content/blog/nexmo-voice-api-asp-net-configure-dr/configure-voice-asp-net.png
author: bibi
published: true
published_at: 2017-07-28T13:13:43.000Z
updated_at: 2021-12-08T12:45:22.463Z
category: tutorial
tags:
  - asp.net
  - voice-api
  - dotnet
comments: true
redirect: ""
canonical: ""
---
*This is part of a series on using The Vonage Voice API with ASP.NET projects. It continues the “Getting Started with Vonage and ASP.NET” series, which follows our [Getting Started series on SMS APIs](https://learn.vonage.com/blog/2017/03/23/send-sms-messages-asp-net-mvc-framework-dr/).*

In this tutorial, we are going to set up an ASP.NET project in Visual Studio that has all the configuration necessary to connect to The Vonage Voice API. This makes it possible to add phone call abilities to an ASP.NET application. Future blog posts will show how to integrate the Voice API into your application; this is to show you how to get started.

<sign-up number></sign-up>

## Configuring a Vonage application

In order to be able to use [The Vonage Voice API](https://developer.vonage.com/voice/voice-api/overview), you'll have to use a [Vonage Application](https://developer.vonage.com/application/overview).
A Vonage application contains the security and configuration information you need to interact with the Vonage Voice REST API and easily use the Voice API.

All requests to the Voice API require authentication. You must generate a private key with the Application API, which allows you to create JSON Web Tokens (JWT) to make the requests. An application associated public/private keys can be created in two ways.

### The Vonage application dashboard

If you go to your Vonage dashboard, under the [Application section](https://dashboard.nexmo.com/applications), you can create a new an application.

![Creating a Voice enabled application](/content/blog/vonage-voice-api-with-asp-net-before-you-start/create-voice-application.png)

Complete the required fields and then click “Generate public/private key pair” this will prompt you to download your private key *(keep this safe!)* as well as populate the public key for you.

![Creating a Voice app, retrieving the public key](/content/blog/vonage-voice-api-with-asp-net-before-you-start/create-voice-application-keys.png)

You can read more about [our application dashboard and how it makes Vonage Voice application management easier to set up in our blog post](https://learn.vonage.com/blog/2017/06/29/voice-application-management-easier/).

### The Vonage CLI

First, let’s install [Vonage's CLI](https://github.com/Vonage/vonage-cli) from npm

```powershell
npm install @vonage/cli -g 
```

then set it up with your Vonage API key and secret.

```powershell
vonage config:set --apiKey=API_KEY --apiSecret=API_SECRET
```

Now that the configuration is done, the next step is creating the Voice Application using the command **`app:create`**.

With both options, you need to register an application name, for example, "My first voice app" and two webhook endpoints to specify the answer and event URLs. The `app:create` command will guide you through this.

```
vonage apps:create 

√ Application Name ... My first voice app
√ Select App Capabilities » Voice
√ Create voice webhooks? ... yes
√ Answer Webhook - URL ... http://example.com/webhook_name/answer
√ Answer Webhook - Method » POST
√ Event Webhook - URL ... http://example.com/webhook_name/event
√ Event Webhook - Method » POST
√ Allow use of data for AI training? Read data collection disclosure - https://help.nexmo.com/hc/en-us/articles/4401914566036 ... no
Creating Application... done
```

When the application is successfully created, the CLI returns the application ID and private key, both are required to interact with the Vonage's Voice API. This information is also stored in two files located in your user directory eg. `c:\users\bob\` and are `vonage_app.json` and `<app_name>.key`

## ASP.NET project setup

Now that we have generated our public/private key pair and our Vonage application let’s look at how we should configure our ASP.NET project. You may have noticed that there is now more than one ASP.Net platform: The ASP.Net is built specifically for Windows while ASP.Net Core is the new open-sourced and cross-platform framework. 

We will try to cover both when there is a difference in code otherwise we will use one or the other with a focus on ASP.Net Core as it’s the way forward. 

### ASP.Net Web project setup

First, open up Visual Studio and create a new **ASP.NET Web Application (.NET Framework)** project.

![Initiating an ASP.Net project](/content/blog/nexmo-voice-api-with-asp-net-before-you-start/asp-project.png)

Select the **MVC Template** and ensure the Authentication type is set to **No Authentication**. Click **OK** to create the project.

![Choosing an MVC template](/content/blog/nexmo-voice-api-with-asp-net-before-you-start/mvc-template.png)

### ASP.Net Core & .Net 5 onwards project setup

In Visual Studio, create a new project and choose ASP.NET Core Web Application.

![Choosing an ASP core project](/content/blog/nexmo-voice-api-with-asp-net-before-you-start/aspcore-project.png)

Then select the Web Application template.

![Choosing ASP core project template](/content/blog/nexmo-voice-api-with-asp-net-before-you-start/aspcore-project-template.png)

### Installing the Vonage .Net SDK

Whether you opt for ASP.Net Web or Core project, the following steps are the same. 

Install the Vonage .Net SDK via the NuGet Package Manager Console.

```
Install-Package Vonage
```

Add a JSON file (appsettings.json) to your project. Inside which you will add your Vonage credentials.

```json
{
  "appSettings": {
    "Vonage_key": "VONAGE-API-KEY",
    "Vonage_secret": "VONAGE-API-SECRET",
    "VONAGE_FROM_NUMBER": "VONAGE-VIRTUAL-NUMBER"
  }
}
```

Now you’re ready to dive into code. Let’s see how you can make a Text-to-Speech phone call in your ASP.NET project with the Voice API.

## Learn more about Vonage’s APIs and ASP.NET

This post was just a quick introduction to setting up your first Vonage application with ASP.NET.
Now you are ready to dive into code and learn [How to make a Text-to-Speech phone call in ASP.NET with The Vonage Voice API](https://learn.vonage.com/blog/2017/07/28/text-to-speech-phone-call-dr) 

Also, why not try [sending an SMS with ASP.NET MVC](https://learn.vonage.com/blog/2017/03/23/send-sms-messages-asp-net-mvc-framework-dr/)? Or learn how to [receive SMS with ASP.NET MVC](https://learn.vonage.com/blog/2017/03/31/recieve-sms-messages-with-asp-net-mvc-framework-dr/)? Both posts are on our [developer blog](https://learn.vonage.com/blog/category/developers-2/). You might also be interested in our [open source .NET SDK which is available on Github](https://github.com/Vonage/vonage-dotnet-sdk).