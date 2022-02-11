---
title: Get a “Beautiful Morning Weather” alert with Zapier and Vonage
description: Learn how to use Zapier to receive timed Voice notifications.This
  tutorial will walk you through building a weather alert Zap with no code
  required!
thumbnail: /content/blog/zapier-weather-voice-notifications-dr/Blog_Weather-Warnings_1200x600.png
author: julia
published: true
published_at: 2020-07-13T13:31:34.000Z
updated_at: 2021-05-05T09:31:59.813Z
category: tutorial
tags:
  - zapier
  - low-code
  - voice-api
comments: true
redirect: ""
canonical: ""
---
During the past couple of months, most people's lives and routines took a turn for the unexpected, and mine was no exception.

The rhythm I'd gotten into suddenly wasn't there anymore, and I've found myself in desperate need of bringing some structure back into my day-to-day.

My first action item was to reconquer my mornings and start the day on the right foot. I've found taking early morning walks in the sunshine quite uplifting. Throw in an audio book and it gets even better. Afterward, I'd feel energized and having already crossed off two items of my to-do list—exercise and reading, I'd be confident to tackle my day.  

Unfortunately, I found rainy, windy and cold British weather powered morning walks more depressing than uplifting. I'd always wish I had slept in for an extra hour, or simply curled up on the sofa with my morning coffee and a good book. 

Waking up early just to be disappointed was leaving me disheartened. Not the start to the day I was looking for.

If only there was an alarm clock that would only wake me up if the outdoors were welcoming, right? Right. 

In this tutorial, we'll build a Zapier workflow (Zap) that pulls real-time weather data at a scheduled time, then based on our preferred parameters, gives us a wake-up call only if the requirements are being met.

## Prerequisites

Before we get started, you'll need a couple of things:

