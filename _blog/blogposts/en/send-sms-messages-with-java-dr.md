---
title: How to Send SMS Messages With Java
description: Send SMS messages with Java and the Vonage Java SDK. This tutorial
  uses JDK 16 and Gradle 7.1
thumbnail: /content/blog/how-to-send-sms-messages-with-java/java_sms.png
author: judy2k
published: true
published_at: 2017-05-03T13:00:27.000Z
updated_at: 2021-06-29T11:15:41.135Z
category: tutorial
tags:
  - java
  - sms-api
  - gradle
comments: true
redirect: ""
canonical: ""
outdated: false
---
> *We've built this example using JDK 16, Gradle 7.1 and the Vonage Server SDK for Java v.6.4.0*  

The [Vonage SMS API](https://developer.vonage.com/messaging/sms/overview) is a service that allows you to send and receive SMS messages anywhere in the world. Vonage provides REST APIs, but it's much easier to use the Java SDK we've written for you.

In this tutorial, we'll cover how to send SMS messages with Java! View [the source code on GitHub](https://github.com/nexmo-community/send-sms-java/blob/main/src/main/java/getstarted/SendSMS.java).

### Prerequisites

Hopefully, you already have a basic understanding of Java programming - we're not going to be doing any highly complicated programming, but it'll help you get up and running. As well as a basic understanding of Java, you'll also need the following installed on your development machine:
* [Java Development Kit (JDK)](https://www.oracle.com/java/technologies/javase-downloads.html)
* [Gradle](https://gradle.org/) for building your project

<sign-up number></sign-up>

## Using the Vonage Java SDK

First, you need to set up your Gradle project and download the Vonage Java SDK.

Create a directory to contain your project. Inside this directory, run `gradle init`. If you haven't used Gradle before, don't worry - we're not going to do anything too complicated! 
Select _1: basic_ as the type of project to generate, _1: Groovy_ as build script DSL, and name your project—or press Enter for the default option.

Next, open the `build.gradle` file and change the contents to the following:

```groovy
// We're creating a Java Application:
plugins {
    id 'application'
    id 'java'
}

// Download dependencies from Maven Central:
repositories {
    mavenCentral()
}

// Install the Vonage Java SDK
dependencies {
    implementation 'com.vonage:client:6.4.0'
}

// We'll create this class to contain our code:
application {
    mainClass = 'getstarted.SendSMS'
}
```

Now, if you open your console in the directory that contains this `build.gradle` file, you can run:

```shell
gradle build
```

This command will download the Vonage Java SDK and store it for later. If you had any source code, it would also compile that—but you haven't written any yet. Let's fix that!

Because of the `mainClass` we set in the Gradle build file, you're going to need to create a class called `SendSMS` in the package `getstarted`. In production code, you'd want the package to be something like `com.mycoolcompany.smstool`, but this isn't production code, so `getstarted` will do.

Gradle uses the same directory structure as Maven, so you need to create the following directory structure inside your project directory: `src/main/java/getstarted`.

On macOS and Linux, you can create this path by running:

```shell
mkdir -p src/main/java/getstarted
```

Inside the `getstarted` directory, create a file called `SendSMS.java`. Open it in your favourite text editor, and we'll start with some boilerplate code:

```java
package getstarted;

import com.vonage.client.VonageClient;
import com.vonage.client.sms.MessageStatus;
import com.vonage.client.sms.SmsSubmissionResponse;
import com.vonage.client.sms.messages.TextMessage;


public class SendSMS {

    public static void main(String[] args) throws Exception {
        // Our code will go here!
    }
}
```

All this does is import the necessary parts of the Vonage SDK and create a method to contain our code. It's worth running `gradle run` now, which should run your main method. It won't do anything yet, but this is where we get to the exciting bit. 

## Send SMS Messages With Java

Put the following in your `main` method:

```java
VonageClient client = VonageClient.builder()
        .apiKey(VONAGE_API_KEY)
        .apiSecret(VONAGE_API_SECRET)
        .build();
```

Fill in `VONAGE_API_KEY` and `VONAGE_API_SECRET` with the values you copied from the [Vonage API Dashboard](https://dashboard.nexmo.com/). This code creates a `VonageClient` object that can be used to send SMS messages. Now that you have a configured client object, you can send an SMS message:

```java
TextMessage message = new TextMessage(VONAGE_BRAND_NAME,
                TO_NUMBER,
                "A text message sent using the Vonage SMS API"
        );

        SmsSubmissionResponse response = client.getSmsClient().submitMessage(message);

        if (response.getMessages().get(0).getStatus() == MessageStatus.OK) {
            System.out.println("Message sent successfully. " + response.getMessages());
        } else {
            System.out.println("Message failed with error: " + response.getMessages().get(0).getErrorText());
        }
```

Again, you'll want to replace `VONAGE_BRAND_NAME` and `TO_NUMBER` with strings containing the virtual number you bought and your own mobile phone number. Make sure to provide the `TO_NUMBER` in [E.164 format](https://developer.vonage.com/voice/voice-api/guides/numbers)—for example, 447401234567.  
Once you've done that, save and run `gradle run` again. You should see something like this printed to the screen:

`Message sent successfully.[com.vonage.client.sms.SmsSubmissionResponseMessage@f0f0675[to=447401234567,id=13000001CA6CCC59,status=OK,remainingBalance=27.16903818,messagePrice=0.03330000,network=23420,errorText=<null>,clientRef=<null>]]`

... and you should receive a text message! If it didn't work, check out if something was printed after `ERR:` in the line above, and maybe wait a few more seconds for the message to appear.

> Note: In some countries (US), `VONAGE_BRAND_NAME` has to be one of your Vonage virtual numbers. In other countries (UK), you're free to pick an alphanumeric string value—for example, your brand name like AcmeInc. Read about country-specific SMS features on the [dev portal](https://developer.vonage.com/messaging/sms/guides/country-specific-features).

You've just learned how to send an SMS message with Vonage! 
<!--- You can either stop here or, for bonus points, learn how to [build a Web service around it](ADD_LINK_HERE)!-->

## References

* [Vonage SMS API Reference](https://developer.vonage.com/api/sms?theme=dark)
* [Vonage Java SDK](https://github.com/Vonage/vonage-java-sdk)
* [Country Specific SMS Features](https://developer.vonage.com/messaging/sms/guides/country-specific-features)