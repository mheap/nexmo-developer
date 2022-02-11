---
title: "Bots and AI: Bot Messaging vs. Push Notifications vs. SMS"
description: Where does bot messaging fit in among channels such as SMS, email,
  and push notifications? Tech leaders from Microsoft, Nexmo, and The Bot
  Platform discuss.
thumbnail: /content/blog/ai-bot-messaging-push-notifications-sms-dr/28a387ec-9942-4d9b-87e2-5f44fe7b1e58_Bots-Clip4_800x300.jpg
author: sammachin
published: true
published_at: 2017-09-14T15:30:00.000Z
updated_at: 2021-05-14T10:29:41.007Z
category: tutorial
tags:
  - ai
  - chatbots
comments: true
redirect: ""
canonical: ""
---
With so many channels available to deliver messages to users these days—SMS, email, push notifications, and so on—where does bot messaging fit in? And how different from the other channels is it really from a tech standpoint? CEO/Co-Founder of The Bot Platform Syd Lawrence and Microsoft Technical Evangelist Martin Beeby shared their viewpoints in a discussion that also touched on the influence of marketing interests in new channels.

Watch the video of our conversation here, or scroll below the video to read the full transcript.

<youtube id="wuKsfiNnzg4"></youtube>

## Bot Messages vs. Push Notifications vs. SMS (Full Transcript)

