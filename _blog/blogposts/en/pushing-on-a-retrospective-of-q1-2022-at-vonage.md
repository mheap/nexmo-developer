---
title: "Pushing On: A Retrospective of Q1 2022 at Vonage"
description: "Read what we've been up to in the first quarter of the year.
  Spoiler: it's a lot!"
thumbnail: /content/blog/pushing-on-a-retrospective-of-q1-2022-at-vonage/quaterly-releases_q1.png
author: james-seconde
published: true
published_at: 2022-04-07T09:12:14.664Z
updated_at: 2022-04-07T09:12:17.773Z
category: announcement
tags:
  - releases
  - messages-api
  - video-api
comments: false
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
## First Off...

One of the things we have been mindful of here at Vonage is going about our jobs while people, friends and colleagues' lives are affected or torn apart by current events. It feels disingenuous to simply write a roundup of what we have been up to without mentioning the ongoing war in Ukraine.

Our position is clear. We condemn the actions taken by the Russian Federation against Ukraine. We are strictly adhering to the sanctions that have been imposed by the European Union, United Kingdom and United States.

We are also supporting active humanitarian relief efforts for the Ukrainian people. Vonage is currently doubling individual donations internally for the following organisations:

* [Nova Ukraine](https://novaukraine.org/)
* [The Disasters Emergency Committee](https://www.dec.org.uk/)

## ...And Now, The Summary

Q1 in the Vonage Developer Relations team was always set to be something of a reboot. The world of tech events slowly started moving again, and we started booking events to our calendars. We are back on the road, doing what we do best: talking to developers.

Given that we are active once again off the back of [phenomenal events in Q4 2021](https://www.ericsson.com/en/press-releases/2021/11/ericsson-to-acquire-vonage-for-usd-6.2-billion-to-spearhead-the-creation-of-a-global-network-and-communication-platform-for-open-innovation), it's well worth taking the time to slow down a bit (we're a busy bunch, and [now there's more of us!](https://learn.vonage.com/blog/2022/03/23/zachary-powell-joins-the-developer-relations-team/)) and looking at what we have been working on, our content, and successes we've had here over the past three months of 2022.

## Turning Notifications To Conversations

One of the ideas we are concentrating on this year is revising how you communicate with your customers - in an ever-growing, hyper-connected world it is sometimes not enough to simply fire off notifications via typical mediums (email, SMS, etc). What we're looking at is how to turn these interactions from one-way traffic into meaningful conversations to enhance your business's ability to communicate.

### 10DLC

Application-to-person (A2P) messaging in the United States has seen the launch of a major new standard, 10DLC (which stands for 10-Digit Long Code). Messaging communications sent through the major carriers such as Verizon, T-Mobile and AT&T are now registered and signed to ensure system-generated communications are from a trusted source. You can read more about 10DLC and how it impacts your business [in our new documentation section dedicated to it.](https://developer.vonage.com/messages/10-dlc/overview)

### New WhatsApp Conversational Pricing

In February 2022, WhatsApp introduced a new pricing model for conversation-based messaging. In line with this, Vonage has introduced new enhanced conversation-based pricing, which affects initiated messaging between a customer and business in one 24 hour session. Our documentation has been updated accordingly - [you can find everything you'll need to take advantage of this new model here.](https://developer.vonage.com/messages/concepts/whatsapp)

## Video...Everywhere!

We're excited about the work the engineering and product teams are doing to evolve our Video API products, and this quarter has seen a handful of big updates for us to get our teeth into from a developers' perspective.

### Meetings API Early Access

If you're looking to use the Video capabilities of Vonage for meetings and want a solution to fast-track your MVP: we've got you covered! The Developer Relations team had the new Meetings API demoed to us, and we got excited. Before we get ahead of ourselves though, allow us to present a more formal [introduction to the API in this article from Avital Tzubeli](https://developer.vonage.com/blog/22/03/29/introducing-the-meetings-api).

### Experience Composer Beta Announced

Our Developer Advocate Garann Means [wrote an article on lessons learned after two years of Virtual Conferences](https://learn.vonage.com/blog/2022/03/14/lessons-learned-after-two-years-of-virtual-tech-conferences/), and how we approached Developer Relations during the time of COVID has certainly been a hot topic.

So, given our experiences with conference online platforms and the successes or failures of how they are implemented, what apt timing for the announcement that, as a developer, you can implement your own solution! The Vonage Video API now has a big feature update that introduces true immersive experiences for end-users The new feature called Experience Composer (Beta) goes beyond the old stream composition technique and lets developers capture entire applications UI for broadcasts and records. Below is just a sneak peak of what the Experience can do. We will be sharing more details here in the coming weeks. 

​​![](https://lh6.googleusercontent.com/XaFP6tqooZNPd7SSo5VRYdVbigZROqjFeRyEfMabD2E3TiCISA4_Vmzdh1x4h6YXCAUYZTUn2iswcOxv-VDGSwcRPf-SdBsISUZ1lwwiBEK_apIfmau0LtLt1bbqDBOSgMqNBRFV)

### Interactive Broadcast triples capacity and slashes latency

However, Vonage is not new to broadcasting. Our Video API Interactive Broadcast has been powering large-scale WebRTC and HLS sessions since 2016. 
These large-scale interactive experiences are now boosted with:

* Triple capacity for the real-time WebRTC sessions to support up to 15,000 active participants
* HLS latency reduced from 15+ sec to 4-6 sec for live streaming participant
* Stream with no additional costs to all major social media platforms such as Twitch and Facebook Live

You can read more in-depth about the new features in [this post, from Senior Product Manager Jon Montana](https://learn.vonage.com/blog/2021/05/11/video-api-better-interactive-broadcasts-and-recordings/#).

Naturally, our Developer Advocates wanted to get their hands on these new features to check them out. [In this article](https://learn.vonage.com/blog/2021/12/15/create-a-personal-twitch-with-vonage-video-api-and-web-components/) you can read up on our JavaScript Advocate [Dwayne Hemmings](https://twitter.com/lifelongdev)’ writing on [using the VideoAPI and Web Components to create a personal Twitch-like broadcasting platform](https://learn.vonage.com/blog/2021/12/15/create-a-personal-twitch-with-vonage-video-api-and-web-components/).

## Welcome, Jumper.ai!

Conversational Commerce is the idea that people of the future will do everything with their thumbs using social messaging, particularly on mobile devices, including shopping! In fact, social messaging-driven commerce is already a huge trend for major brands across Asia, using WhatsApp, Facebook, Facebook Messenger, Apple Business Chat, WeChat and other channels. This trend is now rapidly expanding in Latin America, Middle East, Africa and Europe (we’re even getting started in the US!)

If you want to learn more about conversational commerce and the Vonage Jumper.ai application, head to [vonage.com/jumperai](https://www.vonage.com/jumperai/). 

Jumper.ai, with its ready-to-go integration of messaging channels, payment gateways, inventory and shipping systems, and blending of chat-bot, live agent and AI interactions may be immediately useful for your eCommerce (now cCommerce) initiatives. Or, maybe this trend will motivate how you expand your own conversational use of our [Messages API](https://developer.vonage.com/messages/overview), perhaps with further omni-channel integrations with Video ([see here](https://ir.vonage.com/news-releases/news-release-details/vonage-strengthens-conversational-commerce-offering-video)) or Voice-based contact centers!

## Looking Ahead…

We’ve had a great start to the year, so now we’re looking at where we go next. Our Developer Relations team is looking to release more integrations to use Vonage APIs with more of your trusted/favourite libraries and frameworks (for example, the [newly released WordPress 2FA Plugin](https://en-gb.wordpress.org/plugins/vonage-2fa/)) so we’ll keep you posted as we roll them out. 

Want to chat with us? We’re on the road! You can catch at many events during the next Quarter, including:

* [APIDays (Singapore](https://www.apidays.global/singapore/))
* [International JavaScript Conference (London)](https://javascript-conference.com/london/)
* [DrupalCon (Portland, OR)](https://events.drupal.org/portland2022)
* [CityJS Brazil (São Paulo)](https://brazil.cityjsconf.org/)
* [Reactathon (San Francisco, CA)](https://www.reactathon.com/)
* [DevOpsDays (Birmingham, UK)](https://devopsdays.org/events/2022-birmingham-uk/welcome/)
* [NDC (London)](https://ndclondon.com/)

So, until next time where we hope the world will be a safer place, in better circumstances.
