---
title: Serverless Contact Centre with Azure Functions
description: Creating a low cost serverless contact centre with Azure Functions
thumbnail: /content/blog/serverless-contact-centre-with-azure-functions/serverless-contact-center.png
author: matt-hunt
published: true
published_at: 2022-02-11T10:17:37.032Z
updated_at: 2022-02-11T09:00:54.797Z
category: tutorial
tags:
  - voice-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
I would be surprised if there isn’t a company out there, from the smallest startup to the largest mega-corporation, that doesn’t want to provide its customers with brilliant customer service. Part of that service could be offering a dynamic and affordable contact centre that can provide self-service options or direct calls to the correct agent or department. [Vonage's Voice API](https://developer.vonage.com/voice/voice-api/overview) and its NCCOs are an easy way to build high-quality voice applications that can control the flow of inbound and outbound calls, create conference calls, record and store calls, playback pre-recorded messages and send text-to-speech messages in 40 different languages.

These days most software one way or the other is hosted wholly or partially in the cloud and it’s no secret that without regulation cloud hosting costs can grow quickly over time. Having worked with Azure for many years, I love learning about the different services it has to offer. My favourite for a while now has been Azure Functions, Microsoft’s serverless offering. They offer all of the security, reliability and scalability that you’d expect from any cloud provider at a cost that is very reasonable. In fact, when using the Consumption plan the first 1,000,000 executions are free.

Armed with these two bits of technology, I thought it would be a good idea to see what it would take to create a low-cost serverless contact centre that could be expanded on or customised to suit many different requirements.

## Prerequisites

* Visual Studio 2022 Preview or Visual Studio Code
* [Vonage CLI](https://developer.vonage.com/application/vonage-cli)
* Azure Functions [Core Tools](https://github.com/Azure/azure-functions-core-tools) (V4 is used in this demo)
* An [Azure Account](https://azure.microsoft.com/en-gb/free/) (This can be set up for Free and Azure Functions are free for the first 1M calls)
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

<sign-up number></sign-up>

## The Plan

For our Contact Centre we will need to set up a couple of things. First a Vonage Application and Number, the Number will be linked to the Application and it's the Application that will call into our Azure Function. The Function will then return Nexmo Call Control Objects (NCCO) as JSON and it is this that will describe the flow of the incoming call.

When receiving a call to our number, we will use text-to-speech to play a message and give the caller a couple of options. I'm only going to create a basic functioning prototype, but there are so many [different actions](https://developer.vonage.com/voice/voice-api/ncco-reference) that we can use with NCCO the possibilities are endless!

## Azure Resources

Before we can set up the Vonage Application we will need to know the hostname for our functions so that we can enter the Answer and Event URLs during its creation. To obtain these we will first need to create an Azure Function App, I find that the easiest way to do this is using the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/), but creating a Function App through the [Azure Portal](https://portal.azure.com/) works just as well. I've just created a simple bash script that does all of this for me in one go, this could be typed out manually or indeed converted to a PowerShell script.

```shell
#!/bin/bash

# You must be logged into your Azure Account
az login

# Function app and storage account names must be unique.
storageName=contactcentrestorage$RANDOM
functionAppName=contactcentre$RANDOM
region=westeurope

# Create a resource group.
az group create --name ContactCentreResourceGroup --location $region

# Create an Azure storage account in the resource group.
az storage account create \
  --name $storageName \
  --location $region \
  --resource-group ContactCentreResourceGroup \
  --sku Standard_LRS

# Create a serverless function app in the resource group.
az functionapp create \
  --name $functionAppName \
  --storage-account $storageName \
  --consumption-plan-location $region \
  --resource-group ContactCentreResourceGroup \
  --functions-version 4
```

Once your function app has been created we will need to retrieve the hostname. We can retrieve the hostname with the Azure CLI command below, changing the "webapp-name" for the name of the function we just created.

```
 az functionapp config hostname list --resource-group ContactCentreResourceGroup --webapp-name contactcentre123 -o tsv --query [].name
```

Make a note of the hostname for when we create the Vonage Application.

## Vonage Application

Once you have registered for a free Vonage account you will be able to retrieve your API Key and API Secret from the [Vonage Dashboard](https://dashboard.nexmo.com/) to configure the Vonage CLI

```shell
vonage config:set -h --apiKey=<key> --apiSecret=<secret>
```

With your Azure Function hostname to hand, we can now create the Vonage Application. Select yes when asked to create Webhooks and enter then as I did below, remember to replace \`contactcentre123.azurewebsites.net\` with your own hostname.

```shell
vonage apps:create

✔ Application Name … contact centre
✔ Select App Capabilities › Voice
✔ Create voice webhooks? … yes
✔ Answer Webhook - URL … https://contactcentre123.azurewebsites.net/api/answer
✔ Answer Webhook - Method › POST
✔ Event Webhook - URL ... https://contactcentre123.azurewebsites.net/api/event
✔ Event Webhook - Method » POST
```

Now we can search for a number to buy and link to our application. We will search for a mobile number in the country you reside in. Our help pages have lists of [what products are supported in which countries](https://help.nexmo.com/hc/en-us/articles/204015043-Which-countries-does-Vonage-have-numbers-in-) and we use the [ISO 3166-1 alpha-2 codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) for our country in our search. I'm based in the United Kingdom so I use "GB" when searching for numbers.

```shell
vonage numbers:search GB --features=VOICE --type=mobile-lvn

Country Number       Type       Cost Features
─────── ──────────── ────────── ──── ─────────
GB      447418368151 mobile-lvn 1.25 VOICE,SMS
GB      447418368155 mobile-lvn 1.25 VOICE,SMS
GB      447418368156 mobile-lvn 1.25 VOICE,SMS
GB      447418368157 mobile-lvn 1.25 VOICE,SMS
GB      447418368158 mobile-lvn 1.25 VOICE,SMS
```

When we find a number that we like we can purchase it and link it to the Vonage Application we created earlier.

```
vonage numbers:buy 447418368151 GB
vonage apps:link 3ff94f7c-fb86-4afd-b338-fe39707b5ef5 --number=447418367999
```

## Creating the Project

Right, let's get coding! To start we'll create a new Azure Functions project using the dotnet runtime.

```
func init ContactCentre —dotnet --worker-runtime dotnet
```

This will create a Function App project in the folder ContactCentre. Next, we need to first add a reference to the Vonage Nuget package and then we will create three functions that all have HTTP Triggers; one that is the Answer endpoint and the second that will be the Event endpoint and the last that will be used to perform and action based on the option provided by the caller. Change into the ContactCentre project folder and run the commands below.

```shell
dotnet add package vonage
func new --name Answer --template "HTTP trigger" --authlevel "anonymous"
func new --name Event --template "HTTP trigger" --authlevel "anonymous"
func new --name Menu --template "HTTP trigger" --authlevel "anonymous"
```

### Answer Function

Whenever someone phones our contact centre, the answer function is always the first endpoint that will be hit. We will return an NCCO object describing the first steps in our process. We'll create a [Talk Action](https://developer.vonage.com/voice/voice-api/ncco-reference#talk) that welcomes our caller and describes what they can do using UK English and voice style 2 (I find this the nicest) but there are plenty of [styles and languages](https://developer.vonage.com/voice/voice-api/guides/text-to-speech#supported-languages) to chose from. The next action is the [MultiInputAction](https://developer.vonage.com/voice/voice-api/ncco-reference#input) which collects digits or speech input by the person you are calling and will pass this input to the EventUrl we supply, in this case, the Menu Function.

Below is the code for the Answer Function.

```csharp
using Vonage.Voice.Nccos;


public static class Answer
{
    [FunctionName("Answer")]
    public static IActionResult Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = null)] HttpRequest req, ILogger log)
    {
        log.LogInformation("Phone call answered");

        var ncco = new Ncco(new NccoAction[] {
            new TalkAction
            {
                Text = "Welcome to the Contact Centre. Press 1 for order information. Press 2 to speak to an operator.",
                Language = "en-GB",
                Style = 2
            },
            new MultiInputAction
            {
                Dtmf = new DtmfSettings{MaxDigits = 1},
                EventUrl = new []{ "https://contactcentre123.azurewebsites.net/api/menu" }
            }
        });

        return new OkObjectResult(ncco);
    }
}
```

### Menu Function

We specified the Menu Function's URL in NCCOs EventUrl property. The input action will POST data relating to the caller's input as JSON to this URL - check out the [webhook reference](https://developer.vonage.com/voice/voice-api/webhook-reference#input) for a full description of the properties. For this exercise, we're just interested in the digits that the caller pressed. The Menu Function below retrieves the digits as the \`selectedOption\` and then we take action based on that.

Below is the code for the Menu Function

```csharp
using Vonage.Voice.Nccos;
using Vonage.Voice.Nccos.Endpoints;


public static class Menu
{
    [FunctionName("Menu")]
    public static async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = null)] HttpRequest req,
        ILogger log)
    {
        log.LogInformation("Menu event triggered");

        string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
        dynamic data = JsonConvert.DeserializeObject(requestBody);

        var ncco = new Ncco();

        var selectedOption = data.dtmf.digits;
        switch (selectedOption.ToString())
        {
            case "1":
                // LOOK UP CUSTOMER SPECIFIC DATA
                ncco.Actions.Add(
                    new TalkAction
                    {
                        Text = "Your order is on it's way.",
                        Language = "en-GB",
                        Style = 2
                    });
                break;
            case "2":
                // CONNECT TO TELEPHONE AGENT
                ncco.Actions.Add(
                    new TalkAction
                    {
                        Text = "Please wait while we connect you to the next available operator.",
                        Language = "en-GB",
                        Style = 2
                    });

                ncco.Actions.Add(
                    new ConnectAction
                    {
                        Endpoint = new Endpoint[]
                        {
                            new PhoneEndpoint
                            {
                                Number = "44123456789"
                            }
                        }
                    });
                break;
        }

        return new OkObjectResult(ncco);
    }
}
```

## Publish the Function App

To get everything working, the last thing we need to do is put our code onto Azure. I find that the quickest way to do this is using the Publish command in Visual Studio. Having loaded the project into Visual Studio all we need to do is right-click on the project name and select "Publish" from the drop-down menu. You will then be presented with the screen below. Select the target as Azure.

![Publishing to Azure](/content/blog/serverless-contact-centre-with-azure-functions/publish-1.png)

The function app we're created earlier used the defaults to it will be an Azure Function App (Windows).

![Choose Function Type](/content/blog/serverless-contact-centre-with-azure-functions/publish-2.png)

Location the Contact Centre Function App and select finish.

![Select Contact Centre Function App](/content/blog/serverless-contact-centre-with-azure-functions/publish-3.png)

You will now have a publish profile set up and be able to upload the app to Azure by simply clicking publish. When that has succeeded the last thing to do is call the phone number of your application and follow the instructions!

## Now We Have a Contact Centre?

While this isn't a fully functional contact centre yet, we now have the basis for one. There are a few things that spring to mind that we could add to make this more functional. 

When a caller presses 1 for order information we could use the phone number they are calling from to retrieve their latest order and customer information and ask for some sort of data to confirm their identity before giving them an order update. Or instead of just connecting the call to a regular phone number we could pass them to a SIP line, a WebSocket endpoint or a Vonage Business Cloud extension. Have a look at the [NCCO Reference](https://developer.vonage.com/voice/voice-api/ncco-reference#connect) for more information on those.

We also have a [Pay Action](https://developer.vonage.com/voice/voice-api/ncco-reference#pay) in developer preview allowing the caller to pay an outstanding bill or perhaps order additional products right there on the call. 

Building from the basics I've covered here it's very easy to see how having a fully functional, customised contact centre hosted at a reasonable price in the cloud is within reach of every business large and small.

## References

* The code from this tutorial can all be found on [GitHub](https://github.com/Vonage-Community/blog-voice-dotnet-serverless_contact_centre)
* More information about [Vonage's NCCO](https://developer.vonage.com/voice/voice-api/overview) and [Voice API](https://www.vonage.co.uk/communications-apis/voice/)
* Try [Azure Functions](https://azure.microsoft.com/en-gb/services/functions/) for free if you haven't already
