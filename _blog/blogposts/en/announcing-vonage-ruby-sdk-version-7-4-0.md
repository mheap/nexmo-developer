---
title: Announcing Vonage Ruby SDK Version 7.4.0
description: Introducing a new NCCO builder in the Vonage Ruby SDK
thumbnail: /content/blog/announcing-vonage-ruby-sdk-version-7-4-0/blog_ruby-sdk-update_1200x600.png
author: ben-greenberg
published: true
published_at: 2021-03-19T08:58:51.980Z
updated_at: ""
category: release
tags:
  - ruby
  - sdk
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
The Vonage Ruby SDK recently published a new release, v7.4.0. 
This new version brings the ability to create actions ("NCCO") for programmable voice calls to the SDK for the first time!

Let's explore the reasoning behind it and how it works.

## What is an NCCO?

The Vonage Voice API can be viewed as a conversation between you and the API mediated through your code. You tell the API how you want it to behave during the phone call with actions constructed in JSON that you send to the Voice API. These actions are called NCCOs.

You can send text-to-speech, initiate a call recording, create a conference call, and a myriad of other activities with NCCOs. The Voice API acts on each NCCO in sequential order, and for the most part, synchronously. For example, let's say you wanted to start a call with a text-to-speech greeting followed by collecting speech input. Your NCCO would look like this:

```
[
  {
    :action => "talk",
    :text => "Hello, please say something!"
  },
  {
    :action => "input",
    :type => ["speech"],
    :context => ["continue", "hangup", "main menu"]
  }
]
```

In the above example, the first NCCO action reads out the greeting of "Hello, please say something!", while the next NCCO action collects speech input. We include an additional optional parameter of `context` in the `input` providing some verbal hints to the speech recognition engine of what kind of words it may expect to hear from the person.

## NCCO Building in the SDK

The process of building NCCOs can get quite complex as the needs of your application or service grow. Each NCCO action has its own specific data structure requirements, and trying to remember each one of them or needing to continually refer back to the [NCCO Reference Guide](https://developer.vonage.com/voice/voice-api/ncco-reference#input) can be overwhelming.

The SDK team at Vonage believes that if an SDK only performs the HTTP requests to the API then it is not fully fulfilling its purpose. An SDK should enable developers to build with the Vonage APIs in a manner that is more streamlined and delightful. 

Now, with version 7.4.0 of the Vonage Ruby SDK, it becomes possible to build NCCO actions programmatically with real-time feedback and support in Ruby! Let's take a look at how it works.
 
## How Does It Work?

The new NCCO builder is similar to the JWT generator functionality in that it is not a part of the client instantiation of the SDK. You do not need to pass in any credentials to begin building an NCCO.

Each NCCO action can be built by invoking its name as the method on the `Vonage::Voice::Ncco` class. For example, the `talk` action becomes the `#talk` method and is accessed by invoking `Vonage::Voice::Ncco.talk`. Each method accepts the parameters that are enumerated in the [NCCO Reference Guide](https://developer.vonage.com/voice/voice-api/ncco-reference#input) on the Vonage API Developer portal.

Additionally, the NCCO builder will provide real-time feedback in the form of exceptions for incorrect parameters. This becomes very helpful as you construct an action that has highly specific data type or data structure requirements. As an example, a phone number must be in [E.164](https://en.wikipedia.org/wiki/E.164) format. The NCCO builder will raise an error and inform you if the number you provided does not match that specification.

The example we began with of two NCCO actions, a `talk` and a speech `input`, can be built with the new NCCO builder as follows:

```ruby
talk = Vonage::Voice::Ncco.talk(text: 'Hello, please say something!')
input = Vonage::Voice::Ncco.input(type: ['speech'], context: ["continue", "hangup", "main menu"])
```

The final step in constructing your NCCO is to invoke the `#build` method. The `#build` method accepts the NCCO action objects and builds a completely ready NCCO JSON structure with the NCCOs in the order that they were passed in. As such, to complete the `talk` and `input` actions example, we would invoke the `#build` method like this:

```ruby
ncco = Vonage::Voice::Ncco.build(talk, input)

# => [{:action=>"talk", :text=>"Hello, please say something!!"}, {:action=>"input", :type=>["speech"], :speech=>{:context=>["continue", "hangup", "main menu"]}}]
``` 

## What's Next?

We have more exciting plans in the works for the Ruby SDK! We are continuing to build up the SDK's features to increase its alignment with our goal of being a resource that not only makes HTTP requests for you but primarily makes your tasks easier and more streamlined.

We always welcome community involvement. Please feel free to join us on [GitHub](https://github.com/Vonage/vonage-ruby-sdk) and the [Vonage Community Slack](https://developer.nexmo.com/community/slack). 
