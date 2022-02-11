---
title: How to Send an SMS with .Net 6 Minimal API
description: This tutorial will show you how to send an SMS with .Net 6 and
  Minimal API using the Vonage API.
thumbnail: /content/blog/how-to-send-an-sms-with-net-6-minimal-api/sms_net-6.png
author: matt-hunt
published: true
published_at: 2021-11-09T11:34:48.690Z
updated_at: 2021-11-06T17:57:46.531Z
category: tutorial
tags:
  - dotnet
  - sms-api
  - minimal-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
I’ve been looking at the preview releases of .Net 6 for some time now, and one of the exciting features that a lot of people have been talking about is Minimal APIs. While it seems that opinion is very divided, I think they are a welcome addition. It removes a lot of the weight of using ASP.NET MVC and certainly lowers the bar to entry with a similar feel to ExpressJS in NodeJS.

A little over a year ago we released a blog post entitled “[How to Send an SMS With ASP.NET Core MVC](https://learn.vonage.com/blog/2020/07/09/how-to-send-an-sms-with-asp-net-core-mvc)”. So with the Release of .Net 6 upon us, I thought it would be a good idea to take inspiration and see what it would be like to use the new Minimal API syntax to emulate the same functionality.

## Just Give Me Code

You can skip straight to the code on [GitHub](https://github.com/Vonage-Community/blog-sms-dotnet_minimal_api-send_sms).

## Prerequisites

* .Net 6 RC 2 SDK or greater
* Visual Studio 2022 Preview or Visual Studio Code

<sign-up></sign-up>

## Creating the Project

The easiest way I’ve found to create a new Minimal API project is using the command below

```
dotnet new web -o SmsDotnetMinimalApi
```

Microsoft also has a [great tutorial](https://docs.microsoft.com/en-us/aspnet/core/tutorials/min-web-api?view=aspnetcore-6.0&tabs=visual-studio) on creating a new Minimal API project using Visual Studio.

We should now have an API with one "Hello World" endpoint. To this we will add two NuGet packages, the first is [Vonage’s .Net SDK](https://www.nuget.org/packages/Vonage/) version 5.9.2 at the time of writing. As this will be an API we won’t have a UI so the second is Swashbuckle / Swagger that will enable us to try out any endpoints we create easily.

```
dotnet add package Vonage
dotnet add package Swashbuckle.AspNetCore
```

## Small Is Beautiful

Along with the usual `appsettings.json`, your newly created project will be just one file, `Program.cs`. This is truly minimal, for an ASP.Net project at least.

![Solution Explorer](/content/blog/how-to-send-an-sms-with-net-6-minimal-api/min-project.png ".Net 6 Project")

Let’s open `Program.cs`, it should look like this.

```csharp
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello World!");

app.Run();
```

This is all you need to have a fully-fledged .NET API all in a single file. This will provide a much lighter starting point to build a small API or microservice. And to be honest, still blows my mind when I think back to how much code WebAPI would need to produce the same outcome.

## Configuration

Let’s make a start by adding some settings. Inside `appsettings.json` we need to add our Vonage key and secret, these are used to authenticate your application with Vonage’s services and can be found at the top of the [Dashboard](https://dashboard.nexmo.com/).

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "Vonage_key": "ab12c3de",
  "Vonage_secret": "ZKSQ1vlzNvyZnQCI"
}
```

Currently, we do not have Dependency Injection configured so let’s add the VonageClient class to the services collection. This will allow it to be injected into any class or method that we will use further down the line.

Import the required namespaces at the top of the file.

```csharp
using Vonage;
using Vonage.Messaging;
using Vonage.Request;
```

Register the VonageClient with the services collection.

```csharp
builder.Services.AddSingleton<VonageClient>(provider =>
{
    var config = provider.GetRequiredService<IConfiguration>();
    var key = config.GetValue<string>("Vonage_key");
    var secret = config.GetValue<string>("Vonage_Secret");
    var credentials = Credentials.FromApiKeyAndSecret(key, secret);

    return new VonageClient(credentials);
});
```

Going line at a time we can see that we get an instance of IConfiguration, this enables us to access the app settings we need. The key and secret are then retrieved from the configuration so that we can create credentials that are required by the VonageClient constructor.

## Sending Out an SMS

Now that we have our VonageClient class configured and ready to be injected let's create a new endpoint that we can send requests to. We will need to pass in a data model to the endpoint so create a class in a new file called \`SmsModel\`. Then inside the class, we want to add the following properties.

```csharp
public class SmsModel
{
    public string To { get;set; }

    public string From { get;set; }

    public string Text { get;set; }
}
```

With our model created we can go ahead and add a new POST method with the VonageClient and our SmsModel class as parameters.

```csharp
app.MapPost("/sms", async (VonageClient vonageClient, SmsModel smsModel) =>
{
    var smsResponse = await vonageClient.SmsClient.SendAnSmsAsync(new SendSmsRequest
    {
        To = smsModel.To,
        From = smsModel.From,
        Text = smsModel.Text
    });
});
```

There are a couple of things going on in the block of code. First, we are using the `MapPost` extension method to create an endpoint at http://localhost:5000/sms. Secondly, we are declaring the parameters for the method; `VonageClient` will get injected using the dependency injection we set up previously, `SmsModel` will be created using the body of the request using [model binding](https://docs.microsoft.com/en-us/aspnet/core/mvc/models/model-binding?view=aspnetcore-6.0). 

The main body of the method does the actual work of sending the SMS. We create an instance of the SendSmsRequest using the data from the model we passed in, then it's just a case of passing the request class to the SmsClient's `SendAnSmsAsync` method. In the spirit of "minimal", this is only one line!

## Try It Out

The project should now build, run and receive requests. As mentioned previously though we have no UI to test this out easily so we will add a few more lines of code to implement the Swagger UI into our project.

Directly after var builder = WebApplication.CreateBuilder(args) we need to add two lines of code. These will add the necessary services to dependency inject.

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
```

With these added, we then register the Swagger middleware before the `app.Run()` line

```csharp
app.UseSwagger();
app.UseSwaggerUI();
app.Run();
```

With all our code now written, we can run the project, hit F5 if you're using Visual Studio or run the command below inside the project folder

```powershell
dotnet run
```

Now browse to <https://localhost:5001/swagger> and you should be able to use the "Try it out" button on the SMS endpoint. From there you will see a 200 response code and receive a text message. 

## Validation

Input validation is a vital part of any API, as it stands there is no validation built into Minimal APIs as you would find with ASP.NET MVC. Damian Edwards has created a small library called [MinimalValidation](https://github.com/DamianEdwards/MiniValidation) using validation attributes similar to the MVC validation.

Personally, I prefer [Fluent Validation](https://fluentvalidation.net/) as it uses code to define rules rather than attributes. An example of this is below, for the full code including validation check out the [repository on GitHub](https://github.com/Vonage-Community/blog-sms-dotnet_minimal_api-send_sms).

Service registration and endpoint changes

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// validation
builder.Services.AddValidatorsFromAssemblyContaining<SmsModel>(ServiceLifetime.Scoped);

...
 
app.MapPost("/sms", async (VonageClient vonageClient, SmsModel smsModel, IValidator<SmsModel> validator) =>
{
    ValidationResult validationResult =validator.Validate(smsModel);
    if (!validationResult.IsValid)
    {
        return Results.ValidationProblem(validationResult.ToDictionary());
    }

    var smsResponse = await vonageClient.SmsClient.SendAnSmsAsync(new SendSmsRequest
    {
        To = smsModel.To,
        From = smsModel.From,
        Text = smsModel.Text
    });

    return Results.Ok();
});
```

Model validator

```csharp
public class SmsModel
{
    public string To { get; set; }
    public string From { get; set; }
    public string Text { get; set; }

    public class Validator : AbstractValidator<SmsModel>
    {
        public Validator()
        {
            RuleFor(x => x.To).NotEmpty().WithMessage("To phone number required");
            RuleFor(x => x.From).NotEmpty().WithMessage("From phone number required");
        }
    }
}
```

Validation extension

```csharp
public static class ValidationExtensions
{
    public static IDictionary<string, string[]> ToDictionary(this ValidationResult validationResult)
       => validationResult.Errors
               .GroupBy(x => x.PropertyName)
               .ToDictionary(
                   g => g.Key,
                   g => g.Select(x => x.ErrorMessage).ToArray()
               );
}
```

## Final Thoughts

While MVC is a fully-featured framework incorporating built-in model binding and validation, extensible pipelines via filters, convention and declarative based behaviours and more. Some may not need specific features or have performance constraints that make using MVC undesirable. With more and more features surfacing as  ASP.NET Core middleware (authorisation, authentication, routing etc), ASP.NET 6 and Minimal APIs bring these features into play with less pomp and is a perfect fit for creating lightweight microservices in a timely fashion in a maintainable way. 

## Resources

* The code from this tutorial can all be found on [GitHub](https://github.com/Vonage-Community/blog-sms-dotnet_minimal_api-send_sms)
* Microsoft [Minimal APIs Overview](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/minimal-apis?view=aspnetcore-6.0)
* David Fowler's Gist [Minimal API's at a Glance](https://gist.github.com/davidfowl/ff1addd02d239d2d26f4648a06158727)
* What people are [Tweeting about Minimal APIs](https://twitter.com/hashtag/minimalapis)
* [Vonage SMS API](https://www.vonage.co.uk/communications-apis/sms/)