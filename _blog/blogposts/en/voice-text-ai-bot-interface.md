---
title: "Bots and AI: Voice vs. Text for Your AI Bot Interface"
description: How do you decide whether your AI bot should be a chatbot or a
  voice bot? Tech leaders from Microsoft, Nexmo, Opearlo, and The Bot Platform
  share insights.
thumbnail: /content/blog/voice-text-ai-bot-interface/722483e8-a628-441d-a6cf-08356a5beb3a_Bots-Clip5_800x300.jpg
author: sammachin
published: true
published_at: 2017-09-21T19:12:09.000Z
updated_at: 2021-05-14T10:22:56.471Z
category: tutorial
tags:
  - ai
  - chat-bots
  - bots
comments: true
redirect: ""
canonical: ""
---
How do you decide whether your AI bot should be a chatbot or a voice bot? The context of the use case is an important factor of course, but should it be <span style="font-style: italic;">the</span> deciding factor or should you make both channels available to users? Microsoft Technical Evangelist Martin Beeby, CEO/Co-Founder of The Bot Platform Syd Lawrence, and CTO/Co-Founder of Opearlo Oscar Merry shared their thoughts from the frontlines of bot development.

Watch the video of our conversation here, or scroll below the video to read the full transcript.

<youtube id="EG3fOTWlSDs"></youtube>

**Sam Machin**  *(Nexmo Developer Advocate & Alexa Champion):* Voice versus text. So we've just been talking about some of the advantages of text for chatbots and there was something for voice bots. Do we need both? What's the pros and cons of each? Is it a case of the right one for the right situation? And should things be available on both channels? Are there some things where I might want to be able to let the user have exactly the same experience on voice and text or not?

**Syd Lawrence** *(CEO/Co-Founder of [The Bot Platform](https://thebotplatform.com/)*): I think some of the examples that Oscar was saying earlier like recipes or you're walking in from your car, like your hands are filled with shopping bags. I mean, that by far needs to be voice. Like, without a shadow of a doubt. I think there are certainly other contexts. Well, sometimes when you need a screen for feedback or screen for information where voice has issues. But yeah, context is definitely important.

**Oscar Merry** *(Co-Founder & CTO at [Opearlo](http://www.opearlo.com/):* Yeah. I think one thing that's really important to remember as well is that voice and text chat are very, very different. We see a lot of companies that have maybe built a chatbot for Facebook Messenger and want to then move that over to Amazon Alexa thinking that it will be a very simple process and we can just literally port it. And it doesn't work at all. And the same in the other way around, if we see companies that have an Alexa app and they wanna port that over to Facebook Messenger. And you really have to be careful doing that, you have to think about the context, as Syd said.

I would say, one thing where I do think eventually people and brands will need to be on both the chat platforms and voice which is people want to have that flexibility.

One thing that we talk a lot about is the driving use case. So Ford, BMW, and VW have all announced that they're bringing Alexa into their new car models. And you're seeing other car companies follow with the other digital assistants. And I think driving is actually gonna be, like a really, really big use case for voice going forward. But having said that, you can definitely see the use case where you're in your car, you're driving to work, you're interacting with your digital assistant there. And then as you get out of the car and you're walking maybe the next five minutes into the office, you continue that through Facebook Messenger. So I think you definitely have to think about both but as Syd said, they're very, very different and you have think about the context.

> "I think driving is actually gonna be, like a really, really big use case for voice going forward."

**Martin Beeby**  *(Technical Evangelist at [Microsoft](https://blogs.msdn.microsoft.com/thebeebs/)):* One of the challenges I think with voice at the moment is if you get into the weeds of actually designing a system in voice, sometimes there are unexpected problems and hurdles that are very difficult to overcome with the current technology.

So, for example, we built very recently an application with a company called [Beezy](https://www.beezy.net/). And they are an organization which tries to extract information from companies about their business. And so the use case is that the user's in their car and they're using their iPhone and they're using the Beezy application. And they record or they activate with Siri and they say, "Have we ever worked with Shell before?" As in the oil company or whatever.

And we got that working pretty simply and it was quite straightforward to figure out the intent and recognize the company, Shell. But then they were asking questions about, "Have we ever worked with a company Misco before?" And Misco is actually not a very common word that's being used in the regular English language. It's very specific to that domain or any company name.

And so most of the voice systems are trained against general English. They're not trained against specific companies or their domain-specific language. Another example is I recently worked on a voice bot for [Plexus Law](http://plexuslaw.co.uk/). And Plexus Law have lots of legalized, lots of legal English that they use inside of their dictations.

> "most of the voice systems are trained against general English. They're not trained against specific companies or their domain-specific language."

And so for example, they were saying...they were asking about a claimant. And most of the regular speech services were returning...instead of saying, claimant, they were referring that as Clementine, like the orange. And obviously, that then becomes really difficult to make any understanding of what the user actually wanted. So we've done a lot of research in our company on what we call custom speech recognition, which is like current speech technology but where you can feed it with reams of, sort of, domain-specific language so it can be more and more accurate.

And I think all of these scenarios around in car or...I'm not going to say Alexa again in case she pops up. But the Amazon-based chat systems and various things, they're all based around generalized speech patterns. And I think if we want these things to really take off, we're going to need domain-specific language understanding into these systems as well—per app, perhaps, domain-specific language understanding.

> "if we want these things to really take off, we're going to need domain-specific language understanding"

**Sam:** Yeah. So the way I've deployed the...the device you deploy in your office for, you know...and maybe it's even the different assistants, isn't it? I can think, especially with the voice thing, that the idea that you have this one device that has Alexa in it but actually, I might wanna have several different...so I have Alexa might be how I manage my home. So I have all my smart home and shopping and domestic kind of stuff in there. And then I have a completely different assistant with a different name which is how I handle my business stuff, call it Moneypenny or something.

And that kind of idea that we say I wanna talk to this one and then that puts us into a domain. Just like we open our work email or we open our personal email, or... people have different personas, different hats, don't they?

 **Martin:** I think one of the challenges maybe with the Amazon one at the moment is that if you speak to that, as the developer, you don't get access to actually what they said, the WAV file. And the same with our Cortana implementation is that you don't get access to where the WAV file is. So you have to rely on their speech to text.

So most of where we're doing more advanced speech to text systems, we're having to actually build that into apps ourselves rather than using these voice assistants. And I think that's a challenge which these large voice assistants or personal assistants are gonna have to overcome somehow. We're gonna have to give developers access to the WAV files, to the actual audio.

**[Editor’s Note: Watch the [full one-hour discussion](https://youtu.be/InJe29Yz5UM) on the state of AI bot technology.]**</em>