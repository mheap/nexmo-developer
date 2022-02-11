---
title: "Developer Tooling for AI Bots: Where Are We?"
description: "[Video] Bot developers from Microsoft, Opearlo, and The Bot
  Platform discuss the developer tooling for bots and the bot deployment
  process."
thumbnail: /content/blog/developer-tooling-ai-bots/Bots-Clip9_800x300.jpg
author: sammachin
published: true
published_at: 2017-10-25T02:30:08.000Z
updated_at: 2021-05-07T16:27:48.322Z
category: inspiration
tags:
  - chatbots
comments: true
redirect: ""
canonical: ""
---
The developer tooling for bots makes certain aspects of building one painful. And the deployment process after it’s built has its own challenges. I spoke with senior bot developers from Microsoft, Opearlo, and The Bot Platform about the current state of bot tools and deployments. Watch the video of our conversation here, or scroll below the video to read the full transcript. <style>.embed-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style>

<div class="embed-container"><iframe width="300" height="150" src="https://www.youtube.com/embed/fe7Jo5Hkq2k" frameborder="0" allowfullscreen="allowfullscreen"></iframe></div>

## Developer Tooling for AI Bots: Where Are We? (Full Transcript)

**Sam Machin** _(Nexmo Developer Advocate & Alexa Champion)_: So...yeah, and one of the things I found is probably the tooling, particularly around building those voice models and things. It's all...a lot of them seem to be very browser-based. I mean, predominantly it's mostly Alexa but you're spending ages typing and clicking stuff into boxes.

> “you're spending ages typing and clicking stuff into boxes”

And to try and take... a lot of the actual code, the traditional Node, Python, C#, business logic of your bot is actually a very small piece of the bot, isn't it? There's a lot more structured data, probably in something like JSON or YAML or some form of syntax. But it's not...you can't easily just check that into GitHub and check it out and run a build. You have to copy and paste a lot of it in. Do other people find that? 

**Oscar Merry** _(Co-Founder & CTO at [Opearlo](http://www.opearlo.com/))_: Yeah, definitely. I think that's a big challenge. And I think I'm sure there are some solutions to that on the horizon because it does slow people down as they're making updates and making their bots and their voice apps better. 

**Martin Beeby** _(Technical Evangelist at [Microsoft](https://blogs.msdn.microsoft.com/thebeebs/))_: That is true actually. A lot of the cognitive services aspects of it, previously required—in the Microsoft world, at least—required you to go into a browser to do those things. I think we're getting past that now, at least on our platform. Almost every single one of them has code-based APIs where we can do a push. So that Q&A one that I was talking about, for example, you don't have to forward that over to a URL now. You can actually directly get to the API. So most of a build for a bot for us would be done in our DevOps platform, which for us would be Visual Studio Online. So we would be building all the build things that when we do a deploy to GitHub or whatever source control is, that would be the way that we would construct the entire bot. And there'd be lots of different build processes it's going through but now they are all codeable. And I'm not having to log into a website necessarily to update my LUIS model or to update my Q&A database. I can do that all programmatically. So it's kind of, for the larger sort of scaled systems where we need a more defined workflow, we are able, at least on the Microsoft aspect of it, I'm able to code that in a sort of DevOps pattern so we can release with confidence. 

**Sam:** That's really nice. 

**Martin:** But then there are edge cases to that where a new preview API comes, a new preview service comes out that we wanna use that doesn't have an API yet. Which always really irritates me when they release a web frontend to something but don't actually have a code API that I could ultimately push things through. But yeah, I think as these things become more real and more, sort of, serious, then you have to have a DevOps kind of release platform for it.

> “as these things become more real ... you have to have a DevOps kind of release platform for it”

**Sam:** Yeah. Syd, you're nodding. I guess you're a bit lucky because you guys are building this platform, this backend, whatever we're going to call it, engine or framework. How do you guys manage things like deployments and stuff? 

**Syd Lawrence** _(CEO & Co-Founder of [The Bot Platform](https://thebotplatform.com/))_: I mean, so we have various things ourselves. We've got our own API that some of our customers are hooking into to kind of extend it. We've got our system that has got...I mean, we're working with bigger and bigger customers who need a whole deployment process themselves, right? Where it can't just be a case of X person logs in and updates and boom, done, everything's ready. Because ultimately, they have approval processes themselves. So to me, it's a completely different paradigm. But yeah, we also have approval processes as well as APIs to do stuff more powerfully on top of our platform. 

_**[Editor’s Note:** Watch the [full one-hour discussion](https://youtu.be/InJe29Yz5UM) on the state of AI bot technology.**]**_