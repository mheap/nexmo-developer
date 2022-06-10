---
title: WordPress 2FA by Vonage is here!
description: Want Two-Factor Authentication on your WordPress site? We've got you covered!
thumbnail: /content/blog/wordpress-2fa-by-vonage-is-here/wordpress_2fa-vonage.jpg
author: james-seconde
published: true
published_at: 2022-06-14T09:23:37.027Z
updated_at: 2022-06-14T09:23:38.393Z
category: release
tags:
  - php
  - wordpress
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
One of the areas we are focused on this year at Vonage is Integrations, and with me being [the PHP Advocate in my team](https://developer.vonage.com/blog/21/10/11/james-seconde-joins-the-developer-relations-team) it would be impossible to ignore the Content Management System that powers [43% of the world's websites](https://kinsta.com/wordpress-market-share/).

So, it was time to create a plugin for WordPress, and the most logical product of ours to use was the Verify API (more on that shortly). The plugin has now been released for general usage, so in this article I'm going to walk through how to use it.

If you want a concise, short video tutorial which contains a summary of the plugin's usage, [you can find it here](https://www.youtube.com/watch?v=OYMGqh0R__k) (or below).

<youtube id="OYMGqh0R__k"></youtube>



#### What it Does

[The Vonage Verify API](https://developer.vonage.com/verify/overview) is a product from Vonage that allows developers and product owners to integrate two-factor authentication into their software using their Vonage account. The Verify API has a built-in workflow that enables you to choose the delivery medium for PIN codes it uses (SMS, Voice) and allows you to check against previous Verification flows via a unique Request ID assigned to each attempt to use it.

Our WordPress plugin wraps the API calls in this workflow to integrate it as part of the WordPress login process. So, your site account users will be able to enable 2FA.

#### Installing

You can install the plugin from [the WordPress plugin storefront](https://en-gb.wordpress.org/plugins/) which you can also access from your Plugins admin menu when logged into your site:

![Screenshot of the WordPress Admin Plugin page](/content/blog/wordpress-2fa-by-vonage-is-here/screenshot-2022-05-24-at-13.39.48-1.png)

Once you've entered the storefront, go to the search bar and type in `vonage`. You should then see the plugin:

![Screenshot of WordPress Storefront showing Vonage Plugin](/content/blog/wordpress-2fa-by-vonage-is-here/screenshot-2022-05-24-at-13.41.54.png)

Install and activate the plugin. Once activated, providing you are an administrator (we're going to assume you are here, as you were able to install a new plugin), you'll see the Vonage 2FA setup menu appear in the left-hand menu:

![Screenshot of WordPress Admin Menu now showing Vonage 2FA link](/content/blog/wordpress-2fa-by-vonage-is-here/screenshot-2022-05-24-at-13.43.25-1.png)

#### Vonage Signup + Credentials

In order to use the Plugin, we'll need a Vonage Developer account. Head over to [the Vonage Account Creation page](https://dashboard.nexmo.com/sign-up) and complete the signup process in order to create an account.

Once we have an account, we need the Master API key and API Secret. You can find them here:

![Screenshot of Vonage Dashboard, showing API Key and Secret](/content/blog/wordpress-2fa-by-vonage-is-here/screenshot-2022-05-24-at-13.47.13.png)

Copy the two keys into their respective fields within the 2FA plugin settings page, which looks like this:

![Screenshot of the Vonage 2FA Plugin settings page](/content/blog/wordpress-2fa-by-vonage-is-here/screenshot-2022-05-24-at-13.51.59.png)

Save your changes, and your account is all hooked up.

Now, each user can configure their 2FA settings. Head to a WordPress user profile and scroll to the bottom: you'll see the Vonage 2FA user settings here.

![Screenshot of a WordPress user profile with new 2FA settings added](/content/blog/wordpress-2fa-by-vonage-is-here/screenshot-2022-05-24-at-13.57.48.png)

You're all set. Enable 2FA and log out, and attempt to log in again.

#### Login Flow

What you'll now see when trying to log in is the new sign in flow. Instead of logging out, WordPress now requires you to complete the Verify process by entering the PIN sent out to your cellphone.

![Screenshot of new 2FA login form](/content/blog/wordpress-2fa-by-vonage-is-here/screenshot-2022-05-25-at-08.41.41.png)

Put in the correct PIN, and you should now be logged into your WordPress Dashboard.

#### Under the Hood

There's a little more to how this actually works, so here are some points on what is actually happening in the background:

* The Verify API charges per successful Verification as the default plan. For more information, check out the [pricing structure here](https://www.vonage.com/communications-apis/verify/pricing/).
* Your approved Verification is saved in your browser's session once you've successfully passed it - so if you change machines, wipe local data or your Verification expires at the Vonage end then you will be required to repeat the Verification step.

#### And There Will Be More...

It wasn't a totally smooth ride to write this plugin - from a technical point of view, I'd like to state the following: *Anyone who says WordPress Development is easy doesn't work with WordPress much*. There tends to be a certain snobbery around WordPress when it comes to Development, but the amount of tech debt accrued by the project over the years, plus the sheer volume of installations means that coding for this platform just *isn't easy*.

This was the first in my adventures into Integrations (although I also work with the Laravel core team as Vonage is the default carrier for outbound SMS messages), and there will be more to come. Coming soon in the near future will be *other* implementations of this 2FA workflow on other popular CMS platforms, so watch this space. For now, enjoy your increased security in your WordPress site!
