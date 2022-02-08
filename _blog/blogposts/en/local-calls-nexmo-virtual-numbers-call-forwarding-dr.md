---
title: Make Local Calls with Nexmo Virtual Numbers and Call Forwarding
description: Use Nexmo to set up a a local rate number for friends and family to
  call, then forward their call so you can talk to your favourite humans
  wherever you are.
thumbnail: /content/blog/local-calls-nexmo-virtual-numbers-call-forwarding-dr/Local-Calls-for-Friends-and-Family-this-Christmas.png
author: lornajane
published: true
published_at: 2018-12-10T14:04:04.000Z
updated_at: 2021-05-10T10:37:43.009Z
category: tutorial
tags:
  - number-api
comments: true
redirect: ""
canonical: ""
---
If you have friends and family in more than one location, the ones that you are not spending Christmas with will probably complain about the costs of calling you at Christmas. At least, I'm pretty sure that's not just me! This post is an opportunity for me to share my favourite Nexmo trick for giving your dad (or whomever) a local rate number to call that won't cost you a small fortune if he decides to talk for an hour.

<sign-up number></sign-up>

You'll also need to [add some credit](https://dashboard.nexmo.com/billing-and-payments) in order to follow this tutorial (adding credit proves you're a real person, at which point you can buy a number). You will also need the [Nexmo CLI](https://github.com/Nexmo/nexmo-cli) installed.

## Get a Number in the "Right" Geography

My family are at home in the UK - I'm at home this Christmas too, but as a Developer Advocate I travel a lot and use this trick for people *(Hi Grandpa!)* who can't be expected to keep track of me all the time and know which number to call. First, I'll look at the UK numbers that are available with the `number:search` command and the `GB` code for the UK:

```
nexmo number:search GB --voice
```

The country code is in [ISO 3166-1 alpha-2 format](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) so pick whatever country you'd like. The cost of renting a number varies depending upon the country the number is from, you can always find the most up-to-date prices on [our pricing page](https://www.nexmo.com/pricing). You can also use `--pattern` to look for particular digit sequences.

I've seen a number I want to use, so I'll copy and paste it into the `number:buy` command:

```
nexmo number:buy 447700900000
```

Now I've got my number I can set it up to forward to my real number.

## Forward the Nexmo Number to the Phone You Want to Answer

Next, I'll set up the number I want to forward to. This is great because Nexmo has cheap calling rates everywhere, and if I need to forward to a different number because I'm using a local sim card somewhere, I can do so.

Here's the command that forwards the number I bought to the number I want to answer calls on (note to self: don't put your actual mobile number in the blog post this time!)

```
nexmo link:tel 447700900000 14155550100
```

All set! Test that everything is working by calling the Nexmo number you bought from another phone (or by asking a friend to call it). Rerun this command any time you want to update which phone the calls ring through to - much more straightforward than notifying every one of which number to use every few days! 

With a little bit of Nexmo magic, you can very easily stay in touch with your favourite humans this Christmas.