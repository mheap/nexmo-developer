---
title: Receive an SMS Delivery Receipt with Ruby on Rails
description: We will look at what it means for a message to be delivered, and
  how we can listen for SMS Delivery Receipts from Nexmo
thumbnail: /content/blog/receive-sms-delivery-receipt-ruby-on-rails-dr/sms-delivery-ruby.png
author: chrisguzman
published: true
published_at: 2017-10-19T20:25:20.000Z
updated_at: 2021-05-07T15:30:19.506Z
category: tutorial
tags:
  - ruby
  - sms-api
comments: true
redirect: ""
canonical: ""
---
*This is the second article in a series of "Getting Started with Nexmo SMS and Ruby on Rails" tutorials.*

In our [previous tutorial](https://www.nexmo.com/blog/2017/10/16/send-sms-ruby-on-rails-dr/) I showed you how to send an SMS using the Nexmo API and the Nexmo Ruby gem in a Rails application. What we haven't looked at though is how to know when a message has been delivered. In this tutorial we will look at what it means for a message to be delivered, and how we can listen for Delivery Receipts from Nexmo to update the status of an SMS in our application.

[View the source code on GitHub](https://github.com/Nexmo/nexmo-rails-quickstart/blob/master/app/controllers/sms_delivery_receipts_controller.rb)

## Prerequisites

For this tutorial I assume you will:

* Have a basic understanding of Ruby and Rails
* Have [Rails](http://rubyonrails.org/) installed on your machine
* Have followed our previous tutorial on [Sending an SMS with Ruby on Rails](https://www.nexmo.com/blog/2017/10/16/send-sms-ruby-on-rails-dr/)

<sign-up></sign-up>

## What Does "Delivered" Mean?

When you make a successful SMS request to Nexmo, the API returns an array of `message` objects, ideally with a status of `0` for "Success". At this moment the SMS has not been delivered yet, rather it's been queued for delivery with Nexmo.

In the next step, Nexmo find the best carrier to deliver your SMS to the recipient, and when they do so they notify Nexmo of the delivery with a **Delivery Receipt (DLR)**.

To receive this DLR in your application, you will need to set up a webhook endpoint, telling Nexmo where to forward these receipts to.

![DLR diagram](/content/blog/receive-an-sms-delivery-receipt-with-ruby-on-rails/diagram-dlr.png "DLR diagram")

## Set the Webhook Endpoint with Nexmo

To receive a webhook we need 2 things, firstly we need to set up our server so that Nexmo can make a HTTP call to it. If you are developing on a local machine this might be hard, which is where tools like [ngrok](http://ngrok.io) come in. With ngrok you can make your local Rails server available within seconds to the outside world. For an in-depth tutorial you can check out a previous post explaining how to [connect your local development server to the Nexmo API using an ngrok tunnel](https://www.nexmo.com/blog/2017/07/04/local-development-nexmo-ngrok-tunnel-dr/).

```sh
# forwarding port 3000 to an externally accessible URL
$ ngrok http 3000

Session Status online
Account Cristiano Betta
Version 2.2.4
Region United States (us)
Web Interface http://127.0.0.1:4040
Forwarding http://abc123.ngrok.io -> localhost:3000
Forwarding https://abc123.ngrok.io -> localhost:3000
```

Secondly, we need to make sure our server has an endpoint in place that return a nice and clean HTTP 200 response when called. Let's add a new controller with an empty response.

```ruby
# config/routes.rb
Rails.application.routes.draw do
resources :sms_delivery_receipts, only: [:create]
end

# app/controllers/sms_delivery_receipts_controller.rb
class SmsDeliveryReceiptsController < ApplicationController
skip_before_action :verify_authenticity_token

def create
head :ok
end
end
```

With this in place, you can set up this URL as your webhook address on your Nexmo account. Head over to the settings page on the Nexmo Dashboard and scroll down the **API Settings** and fill in the following 2 details.

* Set the **Webook URL for Delivery Receipts** to the ngrok URL, e.g. `http://abc123.ngrok.io/sms_delivery_receipts`
* Ensure the **HTTP Method** is set to `POST` for this tutorial

![Webhook Endpoint Configuration](/content/blog/receive-an-sms-delivery-receipt-with-ruby-on-rails/endpoint-1-.png "Webhook Endpoint Configuration")

Finally, save the form. You might see an error appear after a few seconds if your server can not be reached, or the endpoint did not return a HTTP 200 response. In this case head over to the [ngrok Web Interface](http://127.0.0.1:4040) to inspect the request and response made.

## Handle a Delivery Receipt WebHook

The hard part is done at this point really. When an SMS has been sent and delivered, the carrier will notify Nexmo, and we will in return notify your application by sending a webhook. A typical DLR will look something like this.

```json
{
"msisdn": "14155550102",
"to": "14155550101",
"network-code": "310090",
"messageId": "02000000FEA5EE9B",
"price": "0.00570000",
"status": "delivered",
"scts": "1577880000",
"err-code": "0",
"message-timestamp": "2020-01-01 12:00:00"
}
```

We can extend the example from our previous tutorial and update the SMS record we stored then with the new status.

```ruby
# app/controllers/sms_delivery_receipts_controller.rb
def create
Sms.where(message_id: params[:messageId])
.update_all(status: params[:status]) if params[:messageId]

head :ok
end
```

In this example we find the SMS record with the `messageId` provided, and then update its status with the given status, in this case `"delivered"`.

## Send an SMS and Receive a DLR

Now we can use our "Send an SMS" form by navigating to `http://localhost:3000/outbound_sms`. You can check out how we built this form in the first article of this series, ["Sending an SMS with Rails"](https://www.nexmo.com/blog/2017/10/16/send-sms-ruby-on-rails-dr/).

When the DLR is successfully received we'll see a log of it in our rails console.

```bash
Started POST "/sms_delivery_receipts" for 192.0.2.0 at 2020-01-01 12:00:00 -0500
Processing by SmsDeliveryReceiptsController#create as */*
Parameters: {"msisdn"=>"14155550102",
"to"=>"14155550101",
"network-code"=>"310090",
"messageId"=>"0C00000064064444",
"price"=>"0.00570000",
"status"=>"delivered",
"scts"=>"1577880000",
"err-code"=>"0",
"message-timestamp"=>"2020-01-01 12:00:00"}
SQL (1.1ms) UPDATE "sms" SET "status" = 'delivered' WHERE "sms"."message_id" = ? [["message_id", "0C00000064064444"]]
Completed 200 OK in 3ms (ActiveRecord: 1.1ms)
```

## To sum things up

That's it for this tutorial. We've set up our Rails application to receive webhooks, informed Nexmo where to find our server, and processed an incoming webhook with a Delivery Receipt.

You can view the [code used in this tutorial](https://github.com/Nexmo/nexmo-rails-quickstart/blob/master/app/controllers/sms_delivery_receipts_controller.rb) on GitHub.

*Note: Some US carriers do not support the feature. Also, if you are sending SMS to a Google Voice number, you will not get any receipt. We do not provide reach to other virtual number providers due to fraud prevention purposes. If you have any particular business case where you would like to be able to reach virtual numbers, please [contact our Sales Support team](https://www.nexmo.com/contact-sales)!*

## Next steps

In the next tutorial we will look at receiving inbound SMS messages into our application.