---
title: Full Voice API Support Coming in Nexmo Java Client v2.0
description: Announcing the snapshot release of v2.0 of the Nexmo Java client
  library with full Voice API support available via Gradle or Maven.
thumbnail: /content/blog/full-voice-api-support-coming-nexmo-java-client-v2-0-dr/Java-Code-Sample.png
author: chrisguzman
published: true
published_at: 2017-02-06T18:17:06.000Z
updated_at: 2021-05-17T13:43:19.398Z
category: tutorial
tags:
  - java
  - voice-api
comments: true
redirect: ""
canonical: ""
---
We’re very excited to announce that the *first* snapshot release of v2.0 of the [Nexmo Java client library](https://github.com/nexmo/nexmo-java) is now available. We're publishing this now because we would like to start capturing your feedback, but it’s important to note that this is a SNAPSHOT release. There are some significant code changes coming soon.

This release adds coverage for the Nexmo [Voice API](https://docs.nexmo.com/voice/voice-api). Under the hood, we’ve added automated testing and are enforcing code quality with tools like [Codecov](https://codecov.io/) and [Codacy](https://www.codacy.com/). Additionally, we’ve published this library to the Maven Central snapshot repo and now you can install this library with Gradle or Maven!

The library already works with most of the [Verification API](https://docs.nexmo.com/verify/api-reference) and some of the [SMS API](https://docs.nexmo.com/messaging/sms-api). As we continue to work on the Nexmo Java client we’ll be sure to add more functionality. In the coming weeks and months, you should expect more frequent releases and additional functionality.

It’s also great timing because [Mark (@judy2k)](https://twitter.com/judy2k) and I are headed off to [Jfokus](https://www.jfokus.se) where Nexmo is proud to be a sponsor. You can find us at the Nexmo booth chatting with attendees about the newest version of the library and capturing feedback.

## We’d Love Your Feedback

While the current beta covers only a few of the Nexmo APIs, it does cover all of those concepts and we really want to know what you think about them. Please [create an issue](https://github.com/Nexmo/nexmo-java/issues/new?labels=Question) if you have any thoughts or questions.

Please play around with the snapshot and let us know what you think. You can contact us on [Twitter](https://twitter.com/nexmo) or join our [community slack](https://nexmo-community-invite.herokuapp.com/)

If you’re at **Jfokus**, please stop by our booth at **stand #23**. We’ll be giving out swag, Nexmo credit, and an Amazon Echo Dot for the best piece of feedback we receive about the new release.

## Include nexmo-java in Your Project
To install the Java client library using Gradle, add the following to `build.gradle`:

```groovy
compile 'com.nexmo:client:2.0.0-SNAPSHOT'
```

Alternatively, clone the repo and build the JAR yourself:

```bash
git clone git@github.com:nexmo/nexmo-java.git
cd nexmo-java
gradle build
```

<sign-up number></sign-up>

## What Can I Do with the Nexmo Java Client Library?

Like many client libraries that are simple wrappers around an HTTP client, you can pass the client an array of values that match the API’s expected parameters.

Here’s how to initiate an outbound call, which then reads the user [a message](https://nexmo-community.github.io/ncco-examples/first_call_talk.json):

```java
import java.nio.file.Paths;

import com.nexmo.client.auth.JWTAuthMethod;
import com.nexmo.client.voice.NexmoClient;
import com.nexmo.client.voice.Call;

JWTAuthMethod auth = new JWTAuthMethod(application_id, Paths.get("application_key.pem"));
NexmoClient client = new NexmoClient(auth);
Call call = new Call(to, from,
"https://nexmo-community.github.io/ncco-examples/first_call_talk.json");
CallEvent event = client.getVoiceClient().createCall(call);
```

After the call is answered, you can get more information about it -- including
the amount it cost -- with:

```java
CallRecord info = client.getVoiceClient().getCallDetails(event.getUuid());
System.out.println("This cost: " + info.getPrice() + " EUR");
```

You can modify an existing call in progress, for example by streaming an audio file to an active call:

```java
StreamResponse startStreamResponse = client.getVoiceClient().startStream(event.getUuid(), "https://nexmo-community.github.io/ncco-examples/assets/voice_api_audio_streaming.mp3");
System.out.println("Success! " + startStreamResponse.getMessage());
```

For more examples, please check out the [README](https://github.com/Nexmo/nexmo-java/blob/master/README.md)

## Jfokus

If you’re at Jfokus, swing by our booth and say hi! [Mark (@judy2k)](https://twitter.com/judy2k) and [I (@speaktochris)](https://twitter.com/speaktochris) would be happy to chat. You might even get some swag :)