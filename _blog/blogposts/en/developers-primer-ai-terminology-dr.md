---
title: A Developer’s Primer on AI Terminology
description: Bots, AI, Machine Learning, Digital Assistants. Are they all the
  same thing? What are the differences? We explore AI terminology.
thumbnail: /content/blog/developers-primer-ai-terminology-dr/AI-Terminology_1200x675.png
author: sammachin
published: true
published_at: 2018-11-12T17:01:29.000Z
updated_at: 2021-05-04T13:35:20.935Z
category: inspiration
tags:
  - ai
comments: true
redirect: ""
canonical: ""
---
If you’re a developer working on customer communication tech, you’ve almost certainly started to explore how AI can enhance what you’re building. And during your research you may well have looked back on your CS courses then wondered if the AI that people talk about today is the same thing that computer scientists have been working on for the past few decades. 

Here I’m going to cut through some of the marketing hype that’s grown up around AI by defining the various terms in use. There’s a lot of useful new technology that can improve customer experience and help make customer communication more efficient. But to get there, we need to be clear on what we’re dealing with. Let’s start with bots.

## Bots

Bots have a long history in computing. They’re automated tools that go about their tasks unaided by humans: think search engine web crawlers, IRC autoresponders, and even non-player characters in video games. You might have written one or two yourself. 

When thinking about bots in that context, it’s obvious that AI isn’t necessary for most of them. It’s the same with bots that we find in customer communication. The bots that get mentioned in the same breath as AI are usually conversational interfaces. 

Take [Dom](https://www.dominos.com/chat-pizza-order/), Domino’s customer service bot. Dom ‘talks’ customers through an order, payment, and delivery but nothing that it does is intelligent. The thing about just all bots in use today is that they’re decision trees, rather than AIs. And, of course, a decision tree is really just a bit switch statement: if this happens then do this. 

Crucially, the bots we see in operation today do not learn. At some stage, one of your executives might excitedly ask your team to build a bot that can replace human contact center agents. Here’s the problem with that: today’s bots are only as good as whatever data you feed into them. For example, our pizza bot won’t look back at a customer’s purchase history and “intelligently” create a special offer for them; that is unless a human programmed it to do that. If that decision tree doesn’t cover the specific situation then you’ll need to escalate to a human or disappoint the customer. 

That doesn’t make bots any less useful, though and, actually, they do make use of AI. AI techniques make it possible for bots to turn spoken language into text and then to parse that text to uncover meaning. 

Such a conversational interface means that we can allow customers to self-serve in many more situations. Whereas now that’s pretty much limited to web or mobile, bots open up more channels, including [WhatsApp](https://www.nexmo.com/blog/2017/12/18/whatsapp-customer-messaging-platform/), SMS, Facebook Messenger, Slack, and so on, even voice without the help of a human agent.

## Artificial Intelligence

So, then, what is AI in the context of customer communication? If you have studied computer science formally, then AI probably makes you think of the Turing test. You’ll also know the distinction between strong and weak AI:

*   **Strong AI**: a genuine intelligence that’s able to think for itself (Star Trek’s Data, for example).
*   **Weak AI**: software that uses intelligence-like techniques to go beyond the strictures of whatever the developer programmed.

The AI we see in customer communication is most definitely of the second type and tends to be one of two things: a statistical model or a neural network. Both approaches take an input and produce an output that is a best guess. For example, an AI may receive an audio file as input and produce a text-based best guess as to the spoken words found therein. Those best guesses tend to be pretty accurate, thanks to huge amounts of machine learning––more on that below. Feeding that resulting transcription into a decision tree would give us a voice interface to a bot. 

The point is that modern AIs are algorithms that are good at making guesses and they make so many guesses in such short a time that they appear to learn for themselves really quickly. Even Google’s DeepMind behaves in a similar way. When DeepMind is playing Go, it takes the current state of the board, looks at moves that have worked well in the past, and guesses at what is likely to be the best move it can make. 

As developers, we must be careful to manage expectations around what today’s AI can and can’t do. Remember, even the best bot platforms can’t yet learn how to be better bots. 

While our colleagues might expect that we’ll be able to create largely automated contact centers, it’s our job as developers to show that AI is a useful technique but that truly intelligent machines are still some way off.

## Machine Learning

Machine learning comes up almost as often as AI and it’s one of the techniques that enables AI. Earlier, I mentioned statistical models and neural networks. Both of these approaches require data scientists to compile a large corpus of data to use as training material. 

In the former case, scientists must pick, choose, and tweak statistical models that take the best possible guesses given the data. In the latter, data is fed continuously into a neural network such that each iteration improves the performance and accuracy of the algorithm. The process of discovering and improving upon the underlying guess-model is known as machine learning. 

In short, ML is a process for training AIs.

## Assistants

And now, the assistants: Alexa, Siri, Cortana, and Google Assistant, amongst others. 

Unlike bots, which are focused on a single task and quite a rigid flow through that task––i.e. ordering pizza, where you start with the base, move onto toppings, and then sides––an assistant combines the techniques we’re covering here to create a unified interface to multiple services. 

So, it uses AI-techniques to transcribe spoken language into text, which it then parses with another AI-based technique called Natural Language Understanding. The assistant then connects to whichever bots will complete the given task, such as providing an interface to a pizza ordering bot. In just the same way, it could turn your thermostat up, find the best value flight from Bristol to Amsterdam, and tell you what’s playing at your local theater. 

In customer communication, we can use the big name assistants as just another channel through which customers can access our services. However, we can also use all of the techniques covered here to build new channels specifically for our own companies. For example, what if we built an assistant of our own that was available from within our mobile apps or on our customer service lines?

## Putting It All Together

While expectations may not always match reality, artificial intelligence, machine learning, bots, and virtual assistants are already improving how we communicate with customers. Sure, there’s some hype, but it’s exciting to be on the edge of such an enormous change not only in customer communication but in how people work with computers generally. 

As developers, it’s our job to tread the thin line between helping our colleagues to understand the realities of these new technologies and thinking ahead to see how we can use them to build something revolutionary. And in ten, maybe five, years, perhaps we’ll look back and wonder how we ever communicated with customers without AI techniques.