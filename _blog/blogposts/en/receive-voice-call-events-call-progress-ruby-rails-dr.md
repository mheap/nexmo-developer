---
title: Receive Voice Call Events for a Call In Progress with Ruby on Rails
description: In this tutorial, you'll learn to determine when a voice call has
  connected or completed by listening for call events in your Ruby on Rails
  applications.
thumbnail: /content/blog/receive-voice-call-events-call-progress-ruby-rails-dr/ror-receiving-call-events.png
author: chrisguzman
published: true
published_at: 2017-12-19T21:44:18.000Z
updated_at: 2021-05-20T08:20:36.356Z
category: tutorial
tags:
  - ruby
  - voice-api
comments: true
redirect: ""
canonical: ""
---
_This is the second article in a series of "Getting Started with Nexmo APIs and Ruby on Rails" tutorials. It continues the "[Getting Started with Nexmo SMS and Ruby on Rails](https://www.nexmo.com/blog/2017/10/16/send-sms-ruby-on-rails-dr/)" series._

In our [previous tutorial](https://www.nexmo.com/blog/2017/11/02/outbound-text-to-speech-voice-call-ruby-on-rails-dr/) I showed you how to make a text-to-speech call using the Nexmo API and the Nexmo Ruby gem in a Rails application. What we didn't looked at though is how to know when a call has connected or completed. In this tutorial, we will look at how we can listen for call events from Nexmo to update the status of a call in our application.

[View the source code on GitHub](https://github.com/Nexmo/nexmo-rails-quickstart/blob/master/app/controllers/call_events_controller.rb).

## Prerequisites

To follow this tutorial, I assume you have:

- a basic understanding of Ruby and Rails
- [Rails](http://rubyonrails.org/) installed on your machine
- [NPM](https://www.npmjs.com/) installed for the purpose of our CLI
- followed our previous tutorial on Making a text-to-speech call with Ruby on Rails

<sign-up></sign-up>



## What Does "Connected" Mean?

When you make a successful Voice Call request to Nexmo, the API returns a status for your call. Often this will be the initial state of `started`. Next, Nexmo will route your call and start ringing the phone of the recipient. When that happens we can notify your Rails application of the change in status using a **Call Event Webhook**.

To receive this webhook in your application, you will need to set up a webhook endpoint, telling Nexmo where to forward these receipts.

## Set the Webhook Endpoint with Nexmo

To receive a webhook we need two things. First, we need to set up our server so that Nexmo can make an HTTP call to it. If you are developing on a local machine, this might be hard, which is where tools like [Ngrok](http://ngrok.io) come in. I won't go too much into detail, but with Ngrok you can make your local Rails server available to the outside world within seconds. If you'd like to read more about using ngrok, check out this article detailing [how to use an ngrok tunnel](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/).

 
<pre class="lang:default highlight:0 decode:true " >
# forwarding port 3000 to an externally accessible URL
$ ngrok http 3000

Session Status                online
Account                       Cristiano Betta
Version                       2.2.4
Region                        United States (us)
Web Interface                 http://127.0.0.1:4040
Forwarding                    http://abc123.ngrok.io -&gt; localhost:3000
Forwarding                    https://abc123.ngrok.io -&gt; localhost:3000</pre> 


With this in place, you can set up this URL as your `event_url` webhook address on your Nexmo Application. Lucky for us, we already did this when we created the Nexmo Application in the previous tutorial.
 
<pre class="lang:default highlight:0 decode:true " >
$ nexmo app:create "My Voice App" http://abc123.ngrok.io/inbound_calls http://abc123.ngrok.io/call_events --keyfile private.key --answer_method POST --event_method POST
Application created: aaaaaaaa-bbbb-cccc-dddd-0123456789ab
Private Key saved to: private.key</pre> 

If you need to change the URLs somehow, you can do so easily using a pretty similar command.

<pre class="lang:default highlight:0 decode:true " >
$ nexmo app:update aaaaaaaa-bbbb-cccc-dddd-0123456789ab "My Voice App" http://abc123.ngrok.io/inbound_calls http://abc123.ngrok.io/call_events --answer_method POST --event_method POST
Application updated
</pre> 


## Handle a Call Event WebHook

The hard part is done at this point, really. When a call has been initiated Nexmo will notify your application of any changes in the call by sending a webhook. A typical payload will look something like this:

```json
{
  "uuid": "aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "conversation_uuid": "CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "status": "ringing",
  "direction": "outbound"
}
```

We can extend the example from our previous tutorial and update the call record we stored then with the new status.

```ruby
# app/controllers/call_events_controller.rb
class CallEventsController < ApplicationController
  # We disable CSRF for this webhook call
  skip_before_action :verify_authenticity_token

  def create
    if params[:uuid]
      Call.where(uuid: params[:uuid])
          .first_or_create
          .update(
            status: params[:status],
            conversation_uuid: params[:conversation_uuid]
          )
    end

    head :ok
  end
end
```

In this example, we find the call record with the `uuid` provided, and then update its status with the given `status`, in this case `"ringing"`.

## Start a Call and Receive a Call Event

Now we can use our "Make a call" form by navigating to http://abc123.ngrok.io/outbound_calls (your ngrok URL will be different). You can check out how we built this form in the first article of this series, "[Make an Outbound Text-to-Speech Phone Call](https://www.nexmo.com/blog/2017/11/02/outbound-text-to-speech-voice-call-ruby-on-rails-dr/)."

When the call event is sent, we’ll see a log of it in our Rails console.
 
<pre class="lang:default highlight:0 decode:true " >
Started POST "/call_events" for 192.0.2.0 at 2020-01-01 12:00:00 -0500
  Parameters: { "conversation_uuid"=&gt;"CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "status"=&gt;"ringing", "direction"=&gt;"outbound"}
  Call Load (0.3ms)  SELECT  "calls".* FROM "calls" WHERE "calls"."uuid" = ? ORDER BY "calls"."id" ASC LIMIT ?
  [["uuid", "aaaaaaaa-bbbb-cccc-dddd-0123456789ab"], ["LIMIT", 1]]
Processing by CallEventsController#create as HTML
   (0.0ms)  begin transaction
  Parameters: {"uuid"=&gt;"aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "conversation_uuid"=&gt;"CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
  "status"=&gt;"started", "direction"=&gt;"outbound"}
  SQL (0.3ms)  UPDATE "calls" SET "status" = ?, "conversation_uuid" = ?, "is_inbound" = ?, "updated_at" = ? WHERE "calls"."id" = ?
  [["status", "ringing"], ["conversation_uuid", "CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab"],
  ["is_inbound", "f"], ["updated_at", "2020-01-01 12:00:00"], ["id", 6]]
  Call Load (0.1ms)  SELECT  "calls".* FROM "calls" WHERE "calls"."uuid" = ? ORDER BY "calls"."id" ASC LIMIT ?
  [["uuid", "aaaaaaaa-bbbb-cccc-dddd-0123456789ab"], ["LIMIT", 1]]
   (0.7ms)  commit transaction
   (0.0ms)  begin transaction
Completed 200 OK in 7ms (ActiveRecord: 1.3ms)</pre> 


## To Sum Things Up

That's it for this tutorial. We've set up our Rails application to receive webhooks, informed Nexmo where to find our server, and processed an incoming webhook with a Delivery Receipt.

You can view the [code used in this tutorial](https://github.com/Nexmo/nexmo-rails-quickstart/blob/master/app/controllers/call_events_controller.rb) on GitHub.

## Next Steps

In the next tutorial, we will look at receiving inbound voice calls into our application.
