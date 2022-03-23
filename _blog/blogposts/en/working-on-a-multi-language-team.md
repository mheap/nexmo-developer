---
title: Working on a Multi-language Team
description: Working on a multi-language team can be both challenging and
  rewarding. Here are a few things I've learned.
thumbnail: /content/blog/working-on-a-multi-language-team/multi-language-team-1-.png
author: karl-lingiah
published: true
published_at: 2022-03-21T09:36:20.709Z
updated_at: 2022-03-17T15:58:23.091Z
category: devlife
tags:
  - devlife
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
A lot of the time as developers working as part of a team, we’re used to all members of that team being conversant with the same languages, tech stack, and set of tools. Depending on the context, that might involve working with more than one actual programming language. 

If you’re working on the front-end, you’ll likely need to ‘speak’, HTML, CSS, and JavaScript. In a full-stack context, you can also add one of any number of back-end programming languages. Putting aside any specialization or focus on a particular part of the stack, developers on such a team will have a common technical vocabulary and a shared frame of reference defined by the tech stack that they are using. Since joining the Developer Relations team at Vonage though, I’ve had to get used to quite a different reality to the one I’ve just described.

Just to provide some context here, one of the main objectives for our team is to help and support developers in using Vonage’s many communications APIs. One of the ways we do that is to provide SDKs that abstract away some of the low-level complexity of using the APIs to more easily integrate them into an application. Of course, the developers using Vonage’s APIs do so using a wide variety of programming languages and tech stacks. We, therefore, provide SDKs for many different language implementations and environments: server SDKs for Ruby, PHP, Python, Java, Node, and .net; client SDKs for JavaScript, iOS, and Android.

As the team’s Ruby Developer Advocate, part of my role involves maintaining and improving our Ruby SDKs. When I need to fix a bug or add a feature, I do that by writing Ruby code. My team-mates, however, aren’t writing Ruby. Instead, they’re writing PHP, Python, or C#. We may actually be working on implementing the same feature, but doing so in completely different languages.

Now, I like to think that my JavaScript chops are pretty decent, but it’s not my primary language. I’ve written some PHP in the past (though our PHP advocate, Jim, assures me that the language has changed a lot since those days!) and know a little bit of Python, but I wouldn’t consider myself an expert in either of those languages, and I definitely feel most comfortable when working with Ruby code. 

If I want to be a good team member though and be able to support my colleagues in their work, I need to occasionally push myself outside of my Ruby comfort zone.

During the seven or so months since I joined the team, I’ve found myself acting as a sounding board or second pair of eyes for colleagues working on bugs or features for their (non-Ruby) SDKs. I’ve helped review pull requests for the PHP, Python, and .net libraries. I’ve even pushed some small commits to one of the Python repos.

## Being Uncomfortable (Sometimes) is Good, Actually

Working on a multi-language team can definitely present some challenges. However, I’d like to suggest that it also provides many benefits.

As developers, we strive for mastery of our craft. We build up our expertise to a level where we feel comfortable within a particular knowledge domain. Constructing that ‘knowledge comfort zone’ brings many advantages – we can work confidently, quickly, and efficiently without having to double-check or look things up all of the time. On the flip-side, it can make us lazy and prone to assumptions. When encountering a new problem or situation, we can sometimes fall back on familiar patterns and think that we already know the solution without clearly thinking about the problem.