* a [Zapier account](https://zapier.com/sign-up/)

<sign-up number></sign-up>

## A Word about Zapier

![Zapier Dashboard](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/zapier-dashboard.png "Zapier Dashboard")

### What is Zapier?

Zapier is a low-code tool that allows you to connect your favorite apps and services. It enables you to automate repetitive tasks without coding or relying on developers to build the integrations between two or more different services.  

To find out more about Zapier, visit their [Getting Started with Zapier](https://zapier.com/learn/getting-started-guide/what-is-zapier/)  guide.

### Common Terms: Learn to Speak Zapier

![Zapier workflow for weather notifications using Zapier's built-in Apps and the Vonage APIs](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/zapier-weather-notifications.png "Zapier workflow for weather notifications using Zapier's built-in Apps and the Vonage APIs")

#### Zap

A Zap is an automated workflow that performs repetitive tasks for you. It is the finished product that you're building, and it consists of at least two parts: a trigger (every day at 6:30am) and one or more actions (get weather data, then make a call).

#### Trigger

Each Zap starts with one trigger.\
A trigger is *the* event that sets off the Zap. Once you finish and activate a Zap, Zapier will monitor the app for that event. (Your Zap will only be triggered at 6:30am every morning)

#### Action

An action is an event that happens when your Zap is triggered. In our case, retrieving the weather data is an action. So is filtering the weather data, and making a phone call

#### Task

Each piece of data you run through your Zap counts as a task. That means, if your Zap sends out an SMS notification to 100 people, your Zap just performed 100 tasks. It's worth having the number of tasks your Zaps run in mind, as this helps determine which Zapier plan is best suited for your needs. 

## Build Your Zap

For this Zap, we'll be using a couple of [built-in Zapier apps](https://zapier.com/apps/categories/zapier-tools): 

* [Schedule by Zapier](https://zapier.com/apps/schedule) as our trigger.
* [Weather by Zapier](https://zapier.com/apps/weather) as the first action to get weather data.
* [Filter by Zapier](https://zapier.com/apps/filter) as the second action to define the conditions under which we want the Zap to execute the following steps.  

Then we'll have a look at two of the Vonage integrations: 

* [Vonage Voice API](https://zapier.com/apps/vonage-voice-api/integrations) to make the wake-up call.
* [Vonage SMS API](https://zapier.com/apps/vonage-voice-api/integrations) to deliver weather data to your handset via SMS.

To get started, click the **Make a ZAP** button on the top left corner of your [Zapier dashboard](https://zapier.com/app/dashboard) page.

### The Trigger: Schedule by Zapier

First, select [Schedule by Zapier](https://zapier.com/apps/schedule) from the list of available built-in apps.

![Select Schedule by Zapier from the list of built-in apps](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/select-schedule-zapier.png "Select Schedule by Zapier from the list of built-in apps")

This app offers three trigger events, based on how frequently you'd like your Zap to be run. In this case, select **Every Day** for a daily reminder.

![Events drop-down menu for Schedule by Zapier](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/schedule-trigger-event.png "Events drop-down menu for Schedule by Zapier")

Next, you'll be prompted to customize the time of the day you'd like your Zap to be triggered.\
Specify whether you prefer it to run on weekends or not, by selecting *yes* or *no* from the drop-down menu.

As for the *Time of Day*, either select a value from the drop-down menu or click **Custom** and type the desired value. For example, `6:32am`.

![Set frequency for Schedule by Zapier](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/schedule-customize-day.png "Set frequency for Schedule by Zapier")

Finally, Zapier will try to find test data for this event and you'll be presented with a set of test data. Have a look at these fields and make a note if you find any of the parameters interesting, you'll be able to pull them in dynamically in later steps! 

Click *Continue* to move on to the next step.

![Test data for Schedule by Zapier](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/schedule-test-data.png "Test data for Schedule by Zapier")

### Action 1: Get Weather Data with Weather by Zapier

The first action is getting weather data, and we'll be using [Weather by Zapier](https://zapier.com/apps/weather) powered by [Dark Sky](https://darksky.net/) to accomplish that. Head over to the [Dark Sky docs](https://darksky.net/dev/docs) to find out more about all the data that is being returned by their API.

To configure this action, first select **Get Current Weather** as an *Action Event*.

![Get current weather with Weather by Zapier](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/get-current-weather.png "Get current weather with Weather by Zapier")

In the *Customize Current Weather* section you'll have to fill in the coordinates of your location as *Latitude* and *Longitude* as well as whether you prefer the temperature data to be sent in Celsius or Fahrenheit.\
[LatLong.net](https://www.latlong.net/) is a handy website that returns latitude and longitude for any location of your choice.

![Customize fields for Weather by Zapier](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/customize-current-weather.png "Customize fields for Weather by Zapier")

Next, press *Test & Continue*.

![Press Test&Continue](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/weather-test-buttons.png "Press Test&Continue")

![Test data for Weather by Zapier](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/get-weather-test-data.png "Test data for Weather by Zapier")

Have a look at the test data and think about what parameters you could use to set your wake-up conditions. Would you like to be woken up only if the temperature is over a certain level? Maybe you have an issue with rain but love snowfall. Can't stand the wind blowing in your face and it pouring down at the same time? Me neither!
Shop around and see what matters to you the most. When you're ready, click the **+** sign to get started on the next action.

### Action 2: Set Conditions with Filter by Zapier

At this point, we have all the data required to make an informed decision about going out for a walk or curling up on the couch.\
Next, let's describe the case when you'd be up for a walk. What would the weather be like?

We'll use [Filter by Zapier](https://zapier.com/apps/filter) to set up our weather requirements. The Zap will only continue to run if these conditions are being met.

In this example, I picked `Precip Probability` (the chance it will rain) being less than `0.1` (10%), and `Apparent Temperature` (the temperature outside) greater than `0` (0 degrees celsius).  

Go ahead and have a play with it, create a couple of *Only continue if...* rules. To add a new condition, click either the **+ AND** or the **+ OR** button, depending on whether you'd like both (or all) conditions met for the Zap to continue running, or you'd be happy to wake up in case any of your conditions evaluate as true.   

If at any point you're unsure of the type of the weather properties or their format, check out the [Dark Sky docs](https://darksky.net/dev/docs) where each of the parameters is described in detail.

![Adding rules to Filter by Zapier](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/filter-rules-zapier.png "Adding rules to Filter by Zapier")

Once you're happy with your filter conditions, click the **+** button to move on to the next action.

### Action 3: Create Call with Vonage Voice

Start by searching for and selecting **Vonage Voice API** as the app for the third action.

![Select Vonage Voice](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/pick-vonage-voice.png "Select Vonage Voice")

Next, select an *Action Event* to determine how the call progresses. 

For this example, we'll choose **Create Text to Speech Call** to have a templated message read out to us once the call comes through.

Alternatively, you could go with **Create Stream Call** to have your favorite tunes streamed into your wake-up call, **Create Two Way Call** to have the Zap call both you and a second person, placing the two of you into the same conversation.

![Action events for Vonage Voice. Pick text-to-speech](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/pick-tts-vonage.png "Action events for Vonage Voice. Pick text-to-speech")

Some of Vonage's APIs, including the Voice API, use Vonage Applications to hold security and config information needed to connect to Vonage endpoints.

When prompted to provide your credentials, fill in your API key and secret found in your [dashboard](https://dashboard.nexmo.com/), then pick a name for your Vonage Application. Zapier will create this application for you, and you'll be able to find it in your Vonage account under *[Your applications](https://dashboard.nexmo.com/applications)* going forward.

![Vonage credentials pop-up in Zapier](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/vonage-credentials-zapier.png "Vonage credentials pop-up in Zapier")

Finally, you'll have to set a couple of parameters for the text-to-speech call.

1. Select one of your virtual numbers from the `Number You Want To Use For Caller ID` drop-down. This number will appear on the screen of your handset when the call goes through.  
2. Key in the `Number You Want To Call` in E.164 format. For example 447401234567.  
3. Notice that the `Content Of The Message To Read` field allows templating. This means that you can mix plain text with dynamic properties from previous steps. Remember all the weather data that came through? Yes, any of that. Take a moment and build the message that you'd like to wake up to. Have a look at the image below for some inspiration.  
4. Choose a `Voice` name from the drop-down menu to give your message some personality. I'll go for `Nicole, en-AU, female`.

When you're ready, click *Continue* and test your Zap.

![Customize Vonage text-to-speech fields in Zapier action](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/customize-tts-vonage-all.png "Customize Vonage text-to-speech fields in Zapier action")

Congratulations! Your Zap is ready to go, turn it on and rest assured that you won't miss a beautiful morning walk again!

![Create Vonage text to speech call final test in Zapier](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/vonage-test-zapier.png "Create Vonage text to speech call final test in Zapier")

## Extra Credit

### Action 4: Send Weather Data with Vonage SMS

I try not to be any fussier about my mornings than necessary; clothes on, coffee in hand, go, but sometimes it might be helpful to know whether that inviting morning sunshine comes with 5°C or 25°C attached.

We already have all the weather data from Zapier's built-in app, so it only takes one extra step to pick the entries we're interested in and have them delivered via SMS to our handset.

Click on the **+** button to add another action and search for **Vonage SMS API**.

Next, select **Send SMS** as the *Action Event* and continue. 

![Vonage SMS API integration in Zapier. Select Send SMS from action event drop-down](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/send-sms-vonage-zapier.png "Vonage SMS API integration in Zapier. Select Send SMS from action event drop-down")

Provide tour *API KEY* and *API SECRET* in the pop-up window to authenticate with the SMS API. Find these credentials in your [Vonage API dashboard](https://dashboard.nexmo.com/).

![Vonage SMS credentials in Zapier](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/vonage-sms-auth-zapier.png "Vonage SMS credentials in Zapier")

Next, you'll have to fill in a couple of details:

1. `From`: the number or text shown on a handset when it displays your message. You can set it to a custom alphanumeric value like "Weather Zap" if this feature is [supported in your country](https://help.nexmo.com/hc/en-us/articles/115011781468). 
2. `To`: the number you are sending the SMS to in E.164 format. For example 447401234567.
3. `Text`: the content of your SMS message. Feel free to use templating just like in the text-to-speech call action. For example, I was interested in a weather summary and the apparent temperature---see image below.

   ![Vonage Send SMS fields](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/customize-send-sms.png "Vonage Send SMS fields")

   When you're done, test your Zap and turn it on!

   ![Zapier test data for sending SMS messages vith Vonage SMS](/content/blog/get-a-“beautiful-morning-weather”-alert-with-zapier-and-vonage/send-sms-test-data.png "Zapier test data for sending SMS messages vith Vonage SMS")

   ## What's Next?

Fancy trying another tutorial?

* [Text When You Get Home Safely with Zapier](https://www.nexmo.com/blog/2020/04/09/text-when-you-get-home-safely-with-zapier-dr)
* [Send SMS Confirmations for New Stripe Charges with Zapier](https://www.nexmo.com/blog/2020/04/03/how-to-send-sms-confirmations-for-new-stripe-charges-with-zapier)
* [Send SMS Reminders of Google Calendar Events with Zapier](https://www.nexmo.com/blog/2020/03/04/how-to-send-sms-reminders-of-google-calendar-events-with-zapier-dr)

What will you build next? Let us know!