---
title: Receive a Phone Call with Voice API and Swift
description: Receive inbound calls and speak a message to the caller using
  Nexmo's Voice API and Vapor, the Swift web framework, on macOS or Ubuntu.
thumbnail: /content/blog/receive-call-swift-dr/receive-call-swift.jpg
author: paul-ardeleanu
published: true
published_at: 2019-02-07T11:55:47.000Z
updated_at: 2021-05-12T02:53:09.779Z
category: tutorial
tags:
  - voice-api
comments: true
redirect: ""
canonical: ""
---
In this tutorial you will create a Swift application that can receive phone calls using the [Vapor](https://vapor.codes/) web framework and the [Nexmo Voice API](https://developer.nexmo.com/voice/voice-api/overview). You can follow this tutorial on both MacOS or Ubuntu.

For the complete solution, please check out this [Github repo](https://github.com/nexmo-community/swift-receive-phone-call).

## Prerequisites

<sign-up number></sign-up>

* The [Nexmo CLI](https://github.com/Nexmo/nexmo-cli) - you'll use this to create an application, purchase a number and link the two together
* Swift 4.1 or greater - on MacOS, Xcode 9.3 or greater will do the trick 

## The Plan

This tutorial will walk you through the following steps:

* Learn about Nexmo concepts
* Create a new Vapor project
* Add a route for the voice answer
* Expose the application using ngrok
* Purchase a Nexmo number
* Create a Nexmo application to use with the number
* Test your application

## Nexmo Concepts

Before delving into the build, here are couple of concepts that you'll need to understand.

A [Nexmo application](https://developer.nexmo.com/concepts/guides/applications) allows you to easily use Nexmo products, in this case the [Voice API](https://developer.nexmo.com/voice/voice-api/overview) to build voice applications in the Cloud.

A Nexmo application requires two URLs as parameters:

* `answer_url` - Nexmo will make a request to this URL as soon as the call is answered
* `event_url` - Nexmo sends event information asynchronously to this URL when the call status changes; this ultimately defines the flow of the call

Both URLs need to return JSON and follow the [Nexmo Call Control Object (NCCO)](https://developer.nexmo.com/voice/voice-api/ncco-reference) reference. In the example below, you will define an NCCO that reads a predefined text for an incoming call, using the [Text to Speech](https://developer.nexmo.com/voice/voice-api/guides/text-to-speech) engine.

A [Nexmo virtual number](https://developer.nexmo.com/numbers/overview) will be associated with the app and serve as the "entry point" to it—this is the number you'll call to test the application.

For more information on Nexmo application please visit the Nexmo [API Reference](https://developer.nexmo.com/api/application).

## New Vapor Project

You will use Vapor to create a simple Swift web app—if you don't already have Vapor installed, do so by running this command:

```bash
brew install vapor/tap/vapor
```

Extensive installation instructions are available for [MacOS](https://docs.vapor.codes/3.0/install/macos/) and [Ubuntu](https://docs.vapor.codes/3.0/install/ubuntu/).

From the command line, navigate to an appropriate location where you want your project to reside (e.g. your Documents directory) and create a new Vapor app:

```bash
$ vapor new ReceiveCall
$ cd ReceiveCall/
```

If you are using MacOS you can have `vapor` automatically create an XCode project for you (the `-y` option will automatically open the Xcode project):

```bash
$ vapor xcode -y
```

Build & Run to test your app ensuring that the `Run` scheme is selected. Once everything is compiled, the server is started and you will see a notice in the console:

```
Server starting on http://localhost:8080
```

Point your browser to that URL and an `It works!` message should appear.

## Add the Route

You'll now add a route that will serve as the `answer_url` for the [Nexmo application](https://developer.nexmo.com/api/application#parameters). [http://localhost:8080/webhooks/answer ](http://localhost:8080/webhooks/answer) will respond with the following JSON object:

```json
[
    {
        "action":"talk",
        "text":"<speak>To be <break strength='weak' \/> or not to be <break strength='weak' \/> that is the question.<\/speak>"
    }
]
```

A Vapor project stores its routes in the `routes.swift` file inside the `Sources/App` group. Open this file, clear all the existing routes and define the new route:

```swift
import Vapor

public func routes(_ router: Router) throws {
    router.get("/webhooks/answer") { request -> String in
        let talk = Action(
            action: "talk",
            text: "<speak>To be <break strength='weak' /> or not to be <break strength='weak' /> that is the question.</speak>")
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode([talk]) else { return "error encoding" }
        return String(data: data, encoding: .utf8) ?? "error"
    }
}
```

`Action` is a simple [Swift Structure](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html) to hold the NCCO action details - define it after the router closure:

```swift
struct Action: Encodable {
    var action: String
    var text: String
}
```

By coding `Action` to conform to `Encodable`, you ensure that the `JSONEncoder` can use it.

Build & Run the app and test the new route output at: <http://localhost:8080/webhooks/answer>.

You now have a URL that will be used as the `answer_url`.

## Expose Your Application

For Nexmo to reach your Vapor application, it needs to access a publicly available URL-your application runs on your machine and is only accessible inside your local network. 

[ngrok](https://ngrok.com) is a simple utility that exposes your local web server through public URLs.

With ngrok [installed](https://dashboard.ngrok.com/get-started), run the following command:

```bash
ngrok http 8080
```

Take note of the forwarding address as you will need it when you configure your account — an example output is shown below—the forwarding address is `https://7ffc0230.ngrok.io`.

<img src="https://www.nexmo.com/wp-content/uploads/2019/02/ngrok_no_shadow.png" alt="ngrok running in terminal with forwarding address https://7ffc0230.ngrok.io" width="900" height="360" class="size-full wp-image-27799" />

## Purchase a Number

This will be the number you're going to call to connect to your Nexmo application.
The example below uses an US number but numbers for other countries are [available](https://www.nexmo.com/products/phone-numbers). 

Note: When signing up for a Nexmo account, €2.00 is added to your balance and this will be more than enough to get a number.

To purchase a new number, use the Nexmo CLI:

```bash
nexmo number:buy --country_code US
```

Take note of the new number assigned to you on purchase; you will need this next.

## Create a Nexmo Application

You'll now tie everything together by creating a [new Nexmo application](https://developer.nexmo.com/concepts/guides/applications) using the ngrok forwarding address:

```bash
nexmo app:create "Receive Call Demo" http://your-ngrok-forwarding-address/webhooks/answer http://your-ngrok-forwarding-address/webhooks/events --keyfile private.key
```

Note: The second URL parameter, http://your-ngrok-forwarding-address/webhooks/events, doesn't exist and you'll never actually use it, but an event URL needs to be specified when creating a Nexmo application.

The output given by the above command will include the id of the new application (eg:  Application created: `39083ced-5275-423d-8a1f-9db528c106b1`). You will need this application id to link your phone number to the application—you can use the Nexmo CLI to do this:

```bash
nexmo link:app your-nexmo-phone-number your-application-id
```

The application will now send a request to your <http://your-ngrok-forwarding-address/webhooks/answer> URL when it receives a phone call.

## Test Your Application

From your phone, make a call to your Nexmo number to hear the most important question of them all.

## Conclusion

In a few lines of code you have created an application that can receive a phone call and speak a message to the caller. There are [other ways](https://developer.nexmo.com/voice/voice-api/ncco-reference) to interact with the caller and other [Speech Synthesis Markup Language(SSML)](https://developer.nexmo.com/voice/voice-api/guides/text-to-speech#ssml) tags you can use.

## Where Next?

Want to learn more? Check out our documentation on [Nexmo Developer](https://developer.nexmo.com) where you can learn about the [call flow](https://developer.nexmo.com/voice/voice-api/guides/call-flow), [Voice API](https://developer.nexmo.com/voice/voice-api/overview) and [Nexmo Call Control Objects](https://developer.nexmo.com/voice/voice-api/ncco-reference).