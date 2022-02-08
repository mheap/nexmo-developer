---
title: Text When You Get Home Safely with Zapier
description: Learn how to use Zapier to send SMS messages at the touch of a
  button.This tutorial will walk you through the setup step-by-step with no code
  required!
thumbnail: /content/blog/text-when-you-get-home-safely-with-zapier-dr/Blog_Home-Safe_1200x600.png
author: lornajane
published: true
published_at: 2020-04-09T12:00:45.000Z
updated_at: 2021-04-26T11:09:41.378Z
category: tutorial
tags:
  - zapier
  - no-code
  - sms-api
comments: true
redirect: ""
canonical: ""
---
When I go out with friends, we always ask each other to check in when we safely reach our homes. I always have good intentions of doing this, but after a late night, I sometimes forget, or it can seem too complicated. So I made a little setup to make this easier for myself. And best of all? It uses no code at all. By linking a smart button to the [Vonage SMS integration](https://zapier.com/apps/vonage-sms/integrations) on Zapier, I can send a friend a message at the click of a button. Today's post walks you through setting up something similar for yourself.

<sign-up number></sign-up>

## Set Up a Zapier Trigger

If you don't have a Zapier account already, you can [sign up on their website](https://zapier.com/sign-up/).

Once you're in, you're going to make a new "Zap" (the name for a Zapier task) by clicking on the big "plus" button on the top left-hand side.

![Screenshot of the Zapier user home page](/content/blog/text-when-you-get-home-safely-with-zapier/home-page.png)

The magic of Zapier is that it can wire one in-the-cloud thing to another. Our eventual destination is an SMS, but we will need an input trigger. I had a handy [flic button](https://flic.io/) lying around, but if there's something else you'd like to use as a trigger, that would be fine too! Have a good browse around the treasure trove of options on Zapier and find something that suits your needs.

![Photo of a cute blue flic button](/content/blog/text-when-you-get-home-safely-with-zapier/flic-button.jpeg)

The flic button configuration takes three steps:

* Decide what sort of event to use.
* Authenticate against your flic account.
* Set up which flic button and event (click, double click, or hold) will be the trigger.

![Configuration screen with blue button and click selected](/content/blog/text-when-you-get-home-safely-with-zapier/flic-config3.png)

Click "Continue", and the event is now ready.

## Send an SMS

![Search for Vonage and choose the Vonage SMS integration](/content/blog/text-when-you-get-home-safely-with-zapier/then-sms-zap.png)

Now configure the SMS to send when the button is pressed using your [Vonage API account](https://dashboard.nexmo.com/sign-up?utm_source=DEV_REL&utm_medium=github&utm_campaign=text-when-you-get-home-safely-with-zapier) information.

1. Search for Vonage and choose the "Vonage SMS" app.
2. Choose "Send SMS".
3. Authenticate with your credentials to link your Vonage API account with Zapier.

Now, the fun part! Time to customize the SMS to send.

![SMS Configuration screen showing fields for from, to and text of the message](/content/blog/text-when-you-get-home-safely-with-zapier/sms-settings.png)

* In the **From** field, the dropdown will show you the numbers you own. If you need to buy a number, you can do that on the <a href="https://dashboard.nexmo.com">Dashboard</a> and then refresh the list.
* The **To** field is the number to send to. Note that the number you enter here should be in [E.164 format](https://en.wikipedia.org/wiki/E.164), for example a UK number would start with `44`.
* In the **Text** field, compose the message to send to your friend.

Click "Continue" and then "Test and Review"—you should get an SMS to the phone number you supplied!

All that's left is to turn on your Zap and give it a name, then click "Done Editing".

![Complete screen, saying "Your Zap is on!" and with icons for the flic button and the Vonage SMS integration](/content/blog/text-when-you-get-home-safely-with-zapier/zap-is-on.png)

Press the flic button and an SMS should be sent. Every. Time. You. Press.

Sending an SMS to a friend to let them know you are safely home couldn't be easier. What will you build next? Let us know!