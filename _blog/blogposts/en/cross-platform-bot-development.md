---
title: The Promise and Challenge of Cross platform Bot Development
description: "[Video] Bot builders from Microsoft, Opearlo, and Nexmo talk about
  how developers should tackle cross-platform bot development challenges."
thumbnail: /content/blog/cross-platform-bot-development/Bots-Clip8_800x300.jpg
author: sammachin
published: true
published_at: 2017-10-13T17:12:16.000Z
updated_at: 2021-05-07T15:12:14.686Z
category: inspiration
tags:
  - chatbots
  - voicebots
comments: true
redirect: ""
canonical: ""
---
Building a text or voice bot that can be deployed across all the major bot platforms is not unlike trying to build a mobile app for iOS and Android a decade ago. I spoke with Opearlo Co-Founder / CTO Oscar Merry and Microsoft Technical Evangelist Martin Beeby about how developers should approach cross-platform bot development today and what it might look like in the future. 

Watch the video of our conversation here, or scroll below the video to read the full transcript. 

<youtube id="WUA7njFwuS8"></youtube>

## The Promise and Challenge of Cross-platform Bot Development (Full Transcript)

**Sam Machin** *(Nexmo Developer Advocate & Alexa Champion):* Cool. Yeah, Oscar, what are you guys finding with, particularly around with platforms? I mean, you're predominantly building on Alexa and Google Home. So very much the consumer vertical platforms. But how are you finding the platform tooling environments for that? 

**Oscar Merry** *(Co-Founder & CTO at Opearlo)***:** So I think one big challenge is that, as cross-platform on voice becomes more important, it is a little bit of a challenge to actually build for cross-platform voice. And I think we will start to see additional tools and additional platforms and SDKs that actually help developers build for cross-platform.

> it is a little bit of a challenge to actually build for cross-platform voice

What we advise right now is don't worry too much about it. If you want to build for voice, just focus on Alexa because it's got the biggest user base. And learn the lessons for voice on one platform and then at a later date you can expand it to Google or you can expand it to Cortana if you want. But I think, yeah, cross-platform going forward is gonna be really important. And right now it is a bit of a challenge. To give you an example, with the Google Home device and Google's platform, it's actually very confusing as a developer because there's actually two different ways you can build Google Actions. You can either use API.AI, which in itself is its own kind of bot platform or you can just use the Google Actions SDK and set it up that way. And if you're a brand, there's like a lot to digest there. So that is a big, I think, blocker to people really scaling their voice apps across all of the different platforms. And I think we will see, like, additional tooling, additional SDKs, additional frameworks come out to make that easier. 

**Sam:** I guess it's a little bit like it was with mobile apps, well, probably now 10 years ago when we had only iOS and Android. And you had to build for one and then the other. And then we started to see things like PhoneGap and these kind of platforms for building. Certainly, the simpler stuff where actually you can build a single...yes, this is probably an interesting market there for our PhoneGap or voice platforms as well. 

**Oscar:** There is a lot of stuff you can reuse across the different platforms. Like the things I've talked about so far are around making sure your content is voice ready so that the content the digital assistant responds with makes sense over voice. All of that stuff you can reuse from platform to platform. And all of those learnings you get you can get from just one platform. But yeah, I definitely think there's an opportunity for those types of tools. 

**Martin Beeby** *(Technical Evangelist at Microsoft)***:** I don't know if it's as bad as you described there, Sam. It's not really like iOS and Android were, in my opinion, because they have very deep-rooted things into the operating system, which are very difficult to make cross-platform. And it's a huge developer effort to make cross-platform. Most of the differences between, say, Google Home, Alexa, and say Cortana, they're usually not that deep embedded into the operating system. I know for at least porting Alexa to Cortana skills, it's actually your...they've tried to make it as simple as possible and as easy as possible. So whilst there probably is an opportunity for someone to make it even simpler, I don't think we're really in the problem space that we were with mobile apps, with iOS and Android. It's not that different, they're not that different. 

**Sam:** It’s still an interface, isn't it? It's what you just pass back and forward. Kind of, you're still putting in some text, you're getting a structured request and you're structuring a response. It's always request-response and you're not sort of dealing with low-level stuff in the same way, I guess. 

**Martin:** You're not having to recompile any application, create completely different system calls and potentially being on completely different processes. It's not that level of difficulty with cross-platform. It's a much higher level than that. Whilst there's still a problem, don't get me wrong, it's still...I don't think you're as tightly coupled to the platform, to the channel, to the bot framework, whatever, as you would be with the mobile app space. 

**Oscar:** I think it's less around porting your applications. We've actually ported quite a few Alexa skills over to Cortana. And you guys have made that really easy, actually. I think it's more about what you do after your voice app is live. So what we find on our client projects is that as soon as you get your voice app live, that's just the beginning. And that's where you start to get real insight into what people are doing, why people are frustrated. And you can update any backend code or backend logic. That's fine to update cross-platform because you can just do that. Where the challenge comes in is if you want to update a portion of the voice model on the Alexa Developer Portal and then you also wanna do that for your Google Action that's built through API.AI, and then you also wanna do that for Cortana, it's those kinds of things that is actually, from a workflow perspective, is quite difficult to manage because you have to think, "Have I updated it here? Have I updated it here? Have I updated it here?" That often requires going through some kind of recertification process. And it's more the management after you've got a voice app live on all of the different platforms that's just quite tricky to manage as a workflow.

> as soon as you get your voice app live, that's just the beginning

**Sam:** I mean, do you find it then...presumably, you manage them as separate. Once you...although you may be doing the same thing, they're actually separate apps, packages, skills, whatever you wanna call them and they have to have their own...and you may not have...so you may get a different version if you like. ‘Oh, that feature is live on Alexa but not live in Cortana yet or…’

**Oscar:** Yes, so we always try and share as much as of the, kind of, backend logic as we can because a lot of it can be reused. But yeah, definitely the kind of...however you define the voice model inputs that you give over to Alexa or Google or Microsoft, those things we keep separate. _

**[Editor’s Note:** Watch the [full one-hour discussion](https://youtu.be/InJe29Yz5UM) on the state of AI bot technology.**]**