**Syd Lawrence** *(CEO & Co-Founder of [The Bot Platform](https://thebotplatform.com/))*: One of the things we found is... so, our stuff is either text- or button-based. I mean, ultimately it's kind of using Facebook Messenger as a platform, right? I mean, it's the messenger platform. And there is so many different use cases for different people. Interestingly, a use case that is never really discussed is, well, *messaging*. I mean, it's Facebook Messenger. You can send messages.

And so we did a big thing for the BBC last week for the general election where people could sign up for general election news and to find out when their vote for the constituency, when the count was done. And you got asked what your constituency was by your postcode. So 99% of the people entered a valid postcode because they knew exactly what type of data they should be adding. And that we weren't asking them to say, "I live in this postcode SO23." We were just saying, "What's your postcode?" And then once the account was done, they all got sent messages. And its messaging, and the numbers are far higher than most other platforms.

I mean, Sam, you know text, [SMS](https://www.nexmo.com/products/sms). I mean, Nexmo are great at SMS. And what's the beautiful thing about SMS? Being able to send messages to people and they read them. Like, that is the thing for us is the most interesting part about these messaging bots. I mean, people don't actually want to use them to chat with. They want to use them to complete specific tasks or find specific information.

> people don't actually want to use \[messaging bots] to chat with. They want to use them to complete specific tasks or find specific information.

So I have to admit I hate the word chatbot with kind of a bit of a passion. I get why people use it because there's so many different types of bots. But ultimately, people don't want to chat with these things, they want to use them to either access information or, yeah, be told various bits and pieces.

**Sam Machin**  *(Nexmo Developer Advocate & Alexa Champion): Yeah, they maybe converse with them.

**Martin Beeby** *(Technical Evangelist at [Microsoft](https://blogs.msdn.microsoft.com/thebeebs/))*: One of the things I really like about a messaging platform, which is not as easy to do in other platforms, is the ability to send sort of proactive messages or messages after-the-fact depending on the settings that they've agreed to with the bot. And so on things like Facebook you can—when you have some new information—send them a message like as you were describing there, Syd, about election results. That's something they've opted into and then at a later date, you can send them information about that. And what's really cool about the user experience there is that if they're using Facebook Messenger on their phone or whatever, they're gonna get notified of that just like they would a regular message coming in from one of their friends as well.

> One of the things I really like about a messaging platform ... is the ability to send ... proactive messages or messages after-the-fact

And we find that the open rate of those sorts of things is really high. Far higher than, say, what you might get with email send or even a tweet which you might send out as a company. And because it is personalized and because it is very specific to the information you requested. And that notification—or future notification or proactive messaging—is a really powerful, understated value of these messaging platforms.

**Syd:** And for us I think they're the pure value. Like that is the actual business case. So like you're saying, Martin, the numbers are huge, right? We get 99% read rates on anywhere between 20 to 40% clickthrough. Like, if you compare that to email marketing, it's something stupid like 3,798% more effective. Now, obviously don't spam people. Send people messages that they've actually requested and they want. But it's useful, right? Like, if you do it well, it's just insane.

> We get 99% read rates on anywhere between 20 to 40% clickthrough... if you compare that to email marketing, it's something stupid like 3,798% more effective.

And I get a question a lot which is do you think it's just because these things are new? Now, personally, I don't really. I just think that people are gonna be quite choosy with who they allow to do this.

Again, we do quite a bit of music. And if an artist has got their tour dates are out, and my favorite artist has just announced a tour and I wanna know when the tickets are on sale. And I want to know instantly when the tickets are on sale. Without messaging, messaging bots, your ways are:

* I liked them on Facebook, at which point I'm only gonna see it if I'm part of the 2% organic reach or if they boost to reach me or if I'm on Facebook at the correct time.
* I might follow them on Twitter. Ultimately, as we know, normal people don't use Twitter. And secondly, I’ll only see it if they tweet at the same minute that I'm on Twitter.
* Or thirdly, they might send it as an email at which point it gets lost with all my other spam.

So, there is no other way to get instant gratification unless you go down the route of SMS. Which is, like, still super powerful. And it is. SMS is the only standard that [everyone across the world uses](https://learn.vonage.com/blog/2017/02/16/global-sms-messaging-complex-world/). The problem is that it costs per message.

**Sam:** Yeah, it's a form of push notifications, really, isn't it? Yeah, I mean, it's this thing that actually I'm not gonna install an app for that. And I won't have an app installed from See Tickets or somebody that might push me, but they're probably telling me when every artist’s gone on stage. And I'm not interested in that. And, yeah, it's more of a controlled, specific push channel that you can subscribe to.

**Martin:** It's important to remember that it's ultimately, probably a push notification which is delivering it. I mean, probably the Facebook Messenger application which is delivering the push notification, isn't it?

**Sam:** Yes, yeah, it's a push. But again, it's like you said it. It feels more personal. Push notifications that come generically from apps with news. There's nothing more annoying than this app's pushing me a thing saying, "Oh, you should get this deal now." And I'm just like, "Yeah, yeah, go away." Whereas a push message saying, "You have a new message..."

**Martin:** I do want to go back to... Syd mentioned that he doesn't think it's gonna get too crowded. I do worry about whether it will or not, though. At the moment when you try and produce a bot, they're very clear about the kinds of messages you can send proactively, the kind of things that you can say. I do wonder or worry that that's gonna be exploited or misused to the point where we could switch users off. And I think that's an area where people like Facebook are gonna have to be really careful to make sure that people don't abuse those systems. Because it would be very quick for users to stop notifications on Facebook and to break this whole system.

**Sam:** Yeah, yeah. It's down to the the gatekeepers of each of these platforms, these environments. I think it's one of the things where I always thought SMS has still maintained its value. I mean, Syd said it costs money. And actually, that's a feature. Because it costs money, it's kept...organically, it's helped to keep down the spam and the noise problem. Because this company's only gonna send me a message, they're only going to spend a couple of cents sending me a message if it's got some value. So we can't just block them out for every little thing. There's a certain aspect of control there. I mean, the other one is, yeah, you have to bring in some sort of control obviously with Facebook or with any of the platforms.

> Because \[SMS] costs money, ...organically, it's helped to keep down the spam and the noise problem.

**Syd:** There's a couple of features that are all about designing, which is quite key on this. So I haven't seen many people do this on Facebook Messenger yet. But when you send out your notification, there are actually three types of notifications you can do.

* So you can get one which is sound and vibration, which is like a pure push notification.
* Then there's one which is a silent push notification.
* And then there is third, which is actually a no-push notification. It just appears in Messenger. So you can then send out messages that are totally non-interruptive, but when the user next logs into Messenger they see it.

**Sam:** And that’s a feature of Facebook Messenger, is it?

**Syd:** Yeah, correct.

**Sam:** There's something like that in IRS certainly within push notifications. You can choose on the notifications. I'm presuming they're just copying that through. But again, just about using it sparingly.

***[Editor’s Note: Watch the [full one-hour discussion](https://youtu.be/InJe29Yz5UM) on the state of AI bot technology.]***