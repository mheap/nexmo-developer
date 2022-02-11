---
title: Build a ‘Clock in’ Service With the Shortcuts iOS App
description: Use the Shortcuts iOS application to work with the Vonage APIs
  through this example app that builds a 'clock in' service to switch on call
  phone numbers.
thumbnail: /content/blog/build-a-clock-in-service-with-the-shortcuts-ios-app/Blog_Clock-in_Shortcut-IOS_1200x600.png
author: julia
published: true
published_at: 2020-08-27T13:27:54.000Z
updated_at: 2021-05-11T17:02:04.061Z
category: tutorial
tags:
  - ios
  - low-code
  - no-code
comments: true
redirect: ""
canonical: ""
---
Years ago people didn't have phones, *places* did.

When trying to get ahold of somebody, you'd ring different places. They'd say the person isn't there, so you'd move on to calling the next place and the next, and then the next one. Until you'd have either reached the person or given up in the process.

Mobile communications flipped that on its head, and now we phone people because everybody has a little device. We can call a friend and talk to them, no matter where they are. Which is excellent for the majority of the use cases we find ourselves in.

However, sometimes we do want to phone a place rather than a person. And we don't care who we speak to, as long as we get through to someone who's *there*.  

Offices, shared houses, warehouses, equipment sites, etc. could benefit from that painful process from 20 years ago.

In this tutorial, we're going to use the [Shortcuts](https://apps.apple.com/us/app/shortcuts/id915249334) iOS app on an iPhone to bring that back, this time without having to install landlines. You'll be able to call *the* phone number of the place, and that will automatically be re-routed to whoever is in at the time of the call.

## Prerequisites

* [Shortcuts](https://apps.apple.com/us/app/shortcuts/id915249334) app installed on an iPhone or an iPad running iOS 12 or later

<sign-up number></sign-up>

## What Is Shortcuts?

![Image of Shortcuts logo and a few example screenshots from using the app](/content/blog/build-a-‘clock-in’-service-with-the-shortcuts-ios-app/shortcuts-appstore.png)

The Shortcuts app allows you to quickly automate repetitive tasks directly on your iPhone and iPad without the need to write code.

You can find hundreds of examples in the Gallery or build your own with just a few taps. 

### Actions

![Screenshot of the add new action button](/content/blog/build-a-‘clock-in’-service-with-the-shortcuts-ios-app/add-new-shortcut-action.png)

Each Shortcut comprises a series of actions.

An *action* is the building block of a Shortcut, a single step that performs a particular function.

Browse the over 300 built-in actions and use them with apps like Contacts, Calendar, Maps, Music, Photos, Camera, Reminders, Safari, Health, or any other app that supports Siri Shortcuts. 

Once your Shortcut is ready, you can launch it from the Today widget, from Search or by asking Siri. You can even add an app icon to your home screen for your favorite Shortcuts.  

## Build Your Shortcut

### 1. Get a Virtual Number

You'll need a virtual number to list as a contact number. We will later forward calls from this number to a personal phone number.  

In case you already have a Vonage number you'd like to use, find it under *Numbers >* *[Your Numbers](https://dashboard.nexmo.com/your-numbers)* in your [Vonage dashboard](https://dashboard.nexmo.com/your-numbers). Click on the pencil icon and make sure it is not already in use—settings will be overwritten by the next steps. If all voice config fields are blank, you're good to continue with creating your Shortcut.

![Vonage virtual number config fields in dashboard](/content/blog/build-a-‘clock-in’-service-with-the-shortcuts-ios-app/number-config-dashboard.png)

Alternatively, go to *Numbers >* *[Buy Numbers](https://dashboard.nexmo.com/buy-numbers)* and get a voice-enabled number. You can filter the search results by checking *VOICE* in the *Feature* drop-down. Pick one from the returned results, click *Buy* next to it and make a note of it as you'll need it in the next step. 

![Buy Vonage virtual number](/content/blog/build-a-‘clock-in’-service-with-the-shortcuts-ios-app/buy-number.png)

### 2. Create a New Shortcut

Next, move on to your mobile device.

Once you have the [Shortcuts](https://apps.apple.com/us/app/shortcuts/id915249334) app installed, please open it and click on the **+ Create Shortcut** button to get started on a new Shortcut.

![Create new shortcut](/content/blog/build-a-‘clock-in’-service-with-the-shortcuts-ios-app/create-new-shortcut.png)

### 3. Action 1: Ask for Input

The first action is collecting the user's phone number as text input.

Click on the **+ Add Action** button, then in the **Scripting** category under **Notification** select **Ask for Input**. Tap on the `Question` field and fill in the text you'd like to appear to the user when running this Shortcut. For example, "Set on-call number to:". Next, tap on *Show More* and make sure the `Input Type` is `text`.

![Action 1 finished, ask for input screenshot](/content/blog/build-a-‘clock-in’-service-with-the-shortcuts-ios-app/ask-for-input.png)

Click the **+** sign to add a second action.

### 4. Action 2: Get Contents of URL

Next, you'll set up the call forwarding from the Vonage virtual number to the one collected in *Action 1*.

To achieve this, you'll need to make an HTTP request to the [Numbers API](https://developer.nexmo.com/api/numbers?theme=dark) and update the number that incoming calls should forward to.

In Shortcuts, as a second action, select **Get Contents of URL** from the **Web Requests** section of the **Web** category.

Fill in the action so that it reads: 
*Get contents of `https://rest.nexmo.com/number/update?api_key=YOUR-API-KEY&api_secret=YOUR-API-SECRET`*, replacing `YOUR-API-KEY` and `YOUR-API-SECRET` with your API key and secret found in your [Vonage dashboard](https://dashboard.nexmo.com/).

Next, click on *Show More*, select *POST* as a *Method* and *Form* for *Request Body*. You'll have to add four text fields to the *Request Body*, as follows:

| Key                | Description                                                                                                           |
| ------------------ | --------------------------------------------------------------------------------------------------------------------- |
| country            | The two-character country code in ISO 3166-1 alpha-2 format. For example, GB for Great Britain.                       |
| msisdn             | Your Vonage virtual number in E.164 format. For example, 447401234567.                                                |
| voiceCallbackType  | Type `tel` to indicate that you're forwarding calls to a telephone number.                                            |
| voiceCallbackValue | Select `Provided Input` from the suggested *Variables* list. This will be the personal number captured in *Action 1*. |

![Image of Get contents of URL config fields in Shortcut](/content/blog/build-a-‘clock-in’-service-with-the-shortcuts-ios-app/update-vonage-number.png)

 You're all set to test your Shortcut! Click *Done*, then the **▶** button to test it out! Submit your personal number when prompted, then ring your virtual number to see the call forwarding in action.

### 5. Action 3: Append to File

As the final step, let's create a log of all submitted numbers to keep track of all people that had been on-call.

Click the **+** sign to add a third action, then under **Documents** select **Append to File** in the **File Storage** section.  

After the **Append** keyword, select **Provided Input** followed by a filler text like "clocked in on", then select **Current Date** with your preferred time and date formats. Choose between *iCloud Drive* and *Dropbox* as a *Service*, then fill in the *File Path* field and make sure that the *Make New Line* option is enabled.

Finally, click **Done** and run your Shortcut. Add it to your Home Screen or keep on building it! Let us know how it goes!

![image montage of finished Shortcut, updated number and logs](/content/blog/build-a-‘clock-in’-service-with-the-shortcuts-ios-app/final-run-shortcuts.png)

<style>
img.aligncenter {
  border-width: 0px !important;
}
</style>