---
title: The Coder's Guide to SMS
description: " In this guide, you will learn what SMS is, how companies are
  using it, the difference between SMS, MMS, and OTT, and more!"
thumbnail: /content/blog/the-coders-guide-to-sms/coders_guide_sms_1200x600.png
author: cory-althoff
published: true
published_at: 2021-08-19T08:09:02.915Z
updated_at: 2021-07-28T22:29:00.959Z
category: inspiration
tags:
  - python
  - sms-api
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
As a programmer, you may have come across SMS, which stands for short message service,  but you may not know much about it. SMS is a service for sending short messages over wireless networks using standardized communication protocols.

Neil Papworth sent the first SMS message on December 3, 1992. He wrote Merry Christmas to his co-worker Richard Jarvis, despite Christmas being almost a month away. An SMS message is one of two technologies for sending a text message: the other is called MMS.

Today, over [four billion people send text messages a year](https://www.smseagle.eu/2017/03/06/daily-sms-mobile-statistics/). Companies are increasingly using text messages to reach their customers on their mobile phones because they are convenient, [and customers prefer them](https://www.pcmag.com/news/businesses-take-note-your-customers-prefer-texts). They also have a 98% open rate, which is significantly higher than other forms of communication like email. 

In this guide, you will learn everything you need to know about SMS as a programmer. You will learn what SMS is, how it works, and how companies use them to communicate with their customers. You will learn the difference between it and MMS and OTT applications, as well as a few cool features that not many people know about. Finally, I will also point you to resources that will teach you how to send a text message programmatically in just a few lines of code.

### The History of Short Message Service

Neil Papworth sent the first SMS message in 1992, but its origins started nearly a decade earlier. Historians credit  Friedhelm Hillebrand and Bernard Ghillebaert with inventing SMS at the Franco-German GSM corporation in 1984. Matti Makkonen often called the father of SMS, is often credited for the idea, too, though [he credits Hillebrand and Bernard](https://techcrunch.com/2015/07/22/why-isnt-the-inventor-of-sms-better-known/) with its invention.

Text messaging started gaining traction in 1993 when Nokia released phones that supported the new technology. From 1993 to 1994, mobile phones only supported multi-tap texting (you had to tap numbers to get letters). Texting became faster in 1995 when Cliff Kushler invented the predictive text technology T9, but texting became even more convenient in 1997 when Nokia added the QWERTY keyboard to its phones.

MMS came to mobile phones in 2002, which allowed users to start sending photos and videos to each other. In 2007, Apple launched the iPhone, which helped further popularize text messaging. Texting has continued to grow since then, and [today the world sends six billion texts a month.](https://shso.vermont.gov/sites/ghsp/files/documents/Worldwide%20Texting%20Statistics.pdf)

### How Do Companies Use SMS?

![A picture of a laptop](/content/blog/the-coders-guide-to-sms/digital-marketing-1433427_640.jpg)

More and more companies are using SMS to communicate with their customers because [customers prefer SMS over other forms of communication.](https://www.pcmag.com/news/businesses-take-note-your-customers-prefer-texts)

Some companies use SMS for two-factor authentication: a popular way to help confirm a customer possesses the phone number they signed up for a service with.

Companies also use SMS  for mobile marketing. With a 98% open rate, they are one of the most effective ways to keep customers updated about the status of their order, sales, and any other essential things customers need to know. SMS messages also are read quickly: [90% of all text messages are read within three seconds](https://www.tatango.com/blog/sms-open-rates-exceed-99/), which means SMS marketing is perfect for things like flash sales.

Some companies also use them for customer service. For example, many hotels are creating text messaging systems to better communicate with their guests.

Another use case for text messages is alerts and reminders. For example, hair salons often remind customers about their upcoming appointments using text messages, and banks send alerts via SMS when they think a customer’s card might be compromised.

### The SMS Standard

![A picture of the earth](/content/blog/the-coders-guide-to-sms/screen-shot-2021-07-28-at-3.36.51-pm.png)

SMS lets you send 160 characters of text or 70 characters in Unicode. But, of course, you’ve probably sent an SMS message longer than 160 characters before, so how is that possible? When you send an SMS message longer than 160 characters, your phone carrier breaks the messages up and sends multiple messages.  However, your phone carrier makes sure they arrive in order, which is why you’ve probably never noticed the 160 character limit.

When you send an SMS message, it does not go directly to the recipient's phone. Instead, your message first gets sent to a Short Message Service Center (SMSC), which looks up the recipient and sends the message to them: similar to SMTP.

Here is a diagram that shows how it works:

![A diagram explaining how SMS works](/content/blog/the-coders-guide-to-sms/sms_chart.png)

The MS at the bottom left, and right stands for mobile station: the mobile phones sending and receiving the SMS message. When you send a message, your phone first sends it to a BSS, which stands for base station sub-system. The BSS manages the radio network. The BSS then sends your message to an MSC or mobile switching center. 

The MSC is the phone exchange serving your area (your city, for example). Your text message then travels from the MSC to the SMCS (short message service center). Your phone has an SMCS address that looks like a phone number configured in it, sometimes on your SIM (although iPhones do it slightly differently). 

Your SMSC then uses an HLR (Home Location Register) to find where the recipient is. It gets back an SMSC address for the recipient and sends it to their MSC and back the same path to the recipient's phone.

### SMS VS. MMS

As you learned earlier, when people say the word text message, they mean SMS and MMS. MMS stands for multimedia messaging service and allows you to send messages that include multimedia content over wireless networks.

When you send a text message that only has text, your phone uses SMS, but it uses MMS if you include a picture or video in your message. Because SMS messages only contain text and have a 160 character limit for the length of the message, they are cheaper to send than MMS messages.

 In addition, many people in the U.S. also have unlimited texting plans, so using SMS often means your users won't have to pay anything. Unlike when you use the short message service, which has a 160 character limit, you can send an MMS message with up to 1,000 characters.

Another thing to keep in mind when deciding whether to use SSM or MMS messages is while most people have a smartphone, not everyone does, and your customers without one cannot receive MMS messages.

MMS messages do have some advantages, though. Because MMS messages can include videos and pictures, they often have higher engagement rates and may get shared more on social media.

### How OTT Applications Work

![WhatsApp icon on iPhone](/content/blog/the-coders-guide-to-sms/whatsapp-892926_640.jpg)

Apple's iMessage, WhatsApp, WeChat, and Facebook Messenger are examples of "Over the Top" or OTT applications for instant messaging. Unlike SMS, OTT applications like WhatsApp do not require the user to connect to a cellular network.

OTT applications like iMessage and WhatsApp do not use SMS. However, that does not mean iPhones do not send them: they do. You can only send an iMessage if you and the recipient both have an iPhone. If you send a text message on your iPhone to another Apple user, Apple will send the text using iMessage, and your iPhone will highlight the message in blue.

 If you send a text message (without multimedia) to another device (like Android), Apple will send it using SMS, and the message will be green. On the other hand, Android devices often use Android Messages when two android devices communicate.

The advantages of OTT applications are they are free to customers who have unlimited data plans (and inexpensive for those who do not), allow users to send videos and other multimedia, and often have additional features like video chatting.

SMS has several advantages over OTT, however. OTT applications are "walled gardens," which means someone on Facebook messenger cannot message someone on WhatsApp. It also means you cannot send messages to phone numbers with OTT applications: you can only send messages to people who have downloaded that app.

 With SMS, you can send a message to anyone with a phone number. Plus, short message service messages do not rely on internet connectivity as OTT applications do. Unlike OTT applications, you can send a message to anyone connected to a cellular network with SMS.

### SMS Can Do what?

SMS has many cool less-known features. For instance, did you know you can edit an SMS message after you've sent it? Well, you can! You can "overwrite" a message you previously sent.

 However, you must set this up in advance. You cannot edit the text you already sent someone last night!

You can also use SMS to send a flash message, also called a class zero message. A flash message is a message that pops up on your phone but, by default, doesn't save to your inbox. The point of a flash message is to send something that the receiver won't save by default. In other words, a flash message is a precursor to Snapchat's famous ephemeral messages.

 However, just like Snapchat, it is possible to screenshot a message, it is also possible to download a class zero message (or screenshot it), so you cannot entirely rely on it for secrecy. Another use case for a flash message is sending a message you want the recipient to read immediately.

### Sending an SMS Message Programmatically

![A picture of a laptop](/content/blog/the-coders-guide-to-sms/work-731198_640.jpg)

You can easily send an SMS message programmatically using an API like the one we have at Vonage. 

Using our API is simple: you can send a message in just a few lines of code.

You can learn how to send an SMS message with our API by [reading our SMS API documentation](https://developer.nexmo.com/messaging/sms/overview).

We also have many blog posts that walk you through sending SMS messages with various technologies. For example, this article shows you [how to send an SMS message using Python and Flask](https://learn.vonage.com/blog/2017/06/22/send-sms-messages-python-flask-dr/), and this article [teaches you how to send an SMS message using Node Red.](https://learn.vonage.com/blog/2019/04/24/receive-sms-messages-node-red-dr/)

You can also [browse through our entire list of SMS articles and tutorials here.](https://learn.vonage.com/tags/sms-api/)

### Final Thoughts

With its convenience, ubiquity, and high open rates, SMS is a cornerstone of business communication. 

Now that you've read this guide, I hope you have a basic understanding of SMS and are ready to continue learning more about this communication method that is only growing more important.

If you want to send SMS messages programmatically, the [Vonage SMS API documentation](https://www.vonage.com/communications-apis/sms/) is the best place to start. 

[You can create a free account and start using Vonage's SMS API here.](https://dashboard.nexmo.com/sign-up?icid=tryitfree_api-developer-adp_nexmodashbdfreetrialsignup_nav)

You can also learn [how to make voice calls here. ](https://www.vonage.com/communications-apis/voice/)

I hope you enjoyed this guide, and [please reach out to us on Twitter](https://twitter.com/VonageDev) if you have any questions!