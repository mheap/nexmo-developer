---
title: Getting Started with Nexmo Number Insight APIs and ASP.NET
description: Nexmo Number Insight offers real-time validation of a user-input
  phone number. In this tutorial, get started with Number Insight and ASP.NET
thumbnail: /content/blog/getting-started-with-nexmo-number-insight-apis-and-asp-net-dr/Number-Insight-Nexmo-01.png
author: bibi
published: true
published_at: 2018-05-22T16:19:01.000Z
updated_at: 2021-05-12T21:11:33.116Z
category: tutorial
tags:
  - number-insight
  - dotnet
comments: true
redirect: ""
canonical: ""
---
Our [Number Insight API](https://developer.nexmo.com/number-insight/overview) is perfect for real-time validation of user input that could potentially protect your apps from fraud and spam and help you get details about a phone number such as validity, reachability and roaming status.
You can use also the Number Insight API to validate that a phone number is formatted properly. This is very useful especially if you are using our other APIs.

Number insight is available with three levels:

* [Basic](https://developer.nexmo.com/number-insight/building-blocks/number-insight-basic): used to format numbers and display them in international and local representations.
* [Standard](https://developer.nexmo.com/number-insight/building-blocks/number-insight-standard): best used to identify number type to decide between SMS and Voice; block virtual numbers.
* [Advanced](https://developer.nexmo.com/number-insight/building-blocks/number-insight-advanced): best used to determine risk based on numbers.

The advanced API is also available [asynchronously](https://developer.nexmo.com/number-insight/building-blocks/number-insight-advanced-async) as well as synchronously.

You can check the full list of what's available on each level on [the Number Insight documentation](https://developer.nexmo.com/api/number-insight).

For the sake of readability and getting straight to the point, I'm going to post this tutorial as a series of step-by-step articles instead of one long post. In each article, we will see how to use one of the three levels of the Number Insight API with an ASP.NET app. So let's get started!

## Prerequisites

* Visual Studio 2017.
* A project set up for this tutorial series which you can find on [Github](https://github.com/nexmo-community/nexmo-dotnet-quickstart).
* Optional: [Nexmo CLI](https://github.com/Nexmo/nexmo-cli).

<sign-up></sign-up>

## Configuration

We will be showcasing how to use Number Insight API with an ASP.NET Web Application. So the first step is to create an ASP.NET project. 

* Launch Visual Studio and create a new ASP.NET Web Application (.NET Framework) project. 

![ASP.NET Gif](/content/blog/getting-started-with-nexmo-number-insight-apis-and-asp-net/asp.net-project.png "ASP.NET Gif")

* Select the MVC Template and ensure the Authentication type is set to No Authentication. Click OK to create the project

  ![MVC template](/content/blog/getting-started-with-nexmo-number-insight-apis-and-asp-net/mvc-template.png "MVC template")

* Install the Nexmo C# Client Library via the NuGet Package Manager Console.

```csharp
Install-Package Nexmo.Csharp.Client
```

Voila, we now have the template for the ASP.NET web app project and we are ready to write some code.

![ASP.NET Project Template](/content/blog/getting-started-with-nexmo-number-insight-apis-and-asp-net/asp.net-project-template.png "ASP.NET Project Template")

## Getting some number insights

Now that we set up the project, let's see how to get some insights.
Under the Controllers folder, create [a new controller called NumberInsightController.cs](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoDotNetQuickStarts/Controllers/NumberInsightController.cs). In the constructor,  instantiate a Nexmo Client and authenticate with the API using your API key and secret. Those can be found on [your Nexmo dashboard](https://dashboard.nexmo.com/getting-started-guide).

```csharp
public Client Client { get; set; }

public NumberInsightController()
{
    Client = new Client(creds: new Nexmo.Api.Request.Credentials
    {
        ApiKey = "NEXMO_API_KEY",
        ApiSecret = "NEXMO_API_SECRET"
    });
}
```

Then under the views folder, create [a new folder called NumberInsight](https://github.com/nexmo-community/nexmo-dotnet-quickstart/tree/ASPNET/NexmoDotNetQuickStarts/Views/NumberInsight). This folder will contain all Number Insight views we will need.
We will need an [Index.cshtml](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoDotNetQuickStarts/Views/NumberInsight/Index.cshtml) view to allow the navigation to the other views.

```html
<div>
    <h1>Number Insight</h1>
    <hr style="height:2px;border:none;color:#333;background-color:black" />
    <h2>@Html.ActionLink("Basic", "Basic", "NumberInsight")</h2>
    <h2>@Html.ActionLink("Standard", "Standard", "NumberInsight")</h2>
    <h2>@Html.ActionLink("Advanced", "Advanced", "NumberInsight")</h2>
</div>
```

## Recap

In this first article of the guideline, we:

*   setup the ASP.NET project.
*   installed the Nexmo C# Client Library.
*   prepared the main skeleton of our project.

In the second article, we will learn how to get [Basic Insights](https://www.nexmo.com/blog/2018/05/22/how-to-get-basic-number-insights-within-an-asp-net-app-dr/).