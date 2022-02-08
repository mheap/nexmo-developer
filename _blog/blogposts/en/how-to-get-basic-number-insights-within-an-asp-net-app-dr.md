---
title: How to Get Basic Number Insights Within an ASP.NET App
description: Learn how to use Vonage's Number Insight Basic API to retrieve some
  basic information about a phone number, such as its international and national
  formats and the country where the number is registered, and then present it to
  the user.
thumbnail: /content/blog/how-to-get-basic-number-insights-within-an-asp-net-app-dr/Number-Insight-Nexmo-02.png
author: bibi
published: true
published_at: 2018-05-22T16:19:25.000Z
updated_at: 2021-05-12T21:06:16.621Z
category: tutorial
tags:
  - Number-insights
  - dotnet
comments: true
redirect: ""
canonical: ""
---
This is the second article in this step-by-step series about [Vonage's Number Insight API](https://developer.vonage.com/number-insight/overview) within an ASP.NET web application.

[In the first article](https://learn.vonage.com/blog/2018/05/22/getting-started-with-nexmo-number-insight-apis-and-asp-net-dr/), we walked through everything we need to know about the Number Insight API, setting up the ASP.NET application and getting ready to explore how to get insights about a phone number.

In this article, we will continue from where we left off in the first article for a deep dive into [Number Insight Basic API](https://developer.vonage.com/number-insight/building-blocks/number-insight-basic). We will use the API to retrieve some basic information about a phone number such as its international and national formats and the country where the number is registered and then present it to the user.

Number Insight Basic API is a free synchronous, easy-to-use RESTful web service. For any phone number you can:

* Retrieve the international and local format.
* Know the country where the number is registered.

## Hands-on code

In [NumberInsightController.cs](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoDotNetQuickStarts/Controllers/NumberInsightController.cs), let's start by creating the method that would allow the navigation to the basic insights view.

```csharp
[HttpGet]
public ActionResult Basic()
{
    return View();
}
```

We will now add that view entitled [Basic.cshtml](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoDotNetQuickStarts/Views/NumberInsight/Basic.cshtml) under the NumberInsight views folder.

```html
@using (Html.BeginForm("Basic", "NumberInsight", FormMethod.Post))
{
    <br />
    <input type="text" name="number" id="number" placeholder="Phone Number" />
    <input type="submit" value="Get More Information" />
}
```

This view will serve as a placeholder for the user to input a phone number.

In order to get some basic insights about that phone number, we will add another method to 'NumberInsightController.cs' with a string parameter representing the phone number and make a call to Number Insight Basic API.

```csharp
[HttpPost]
public ActionResult Basic(string number)
{
    var results = Client.NumberInsight.RequestBasic(new   NumberInsight.NumberInsightRequest
    {
        Number = number,
    });

    Session["requestID"] = results.RequestId;
    Session["iNumber"] = results.InternationalFormatNumber;
    Session["nNumber"] = results.NationalFormatNumber;
    Session["status"] = results.StatusMessage;
    Session["country"] = results.CountryName;
    Session["countryCode"] = results.CountryCode;

return RedirectToAction("BasicResults");
}
```

Notice that after fetching the insights, we need to show them to the user.
We are going to create a [BasicResults method](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoDotNetQuickStarts/Controllers/NumberInsightController.cs#L49-L60) in the controller and a [BasicResults.cshtml view](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoDotNetQuickStarts/Views/NumberInsight/BasicResults.cshtml) for that matter.

```csharp
[HttpGet]
public ActionResult BasicResults()
{
    ViewBag.requestID = Session["requestID"];
    ViewBag.iNumber = Session["iNumber"];
    ViewBag.nNumber = Session["nNumber"];
    ViewBag.status = Session["status"];
    ViewBag.country = Session["country"];
    ViewBag.countryCode = Session["countryCode"];

    return View();
}
```

```html
@{
    <h1>Number Insight Basic Results</h1>
     <hr style="height:2px;border:none;color:#333;background-color:black"/>
    <h2>Request ID: @ViewBag.requestID</h2>
    <h2>Status: @ViewBag.status</h2>
    <h2>International Number: @ViewBag.iNumber</h2>
    <h2>National Number: @ViewBag.nNumber</h2>
    <h2>Country: @ViewBag.country</h2>
    <h2>Country Code: @ViewBag.countryCode</h2>
}
```

Now, let's run the app and make a call to Number Insight Basic API.
You can use one of the Vonage numbers provided for testing.

![Basic Number Insights Gif](/content/blog/how-to-get-basic-number-insights-within-an-asp-net-app/basicni.gif "Basic Number Insights Gif")

## Recap

In this article, we learnt how to use Vonage's Number Insight Basic API to retrieve the international and national formats of a phone number and the country where the number is registered. Then we showed this information on a view within an ASP.NET application.
In the next article of the series, we will learn how to get Standard Number Insights within an ASP.NET app. Stay tuned!

## Vonage Number Insight getting started guide for ASP.NET

* [Getting Started with Vonage Number Insight APIs and ASP.NET](https://www.nexmo.com/blog/2018/05/22/getting-started-with-nexmo-number-insight-apis-and-asp-net-dr/).
* How to Get Basic Number Insights Within an ASP.NET App
* [How to Get Standard Number Insights within an ASP.NET App](https://www.nexmo.com/blog/2018/05/24/how-to-get-standard-number-insights-within-an-asp-net-app-dr/)