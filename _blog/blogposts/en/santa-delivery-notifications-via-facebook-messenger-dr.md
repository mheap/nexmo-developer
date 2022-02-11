---
title: Santa Delivery Notifications via Facebook Messenger
description: In this tutorial we find out how to use geolocation and the Nexmo
  Dispatch API to send notifications via Facebook Messenger
thumbnail: /content/blog/santa-delivery-notifications-via-facebook-messenger-dr/Santa-Delivery-Notifications-via-Facebook-Messenger.png
author: leggetter
published: true
published_at: 2018-12-19T14:38:39.000Z
updated_at: 2021-05-11T09:37:34.468Z
category: tutorial
tags:
  - javascript
  - dispatch-api
comments: true
redirect: ""
canonical: ""
---
One of the biggest moments of excitement for me every Christmas as I grew up was waiting to hear if Santa had delivered our presents. Every Christmas morning my Dad would go through to the room with the Christmas tree to check *if* "Santa had been" before we were allowed to run to see our presents.

Now, as a Dad, the responsibility of checking for Santa's delivery is mine.

I've heard of some families getting up at 4am in the morning to open presents! This means that Santa can deliver to some homes pretty early in the morning. So, what am I to do? Am I expected to get out of bed and check under the tree every 30 minutes? As somebody who previously proclaimed to be a "Real-Time Web Evangelist" I'm not keen on the thought of what is effectively the physical version of HTTP Polling. No, no, that won't do. So I decided to build a Santa Delivery Notification system using the Nexmo Dispatch API with Facebook Messenger as the primary notification channel with fallback to SMS because I don't want to miss that notification.

![Santa Delivery Notifications via Facebook Messenger](/content/blog/santa-delivery-notifications-via-facebook-messenger/santa-delivery-notifications-compressor.gif "Santa Delivery Notifications via Facebook Messenger")

