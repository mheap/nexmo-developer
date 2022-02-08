---
title: How to Get Advanced Number Insights Within an ASP.NET App
description: "This is the fourth article in a step-by-step series on how to use
  Nexmo’s Number Insight API within an ASP.NET web application. "
thumbnail: /content/blog/how-to-get-advanced-number-insights-within-an-asp-net-app-dr/Number-Insight-Nexmo-04.png
author: bibi
published: true
published_at: 2018-05-25T11:22:55.000Z
updated_at: 2021-05-13T08:04:45.649Z
category: tutorial
tags:
  - number-insight
  - dotnet
comments: true
redirect: ""
canonical: ""
---
This is the fourth article in a step-by-step series on how to use [Nexmo's Number Insight API](https://developer.nexmo.com/number-insight/overview) within an ASP.NET web application.

[In the first article](https://www.nexmo.com/blog/2018/05/22/getting-started-with-nexmo-number-insight-apis-and-asp-net-dr/), we walked through everything we need to know about Number Insight API, setting up the ASP.NET application and getting ready to explore how to get insights about a phone number.
[In the second article](https://www.nexmo.com/blog/2018/05/22/how-to-get-basic-number-insights-within-an-asp-net-app-dr/), we covered [Number Insight Basic API](https://developer.nexmo.com/number-insight/building-blocks/number-insight-basic) and how to use it.
[The third article](https://www.nexmo.com/blog/2018/05/24/how-to-get-standard-number-insights-within-an-asp-net-app-dr/) was dedicated to [Number Insight Standard API](https://developer.nexmo.com/number-insight/building-blocks/number-insight-standard).

In this article, we will have a deep dive into [Number Insight Advanced API](https://developer.nexmo.com/number-insight/building-blocks/number-insight-advanced).

Number Insight Advanced API is an easy-to-use RESTful web service. For any phone number you can:

* Retrieve the international and local format.
* Know the country where the number is registered.
* Line type detection (mobile/landline/virtual number/premium/toll-free).
* Detect mobile country code (MCC) and mobile network code (MNC).
* Detect if number is ported.
* Identify caller name (USA only) - see the CNAM guide for details.
* Identify network when roaming.
* Confirm user's IP address is in same location as their mobile phone.

## Hands on code

In [NumberInsightController.cs](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoDotNetQuickStarts/Controllers/NumberInsightController.cs), let's start by creating the method that would allow the navigation to the advanced insights view.

```csharp
[HttpGet]
public ActionResult Advanced()
{
   return View();
}
```

then add the view [Advanced.cshtml](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoDotNetQuickStarts/Views/NumberInsight/Advanced.cshtml) to the NumberInsight views folder.

```html
@using (Html.BeginForm("Advanced", "NumberInsight", FormMethod.Post))
{
    <br />
    <input type="text" name="number" id="number" placeholder="Phone Number" />
    <input type="submit" value="Get More Information" />
}
```

This view will serve as a placeholder for the user to enter a phone number.

In order to get advanced insights about that phone number, we will add another method to 'NumberInsightController.cs' with a string parameter representing the phone number and make a call to Number Insight Advanced API.

```csharp
[HttpPost]
public ActionResult Advanced(string number)
{
    var results = Client.NumberInsight.RequestAdvanced(new NumberInsight.NumberInsightRequest()
    {
        Number = number,
    });

    Session["requestID"] = results.RequestId;
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

    Session["validNumber"] = results.NumberValidity;
    Session["ported"] = results.PortedStatus;
    Session["reachable"] = results.NumberReachability;
    Session["roaming"] = results.RoamingInformation.status;

    return RedirectToAction("AdvancedResults");
}
```

Notice that after fetching the insights, we need to publish them to the user.
We are going to create an [AdvancedResults method](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoDotNetQuickStarts/Controllers/NumberInsightController.cs#L169-L192) in the controller and a [AdvancedResults.cshtml view](https://github.com/nexmo-community/nexmo-dotnet-quickstart/blob/ASPNET/NexmoDotNetQuickStarts/Views/NumberInsight/AdvancedResults.cshtml) for that matter.

```csharp
[HttpGet]
public ActionResult AdvancedResults()
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
    ViewBag.validNumber = Session["validNumber"];
    ViewBag.ported = Session["ported"];
    ViewBag.reachable = Session["reachable"];
    ViewBag.roaming = Session["roaming"];

    return View();
}
```

```html
@{
    <h1>Number Insight Advanced Results</h1>
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
        <hr style="border:2px solid black" />
        <h2>Number Validity: @ViewBag.validNumber</h2>
        <h2>Number Portability: @ViewBag.ported</h2>
        <h2>Number Reachability: @ViewBag.reachable</h2>
        <h2>Roaming Information: @ViewBag.roaming</h2>
}
```

Now, let's run the app and make a call to Number Insight advanced API.
You can use [one of the Nexmo numbers](https://developer.nexmo.com/contribute/guides/write-the-docs#numbers) provided for testing.

![Advanced Number Insight GIF](/content/blog/how-to-get-advanced-number-insights-within-an-asp-net-app/advancedni.gif "Advanced Number Insight GIF")


## Recap

In this article, we learnt how to use Nexmo’s Number Insight Advanced API to retrieve advanced insights about a phone number. Then we showed this information on a view within an ASP.NET application.

## Nexmo Number Insight getting started guide for ASP.NET

* [How to Get Number Insights within an ASP.NET app](https://www.nexmo.com/blog/2018/05/22/getting-started-with-nexmo-number-insight-apis-and-asp-net-dr/).
* [How to Get Basic Number Insights within an ASP.NET app](https://www.nexmo.com/blog/2018/05/22/how-to-get-basic-number-insights-within-an-asp-net-app-dr/).
* [How to Get Standard Number Insights within an ASP.NET app](https://www.nexmo.com/blog/2018/05/24/how-to-get-standard-number-insights-within-an-asp-net-app-dr/).
* How to Get Advanced Number Insights within an ASP.NET app.