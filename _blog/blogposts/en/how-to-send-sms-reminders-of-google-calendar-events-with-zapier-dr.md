---
title: How to Send SMS Reminders of Google Calendar Events with Zapier
description: Learn how to send SMS reminders to Google Calendar event
  participants with the Nexmo SMS and Zapier integration.
thumbnail: /content/blog/how-to-send-sms-reminders-of-google-calendar-events-with-zapier-dr/E_Google-Calendar-Reminders_1200x600.png
author: nahrinjalal
published: true
published_at: 2020-03-04T18:22:53.000Z
updated_at: 2021-05-24T14:13:31.484Z
category: tutorial
tags:
  - zapier
  - sms-api
comments: true
redirect: ""
canonical: ""
---
Are your days packed with meetings and events? Do you find yourself wishing you had an assistant to remind you of what to anticipate next? Fortunately, there is a quick way to make sure you never forget about a meeting and to control how much time you give yourself to prepare for it.

In this tutorial, we will learn how to send SMS reminders prior to Google Calendar events with [Zapier](https://zapier.com/home), the workflow automation platform. This is a brand new integration (currently in Beta), and we're excited to bring you use cases that help eliminate unnecessary manual tasks and enable you to focus on what's most important. Keep reading to find out how you, too, can receive SMS reminders in a matter of minutes—no coding required!

### Prerequisites

To get started, you will need the following:

1. A Vonage account
2. A [Zapier](https://zapier.com/home) account

You'll receive complimentary credit to purchase SMS enabled numbers when first signing up for your Vonage account. The free Zapier plan allows for workflows containing two steps, which is all we'll need for this tutorial.

<sign-up></sign-up>

### Step 1: Create a Zap

Log in to your Zapier account and click the **Make a Zap** button on the sidebar. Zapier workflows are called Zaps, so you'll see that term used often.

Then, name your Zap by replacing the placeholder text in the header.

### Step 2: Create a Google Calendar Trigger

#### Choose App & Event

Under **Choose App & Event**, search for and select Google Calendar. Next, open up the list of options under **Choose Trigger Event** and select **Event Start**. This ensures our action (the SMS) will happen prior to the event.



![Create a Google Cal trigger](/content/blog/how-to-send-sms-reminders-of-google-calendar-events-with-zapier/zap1.png)

#### Choose Account

Now, select your Google account. If multiple options are presented, make sure that you choose the account containing the calendar you want to use in your Zap.

> Note: The calendar you plan to use must contain events. If it doesn't, go ahead and schedule an event for today's date, so we may use it later to test the configuration.

#### Customize Event

You will then be prompted to choose the calendar, enter how far in advance you'd like to receive SMS reminders, and a search term (optional). If you're interested in receiving reminders of only certain events, enter a term that may be used to find them. In the example below, SMS reminders will be sent only for the events with "meeting" in them.

![Customize Zap Event](/content/blog/how-to-send-sms-reminders-of-google-calendar-events-with-zapier/zap2.png)

> Note: As we are currently using the free plan, **Time Before** must be no less than 16 minutes. Feel free to upgrade your plan for more flexibility.

#### Find Data

Next, Zapier will attempt to find some sample data from Google Calendar to help set up and test the Zap.



![Find data to test Zap](/content/blog/how-to-send-sms-reminders-of-google-calendar-events-with-zapier/zap-data.png)

Select an event and click **Done Editing** to proceed to the next step. If Zapier has trouble finding data for the trigger, add a new event in Google Calendar and try pulling in more samples.

### Step 3: Configure the Vonage SMS Action

#### Choose App & Event

With Google Calendar configured, we're now ready to add the SMS action to the workflow! To start, search for **Vonage SMS** in **Choose App & Event**.



![Configure with SMS](/content/blog/how-to-send-sms-reminders-of-google-calendar-events-with-zapier/choose-nexmo.png)

Then, proceed with the default **Send SMS** action event.

#### Choose Account

Before we can move any further, we need to allow Zapier access to your Vonage account.



![Add Vonage account](/content/blog/how-to-send-sms-reminders-of-google-calendar-events-with-zapier/nexmo-account.png)

Enter the API key and API secret found at the top of your [Vonage dashboard](https://dashboard.nexmo.com) when prompted.



![Add credentials](/content/blog/how-to-send-sms-reminders-of-google-calendar-events-with-zapier/nexmo-prompt.png)

Once added, your account will appear as an option on the dropdown.

#### Customize Send SMS

With that, we are ready to customize the SMS!

As your Vonage account is connected, Zapier will pull in any SMS enabled numbers on your account and use them to prepopulate the **From** dropdown with options to select. If you haven't already purchased a number, use your complimentary credit to do so on the [dashboard](https://dashboard.nexmo.com).

Next, add the phone number you would like the SMS reminders to be sent to, including the area code. Then, construct the SMS template with as many details as you please. Zapier will pull in all sorts of data from Google Calendar that may be included in the message. Integrate the data directly within the **Text** field like so:



![Customize SMS](/content/blog/how-to-send-sms-reminders-of-google-calendar-events-with-zapier/customize-sms.png)

### Step 4: Test the Integration

#### Send Data

Let's **Send Data** to **Test & Review** the Zap and ensure it's functioning correctly.



![Test Zap](/content/blog/how-to-send-sms-reminders-of-google-calendar-events-with-zapier/final-test.png)

If the test is successful, you will receive an SMS reminder along with a success message.



![Receive success message](/content/blog/how-to-send-sms-reminders-of-google-calendar-events-with-zapier/success-zap.png)

Lastly, toggle the Zap on to make it live.



![Toggle Zap on](/content/blog/how-to-send-sms-reminders-of-google-calendar-events-with-zapier/final-zap.png)

That’s it! You're all set to start receiving SMS reminders prior to your Google Calendar events.

### What's next?

If you often have phone meetings scheduled, there will soon be a way to enhance this workflow even further. With the upcoming **Voice integration**, you can receive an SMS reminder *and then* be connected in a conference call between 2-50 participants. Automating workflows like this removes unnecessary manual work and enables you to focus your time and energy on what's most important.

If you would like to learn about more ways to automate tasks using a Zapier workflow, look out for more tutorials in this space soon!