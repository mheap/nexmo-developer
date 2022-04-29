---
title: Writing Technical Blog Posts About Coding Projects
description: Sharing knowledge with technical blog posts helps everyone in our
  developer communities. In this post, we review some of the differences when
  writing about code and how to do it successfully.
thumbnail: /content/blog/writing-technical-blog-posts-about-coding-projects/technical-blog-writing.png
author: garann-means
published: true
published_at: 2022-04-26T09:19:04.531Z
updated_at: 2022-04-19T20:48:53.578Z
category: devlife
tags:
  - blog-posts
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
You could say that writing code is easier than writing *about* code. Code basically works or it doesn't, while natural language can fail or succeed in all kinds of different ways. But if you're a strong coder, you have most of the skills you need to be successful at that other type of writing, and other developers can benefit from you sharing your ideas.

Writing a blog post is similar to writing code:

- You develop an idea and outline how you'll get from nothing to its full realization.
- You follow syntactical rules to avoid misinterpretations.
- You strive to be verbose enough to be understood while simplifying wherever possible.

When you're writing *about* code, there are additional techniques you can use. But it helps to also stay focused on what your reader wants from your post. An advantage technical blog posts have over other types of writing is that what the reader wants is usually pretty obvious.

## Effective Technical Writing

The problem is that technical writing is dry. Different people have lots of different strategies to mitigate it, but clever tricks can't change that central fact. Reading abstract explanations of algorithms and syntax is a difficult task. The brain–[especially memory](https://qbi.uq.edu.au/brain-basics/memory/how-are-memories-formed)–works by making associations, and technical information offers few footholds for those associations.

This doesn't apply only to technical writing. If you've ever struggled to stay awake during a half-hour lecture or conference talk but have no problem focusing on a two-hour movie, you already know that. Boredom has less to do with the people receiving information than with how it's presented.

Why do people read technical blog posts? Mostly, they want to know how to accomplish a task or they want a deep dive into a specific topic. Your challenge is to answer that need before their attention span runs out.

The one thing technical writing is almost always improved by is less of it. That's true of both the length of the post and the length of your sentences. It's even true for the code examples you use. Consuming technical information is enough of a challenge for our brains. You can help people understand your subject by doing the work of prioritizing information for them and removing anything that isn't crucial.

There are lots of different approaches you can use to lighten the writing you're left with. Some effective tools are:

