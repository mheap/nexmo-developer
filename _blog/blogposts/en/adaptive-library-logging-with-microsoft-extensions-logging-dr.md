---
title: Adaptive Library Logging with Microsoft.Extensions.Logging
description: In this post we demonstrate how to add extensible logging to any
  .NET app or framework using Microsoft.Extensions.Logging
thumbnail: /content/blog/adaptive-library-logging-with-microsoft-extensions-logging-dr/E_Love-the-Log_1200x600.png
author: stevelorello
published: true
published_at: 2020-02-10T13:47:01.000Z
updated_at: 2021-04-28T12:50:29.759Z
category: tutorial
tags:
  - dotnet
  - logging
comments: true
redirect: ""
canonical: ""
---
## How I Learned to Stop Worrying and Love to Log

In my career, I've worked on a few different medium to large scale .NET projects. With each project I saw a different type of logger, and typically all of them used more than one logger!

Usually, the story goes something like this: "In the early days we couldn't decide which logger we wanted to use, so we built our own. Then we realized the way we'd implemented the logging was not the most efficient, so we switched over to X logger as the app scaled. We didn't want to go back and remove the old logger because that would involve us touching every file in our solution, so we just removed it from the places where the old logger was causing problems, and from now on we're just going to be using X logger for everything."

As I said, this is a surprisingly common problem—and one we can sidestep by abstracting the logger from the logging.

## Logging In the Nexmo .NET Library

Recently I've been taking a look at Nexmo's [.NET Server SDK](https://github.com/Nexmo/nexmo-dotnet) and have been cleaning some things up. Whilst doing this I noticed is that our logging framework [LibLog](https://github.com/damianh/LibLog) has been deprecated.

This tool was great, as it abstracted the logger from the operation of logging. It allowed anyone developing against our SDK to bring their own logger. So long as your logger was supported, you could have the SDK's logger piggyback on your logger of choice without any intervention (which realistically could be a pro or con depending on how you look at it).

Because of LibLog's deprecation, I was forced to look elsewhere for a logging tool to meet our needs. Fortunately, I didn't need to look far.

## Moving Forward With Microsoft.Extensions.Logging

The (relatively) new [Microsoft.Extensions.Logging](https://www.nuget.org/packages/Microsoft.Extensions.Logging/) package hit the nail on the head with functionality. With the extension package, you can simply install the NuGet package, along with whatever logging framework you've chosen to use, set up a factory, and create the logger.

This suits our use case as we don't necessarily want our logs to automatically piggyback onto and interleave into our users' logs—and at the same time we don't want to dictate to our users exactly where, how, and with what framework the logs will be captured.

So now with our next major version release, 5.0.0, you will be able to activate whatever level or category you want within the SDK dynamically by simply swapping out the Logger Factory in the SDK.

## Building Loggers with Microsoft.Extensions.Logging

### Build the Log Provider

Two components underpin Microsoft.Extensions.Logging: ILoggerFactory and ILogger. The factory generates the loggers and the logger does the logging.

These two components are used in the LogProvider class to allow us to create a fully dynamic, extensible logger for the library, allowing the developer to bring their own logger.

```csharp
public static class LogProvider
{
    private static IDictionary<string, ILogger> _loggers = new Dictionary<string, ILogger>();
    private static ILoggerFactory _loggerFactory = new LoggerFactory();

    public static void SetLogFactory(ILoggerFactory factory)
    {
        _loggerFactory?.Dispose();
        _loggerFactory = factory;
        _loggers.Clear();
    }

    public static ILogger GetLogger(string category)
    {
        if (!_loggers.ContainsKey(category))
        {
            _loggers[category] = _loggerFactory?.CreateLogger(category)?? NullLogger.Instance;
        }
        return _loggers[category];
    }
}
```

In our model, we create a static class called LogProvider with two fields: _loggers, a dictionary containing the logger for each category, and _loggerFactory, which builds the loggers.

There are also two methods: SetLogFactory, which disposes of the old LogFactory and sets the log factory to the new log factory passed in, and GetLogger, which checks the _loggers to see if that category's logger has been created, and creates one if it hasn't.

### Using the Log Provider

Now on the onset of any method that we want to log from we simply have to call GetLogger with the appropriate category:

```csharp
var logger = Api.Logger.LogProvider.GetLogger(LOGGER_CATEGORY);
```

### Logging

From here we simply need to use the logger as any other logger we've seen before. For example:

```csharp
logger.LogInformation("Available authentication: {0}", string.Join(",", authCapabilities));
```

This will log as information the available authentication capabilities in whatever format you've provided to your logger.

## Configuring adaptive loggers

Now that we've covered creating and utilizing the loggers, let's look at actually configuring them to do what we'd like.

### Select your log provider

One of the cool things about Microsoft.Extensions.Logging is that it's agonistic to the log provider that you use. So long as the log provider implements the `ILogProvider` interface it can be whatever it likes. And from the perspective of the developer trying to leverage it, it's even simpler. Most of the major third party log providers you're likely to use (e.g. Log4Net, Serilog, NLog, etc.) have Extension packages that make adding the desired logger simple.

### Logging to Console with Serilog

To demonstrate how we can build these loggers, let's take the example of logging out the Console with Serilog. To do this you will create a need the following NuGet packages:

* Microsoft.Extensions.Logging
* Serilog.Extensions.Logging
* Serilog.Sinks.Console

You will then do the following:

* Create a new LoggerFactory which will be what we use to create
* Create a new LoggerConfiguration which will set the Serilog configuration
* Call the AddSerilog function on the factory
* Create a logger of category 'test'
* Log away

Chained together this looks like:

```csharp
var log = new LoggerConfiguration()
    .MinimumLevel.Debug()
    .WriteTo.Console(outputTemplate: "{Timestamp:HH:mm} [{Level}] ({Name:l}) {Message}\n")
    .CreateLogger();
var factory = new LoggerFactory();
factory.AddSerilog(log);
ILogger logger = factory.CreateLogger("test");
logger.LogInformation("Hello world");
```

Very clean and simple.

Now to interact with the Nexmo SDK, instead of creating a logger after configuring the factory, simply set the LogFactory in the Log Provider to the log factory you created and added Serilog to, and you'll see the logging come through from the SDK.

```csharp
var log = new LoggerConfiguration()
    .MinimumLevel.Debug()
    .WriteTo.Console(outputTemplate: "{Timestamp:HH:mm} [{Level}] ({Name:l}) {Message}\n")
    .CreateLogger();
var factory = new LoggerFactory();
factory.AddSerilog(log);
LogProvider.SetLogFactory(factory);
```

Et Voila—our own highly configurable library logger.

## Benefits

Microsoft.Extensions.Logging allows us to avoid the nightmare scenario of starting a project using one logger and needing to, for whatever reason, switch to another.

If you want to use your logger you're still free to, even while using the Logging Extensions. All you need to do is implement the ILogProvider interface with whatever logger you want to use and add it to the factory.
