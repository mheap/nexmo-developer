---
title: How to Handle Inbound Phone Calls with Ruby on Rails
description: In this Nexmo Voice API tutorial, you will learn how to receive an
  inbound call by implementing a webhook endpoint in Ruby on Rails.
thumbnail: /content/blog/how-to-handle-inbound-phone-calls-with-ruby-on-rails/voice-receive-call-ruby.png
author: chrisguzman
published: true
published_at: 2017-12-21T17:23:30
updated_at: 2021-05-20T08:29:04.761Z
category: tutorial
tags:
  - ruby
  - voice-api
comments: true
redirect: ""
canonical: ""
---
*This is the third article in a series of "[Getting Started with Vonage Voice APIs and Ruby on Rails](https://learn.vonage.com/blog/2017/11/02/outbound-text-to-speech-voice-call-ruby-on-rails-dr/)" tutorials. It continues the "[Getting Started with Vonage and Ruby on Rails](https://learn.vonage.com/blog/2017/10/16/send-sms-ruby-on-rails-dr/)" series.*

In the [previous article](https://learn.vonage.com/blog/2017/12/19/receive-voice-call-events-call-progress-ruby-rails-dr/), you learned how to set up a Rails application to be publicly accessible by Vonage and then receive a **Call Event Update** for a call in progress. In this article, you will learn how to receive an inbound call by implementing a similar webhook endpoint in Ruby on Rails.

[View the source code on GitHub](https://github.com/Nexmo/nexmo-rails-quickstart/blob/master/app/controllers/inbound_calls_controller.rb).

## Prerequisites

To follow this tutorial, you need to have:

* A basic understanding of Ruby and Rails
* [Rails](http://rubyonrails.org/) installed on your machine
* [NPM](https://www.npmjs.com/) installed for the purpose of our CLI
* Followed our [previous tutorial on receiving call event updates with Ruby on Rails](https://www.nexmo.com/blog/2017/12/19/receive-voice-call-events-call-progress-ruby-rails-dr/)

<sign-up></sign-up>

## What Is an "Inbound Call"?

When someone calls the Vonage number that was purchased in the first tutorial, it will be received by Vonage. We will then make an HTTP call to the `answer_url` for the Vonage Application associated with that number.

To receive this webhook, you will need to set up a webhook endpoint and tell Vonage where to find it. For a refresher on how to set up [ngrok](http://ngrok.io) for your application, read our post on [connecting your local development server to the Vonage API using an ngrok tunnel](https://learn.vonage.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/).

## Set the Webhook Endpoint with Vonage

The first step is to use the [Vonage CLI tool](https://github.com/Vonage/vonage-cli) to link the Vonage Application created in the previous tutorial to the purchased Nexmo number. We pass in the phone number and the application's UUID.

<pre class="lang:default highlight:0 decode:true " >
$ vonage apps:link aaaaaaaa-bbbb-cccc-dddd-0123456789ab --number=14155550102
</pre> 

This command tells Vonage to make an HTTP call to the `answer_url` of the Vonage Application every time the Vonage Number receives an inbound call. We already set the `answer_url` in the first tutorial of this series, but if you need to update it you can do so as follows:

<pre class="lang:default highlight:0 decode:true " >
$ vonage apps:update aaaaaaaa-bbbb-cccc-dddd-0123456789ab --name="My Voice App" --voice_answer_url=http://abc123.ngrok.io/inbound_calls --voice_event_url=http://abc123.ngrok.io/call_events --voice_answer_http=POST --voice_event_http=POST
Application updated
</pre>

## Handle an Incoming Call WebHook

The hard part is really done at this point. When a call comes in on your Vonage number, Vonage will notify your application by sending a webhook to the `answer_url`. A typical payload for this webhook will look something like this:

```json
{
    "from": "14155550104",
    "to": "14155550102",
    "conversation_uuid": "CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
}
```

In this payload, the sending conversation is identified by the `conversation_uuid` parameter, and the `from` and `to` specify the caller and the Vonage number called. Let's add a new controller to process this payload and store a new call record.

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :inbound_calls,  only: [:create]
end

# app/controllers/inbound_calls_controller.rb
class InboundCallsController < ApplicationController
  # We disable CSRF for this webhook call
  skip_before_action :verify_authenticity_token

  def create
    Call.where(conversation_uuid: params[:conversation_uuid])
        .first_or_create
        .update_attributes(
          to: params[:to],
          from: params[:from]
        )

    render json: [
      {
        action: 'talk',
        voiceName: 'Jennifer',
        text: 'Hello, thank you for calling. This is Jennifer from Vonage. Ciao.'
      }
    ]
  end
end
```

Although storing and updating the call details is not really necessary, it's useful to keep track of current call statuses, durations, and any other information that might benefit your application. This action returns a new [Vonage Call Control Object (NCCO)](https://developer.vonage.com/voice/voice-api/overview#ncco) that will play back a simple voice message to the recipient as specified. There are many more actions you can specify in the NCCO—have a play with them if you want.

OK, now start your server, ensure you have something like [ngrok](http://ngrok.io) running, and make a voice call to your Vonage number! Can you hear Jennifer?

## To Sum Things Up

That's it for this tutorial. We've completed all the steps for receiving an inbound call in Ruby on Rails:


1. set up our Rails application to receive an inbound voice call webhook 

2. informed Vonage of where to find our server 

3. processed an incoming webhook 

4. provided instructions to Vonage to play back a message

You can view the [code used in this tutorial](https://github.com/Nexmo/nexmo-rails-quickstart/blob/master/app/controllers/inbound_calls_controller.rb) on GitHub.

## Next Steps

That's it for this series on Ruby on Rails tutorials for now. As a reminder, you can see the source code for all of the SMS and Voice tutorials in our [Ruby on Rails Quickstart repo](https://github.com/Nexmo/nexmo-rails-quickstart).