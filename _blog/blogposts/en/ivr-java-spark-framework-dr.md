---
title: How to Build a Simple IVR with Java and the Spark Framework
description: Interactive Voice Response (IVR) is a key part of many customer
  facing phone systems. This tutorial shows you how to build one using Java and
  Spark.
thumbnail: /content/blog/ivr-java-spark-framework-dr/ivr-java-feature-image.png
author: judy2k
published: true
published_at: 2019-07-02T07:01:19.000Z
updated_at: 2021-04-26T14:55:49.261Z
category: tutorial
tags:
  - java
  - voice-api
comments: true
redirect: ""
canonical: ""
---
An IVR is the technical name given to an automated phone call where you enter digits on your phone keypad and the call responds appropriately - by reading you information, or connecting you to a number, or whatever. The great thing is that you can build them with Nexmo Voice!

In this tutorial, you'll build a small microservice to host a basic IVR. I'll run you through everything you need to know to set up a Spark service that can receive inbound calls and capture user input entered via the keypad.

The idea is to build a really small IVR that allows the user to input a DTMF code. In _this_ case, the call will simply read back to
you the number you entered.

I find it's quite helpful to have either a script or a flowchart on-hand when building an IVR. Here's the script for your service:

```text
[Caller dials Nexmo number]

IVR: Welcome to my Nexmo IVR! Please enter a digit.

[Caller enters '5']

IVR: You entered 5. Thank you for calling!

[IVR hangs up]
```

The code for this tutorial can be found on [GitHub][repo].

## Requirements

Before I get started, you should have the following set up:


