---
title: Create a Fraud Detection Microservice in .NET and Vonage
description: Create a .NET microservice that can verify phone numbers and send
  that information back to multiple consumers/services. Each consumer can make
  their own decision about how they want to use the results. You also understand
  how using an event-driven approach can keep the various parts of your system
  decoupled and autonomous.
thumbnail: /content/blog/create-a-fraud-detection-microservice-in-net-and-vonage/fraud-detection-microservices.png
author: james-hickey
published: true
published_at: 2021-08-17T07:35:26.768Z
updated_at: 2021-08-06T18:33:09.207Z
category: tutorial
tags:
  - c-sharp
  - number-insight-api
  - dotnet
comments: true
spotlight: true
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
When you sign up for services like insurance policies, financing assets like a mortgage, or even something like a mobile phone plan, the company you’re applying for needs to make sure you are a real person. On top of that, it would be valuable for these companies to have a way to verify if a phone number a prospective client gives them is a real and active number that can be reached in the future.

Vonage has a fantastic Phone [Number Insights API](https://developer.vonage.com/api/number-insight) that can help support these kinds of scenarios. As a developer, you might be asked to build an isolated internal microservice that handles this use case.

In this article, you’ll learn how to use the Vonage Number Insights API and .NET to build a small distributed service that can supply this kind of functionality.

## Code

If you wish to skip ahead, you can view the [code for this tutorial on GitHub.](https://github.com/nexmo-community/vonage-api-dotnet-fraud-service)

## Prerequisites

To get started, you’ll need:

* An IDE for .NET development like Visual Studio, Visual Studio Code, or JetBrains Rider
* The [latest version of .NET](https://dotnet.microsoft.com/download) installed

<sign-up></sign-up>

## Starting Your .NET Worker Service

In .NET, a worker service is akin to a background process that will typically be subscribed to a message bus/queue or poll some other service.
In this tutorial, you’ll build a microservice that accepts messages from a message queue, process them by calling the Vonage API, and then send a response message back to the queue.

Let’s create a .NET worker service by executing the following in a terminal:

`dotnet new worker -o FraudService`

Next, execute `cd ./FraudService` to navigate to the folder the `dotnet` command created for you.

You’ll need to install [Coravel](https://github.com/jamesmh/coravel) which will help with scheduling jobs in our worker service:

`dotnet add package Coravel`

You’ll also need the [Vonage C# SDK client](https://github.com/Vonage/vonage-dotnet-sdk) installed:

`dotnet add package Vonage`

Finally, delete the file `Worker.cs` from the project as you won’t be needing it.

## Building The Main Fraud Detection Logic

The small (micro) service you’ll build will simulate interacting with inputs and outputs via an event bus or queue. Exposing functionality directly via a REST API or another RPC method can lead to issues like [chatty services](https://docs.aws.amazon.com/whitepapers/latest/microservices-on-aws/chattiness.html), less resilient systems, etc.

To keep things simple, this tutorial will store messages/events using the file system.

Create a file called `MockEventBus.cs` and replace it with the following code:

```csharp

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace FraudService
{
    public class MockEventBus
    {
        public class Event
        {
            public string Data { get; set; }
        }

        public async Task SendTo(string queueName, Event @event)
        {
            await UsingStoredEvents(queueName, events =>
            {
                events.Add(@event);
            });
        }

        public async Task<List<Event>> RemoveFrom(string queueName)
        {
            var next = new List<Event>(0);

            await UsingStoredEvents(queueName, events =>
            {
                if (events.Any())
                {
                    next.AddRange(events);
                    events.Clear();
                }
            });

            return next;
        }

        private async Task UsingStoredEvents(string queueName, Action<List<Event>> action)
        {
            await using var fileRead = File.Open($"./mock_event_bus_{queueName}.json", FileMode.OpenOrCreate);
            var events = fileRead.Length > 0
                ? await JsonSerializer.DeserializeAsync<List<Event>>(fileRead)
                : new List<Event>();
            fileRead.Close();

            action(events);

            await using var fileWrite = File.Open($"./mock_event_bus_{queueName}.json", FileMode.Truncate);
            await JsonSerializer.SerializeAsync(fileWrite, events);
            fileWrite.Close();
        }
    }
}
```

This class will give us the ability to simulate sending and receiving mock distributed messages. It has two public methods: one to “send” a message to a specific queue — implemented as a file — and another to remove all messages from a given queue/file.

Next, you’ll create a file called `Constants.cs` and fill it with the following:

```csharp

namespace FraudService
{
    public class Constants
    {
        public static readonly string NumbersToValidateQueue = "phone_numbers_to_validate";
        public static readonly string ValidatedNumbersQueue = "validated_phone_numbers";
    }
}
```

These are the names of the two queues that we’ll need to send/receive our messages to.

Next, create a file `CheckPhoneNumberInvocable.cs`. This file is where the meat of our application will live. The logic for pulling messages off our queue, calling the [Vonage Number Insight API](https://developer.vonage.com/number-insight/overview), and storing the results will all be encapsulated here.

Replace the contents of `CheckPhoneNumberInvocable.cs` with the following:

```csharp

using System.Threading.Tasks;
using Coravel.Invocable;
using Vonage;
using Vonage.NumberInsights;

namespace FraudService
{
    public class CheckPhoneNumberInvocable : IInvocable
    {
        private readonly MockEventBus _bus;
        private readonly VonageClient _client;

        public CheckPhoneNumberInvocable(MockEventBus bus, VonageClient client)
        {
            _bus = bus;
            _client = client;
        }

        public async Task Invoke()
        {
            var events = await _bus.RemoveFrom(Constants.NumbersToValidateQueue);

            foreach (var @event in events)
            {
                var phoneNumber = @event.Data;

                var request = new StandardNumberInsightRequest()
                {
                    Country = "",
                    Number = phoneNumber
                };
                var response = await _client.NumberInsightClient.GetNumberInsightStandardAsync(request);

                var carrierName = response.CurrentCarrier.Name ?? "Carrier not available";
                var country = response.CountryName ?? "Country not available";

                await _bus.SendTo(Constants.ValidatedNumbersQueue, new MockEventBus.Event
                {
                    Data = $"{phoneNumber}: {country}: {carrierName}"
                });
            }
        }
    }
}
```

In this fake scenario, other services may want to know if a given phone number has a legit carrier and verify what country the number is registered in. Having this information could help to make decisions around fraudulent accounts, customers, etc.

Let's have a closer look at the code! It pulls messages/events from a queue where each message is a phone number to be verified. The results sent by the Numbers Insight API for that number are then stored in another queue.

This is common in distributed systems: a microservice will publish its final results to an asynchronous message queue. Other systems can subscribe to this queue and receive these results and do whatever they need to do.

This approach allows each service to be autonomous and resilient. For example, if a particular service goes down, it can begin processing messages placed in the queue while it was down once it's back up.
With the typical REST/RPC approach, when a service is down, it cannot receive messages or requests at all - making the asynchronous message-driven approach more resilient.

Getting back to the code, you’ll need to configure and glue the different pieces of this application together. Replace `Program.cs` with the following:

```csharp

using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Coravel;
using Microsoft.Extensions.DependencyInjection;
using Vonage;
using Vonage.Request;

namespace FraudService
{
  public class Program
    {
        public static async Task Main(string[] args)
        {
            var provider = CreateHostBuilder(args).Build();
            provider.Services.UseScheduler(scheduler =>
            {
                scheduler
                    .Schedule<CheckPhoneNumberInvocable>()
                    .EveryTenSeconds()
                    .PreventOverlapping(nameof(CheckPhoneNumberInvocable));
            });
            await ConfigureTestPhoneNumbers(provider);
            provider.Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureServices((hostContext, services) =>
                {
                    var configuration = Credentials.FromApiKeyAndSecret(
                        "your_api_key",
                        "your_api_secret"
                    );
                    var vonageClient = new VonageClient(configuration);

                    services.AddSingleton(vonageClient);
                    services.AddTransient<MockEventBus>();
                    services.AddTransient<CheckPhoneNumberInvocable>();
                    services.AddScheduler();
                });

        private static async Task ConfigureTestPhoneNumbers(IHost provider)
        {
            var bus = provider.Services.GetRequiredService<MockEventBus>();
            await bus.SendTo(Constants.NumbersToValidateQueue, new MockEventBus.Event
            {
                Data = "15555555555" // Add your phone number here!
            });
        }
    }
}
```

This tutorial uses [Coravel](https://github.com/jamesmh/coravel) to configure an easy way to run our `CheckPhoneNumberInvocable` class once every ten seconds. It simulates polling or subscribing to a message queue, as you’ll see in a minute.

## Testing Your Microservice

After you’ve replaced your API key and secret in `Program.cs`, try running the application by executing the following in a terminal:

`dotnet run`

As the program runs, you’ll see two new `.json` files generated by the application. You can check `mock_event_bus_validated_phone_numbers.json` to see the messages for all validated phone numbers.

In `Program.cs`, there’s a method called `ConfigureTestPhoneNumbers()` where you can hard-code some phone numbers to test immediately upon application startup. However, as the application is running, you can also modify `mock_event_bus_phone_numbers_to_validate.json` and add new numbers on the fly. Doing so can stimulate new messages coming in from a queue.

You might replace the contents of `mock_event_bus_phone_numbers_to_validate.json` with the following:

```json

[ { "Data": "19055555555" } ]
```

After a few seconds, take a look at `mock_event_bus_validated_phone_numbers.json` to see the results of whatever phone number you chose to verify!

## Conclusion

You’ve successfully created a .NET microservice that can verify phone numbers and send that information back to multiple consumers/services. Each consumer can make their own decision about how they want to use the results. You also understand how using an event-driven approach can keep the various parts of your system decoupled and autonomous.

The Numbers Insight’s API has many other fantastic abilities. While this tutorial used the “Standard” Numbers Insights API, there is a [more advanced feature](https://developer.vonage.com/api/number-insight?theme=dark#getNumberInsightAsync) where you can get a bunch more information about a given phone number. Try it out sometime!