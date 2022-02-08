---
title: Version 4 of the Nexmo Java Client Library Is Here
description: Version 4.0.0 of the Nexmo Java Client Library brings a couple of
  backwards compatibility breaks but a whole host of shiny new features.
thumbnail: /content/blog/java-client-version-4-dr/java-version-4.png
author: cr0wst
published: true
published_at: 2018-11-16T22:33:39.000Z
updated_at: 2021-05-04T14:46:53.403Z
category: release
tags:
  - java
comments: true
redirect: ""
canonical: ""
---
Today we released version 4.0.0 of our [Nexmo Java Client Library](https://github.com/nexmo/nexmo-java). While we felt really good about our 3.x versions of the library, we realized that there are a few things holding it back from providing the ideal user experience.

A new major version means a couple of backwards compatibility breaks, but a whole host of shiny new features. I wanted to offer up some migration tips and talk about why we chose this direction.

For a full list of changes, you can find our changelog on the [release page](https://github.com/Nexmo/nexmo-java/releases/tag/v4.0.0)

## Java 7 Support

It was a difficult decision, but we decided that it was time to drop official support for Java 7. Deciding the next version of Java to target was also a challenge, but we have updated the target version to Java 8.

### Oracle Support Ending

Oracle ended public updates of Java 7 back in April of 2015. While they still offer extended support until July of 2020, they have been encouraging users to update for quite some time.

![Wikipedia Java Version Table](/content/blog/version-4-of-the-nexmo-java-client-library-is-here/wikipedia-java-versions.png "Wiki Java Version")

It is true that other JDKs are still updated for Java 7, but we believe that it is one of the limiting factors in allowing us to move forward with development. 

Recently we [Ended Support for Legacy TLS Protocols](https://www.nexmo.com/blog/2018/06/13/nexmo-protects-customers-by-ending-support-for-legacy-tls-protocols/). Additionally, [Maven Central](https://blog.sonatype.com/enhancing-ssl-security-and-http/2-support-for-central) dropped support in May of 2018. This complicates the continuous integration process and makes maintaining the library with Java 7 support extra challenging.

### Java Versions Moving Forward

We didn't take this decision lightly and, with the new releases moving to a [6 month release cadence](https://blogs.oracle.com/java-platform-group/update-and-faq-on-the-java-se-release-cadence), we don't think future releases will be this drastic. Donald Smith, from Oracle states:

> Going from Java 9->10->11 is closer to going from 8->8u20->8u40 than from 7->8->9.  It’s scary to see at first when you’re used to major releases about every three years and have a mental model of the huge impact of those major changes.  The six-month cadence is not that.

We want to be as inclusive as possible, and have added some features to the client to help with determining the best version of Java to target going forward.

## Client Instantiation

Instantiating the `NexmoClient` object no longer requires you to think about *how* to authenticate. Instead, you are now provided with a `Builder` to assist with constructing the client using various configuration options.

### Old

Here's how the `NexmoClient` used to be instantiated for use with both the SMS and Voice API:

```java
AuthMethod tokenAuth = new TokenAuthMethod(NEXMO_API_KEY, NEXMO_API_SECRET);
AuthMethod applicationAuth = new JWTAuthMethod(NEXMO_APPLICATION_ID,
        FileSystems.getDefault().getPath(NEXMO_APPLICATION_PRIVATE_KEY_PATH)
);

NexmoClient client = new NexmoClient(tokenAuth, applicationAuth);
```

This process required you to understand *how* the authentication scheme works. We also felt that using names like `TokenAuthMethod` and `JWTAuthMethod` weren't intuitive enough.

### New

With the new version, this is how you can instantiate `NexmoClient` for use with both the SMS and voice API:

```java
NexmoClient client = new NexmoClient.Builder()
        .apiKey(NEXMO_API_KEY)
        .apiSecret(NEXMO_API_SECRET)
        .applicationId(NEXMO_APPLICATION_ID)
        .privateKeyPath(NEXMO_PRIVATE_KEY_PATH)
        .build();
```

You can also provide it with the contents of your private key file, should you be loading this from another source:

```java
NexmoClient client = new NexmoClient.Builder()
        .apiKey(NEXMO_API_KEY)
        .apiSecret(NEXMO_API_SECRET)
        .applicationId(NEXMO_APPLICATION_ID)
        .privateKeyContents(NEXMO_PRIVATE_KEY_CONTENTS)
        .build();
```

As a user, you should only need to care about the credentials you have. You shouldn't have to concern yourself with which `AuthMethod` to use with your API key and secret, just provide the `Builder` with all the credentials that you have.

There are some caveats to providing things this way. If you provide an API key you must also provide either a secret or a signature secret. Failure to do so will cause the `build` method to throw a `NexmoClientCreationException`.

## The Nexmo Call Control Object

The [Nexmo Call Control Object (NCCO)](https://developer.nexmo.com/voice/voice-api/guides/ncco) serializers received a major overhaul in this update. Originally, we called our serializers NCCO classes with names like `TalkNcco`, `InputNcco`, `ConnectNcco`. However, this doesn't match the actual naming convention.

Our [NCCO Guide](https://developer.nexmo.com/voice/voice-api/guides/ncco) says

> A Nexmo Call Control Object (NCCO) is a JSON array of actions that is used to control the flow of a Voice API Call.

So, we renamed them to action classes with names like `TalkAction`, `InputAction`, and `ConnectAction`. Additionally, we provided a special collection wrapper called `Ncco` to tie them all together and handle building the JSON structure.

### Old

Here's how you might handle creating an NCCO to have a user record a message:

```java
Route answerRoute = (req, res) -> {
    String recordingUrl = String.format("%s://%s/webhooks/recordings", req.scheme(), req.host());

    TalkNcco intro = new TalkNcco("Please leave a message after the tone, then press #.");

    RecordNcco record = new RecordNcco();
    record.setEventUrl(recordingUrl);
    record.setEndOnSilence(3);
    record.setEndOnKey('#');
    record.setBeepStart(true);

    TalkNcco outro = new TalkNcco("Thank you for your message. Goodbye");

    Ncco[] nccos = new Ncco[]{intro, record, outro};

    res.type("application/json");

    return new ObjectMapper().writer().writeValueAsString(nccos);
};
```

### New

Now, you can do something like this:

```java
Route answerRoute = (req, res) -> {
    String recordingUrl = String.format("%s://%s/webhooks/recordings", req.scheme(), req.host());

    TalkAction intro = new TalkAction.Builder("Please leave a message after the tone, then press #.").build();

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

Or, you could build the objects and wrap them in an `Ncco` without creating the additional local variables:

```java
return new Ncco(
        new TalkAction.Builder("Please leave a message after the tone, then press #.").build(),
        new RecordAction.Builder()
                .eventUrl(recordingUrl)
                .endOnSilence(3)
                .endOnKey('#')
                .beepStart(true)
                .build(),
        new TalkAction.Builder("Thank you for your message. Goodbye").build()
).toJson();
```

The goal with this change was to create a more intuitive experience for creating objects with lots of properties. 

For some items, like `TalkAction` with only a `text` property, it seems like more code. However, the benefit is fully realized when your actions become a little more complex.

We want to look into other ways we can assist with this, perhaps by using factory methods to provide some easy shortcuts.

## Number Insight Requests

Our `InsightClient` had quite a few methods on it with various parameter combinations. As the number of options for number insight grows, the parameter list is only going to grow with it.

There's a common trend in most of these updates and, once again, we went with the builder pattern.

### Old

To perform standard number insight request with Caller ID (CNAM) information you would do something like this:

```java
StandardInsightResponse response = client.getInsightClient()
        .getStandardNumberInsight(INSIGHT_NUMBER, null, true);
```

Notice that you have to use `null` in the second parameter in order to get access to the `cnam` parameter. This feels wrong.

### New

Now, you can do this:

```java
StandardInsightRequest request = new StandardInsightRequest.Builder(INSIGHT_NUMBER)
        .cnam(true)
        .build();

StandardInsightResponse response = client.getInsightClient()
        .getStandardNumberInsight(request);
```

We didn't get rid of the existing method, but we did decide to deprecate it in favor of using the request builders with removal in the next major version.

I talked about how the builder pattern can increase the verbosity of code. So, for the number insight request objects, we have also included some static factory methods for common use cases.

While you can build request objects like this:

```java
AdvancedInsightRequest request = new AdvancedInsightRequest.Builder(INSIGHT_NUMBER).build();
```

You can also use a provided static factory method like this:

```java
AdvancedInsightRequest request = AdvancedInsightRequest.withNumber(INSIGHT_NUMBER);
```

We want to play around with these factory methods a bit more, especially for our new action classes.

## Scope Limiting

The standard workflow in the 3.x versions has always been to go through `NexmoClient` to get access to other clients that give access to the API. This is still the case. However, most of our `Endpoint` and `Method` classes were declared public. This has made providing updates challenging, because we don't want to break the public interface we've created as it requires a major version update.

As a reminder, you should always use `NexmoClient` to obtain instances of other clients and access the API:

```java
NexmoClient client = new NexmoClient.Builder()
        .apiKey(NEXMO_API_KEY)
        .apiSecret(NEXMO_API_SECRET)
        .build();

SmsClient smsClient = client.getSmsClient();

TextMessage message = new TextMessage("Acme Inc", TO_NUMBER, "Hello World!");

SmsSubmissionResponse response = smsClient.submitMessage(message);
```

There shouldn't be any need to instantiate a new `Endpoint` or `Method` class, as these are used internally and are subject to change.

We've updated the scope of most internal classes to the package default scope. While this doesn't provide true encapsulation, we're doing this to discourage any use of these classes directly so we can better update them. This required some package changes as well, you may notice that some packages have been removed or renamed.

## Conclusion

First off, sorry we broke things! But we hope that these changes can put us in a better position to provide updates in the future.

If you have any issues in the migration process, or notice any oddities with the version 4 library, don't hesitate to [Submit an Issue](https://github.com/Nexmo/nexmo-java/issues) and let us know!

Don't forget to check out our updated building blocks on [Nexmo Developer](https://developer.nexmo.com/).