* The [Nexmo CLI](https://developer.nexmo.com/tools). (You can get by without this by using the Nexmo Dashboard, but it makes life _much_ easier!)
* A [JDK](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) installed (I built this with JDK 8).
* [Maven](https://maven.apache.org/index.html) to build your Java code.
* [Ngrok](https://ngrok.com/) so Nexmo can reach the service running on your development machine

<sign-up number></sign-up>



## Getting Started

First, create should bootstrap a Maven project using the following command:

```bash
mvn archetype:generate -DgroupId=com.nexmo.xwithy -DartifactId=ivr-demo -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4
```

Running this command will create a Maven project file, and a source file in the correct place - it looks a bit like this:

```text
ivr-demo
├───pom.xml
└───src
    └───main
        └───java
            └───com
                └───nexmo
                    └───xwithy
                        └───App.java
```

Open up `pom.xml` in your favourite code editor (I'm using [VSCode][vscode]) and
first change the target version of Java from 1.7 to 1.8:

```xml
<maven.compiler.source>1.8</maven.compiler.source>
<maven.compiler.target>1.8</maven.compiler.target>
```

Then add the Nexmo and Spark dependencies to the `<dependencies`> section:

```xml
<dependency>
    <groupId>com.nexmo</groupId>
    <artifactId>client</artifactId>
    <version>4.4.0</version>
</dependency>

<dependency>
    <groupId>com.sparkjava</groupId>
    <artifactId>spark-core</artifactId>
    <version>2.7.2</version>
</dependency>

<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>slf4j-simple</artifactId>
    <version>1.7.21</version>
</dependency>
```

Now I recommend you compile the project, just to download the dependencies and make sure that everything in your project is okay:

```bash
mvn compile
```

You should see a lot of output as Maven downloads everything it needs, and then the message `BUILD SUCCESS`. If you don't, check your XML file to make sure that you entered the configuration above correctly and in the right place.

## Let's Take Phone Calls

I'm going to explain how to build up the code step-by-step, but it may be
helpful to take a look at the end result, which you can find [on GitHub](https://github.com/nexmo-community/java-ivr-demo/blob/master/src/main/java/com/nexmo/xwithy/App.java). It's all in one class, and I've added lots of comments, so it will hopefully not be too difficult to follow.

Almost everything goes inside our `main` method, which is executed when we run the `App` class. Spark may work a little differently to what you're used to. You register the way you would like Spark to behave by calling static methods, and then Spark will host your web application until you tell it to stop!

Put the following line into your `main` method:

```java
port(4567);
```

The line above tells Spark which TCP port you would like to host your service on. I've picked 4567. You can choose a different number, but make sure you take a note of the number you choose - you'll need it later! (Pick a number above 1024 - this may save you [some trouble](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers#cite_note-man-5-services-die.net-4).)

The next thing you should do is to register an HTTP endpoint for Nexmo to call. This will be hosted at `/inbound` and will be called by Nexmo when someone calls your Nexmo Virtual Number. Put the following code _inside_ your `main` method, after the `port` call:

```java
post("/inbound", (req, res) -> {
    res.type("application/json");
    return new Ncco(
        TalkAction.builder("Welcome to my Nexmo IVR!").build()
    ).toJson();
});
```

When Nexmo calls this number, your application should return a JSON response that looks like this:

```json
[
  {
    "text": "Welcome to my Nexmo IVR!",
    "action": "talk"
  }
]
```

This will tell Nexmo to answer the call, and read them a friendly message. You can test this now, by compiling and running the following from your command prompt:

```bash
$ mvn compile
$ mvn exec:java -Dexec.mainClass="com.nexmo.xwithy.App"
```

Spark will print out some log messages, and when it's finished, you can test it using `curl` on the command-line, like so:

```bash
$ curl -X POST http://localhost:4567/inbound
[{"text":"Welcome to my Nexmo IVR!","action":"talk"}]
```

The curl command above makes an HTTP POST request to your server and prints out the response. If you're not so comfortable on the command-line, or you just prefer a visual application, you can use [Postman](https://www.getpostman.com/downloads/) to do the same thing.

You can stop the service at any time by entering `Ctrl-C`. You'll need to do this, and recompile and re-run each time you change your source code and want to test your service.

Now you hopefully have an application which can handle inbound Nexmo Voice calls. It's time to connect a Nexmo phone number to your application.

## Connect Nexmo To Your Service

Do you remember the [Requirements](#requirements) section above, where I said you'd need Ngrok installed? Fortunately, my colleague [Aaron](https://twitter.com/aaronbassett) has written a great [guide to using Ngrok & Nexmo](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/). You should read it! You can get Ngrok running by opening up a console tab (you need to run it at the same time as your Java service) and running the following command:

```bash
$ ngrok http 4567

...
Web Interface                 http://127.0.0.1:4040
Forwarding                    http://r6nd0m.ngrok.io -> http://localhost:4567
Forwarding                    https://r6nd0m.ngrok.io -> http://localhost:4567
```

You'll notice in the output that there are two lines called 'Forwarding'; one has an HTTP URL, and the other is HTTPS. Take a note of the HTTPS URL - you'll need it in a minute. The other thing to note is the 'Web Interface' line. I recommend you open up that URL in your browser right now - because you're about to check that Ngrok is connected to your Java IVR service.

Using `curl` (or Postman), run a similar request to the one you made above, but this time use the Ngrok URL you've just been given, with `/inbound` added to the end of it. Mine looks like this:

```bash
$ curl -X POST https://r6nd0m.ngrok.io/inbound
[{"text":"Welcome to my Nexmo IVR!","action":"talk"}]
```

You should see the same output as before. This means Nexmo will be able to reach your service (while both Ngrok _and_ your service are still running).

Hopefully you have a Nexmo account, and the Nexmo CLI tool set up. If not, now's the time! When you're ready ...

## Buy a Nexmo Number

You can start renting a Nexmo number by running the following `nexmo` command on your command-line:

```bash
nexmo number:buy  --country_code US
```

If you like the number it's selected for you, type 'confirm' and hit Enter. If you prefer to choose a number from a list, I recommend use the [Nexmo Dashboard](https://dashboard.nexmo.com/buy-numbers). Take a note of the number.

## Create a Nexmo Voice Application

Now you need to create a Nexmo Voice application, which groups together one or more Nexmo numbers with some webhook configuration. Remember to change the Ngrok host name to the one you were given above!

```bash
nexmo app:create --keyfile private.key "My IVR Demo" --answer_method POST --event_method POST https://r6nd0m.ngrok.io/inbound https://r6nd0m.ngrok.io/event
```

The command above sets up a Nexmo application which knows how to call your service when an inbound call is received. You've also saved the private key to a local file `private.key`. You won't be using it in this tutorial, but it may be useful later on as you add more functionality to your service.

Take a note of your application ID. You'll need it next.

## Link Your Nexmo Number

Using the phone number and the application ID you were given above, run the following command:

```bash
nexmo link:app NEXMO_NUMBER APPLICATION_ID
```

## Testing Your Service

Now, if you call the Nexmo number from your cellphone, Nexmo should pick up, and you should hear the message "Welcome to my Nexmo IVR!" and then the call will hang up.

If this doesn't work, check the Ngrok console in your browser at http://localhost:4040/ and make sure that the call was received by Ngrok and successfully passed through to the Java service running on your development machine.

## Make it an IVR

Your IVR isn't really very useful yet! I'll show you how to allow the user to enter input from their keypad (this is called a DTMF, which stands for Dual Tone Modulated Frequency, but that's not really important).

## Ask for Input

First, go back to the `get` call you've written, and add a second parameter to the `Ncco` constructor call, so it looks like this:

```java
return new Ncco(
    TalkAction.builder("Welcome to my Nexmo IVR! Please enter a digit.")
            .build(),
    InputAction.builder()
            .maxDigits(1)
            .timeOut(5)
            .eventUrl(pathToUrl(req, "/input"))
            .build()
).toJson();
```

This InputAction instructs Nexmo to wait for 5 seconds for the user to enter 1 digit on their keypad. When the digit is entered, Nexmo will make a call to your server at `/input` with the details of the DTMF code that was entered by the user. You'll write the handler for `/input` in a moment.

I've also modified the TalkAction call, so that we've set `bargeIn` to true. This means a listener in a hurry doesn't need to wait for the message to complete before entering the DTMF code.

The other thing to note is the `pathToUrl` method that's being used to generate an absolute URL to your service. This is a 10-line utility method I've written. Paste it into your `App` class from the [code on GitHub](https://github.com/nexmo-community/java-ivr-demo/blob/master/src/main/java/com/nexmo/xwithy/App.java#L20-L30). I won't explain how it works here, because it's not really what this tutorial is about!

## Handle the Input

Now that you've instructed Nexmo to call `/input` when the user enters a DTMF code, you need to handle that call. Enter the following code into the end of your `main` method:

```java
post("/input", (req, res) -> {
    InputEvent input = InputEvent.fromJson(req.body());

    res.type("application/json");
    String message = "You entered " + input.getDtmf();
    return new Ncco(TalkAction.builder(message).build()).toJson();
});
```

The code above is very similar to your existing `/inbound` handler, but in this case it parses the received JSON into an InputEvent in the request, extracts the DTMF code from that. It then responds to the user by reading out a message telling them the code that they entered.

Test your application by calling your Nexmo number and entering a code on the keypad when asked!

## Conclusion

This is a very simple example of responding to a DTMF code, but you can extend it to suit your application. Maybe you could look up a record in a database with an ID entered by the user, or you could build a switchboard to forward to someone in your organisation. There are lots of possibilities!

For further information check out our award-winning documentation at [Nexmo Developer](https://developer.nexmo.com/voice/).

If you're building a larger Spark service, I wouldn't recommend putting all your code in a single `main` method! Fortunately, the Spark team have written a [Blog post][spark-recommended-structure] describing best-practice for larger applications.

If you have any feedback, or would like help with this tutorial, I'm [@judy2k](https://twitter.com/judy2k) on Twitter - send me a DM. Alternatively, you can email our Developer Relations team at [devrel@nexmo.com](mailto:devrel@nexmo.com), or join the [Nexmo community Slack](https://developer.nexmo.com/community/slack).

[vscode]: https://code.visualstudio.com/
[repo]: https://github.com/nexmo-community/java-ivr-demo
[spark-recommended-structure]: http://sparkjava.com/tutorials/application-structure