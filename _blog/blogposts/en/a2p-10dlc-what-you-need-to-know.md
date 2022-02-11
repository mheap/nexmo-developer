---
title: A2P 10DLC - What You Need to Know
description: "A quick overview of what 10DLC is and what you need to know moving forward. "
thumbnail: /content/blog/a2p-10dlc-what-you-need-to-know/10dlc_developers.png
author: caroline-kerns
published: true
published_at: 2022-01-17T14:54:38.888Z
updated_at: 2022-01-11T20:56:12.434Z
category: announcement
tags:
  - 10DLC
  - A2P
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Over the past couple of months, you may have heard the term "10DLC" and wondered what it means and why it's important. 

10DLC stands for 10-Digit Long Code. It is the new standard for Application-to-Person (A2P) messaging in the US, which applies to all messaging over 10 digit geographic phone numbers. 

They are also the fixed numbers you may bring over to Vonage for SMS provisioning. A 10 DLC number is essentially a local 10-digit phone number that can support higher volumes of text messages. Many experts anticipate that 10 DLC will become the new standard for business text messaging. 10 DLC numbers are designed and sanctioned by the termination vendors for A2P SMS messaging. This new standard provides many benefits to our users including supporting higher messaging throughput and better deliverability.

## Background of Long Codes

Long codes are essentially 10 digit phone numbers designated by the mobile operators for person-to-person communication. Some sample use cases include chat applications, anonymous dating applications, and customer service communications.

Historically in the United States, P2P (person-to-person) traffic (not A2P traffic) is permissible using a Vonage USA long code. Long virtual numbers are available [here](https://dashboard.nexmo.com/private/numbers#add_number) if your business does not already own one. There are also additional use case limitations for long code traffic, which can be viewed in more detail [here](https://help.nexmo.com/hc/en-us/articles/204017023-USA-SMS-Features-Restrictions).

## How is A2P 10DLC affecting the use of Short and Long Code Use

Since A2P (application-to-person) traffic on long codes has not been supported by the carriers historically, businesses have been forced to utilize short codes for their A2P needs. However, for carriers that are opting to launch and support A2P for 10DLC in the USA, this limitation will be lifted and A2P traffic will be allowed (with new guidelines).

You may wonder why additional option for A2P was introduced. The reason this new regulation has been introduced is to cut down on spamming and misuse of messages for illegal and intrusive activities. It also offers a cost effective option for customers to migraine off of US shared short codes.

**Please Note:** Adherence to new rules mentioned below is a requirement and fines will be imposed on accounts found to be non-compliant.

## What do I need to do?

If you don’t send messages to United States based users, you won’t have to do anything, but if you do, read on for important information:

There are two important requirements to keep in mind about the new A2P 10DLC system. These requirements are called “Brand Registration” and “Campaign Registration”. 

* First, businesses have to identify **who** they are to the carrier networks (Brand Registration). 
* Second, businesses must register **what type** of messages they are sending, i.e. notifications, etc. (Campaign Registration). 

Each wireless carrier is launching their A2P 10 DLC capabilities with unique guidelines and on different timelines. We’ve outlined the current fees for you on this page and will continue to update you with what we know, how the changes will affect you, and what you can do to ensure the optimum benefits of your services and solutions with us.

T-Mobile and AT&T’s new Code of Conduct prohibits the use of shared originators, therefore, Shared Short codes are not an acceptable format for A2P messaging.

Vonage customers using a Shared Short Code, must migrate SMS traffic to either a [10DLC](https://help.nexmo.com/hc/en-us/articles/360027503992), [Toll Free SMS Number](https://help.nexmo.com/hc/en-us/articles/115011767768), or [Dedicated Short Code](https://help.nexmo.com/hc/en-us/articles/360050950831).

Vonage customers using our Shared Short Code API must migrate to either our [SMS API](https://developer.vonage.com/messaging/sms/overview) or [Verify API](https://developer.vonage.com/verify/overview).

Customers using Dedicated Short Codes are not affected by these changes within the scope of 10 DLC.

## Carrier Fees

Various carriers have determined their own fees that are industry-wide. We will be passing on the additional surcharges to our customers at the same rate charged to Vonage. Other fees may be imposed by carriers. 

**Please note:** These carrier fees may be subject to change. We will do our best to keep our customers up to date.

Verizon:

* Pass-through fee for mobile terminated (MT) messages originating from long codes: $.0025 or €0.00208.

AT&T: 

* Pass-through fee for registered/unregistered traffic to mobile terminated (MT) messages: $.002 or €0.00166 per SMS. 

T-Mobile & Sprint:

* Pass-through fee for registered: $0.003 per mobile terminated (MT) and MO message. Pass-through fee for unregistered: $0.004 or €0.00332 per mobile terminated (MT) and MO message starting March 1st, 2022.

Other Carriers:

* Other wireless carriers are currently testing their solution and expected to follow suit and release their A2P 10 DLC service in the future. As soon as we hear more about the respective A2P 10 DLC releases for other wireless carriers in the US, we’ll update you with what we know, how the changes will affect you, and what you can do to ensure the optimum benefits of your services and solutions with us.

## Questions?

We understand that this may be very confusing to you as a customer. Please don't hesitate to reach out to us via the [Community Slack Channel](https://developer.vonage.com/community/slack) if you have questions.