---
title: Comparing CLI Building Libraries
description: Whilst looking to rebuild our own Command Line Interface, we tested
  out some of the popular CLI building choices. Here's what we found.
thumbnail: /content/blog/comparing-cli-building-libraries/Blog_Next-CLI_Part2_1200x600.png
author: laka
published: true
published_at: 2020-06-12T12:30:15.000Z
updated_at: 2021-04-20T10:02:56.000Z
category: tutorial
tags:
  - node
  - cli
comments: true
redirect: ""
canonical: ""
---
Nexmo has a [CLI](https://github.com/nexmo/nexmo-cli), which we use as an alternative to the [Dashboard](https://dashboard.nexmo.com/). It allows you to manage your Nexmo account and use Vonage products from the command line. We've had this tool for about 4 years, and it is written in [Node.js](https://nodejs.org/).

Last week [I wrote about why we're taking the time to re-write it](https://learn.vonage.com/blog/2020/06/05/building-your-next-cli-dr), and I shared a bit about the process we're using to re-write the Nexmo CLI.

Today, I'm going to go into more detail, share the frameworks we analyzed, and the criteria we used to do so. I'm also going to show you some pros and cons of the ones we picked to build our proofs of concept with.

## Benchmark Criteria

After we went through our internal CLI retrospective and identified a set of requirements, we put together a list of example commands. These commands helped us come up with a set of criteria to benchmark libraries used to build Command-Line Interfaces. Our criteria looked to answer a few questions:


- What language does the library support?
- Is it actively maintained?
- Does it support sub-commands? i.e. `nexmo app list`
- Does it have built-in support for multiple output formats?
- Does it have a plugin mechanism?
- Can commands have multiple aliases?
- Can it generate binaries?
- How does config management look like?
- Is it cross-platform?
- Does it have command autocomplete?
- Can it have interactive commands?
- Can we define global flags?

Armed with this list of burning questions, we set on a quest to come up with as many CLI building libraries that ticked most of the boxes and check off their features against our list of qualifying criteria. In the end we narrowed it down to six libraries, for JavaScript, TypeScript and Go, based on the available language skills in the team: [oclif](https://oclif.io/), [gluegun](https://github.com/infinitered/gluegun), [ink](https://github.com/vadimdemedes/ink), [caporal](https://github.com/mattallty/Caporal.js), [cli](https://github.com/urfave/cli) and [cobra](https://github.com/spf13/cobra).

## Feature Comparison

We went through each framework homepage and picked up on the features they supported, creating an analysis matrix. We used ✅ to mean the framework has full support for that feature, ❎ to mean the framework doesn't support that feature and ✳️ that there was only partial support. Here is how our matrix looked like for the 6 frameworks we identified:

| Framework | oclif | gluegun | ink | caporal | cli | cobra |
| :----| :----| :----| :----| :----| :----| :---- |
| Language | JS/TS | JS | React | JS | Go | Go |
| Maintained | ✅ | ✅ | ✅ | ✳️ | ✅ | ✅ |
| Sub-command | ❎ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Output Formats | ✳️ | ❎ | ❎ | ✅ | ? | ? |
| Plugins | ✅✅ | ❎ | ❎ | ❎ | ? | ? |
| Alias | ✅ | ❎ | ❎ | ✅ | ✅ | ✅ |
| Bin | ✅ | ✅ | ✅ | ✅ | ? | ? |
| Config Management | ✅ | ✅ | ✅ | ✅ | ? | ? |
| Windows Support | ✳️ | ❎ | ❎ | ✅ | ✅ | ✅ |
| Autocomplete | plugin | ❎ | ✅ | ✅ | ✅ | ✅ |
| Interactivity | ✳️ | ✅ | ❎ | ❎ | ? | ? |
| Global flag definition | ✅ | ✅ | ❎ | ✅ | ✅ | ✅ |

Looking at the feature checklist we couldn't identify a clear winner, especially since there were still some unknowns. So we decided to pick 3 frameworks and build a proof of concept with each one of them.

## PoCs

Our first pick to build a proof of concept was `oclif`. The main reason we chose it was because it seemed to tick most of our boxes, some even twice (it had plugin support, and a plugin to build plugins with).

The second pick was `caporal` because the library seemed reasonably similar to our current framework, `commander`. This would mean that the learning curve and the time to re-write it would have been considerably less.

Finally, our last pick for the proof of concepts was `ink`, and we chose it because it ticked enough of the boxes to make it worthwhile and has a massive ecosystem behind it.

Once we identified the frameworks, we came up with a scope for the proof of concepts. We wanted something representative of the final CLI instead of building a `Hello World` example. At the same time, it had to be small enough that we wouldn't feel bad throwing away the proof of concept at the end of this exercise. We landed on building the current `nexmo setup` and `nexmo number:list` commands. That meant we could test global flags, config management, sub-commands, output formats, interactivity, and various language frameworks.

## Picking Our Next CLI Building Library

[Lorna](https://twitter.com/lornajane), [Dwane](https://twitter.com/dwaneio/) and [myself](https://twitter.com/lakatos88) each picked up one of the three frameworks, and we started building our proofs of concepts. Once we were done, we showcased some of the pros and cons of working with each library and how that relates to some of our other requirements.

### Caporal

Lorna built the [`caporal` PoC](https://github.com/lornajane/nexmo-caporal-cli). The biggest pro for it was that it was possible to migrate our current CLI from `commander` to `caporal` without requiring a full re-write. That would save us quite some time.

The cons were mostly similar to our current `commander` limitations, and the project isn't as actively maintained as we would have liked. We would probably have to fork the project and maintain a community around it, which would negate some of the speed we gained if we didn't have to re-write. It would also mean some of our requirements, like plugins, need to be built from scratch.

### Ink

Dwane built the `ink` PoC. The biggest pro was that it was using React as the framework, which brings a massive community and ecosystem along with it. It had a lot of plugins available for most things we wanted for our next CLI, but some of them were not yet compatible with the latest `ink` version. It also had React-like diffing for the terminal output, meaning we could not only build interactive commands but also have dynamic output. The cons were not few, one of them being the fact that it was React-based, and the team needed to be familiar with it. Another con was that `ink` on its own wasn't suited for a big CLI like ours.

`pastel`, on the other hand, was a better-suited framework, built on top of `ink`, which gave us the same advantages, so Dwane built a PoC using that. `pastel` came with its own set of cons though, mostly the fact that it hadn't been actively maintained in the past year, with the last release being 10 months ago.

### Oclif

I built the [`oclif` PoC](https://github.com/AlexLakatos/nexmo-oclif-cli). The biggest pro was that `oclif` did tick most of our requirements, and they worked as advertised. So we wouldn't have to build a lot of the functionality for the non-user-facing requirements, like a plugin system. It was also better suited for building large CLIs. The code structure conventions it uses make it easier to maintain the code.

It did come with a bunch of cons as well, however. Even though the website advertises both JavaScript and TypeScript as supported, the docs were quite TypeScript heavy, to the point that most of the advanced use cases weren't documented in JavaScript.

The fact that I chose TypeScript for building the PoC also meant that importing the [Nexmo Node.js SDK](https://github.com/Nexmo/nexmo-node) into it as is would be problematic, so we'd need to invest some time into adding TypeScript support there first.


## What's Next?

After carefully considering how all those pros and cons affected us, we chose to go ahead and build the next Nexmo CLI using `oclif`.

We chose it because the support and documentation for it were great, along with the growing community of people using it. It's also actively maintained. We're also adding full support for TypeScript to our Node.js SDK, so it seemed like a good fit to keep the same stack across our SDK and CLI.

While we're working on improving our Nexmo CLI, you can track our progress at [https://github.com/nexmo/nexmo-cli](https://github.com/nexmo/nexmo-cli). If you have any suggestions or issues, please feel free to raise them in GitHub or in our [community slack](https://developer.nexmo.com/community/slack).
