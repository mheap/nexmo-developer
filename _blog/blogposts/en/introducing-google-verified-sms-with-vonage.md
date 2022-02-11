---
title: Introducing Google Verified SMS with Vonage (Early Access)
description: Verified SMS is a feature provided by Google for Android phone
  users whereby SMS messages have their content verified on a per-message basis.
  When a message is verified, the users receiving the messages will see the
  sender’s business name, their business logo, and a verified sender badge
  within the message thread.
thumbnail: /content/blog/introducing-google-verified-sms-with-vonage/Blog_Google_VerifySMS-1200x600.png
author: greg-holmes
published: true
published_at: 2020-10-15T13:34:42.000Z
updated_at: 2021-04-19T10:22:45.560Z
category: tutorial
tags:
  - messages-api
  - sms-api
comments: true
redirect: ""
canonical: ""
old_categories:
  - developer
  - product
  - real-time-communications
  - sms
---
Verified SMS is a feature provided by Google for Android phone users whereby SMS messages have their content verified on a per-message basis.

When a message is verified, the users receiving the messages will see the sender's business name, their business logo, and a verified sender badge within the message thread.

Businesses send trillions of messages each year to communicate with their consumers; however, it can be difficult to determine which of the received messages is valid and which is an attempt of phishing.

By using [Google Verified SMS](https://developers.google.com/business-communications/verified-sms), consumers using Android mobile phones will be able to see that they're receiving the SMS from a verified and trusted source, making sending SMS messages safer and more trustworthy, and increasing communication reach.

![Verified SMS comparison](https://www.nexmo.com/wp-content/uploads/2020/10/overview.png)

## How Does Google Verified SMS Work?

A typical flow for sending an SMS with Vonage is as follows:

Your application sends an HTTP API request to Vonage to send an SMS message. This method may be an SMS message via the `/sms` endpoint, or the `/verify` endpoint if performing a verification or 2FA workflow. After this, Vonage forwards this request to the carrier(s), who then delivers the SMS to the destined phone number(s).

This process is still the same for sending a Google Verified SMS. Some additional steps get handled in the background. First, you send an HTTP API request to Vonage to send the SMS, Vonage then checks whether the end user's device can receive a Verified SMS. If not, Vonage will send a standard SMS.

If the end user's device can receive Verified SMS messages, Vonage sends a one-way hash version of the message body to Google. Vonage will then send the SMS message to the carrier(s) who deliver to the destined phone number(s). Once the user's handset receives the SMS, so long as data transfer is available, it sends a hash version of the SMS content to Google, which is then compared to the hash message from Vonage to determine whether they match.

## How Can I Use Google Verified SMS?

This feature is currently in early access with limited availability. However, to register your interest, please contact our [API team.](https://www.vonage.com/contact-apis)

For this feature to work with your SMS messages, you will need to provide Vonage with a list of your Sender IDs that you would like to verify, your company logo, and your brand description. Both of which will be displayed to the customer when they receive an SMS.

Once Vonage submits the request to Google, you will receive an email from Google confirming that you would like Vonage to send Verified SMS messages on your behalf.

The good news is that you can continue sending your SMS messages the same way you are now, letting Vonage automatically detect whether you have registered as a Verified SMS source. If you are, then the SMS will be sent as a Verified SMS message; otherwise, Vonage will send the SMS as usual.

Don't forget, if you have any questions, advice or ideas you'd like to share with the community, then please feel free to jump on our [Community Slack](https://developer.nexmo.com/community/slack) workspace, or send me a [Tweet](https://www.twitter.com/greg__holmes). I'd love to hear back from anyone that has implemented this feature or how it would benefit your project.