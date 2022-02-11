---
title: How to Get Standard Number Insights Within an ASP.NET App
description: Learn how to use Nexmo's Number Insight API within an ASP.NET web application.
thumbnail: /content/blog/how-to-get-standard-number-insights-within-an-asp-net-app-dr/Number-Insight-Nexmo-03.png
author: bibi
published: true
published_at: 2018-05-24T13:03:23.000Z
updated_at: 2021-05-12T21:35:36.780Z
category: tutorial
tags:
  - number-insight
  - dotnet
comments: true
redirect: ""
canonical: ""
---
This is the third article in a step-by-step series on how to use [Nexmo's Number Insight API](https://developer.nexmo.com/number-insight/overview) within an ASP.NET web application.

[In the first article](https://www.nexmo.com/blog/2018/05/22/getting-started-with-nexmo-number-insight-apis-and-asp-net-dr/), we walked through everything we need to know about Number Insight API, setting up the ASP.NET application and getting ready to explore how to get insights about a phone number.

Then we learnt how to use [Number Insight Basic API](https://developer.nexmo.com/number-insight/building-blocks/number-insight-basic) in the second article in this series : [How to Get Basic Number Insights Within an ASP.NET App](https://www.nexmo.com/blog/2018/05/22/how-to-get-basic-number-insights-within-an-asp-net-app-dr/).

In this article, we will explore [Number Insight Standard API](https://developer.nexmo.com/number-insight/building-blocks/number-insight-standard).

Number Insight Standard API is a synchronous, easy-to-use RESTful web service. For any phone number you can:

* Retrieve the international and local format.
* Know the country where the number is registered.
* Line type detection (mobile/landline/virtual number/premium/toll-free).
* Detect mobile country code (MCC) and mobile network code (MNC).
* Detect if number is ported.
* Identify caller name (USA only).
* Check if phone number is reachable.

<h2>Hands on code</h2>

In order to get standard insights for a phone number, we will create a view where we can put a number. By clicking on the 'Submit' button, we are going to fetch standard insights then publish them on a results view.

Let's start by creating the method that would allow the navigation to the standard insights view in [NumberInsightController.cs](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoDotNetQuickStarts/Controllers/NumberInsightController.cs)

```csharp
[HttpGet]
public ActionResult Standard()
{
    return View();
}
```

We will now add the view  [Standard.cshtml](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoDotNetQuickStarts/Views/NumberInsight/Standard.cshtml) under the NumberInsight views folder.

```html
@using (Html.BeginForm("Standard", "NumberInsight", FormMethod.Post))
{
    <br />
    <input type="text" name="number" id="number" placeholder="Phone Number" />
    <input type="submit" value="Get More Information" />
}
```

Next, we are going to request standard insights from the API.

```csharp
[HttpPost]
public ActionResult Standard(string number)
{
    var results = Client.NumberInsight.RequestStandard(new NumberInsight.NumberInsightRequest()
    {
        Number = number,
    });

    Session["requestID"] =  results.RequestId;
    Session["iNumber"] = results.InternationalFormatNumber;
    Session["nNumber"] = results.NationalFormatNumber;
    Session["country"] = results.CallerName;
    Session["countryCode"] = results.CountryCode;
    Session["status"] = results.StatusMessage;

    if (results.OriginalCarrier != null)
    {
        Session["originalCarrierName"] = results.OriginalCarrier.Name;
        Session["originalCarrierCode"] = results.OriginalCarrier.NetworkCode;
        Session["originalCarrierType"] = results.OriginalCarrier.NetworkType;
        Session["originalCarrierCountry"] = results.OriginalCarrier.Country;
    }
    if (results.CurrentCarrier != null)
    {

        Session["currentCarrierName"] = results.CurrentCarrier.Name;
        Session["currentCarrierCode"] = results.CurrentCarrier.NetworkCode;
        Session["currentCarrierType"] = results.CurrentCarrier.NetworkType;
        Session["currentCarrierCountry"] = results.CurrentCarrier.Country;
    }

    return RedirectToAction("StandardResults");
}
```

[StandardResults()](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoDotNetQuickStarts/Controllers/NumberInsightController.cs#L103-L122) and [StandardResults.cshtml](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoDotNetQuickStarts/Views/NumberInsight/StandardResults.cshtml) will allow us to view the results.

```csharp
[HttpGet]
public ActionResult StandardResults()
{
    ViewBag.requestID = Session["requestID"];
    ViewBag.iNumber = Session["iNumber"];
    ViewBag.nNumber = Session["nNumber"];
    ViewBag.status = Session["status"];
    ViewBag.country = Session["country"];
    ViewBag.countryCode = Session["countryCode"];
    ViewBag.currentCarrierName = Session["currentCarrierName"];
    ViewBag.currentCarrierCode = Session["currentCarrierCode"];
    ViewBag.currentCarrierType = Session["currentCarrierType"];
    ViewBag.currentCarrierCountry = Session["currentCarrierCountry"];
    ViewBag.originalCarrierName = Session["originalCarrierName"];
    ViewBag.originalCarrierCode = Session["originalCarrierCode"];
    ViewBag.originalCarrierType = Session["originalCarrierType"];
    ViewBag.originalCarrierCountry = Session["originalCarrierCountry"];

    return View();
}
```

```html
@{
        <h1>Number Insight Standard Results</h1>
        <hr style="height:2px; color:black" />
        <h2>Request ID: @ViewBag.requestID</h2>
        <h2>Status: @ViewBag.status</h2>
        <hr style="border:2px solid black" />
        <h2>International Number: @ViewBag.iNumber</h2>
        <h2>National Number: @ViewBag.nNumber</h2>
        <h2>Country: @ViewBag.country</h2>
        <h2>Country Code: @ViewBag.countryCode</h2>
        <hr style="border:2px solid black" />
        <h2>Current Carrier Name: @ViewBag.currentCarrierName</h2>
        <h2>Current Carrier Code: @ViewBag.currentCarrierCode</h2>
        <h2>Current Carrier Type: @ViewBag.currentCarrierType</h2>
        <h2>Current Carrier Country: @ViewBag.currentCarrierCountry</h2>
        <hr style="border:2px solid black" />
        <h2>Original Carrier Name: @ViewBag.originalCarrierName</h2>
        <h2>Original Carrier Code: @ViewBag.originalCarrierCode</h2>
        <h2>Original Carrier Type: @ViewBag.originalCarrierType</h2>
        <h2>Original Carrier Country: @ViewBag.originalCarrierCountry</h2>
}
```

Now, let's run the app and try to get standard Number Insight.
You can use [one of the Nexmo numbers](https://developer.nexmo.com/contribute/guides/write-the-docs#numbers) provided for testing.

![Standard Number Insights Gif](/content/blog/how-to-get-standard-number-insights-within-an-asp-net-app/standardni.gif "Standard Number Insights Gif")

## Recap
In this article, we learnt how to use Nexmo’s Number Insight Standard API to retrieve the international and national formats of a phone number, the country where the number is registered and information about its portability and reachability. Then we showed this information on a view within an ASP.NET application.
If you'd like to learn how to get Advanced Number Insights, then tune in to the next article in this series. 

## Nexmo Number Insight getting started guide for ASP.NET

* [How to Get Number Insights within an ASP.NET app](https://www.nexmo.com/blog/2018/05/22/getting-started-with-nexmo-number-insight-apis-and-asp-net-dr/).
* [How to Get Basic Number Insights within an ASP.NET app](https://www.nexmo.com/blog/2018/05/22/how-to-get-basic-number-insights-within-an-asp-net-app-dr/).
* How to Get Standard Number Insights within an ASP.NET app.