There’s a concept in Zen Buddhism called [Shoshin](https://en.wikipedia.org/wiki/Shoshin), which translates as “beginner’s mind”. It essentially refers to an idea of being open to possibilities and without preconceptions when studying a topic or approaching a new problem. Acquiring expertise strips away “beginner’s mind”, but occasionally leaving your language comfort zone can help re-establish it. 

For example, if I’m working on a feature for one of the Ruby libraries and thinking about it in a purely Ruby context, I may fall into the bad habit of focusing solely on the solution and not thinking clearly about the problem. If, however, I’m discussing that same feature with colleagues in a PHP or Python context, it forces me to shed any Ruby-specific assumptions about the solution and instead focus on the problem.

As well as stripping away preconceptions, working day-to-day with developers from other language backgrounds can broaden your horizons in other ways. It opens you up to different approaches and ways of doing things, and, ultimately, different ways of thinking. 

There’s a linguistic theory known as [linguistic relativity](https://en.wikipedia.org/wiki/Linguistic_relativity) or the Sapir-Whorf hypothesis. This theory suggests that the structure of a language can influence how we think and how we see the world. The theory was developed with human languages in mind rather than programming languages. Since programming languages are designed by humans though, the same theory can be applied.

The design of programming languages can create certain orthodoxies around how software should be written. Languages can be strongly or weakly typed. Certain languages lend themselves to an imperative approach, others to a declarative one. Language features such as these can make you think in a certain way when you write code. 

If a certain way of thinking is all you’ve ever experienced, you can fall into the trap of believing that this way is the right way. Experiencing different languages and approaches opens you up to the different ways of thinking suggested by the design of those languages. It can show you that there isn’t necessarily one ‘right’ way, just different ‘ways’, each with its own trade-offs.

For example, although Ruby has always been (and still is by default) a dynamically typed language, we now have the option of introducing static type checking in our Ruby programs. Libraries like Sorbet have been around for a few years, and more recently with Ruby 3 has introduced this option natively. *Thinking* in a statically-typed way probably still feels a little alien to most Ruby developers though, and we can learn a lot by looking at code in a statically typed language such as C#.

```c#
private static void ValidSmsResponse(SendSmsResponse smsResponse)
```

When looking at a method signature in an unfamiliar language like this, we have no preconceptions about the language. In order to understand what the code is doing, we have to ask ourselves *what* each element of the signature is for, and *why* it was written like this. We can learn from this process, and take that learning back to our Ruby code.

## Learning Points and Tips

During the past few months, I’ve learned a few helpful approaches for working on a multi-language team, and I just wanted to share a few of them here.

### Zoom Out to Establish Context

A few months ago, Jim was working on deprecating and removing various Traits from one of the PHP libraries, and wanted someone to talk through the changes he was making to the codebase. During the start of our conversation, I was kind of getting lost in the weeds of the PHP-specific syntax. What really helped in that situation was to zoom out, and discuss the changes at a higher level of abstraction. Rather than thinking about what a specific line of code was doing, it was easier to understand the context of the changes by asking things like “what’s the purpose of this Trait?”, “what’s the relationship between these classes”, and so on. Once you’ve established a clear context for what some unfamiliar code is doing, it’s much easier to then zoom back into the implementation detail.

### Re-use Mental Models

Something else that can be useful when treading on unfamiliar ground is to re-use or re-purpose existing mental models. During our learning journeys as programmers, we’ve all spent a lot of time establishing solid mental models for the numerous technical concepts that we work with. The good news is that many of these can be re-used or re-purposed in the context of other programming languages. 

One example might be trying to explain something like Ruby blocks to a non-Ruby dev. Syntactically, blocks are quite particular to the Ruby language, but if I need to explain what they are to, say, a JavaScript developer, I can say something like “they kind of work like call-back functions”. Sure, if you dig into the detail of the language implementation they’re not the same thing, but as a general mental model for explaining what they do and how they are used, it’s probably close enough.

Conceptually, passing a block to `map` in Ruby:

```ruby
[1, 2, 3].map do |num|
  num + 1
end
```

isn't really that different from passing a call-back function to `map` in JavaScript:

```javascript
[1, 2, 3].map(function(num) {
  return num + 1;
});
```

Depending on our syntactical choices in both languages, they might even *look* fairly similar:

```ruby
# Ruby
[1, 2, 3].map { |num| num + 1 }
```

```javascript
// JavaScript
[1, 2, 3].map(num => num + 1)
```

### Identify Similarities to Understand Differences

Continuing on this theme, another thing to do is to seek out the similarities between different languages and tech stacks. I mentioned earlier the advantages that can come by exploring, and being open to, the different approaches that programming languages can take. Ultimately though, those languages, and the tooling built around them, generally aim to solve the same set of problems. 

For example, there are testing libraries available for most programming languages. The syntax that they use will differ from language to language; some, like RSpec, may even use their own DSL. Ultimately though, testing libraries are all solving the same problem. At a general level, they will all use assertions in some way. 

Minitest and PyTest are both testing libraries, one for Ruby and the other for Python. Identifying those similarities between them can provide a base-level context which can then help to surface the interesting differences in how they work or how they’ve been implemented.

## A World Beyond Ruby

I guess that what I’m trying to say with all this, is that while it can be tempting to just stay in your comfort zone, and stick to what you’re used to, what I’ve experienced over the past few months has reminded me that there’s a whole wide world of vibrant and interesting stuff going on in languages other than Ruby. I love Ruby, and certainly have no plans to move away from it as my primary language, but I am super excited to dive into and further explore some of those other languages.