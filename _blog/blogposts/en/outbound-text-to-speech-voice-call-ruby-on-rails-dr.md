---
title: Make an Outbound Text-to-Speech Phone Call with Ruby on Rails
description: With the Nexmo Voice API, you can make worldwide outbound calls.
  All you need is your virtual phone number, the Ruby Gem, and a few lines of
  code.
thumbnail: /content/blog/outbound-text-to-speech-voice-call-ruby-on-rails-dr/voice-make-call.png
author: chrisguzman
published: true
published_at: 2017-11-02T14:45:39.000Z
updated_at: 2021-05-07T16:31:54.119Z
category: tutorial
tags:
  - ruby
  - voice-api
comments: true
redirect: ""
canonical: ""
---
*This is the first article in a series of "Getting Started with Vonage Voice APIs and Ruby on Rails" tutorials. It continues the "Getting Started with Vonage SMS and Ruby on Rails" series.*

With the help of the [Vonage Voice API](https://developer.vonage.com/voice/voice-api/overview) you can make worldwide outbound and inbound calls in 23 languages with varieties of voices and accents. All you need is your virtual phone number, the [Ruby Gem](https://github.com/Vonage/vonage-ruby-sdk), and a few lines of code.

In this tutorial—and the ones to follow—I will take you through some real-life examples of how to integrate Vonage into your Rails application. I'll explain how to set up the basics, and then we will write some code together to properly integrate Vonage and start making and receiving phone calls. Let's get started!

[View the source code on GitHub](https://github.com/Nexmo/nexmo-rails-quickstart/blob/master/app/controllers/outbound_calls_controller.rb)

## Prerequisites

For this tutorial I assume you will have:

* A basic understanding of Ruby and Rails
* [Rails](http://rubyonrails.org/) installed on your machine
* [NPM](https://www.npmjs.com/) installed for the purpose of our CLI

<sign-up number></sign-up> 


## Get your API keys

In this tutorial, we will use this as our main way of preparing our application.

The Vonage CLI is a Node module and therefore does require NPM to have been installed.

<pre class="lang:default highlight:0 decode:true ">
$ npm install vonage-cli -g
$ vonage config:set --apiKey=YOUR-API-KEY --apiSecret=YOUR-API-SECRET
</pre>

With this in place, we can run the following commands to find and purchase a Voice-enabled number:

```shell
$ vonage numbers:search US --features=VOICE
14155550102
14155550103
14155550104
$ vonage numbers:buy 14155550102 US
```

Alternatively, head over to the [Numbers page](https://dashboard.nexmo.com/buy-numbers) on the Vonage Dashboard and purchase a number via the web interface.

## Create a Vonage Application

In our previous series of SMS tutorials, we were able to configure a phone number directly with an endpoint. In this tutorial, we will be using the new, more powerful and more secure [Vonage Applications](https://developer.nexmo.com/api/application) API for configuring our callbacks.

![Make voice calls](/content/blog/make-an-outbound-text-to-speech-phone-call-with-ruby-on-rails/voice-make-call-diagram.png "Make voice calls")

*Diagram: Using the Voice API to call your mobile phone*

Our first step is to create an application by providing an application name and some callback URLs. Don't worry about these URLs yet as we'll be updating them later in a future tutorial.

<pre class="lang:default highlight:0 decode:true ">
$ vonage apps:create "My Voice App" --voice_answer_url=http://example.com/inbound_calls --voice_event_url=http://example.com/call_events --voice_answer_http=POST --voice_event_http=POST
Application created: aaaaaaaa-bbbb-cccc-dddd-0123456789ab
</pre>

This will create a Vonage Application with UUID `aaaaaaaa-bbbb-cccc-dddd-0123456789ab` and a private key stored in a file called `private.key`. Make sure you don't lose this key; Vonage does not keep a copy and it's used to sign your API calls.

## Install the Vonage Ruby Gem

The easiest way to interact with the Vonage Voice API with Ruby is using the [`vonage` gem](https://github.com/Vonage/vonage-ruby-sdk).

```shell
$ gem install vonage
```

This gem conveniently provides an easy wrapper around the [Vonage REST API](https://developer.nexmo.com/api/voice). To initialize it, we will need to pass it the Application UUID and private key that we created earlier. Create a file named `make-call.rb` with the following contents, replacing `application_id` with your application ID:

```ruby
require "vonage"

vonage = Vonage::Client.new(
application_id: 'aaaaaaaa-bbbb-cccc-dddd-0123456789ab',
private_key: File.read('private.key')
)
```

## Make a voice call with Ruby

With our API client in place, making the first voice call is easy; we simply call the `create_call` method on the initialized client and pass in a configuration specifying who to call `to`, what number to call `from`, and an `answer_url` that will return a [Vonage Call Control Object (NCCO)](https://developer.vonage.com/voice/voice-api/overview#ncco) containing the actions to play back to the receiver. To get us up and running quickly, we'll provide a predefined NCCO URL that's hosted on Github.

Add the following code to `make-call.rb`:

```ruby
vonage.create_call({
to: [
{
type: 'phone',
number: '14155550101'
}
],
from: {
type: 'phone',
number: '14155550102'
},
answer_url: [
'https://nexmo-community.github.io/ncco-examples/first_call_talk.json'
]
})
```

This will play back a simple voice message to the recipient as specified by [`first_call_talk.json`](https://nexmo-community.github.io/ncco-examples/first_call_talk.json). Run `ruby make-call.rb` now, and wait for a call from Vonage that will read you a simple voice message.

There are a lot more parameters that we could pass into this method. Have a look at the [reference documentation](https://developer.nexmo.com/api/voice#payload) for full details.

## Make an outbound call from Ruby on Rails

In a Rails application, we'd probably have a Model for Calls where we can store the `to`, `from`, and maybe the `text` to play to the recipient before making the Vonage API call. For this example you could create a migration for a Call like so:

<pre class="lang:default highlight:0 decode:true ">$ rails generate migration CreateCalls to:string from:string text:text uuid:string status:string
</pre>

In my demo application, I've also whipped up [a simple form](https://github.com/Nexmo/nexmo-rails-quickstart/blob/master/app/views/outbound_calls/index.html.erb) for the [Call model](https://github.com/Nexmo/nexmo-rails-quickstart/blob/master/app/models/call.rb).

`localhost:3000/outbound_calls`

![Make call form](/content/blog/make-an-outbound-text-to-speech-phone-call-with-ruby-on-rails/call-ui.png "Make call form")

When the form is submitted, we store the Call record and then make the call. In a real application, you might use a background queue for this, though in this case, we will just pass the Call record to a new method.

```ruby
# config/routes.rb
Rails.application.routes.draw do
resources :outbound_calls, only: [:index, :create, :show]
end

# app/controllers/outbound_calls_controller.rb
class OutboundCallsController < ApplicationController
def create
@call = Call.new(safe_params)

if @call.save
make @call
redirect_to :outbound_calls, notice: 'Call initiated'
else
flash[:alert] = 'Something went wrong'
render :index
end
end

private

def safe_params
params.require(:call).permit(:to, :from, :text)
end
end
```

Next, we can pass the call information to the Vonage API.

```ruby
# app/controllers/outbound_calls_controller.rb
def make call
response = vonage.create_call({
to: [
{
type: 'phone',
number: call.to
}
],
from: {
type: 'phone',
number: call.from
},
answer_url: [
outbound_call_url(call)
]
})

call.update_attributes(
uuid: response['uuid'],
status: response['status']
) if response['status'] && response['uuid']
end
```

The response object will contain a `uuid` if the call was initiated successfully. We can store the `uuid` and the current call `status` on the Call record. The `uuid` can be used to track the status of the Call, specifically when a [Call Update](https://developer.nexmo.com/api/voice#webhook) comes in via a webhook.

## Provide an NCCO to play back text

When we called the `create_call` method we used `outbound_call_url(call)` in the `answer_url` array. That `answer_url` needs to be available to the public internet so that it is reachable by the Vonage APIs. You can do so by using [ngrok.](https://ngrok.com/) For more detailed instructions see [Aaron's](https://twitter.com/aaronbassett) post explaining [how to connect your local development server to the Vonage API using an ngrok tunnel](https://learn.vonage.com/blog/2017/10/19/receive-sms-delivery-receipt-ruby-on-rails-dr/).

After setting up ngrok like so:

<pre class="lang:default highlight:0 decode:true "># forwarding port 3000 to an externally accessible URL
$ ngrok http 3000

Session Status                online
Account                       Cristiano Betta
Version                       2.2.4
Region                        United States (us)
Web Interface                 http://127.0.0.1:4040
Forwarding                    http://abc123.ngrok.io -&gt; localhost:3000
Forwarding                    https://abc123.ngrok.io -&gt; localhost:3000
</pre>

You will have an `answer_url` that looks something like this:

`http://abc123.ngrok.io/outbound_call/123`

When the call is initiated, Vonage will make an HTTP request to that endpoint expecting an NCCO object with the actions to perform. In our case, we want to simply play back the `text` we specified on the Call object.

```ruby
# app/controllers/outbound_calls_controller.rb
def show
call = Call.find(params[:id])

render json: [
{
"action": "talk",
"voiceName": "Russell",
"text": call.text
}
]
end
```

Now go ahead, submit the form and within a few seconds you will receive a call playing back the message you just specified! There are many more actions you can specify in the [NCCO](https://developer.nexmo.com/voice/voice-api/overview#ncco). Have a play with them if you want.

![Receive call](/content/blog/make-an-outbound-text-to-speech-phone-call-with-ruby-on-rails/android.png "Receive call")

## To sum things up

That's it for this tutorial. We've successfully:

<ol>
 	<li>Created a Vonage account.</li>
 	<li>Installed the CLI.</li>
 	<li>Bought a number and created a Vonage Application.</li>
 	<li>Installed and initialized the Ruby gem.</li>
 	<li>Created a deep integration into our Rails application.</li>
</ol>
You can view the [code used in this tutorial](https://github.com/Nexmo/nexmo-rails-quickstart/blob/master/app/controllers/outbound_calls_controller.rb) on GitHub.

## Next steps

In the next tutorials, we will look at receiving Call Events for calls we've created, and how to receive inbound calls as well.