---
title: "Bots and AI: What Is a Bot Platform, Exactly?"
description: The major providers in the AI bot space all offer roughly the same
  technology, but each one has its own terminology. Senior bot builders sort it
  all out.
thumbnail: /content/blog/ai-bot-platform/Bots-Clip7_800x300.jpg
author: sammachin
published: true
published_at: 2017-10-05T16:00:18.000Z
updated_at: 2021-05-14T09:47:01.330Z
category: tutorial
tags:
  - ai
  - chatbots
comments: true
redirect: ""
canonical: ""
---
The major providers in the AI bot space—IBM Watson, Microsoft Cognitive Services, Amazon Lex, Google APIs—all offer roughly the same things, but each one has its own terminology. From bot platform to bot channel to bot framework, I asked Microsoft Technical Evangelist Martin Beeby and CEO/Co-Founder of The Bot Platform Syd Lawrence to help me put technology to the terms.

Watch the video of our conversation here, or scroll below the video to read the full transcript.

<youtube id="pcxBc9xjrzw"></youtube>

## Bots and AI: What Is a Bot Platform, Exactly? (Full Transcript)

**Sam Machin**  *(Nexmo Developer Advocate & Alexa Champion)*: So let's get a bit more technical this time. So kind of, one of the things I've learned is that looking at, particularly if I'm looking across different platforms, I've been doing stuff with IBM Watson, with Microsoft's Cognitive Services, with Amazon's Alexa and [Lex](https://learn.vonage.com/blog/2017/05/11/nexmo-aws-lex-connector-in-public-beta-dr/), and the Google API, AI Google Assistance. Everybody's got different...everybody's doing roughly the same thing in a set of APIs.

They've all got a thing, they've got a speech to text thing. They've got some kind of natural language processing thing, they've got some kind of runtime thing. But they're calling them different names, different terminology. Is anybody sort of seeing any...I mean, for example, if we go back to our bot platforms, what is a bot platform? Syd, it's your company.

**Syd Lawrence**  *(CEO/Co-Founder of [The Bot Platform](https://thebotplatform.com/)):* Before we launched as The Bot Platform, they weren't called bot platforms. So we've been building our systems out since last April. And there were a few, what was called bot builders launched. And we...well, we believed that what we were creating wasn't just a bot builder but it was a whole platform for not just bots but also extending bots. And doing some various bits and pieces that we did behind the scenes. So we launched The Bot Platform.

Then in the last three months, I've noticed everyone has started to call them bot platforms. And now that makes it look like we...well, I can't work out whether it's a good thing because we were out first or whether it's a bad thing because people now just think that we're only called The Bot Platform because people are calling them bot platforms.

So ultimately, I've...so our initial aim is we've been building out a system to allow other people to create their own app messaging bots. And now what we've actually realized in the last six months is that people have got no idea what to do when they're presented with a technical solution like this.
`"people have got no idea what to do when they're presented with a technical solution like this."`
So I mean, it's not technical it's, kind of, you could describe it as a CMS to a degree. So what we're now doing is we're offering a service solution where we help build out the bot for them or with them to begin with and then hand over the technical solution later.

But yeah, ultimately they weren't called bot platforms until we launched The Bot Platform. So that's my answer to that question.

**Sam:** So tell me, I mean one of the debates I've wanted to hear is to me...okay. But I mean, the bot platform has to have certain things. Like Facebook Messenger on its own isn't a bot platform, is it?

**Martin Beeby**  *(Technical Evangelist at [Microsoft](https://blogs.msdn.microsoft.com/thebeebs/)):* We'd call that a...we would describe that as a channel in our terminology. So Skype or Facebook or whatever your platform or Kik or whatever—or Slack—we call them channels. And then we have a framework, a bot framework, which spans all of those things. So you can build for all of those things with one bot. With one bot framework, you can build for all those platforms.

But yeah, for all those platforms, for all those channels. See, we're getting confused with terminology already. I'm trying to help with the terminology and making more ambiguity. But yeah, we would call those channels and then we have a bot framework. We don't actually call it bot platform because we recognize that Syd was there first. So we didn't want to disrupt that area.

**Sam:** I think that's...yeah, definitely the channel channel is one of the things I'm seeing as an emerging terminology. The channel is how the user accesses the bot because the bot itself is...and most of these channels are really communication channels. They're originally designed for person-to-person chat primarily. Slack is a way you can communicate with other people. It's just where the only difference is instead of communicating with a person, you're communicating with a bot. So to the bot itself is living...is no more part of the channel than I am as the user. The channel is what connects me and the bot.

And I suppose in some of the more closely coupled systems, like Alexa perhaps, it's all-in-one. But as we've still got building things on existing communication channels, then yes. Then definitely there's a separation between the bot.

So Martin, what is your framework? What does your framework do at a generic kind of level? What are the features that make that up?

**Martin:** Roughly, it's a framework, a development kit, an SDK which works in either Node or C#. And you build this bot and it...both of those different languages slightly work slightly differently. But roughly speaking, we have a pattern for getting a message coming in and then passing messages back. We span all of the platforms. So yo would build one bot using either either node or C#...

**Syd:** It span all the *channels*.

**Martin:** Did I say platforms? Great. I span all the channels. And the idea being is you build one of these things and then we sort of stand there as an intermediary making sure it's available on all the different channels for you. But you build one bot.

More recently as well, you can respond with different responses depending on the channel that you're speaking on. So if I'm building a Facebook Messenger bot, for example, I probably wanna be heavy on the UI. Like, because Facebook Messenger guidelines talk about buttons and carousels and things like that. Well on some of the channels, they're much more restrictive about what the interface looks like. And maybe you're just delivering text in those instances or buttons or whatnot. So we build one bot but you can respond differently depending on the channel and the way that the message comes into you.

But the reason, the kind of...the proposition that Microsoft are offering is this saving of money. You build one single bot and then you can make it available on Skype, Facebook Messenger, and Slack.
`"You build one single bot and then you can make it available on Skype, Facebook Messenger, and Slack."`
<b>Sam: </b>What was the old adage of Java? "Write once, run everywhere."

**Martin:** Yeah we're in that...that's the idea of trying to making simpler and simpler. And the hope is that as more and more channels come on you can take the benefit of those without having...or having to do very little development work. And that's, when we're looking at international clients, that's really an important aspect of that because depending on the geography that you live in, different messaging platforms are more important in different geographies. So someone which is building these, a bot for maybe a Chinese audience would be looking at a whole different slew of social networks than someone which is looking to build one for North America.

So that's the concept that we're trying to deliver or help with to make developers more productive, because that's ultimately our game.

**Sam:** So your framework...so actually within that, to me there's probably a few things you’re doing. Because you've got some...you take the incoming messages from the channel and that's the entry point of your framework. But then presumably there's some sort of natural language...well, is natural language close? Potentially speech to text then natural language processing.

**Martin:** You absolutely can but you don't have to. Obviously if you want to, it's very, very simple to add in natural language understanding. Or we call it [LUIS](https://www.luis.ai), Language Understanding \[Intelligent] Service. It's an Azure service that you just add in language understanding and then you can tie that up to different functions based on the intent of the user. It's very straightforward to kind of use. But you don't need to use any of that. I mean, it's up to you.

**Sam:** You can just take the raw channel input into your code then, whatever the user’s typed into the Messenger or whoever can be fed to your code, or...

**Martin:** Absolutely. Absolutely. You could write, you could basically have your bot intelligence could all be based on Regex if you're really wanting to do that. But generally speaking, we would recommend—in most instances at least—to have some kind of language understanding service rather than trying to figure out what the user is trying to do in your bot. And most of the examples we generate include that.

But yeah, there's lots of different services we offer. We offer a Q&A service, for example. So you load up all of your questions and answers and we can serve that up as a bot for you very quickly and simply. You can do that almost with no code, using Azure functions as well. Which if you're familiar with AWS, they have this stack called Lambda which is like a serverless stack. We also have that same thing, it's called Azure Functions. And you can just, with a couple of clicks, deploy a bot to that, upload a question and answer sort of Excel spreadsheet. And it will then, your bot will be able to answer questions on a, like a frequently-asked question bot sort of thing. And so you're using machine learning to figure out the right thing.

**Sam:** I had a little play with that, actually. Yes, it's a rather cool way to get to your first bot. I think it took a Word document, even for me. I wanted just a key question and answer.

**Martin:** It would take a web page with a Q&A on it and convert that into a Q&A bot. And it's surprisingly accurate. It's not just doing pattern-matching, it's doing natural language understanding then mapping that. It's doing text rank and all that sort of clever machine learning stuff behind the scenes. But you, as a user, you can build a Q&A bot very, very quickly using something like that.

***[Editor’s Note:Watch the [full one-hour discussion](https://youtu.be/InJe29Yz5UM) on the state of AI bot technology.]***