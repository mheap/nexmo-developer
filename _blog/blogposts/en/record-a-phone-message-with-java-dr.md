---
title: Record a Phone Message with Java
description: Sometimes you're not around to answer the phone when it rings.
  Learn how to enable your callers to record a phone message utilizing Java and
  Vonage.
thumbnail: /content/blog/record-a-phone-message-with-java-dr/ord-a-Phone-Message-with-Java.png
author: cr0wst
published: true
published_at: 2019-02-19T19:15:41.000Z
updated_at: 2021-05-12T03:08:33.113Z
category: tutorial
tags:
  - java
  - voice-api
comments: true
redirect: ""
canonical: ""
---
## Introduction

In a previous tutorial, we showed you how to [Receive a Phone Call with Java](https://learn.vonage.com/admin/#/collections/blog/entries/record-a-phone-message-with-java-dr) and respond using text to speech. We can also allow users to leave a message and then retrieve that recorded message.

## Prerequisites

<sign-up number></sign-up>

You will be using [Gradle](https://gradle.org) to manage your dependencies and run your application. Additionally, you'll need to make sure you have a copy of the JDK installed. I will be using JDK 8 in this tutorial.

Finally, you'll need the [Vonage CLI](https://github.com/Vonage/vonage-cli) installed. You'll use it to purchase a phone number and configure your Vonage account to point at your new application.

## Record a Phone Message with Java

This tutorial will walk you through the following steps:

1. Using Gradle to setup a new Java project.
2. Using the [Spark](http://sparkjava.com) framework for controlling the call.
3. Purchasing a number and configuring your Vonage account to use that number with your application.

### Using Gradle to Setup a New Java Project

You will use Gradle to manage your dependencies and to create and run your Java application.

The `gradle init --type=java-application` command will create all of the folders you will need as well as a sample class where you will be writing your code.

From the command line, create a new Java project with the following commands:

```bash
mkdir record-a-message
cd record-a-message
gradle init --type=java-application
```

### Using the Spark Framework for Controlling the Call

You will use the Spark framework to receive a HTTP call made by Vonage when your number receives a call, and to receive the request that Vonage sends after the message has been recorded.

#### Adding the Dependencies

Add the following to the `dependencies` block in your `build.gradle` file:

```groovy
// Spark Framework
implementation 'com.vonage:client:[6.1.0,7.0.0)'
//Vonage Client
implementation "com.sparkjava:spark-core:2.6.0"
```

Your `dependencies` block should look like this:

```groovy
dependencies {
    testImplementation 'junit:junit:4.12'

    implementation 'com.vonage:client:[6.1.0,7.0.0)'
    implementation "com.sparkjava:spark-core:2.6.0"
}
```

Gradle will create the `App` class in the `src/main/java` folder. Inside of this class is a `getGreeting` and a `main` method. You won't need the `getGreeting` method, so feel free to remove it.

#### Define the Answer Route

First, you will define the route that will be used for answering the call. When a call is received, Vonage will send a request to a pre-defined webhook URL. It expects to receive a [Vonage Call Control Object (NCCO)](https://developer.vonage.com/voice/voice-api/ncco-reference) containing a list of actions to execute.

When the phone call is answered, your application will instruct Vonage to execute three actions:

1. A `talk` action to greet the caller and instruct them on how to leave a message.
2. A `record` action which will instruct the Voice API to start recording.
3. A `talk` action to thank them for leaving a message.

This is the resulting NCCO that your application will create:

```json
[
  {
    "text": "Please leave a message after the tone, then press #. We will get back to you as soon as we can.",
    "action": "talk"
  },
  {
    "endOnSilence": 3,
    "endOnKey": "#",
    "beepStart": true,
    "eventUrl": [
      "http://your-web-address/webhooks/recordings"
    ],
    "action": "record"
  },
  {
    "text": "Thank you for your message. Goodbye",
    "action": "talk"
  }
]
```

Add the following to the `main` method of the `App` class, making sure to resolve all imports:

```java
/*
* Route to answer and connect incoming calls with recording.
*/
Route answerRoute = (req, res) -> {
    String recordingUrl = String.format("%s://%s/webhooks/recordings", req.scheme(), req.host());

    TalkAction intro = new TalkAction.Builder("Please leave a message after the tone, then press #. We will get back to you as soon as we can.")
            .build();

    RecordAction record = new RecordAction.Builder()
            .eventUrl(recordingUrl)
            .endOnSilence(3)
            .endOnKey('#')
            .beepStart(true)
            .build();

    TalkAction outro = new TalkAction.Builder("Thank you for your message. Goodbye").build();

    res.type("application/json");

    return new Ncco(intro, record, outro).toJson();
};
```

The `record` action has a few different properties. For example, you can define the event url that will be sent a request when the recording is finished, end the recording on a specific key press, and play a beep at the start of the recording.

#### Define the Recordings Route

The `record` action has a property called `eventUrl` which is used to communicate when the recording is finished. The following is an example of the return parameters sent to the event url:

```json
{
  "start_time": "2020-01-01T12:00:00Z",
  "recording_url": "https://api.nexmo.com/media/download?id=aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "size": 12345,
  "recording_uuid": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "end_time": "2020-01-01T12:01:00Z",
  "conversation_uuid": "bbbbbbbb-cccc-dddd-eeee-0123456789ab",
  "timestamp": "2020-01-01T14:00:00.000Z"
}
```

The [Vonage Java Client](https://github.com/Vonage/vonage-java-sdk) has a class called `RecordEvent` which can be used to deserialize the JSON sent to `eventUrl`. For now, you're going to output the `recording_url` to the console.

Add the following to the `main` method of the `App` class, resolving any imports:

```java
/*
* Route which prints out the recording URL it is given to stdout.
*/
Route recordingRoute = (req, res) -> {
    RecordEvent recordEvent = RecordEvent.fromJson(req.body());
    System.out.println(recordEvent.getUrl());

    res.status(204);
    return "";
};
```

#### Register the Routes

Up until this point you have defined two routes:

* The first route will respond to Vonage with an NCCO when Vonage answers the incoming call.
* The second route will log the recording URL when Vonage finishes recording the message.

In order to use these routes, we need to configure Spark. Your application will listen on port `3000`, and the routes will be configured on `/webhooks/answer` and `/webhooks/recordings`.

Add the following to the `main` method of the `App` class:

```java
Spark.port(3000);
Spark.get("/webhooks/answer", answerRoute);
Spark.post("/webhooks/recordings", recordingRoute);
```

### Purchasing a Number

You will need a Vonage number in order to receive phone calls. If you do not have a number you can use the Vonage CLI to purchase one

First search for a available number with `Voice` feature

```bash
vonage numbers:search --features=VOICE US
```

Once you select a number you like you can buy the number with:
```bash
vonage numbers:buy 1201XXXXXXX US
```

Take note of the number that you purchase. You will need this number to link your application and for testing.

### Exposing Your Application

In order to send an HTTP request to your application, Vonage needs to know the URL that your application is running on.

Instead of configuring your local network or hosting your application on an external service, you can use [ngrok](https://ngrok.com/) to safely expose your application to the internet.

Download ngrok and run the following command:

```bash
ngrok http 3000
```

Take note of the forwarding address as you will need it when you configure your account. In the following picture, the forwarding address is `http://99cad2de.ngrok.io`.

![Screenshot of ngrok running in terminal with forwarding address http://99cad2de.ngrok.io](/content/blog/record-a-phone-message-with-java/ngrok.png "Screenshot of ngrok running in terminal with forwarding address http://99cad2de.ngrok.io")

### Configure Your Vonage Account

If you do not have an application you can use the Vonage CLI to create one using your ngrok forwarding address:

```bash
vonage apps:create "Record Message Demo" --voice_answer_url=http://your-ngrok-forwarding-address/webhooks/answer --voice_event_url=http://your-ngrok-forwarding-address/webhooks/answer
```

You can also pass your own public key with `--public_keyfile`. More instruction [here](https://developer.vonage.com/application/vonage-cli#creating-an-application-with-your-own-public-private-key-pair)

After running this command, you will be shown an an application id. For example: `notreal-1111-2222-3333-appid`. You will need this application id to link your phone number to the application.

You can use the Vonage CLI to link your phone number and application:

```bash
vonage apps:link your-application-id --number=your-vonage-phone-number
```

This command instructs Vonage to create a new application on your account. The application will send a request to the first URL when it receives a phone call. The application will send requests to the second URL when the call status changes.

### Test Your Application

Start your application with the `gradle run` command inside of your `record-a-message` directory.

Make a call to your Vonage number and test out your application. You will hear the message, "Please leave a message after the tone, then press #. We will get back to you as soon as we can." Once you hear the beep, leave a message and then press `#`. You should then hear "Thank you for your message. Goodbye." and the recording URL will be displayed on your console.

## Conclusion

In a few lines of code you have created an application that can receive a phone call, record a message, and then display the URL to that recording.

Check out our documentation on [Vonage Developer](https://developer.vonage.com) where you can learn more about [call flow](https://developer.vonage.com/voice/voice-api/guides/call-flow) or [Vonage Call Control Objects](https://developer.vonage.com/voice/voice-api/ncco-reference). See our [Vonage Quickstart Examples for Java](https://github.com/Vonage/vonage-java-code-snippets) for full code examples on [this tutorial](https://github.com/Vonage/vonage-java-code-snippets/blob/master/src/main/java/com/vonage/quickstart/voice/RecordMessage.java) and more.