- Humor
- Anthropomorphizing concepts or code
- Images (GIFs, [not pie charts](https://arbor-analytics.com/post/2021-03-12-some-data-on-why-pie-graphs-are-bad/))
- Interactive examples
- Code
- Bulleted lists

Some of those techniques affect the writing itself, and some provide a break from it. But they all use different parts of the brain than the part that remembers formulas and algorithms. Memories are made of links between parts of the brain, and remembering the things you're reading as you're going along is key to avoiding mental exhaustion long enough to understand the big picture.

If you haven't done a lot of technical writing, or haven't done a lot you've felt satisfied with, it may be worth experimenting with other ways of lightening it. The authentic voice of the author is as important in a blog post about code as anywhere else. Your voice is amplified by having a well-planned strategy that feels natural.

## Technical Terms

Of course, it's fine to talk about making jokes and adding GIFs to spice up your writing, but at some point, you're going to have to wade into the murky waters of acronyms and Hungarian notation.

The first way to handle technical terminology is to back up and make sure you've scoped your post correctly. A blog post where you have to spend multiple paragraphs explaining each technical term probably shouldn't be the same one where you're using several technical terms in a sentence. If you do find yourself mixing a lot of technical terms and think no one individual may know all of them, you can link the term to its canonical definition rather than potentially overexplaining. You can also split your post into two, with an optional prequel covering all the groundwork some people may want to skip.

To make your writing less dry, incorporate technical terms into the narrative flow of your post. So rather than:

> "`getData` is the name of the function that gets the data. Its return value is `output`. It can return nothing or an object. It takes two arguments. `source` is the first argument, and `filter` is the second, which is optional."

You might integrate technical terms with natural language like so:

>  "By passing a data `source` into `getData` as its first argument, we can get an `output` object containing our data. We can optionally add a `filter` to reduce the data returned. If there are no matches, `getData` will just return `null`."

It might be tempting to treat technical terms with a kind of formality, but I think it makes the writing much harder to digest. The way you'd speak to someone you were pair programming with about code you're working on together will be immediately clearer.

## The Role of Formatting

Switching back and forth between narrative and variable names without being explicit about what you're doing is made possible by `<code>` tags in the final HTML of your post. They give a visual indication that you're talking about a specific element of the technical solution, and they can also be recognized by assistive technologies. Any other formatting of technical terms, like bolding the name of a certain technology or tool, is up to you or your organization's style guide.

The way you format code blocks is important, too. At a minimum, it helps to have syntax highlighting. Not only does this make code easier to understand visually, but it also provides visual interest within your post. Code in code blocks should be cleaned up for your post. If your code comments explain the same things your blog post does, you can remove them in order to present less code. You can also remove any inherited indentation of the code so it's not necessary to scroll horizontally to read it.

Formatting your post into subsections is useful for organizing information and, depending on the blog platform you're using, can provide navigation shortcuts within the post. You can also use asides and bulleted lists to organize the post. Just don't go overboard with formatting. Most blog posts should probably still be mostly text, even if they're about code.

Linking to other resources deserves a little strategy. If you found something helpful and it fits naturally in the flow of your text to link to it, having the extra information in context is useful. But you don't want to add so many links in your text that it's distracting. If you have a lot of things to link to, you can always put a list at the top or bottom of the post. That has an advantage too, in that it doesn't encourage people to stop reading and go somewhere else mid-tutorial.

## Using Images

The use of images is pretty standard in news articles and other pieces of content that might go through a lengthier production process than a blog post. Having at least one main image on technical articles is also common. We've already covered the value of this.

Technical blog posts may use images in the body of the post, as well. These could be more visual relief, like GIFs to break up the text, or they could be explanatory. The only considerations with decorative images are legal and accessibility concerns. With permission to use the image and considerate captioning, they should be fine.

Some technical concepts benefit from a visual demonstration. You can screenshot steps in a setup process or make the process into a GIF. Showing directory structures, example output, or a user interface you're not coding in the post can also be helpful. It's important not to rely completely on images for those things, though. You should still explain whatever's in the image or give enough information for people to produce the same thing locally.

## Explaining Code

If you're going to write a blog post about a piece of code, you should plan to explain the code. Pointing your readers to a repo, narrating a few lines, and dropping your Twitter handle is unlikely to result in a very useful blog post.

If the code for your blog post is written specifically for that purpose (not a piece of a larger project), it's very helpful to keep track of the steps you take to create it as you're coding it. This will give you a ready-made outline for the post. You can even literally take notes of your steps in the blog post and once the code is done, *voilà*, your outline is already in place. If the code is just a piece of something else, figure out which pieces are crucial to the point of your post, and organize them so that the first parts you discuss are the dependencies of the ones that follow.

> These are generic suggestions, of course. If you're dissecting someone else's code, or just explaining something really complex, starting with the finished product and taking a "how did they do that" approach might be awesome.

A trick that I feel works well is to write the narrative around your code as though the code examples aren't there. Another way to think of this is as if you were giving a coding interview and needed to express the important parts of the solution while leaving the implementation details unspecified. People are probably looking for something out of a blog post that they can't get just looking at the GitHub repo, so a blog post should do more than just say, "Now we'll add the `getData` function:" There's a sweet spot between that and repeating the entire code block in natural language.

The way you break up your code can assist with striking the right balance of explanation and self-documentation. If you can split your code up into blocks with about ten important lines (things that aren't boilerplate or closing parentheses), you can write a 2-3 sentence paragraph explaining each and keep a nice pace. But you can't always do that. Some functions are huge.

If the code you need to discuss is very long, consider artificially splitting it up. I prefer to do this by leaving placeholder comments like `//INSTANTIATE VARIABLES` and `//FETCH VALUES`, so I don't have to change the operation of the code itself and potentially introduce a bug at the last minute. However, splitting long code out into modules or separate functions also works. Adding abstractions makes your code much easier to discuss, and the same benefit of reusability you get in the code itself is one your blog posts can share. If you write about a similar subject again, you can reuse those pieces and maybe even their explanation.

## Wrapping It Up

At the end of your post, it's useful to confirm what the expected result is. If your reader's been coding along with each step and they're getting errors, they probably already have a suspicion there was a misunderstanding. But that's not always the case. You might conclude by saying, "Now you've got your application code ready. You just need to set up your API credentials by following *this tutorial* and you'll be able to run the app."

If you get to the end of your post and don't have much more to say, it's a good indication you set the scope for the post correctly. If you're cramming a lot of caveats into extra paragraphs, consider going back and fixing the things in the code or the post that are bugging you.

The final piece of writing a technical blog post is the same as a non-technical one: editing it. With a technical blog post, it's important to manually check any suggestions coming from an automated proofreading tool. If you need to make edits to your code blocks, make sure the code still runs afterward.

If you're interested in writing a technical blog post about your work with Vonage's APIs, we're currently accepting submissions to our [Developer Spotlight](https://learn.vonage.com/spotlight/) program.