In this post I'm going to walk through the components used and how they come together to offer a Santa Delivery Notification solution. Details of the code won't be covered, but you can find all the [code on GitHub](https://github.com/nexmo-community/santa-delivery-notifications) along with instructions for running your own instance of the app.

## How it Works

The app uses a combination of a Node.JS application, the [Nexmo Dispatch API](https://developer.nexmo.com/dispatch/overview) to send the Facebook Messenger message with SMS fallback if the message isn't read, a Santa API written by [Steve Crow](https://twitter.com/cr0wst) for his [Tracking Santa with SMS and Java](https://www.nexmo.com/blog/2018/12/07/track-santa-sms-java-dr/) blog post, a Facebook Page and associated Facebook Application.

### Logging into Facebook

The first part of the application asks the user to log in to Facebook.

![Facebook Login Flow](/content/blog/santa-delivery-notifications-via-facebook-messenger/fb-login.svg "Facebook Login Flow")

This uses the [Facebook login](https://developers.facebook.com/docs/facebook-login/web/login-button/) button which relies upon the [Facebook JavaScript SDK](https://developers.facebook.com/docs/javascript/quickstart).

### Get the Users' Location

Whether Santa has delivered is determined using a combination of:

1. Where the user is located
2. Where Santa is on his delivery route

![Location flow](/content/blog/santa-delivery-notifications-via-facebook-messenger/location.svg "Location flow")

The user's location is determined using the browser [Geolocation API](https://developer.mozilla.org/en-US/docs/Web/API/Geolocation_API). This returns just the coordinates of the user as a best-guess.

The coordinates are sent to the Node.JS back-end that uses the API that was created for the [Tracking Santa with SMS app](https://github.com/nexmo-community/santa-tracker-sms) to find the nearest city for the coordinates.

### Get user's phone number for SMS fallback

Now that the application knows where the user is located we need to know how to deliver notifications. If the Facebook Messenger message remains unread, the Nexmo Dispatch API will fallback to also delivering the message via SMS. So, we need the user's phone number for that fallback.

![Get user's phone number flow](/content/blog/santa-delivery-notifications-via-facebook-messenger/get-phone-number.svg "Get use's phone number flow")

The user is to enter their phone number and click the "Go" button. Upon clicking the phone number is sent to the Node.JS back-end and the phone number stored for that user.

An enhancement to the current functionality here would be to use the Nexmo [Number Insight API](https://developer.nexmo.com/number-insight/overview) to ensure the phone number was valid and [Verify API](https://developer.nexmo.com/number-insight/overview) to confirm ownership of that phone number by the user.

### Subscribe for Facebook Messenger "Santa Delivery Notifications"

Probably the trickiest part of the whole application was being able to send messages to the user without having them first send a message to our Facebook page.

Eventually, I came across the [Send to Messenger plugin](https://developers.facebook.com/docs/messenger-platform/discovery/send-to-messenger-plugin) that seems to be set up for this. However, it does add some additional requirements around setting up a [Facebook application](https://developers.facebook.com/docs/apps/) and an ["opt_in" webhook](https://developers.facebook.com/docs/messenger-platform/reference/webhook-events/messaging_optins).

I also found that the "Send to Messenger" button didn't render unless the user was already logged in to Facebook. If you take a look at the [client-side JavaScript on GitHub](https://github.com/nexmo-community/santa-delivery-notifications/blob/4f6f07cb41b6a970192c92de36a7313f1f9abf76/public/index.js) for this app, you'll see some code in place to deal with a few caveats of using this plugin including having to reload the page when the user logs in to Facebook.

![Confirm subscription flow](/content/blog/santa-delivery-notifications-via-facebook-messenger/confirm-subscription.svg "Confirm subscription flow")

When the user clicks the "Send to Messenger" button (which you can configure to say instead "Subscribe") it will trigger the configured "opt_in" webhook from Facebook. The webhook payload contains the all-important [Page Scoped User ID](https://developers.facebook.com/docs/pages/access-tokens/psid-api) which is a unique ID for the user associated with a Facebook Page.

At this point, we save an official subscription within a database. This application uses a MongoDB instance managed by [MLab](https://mlab.com/).

With this ID the application can now send messages to the user using the [Nexmo Dispatch API](https://developer.nexmo.com/dispatch/overview). To confirm the subscription a message is sent informing them that they have subscribed and their location.

![Subscription confirmation dialog](/content/blog/santa-delivery-notifications-via-facebook-messenger/subscription-confirmation-dialog.jpg "Subscription confirmation dialog")

### Check Santa's Location and Send Notifications

With the subscription saved all that's left to do is monitor Santa's location using the previously mentioned Santa API.

![Santa delivery notifications flow](/content/blog/santa-delivery-notifications-via-facebook-messenger/santa-delivery-notifications.svg "Santa delivery notifications flow")

The application uses the user's coordinates with the API, and when the API indicates that Santa is moving `away` from the user's location, we know that Santa must have delivered. Thus, a Santa Delivery Notification is sent via Facebook Messenger using the Nexmo Dispatch API. If the message is not read within a configurable amount of time (see `expiry_time` in the [API reference](https://developer.nexmo.com/api/dispatch)) an SMS notification is also sent.

# Conclusion

In this post, we've covered how a Santa Delivery Notification using Facebook Messenger with SMS fallback can be built using the Nexmo Dispatch API. Please take a look at the [code on GitHub](https://github.com/nexmo-community/santa-tracker-sms) or [raise an issue](https://github.com/nexmo-community/santa-tracker-sms/issues) (or a pull request) if you've any ideas on making the application better (also see "Where next" below) or if you have any questions.

Now parents and guardians around the world can sleep easy knowing that they only need get out of bed to check if Santa has delivered once they've received that Santa Delivery notification.

# Where next

* Try out the [Dispatch API](https://developer.nexmo.com/dispatch/overview) standalone
* Add the [Number Insight API](https://developer.nexmo.com/number-insight/overview) to the application to check the number format or even that the phone number is located in the same place as the geolocation API indicated
* Use the [Verify API](https://developer.nexmo.com/verify/overview) to ensure the that user owns the phone number they are registering
* Let us know what you think by tweeting at [@NexmoDev](https://twitter.com/NexmoDev)