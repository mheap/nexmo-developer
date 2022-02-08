---
title: Building Your Next CLI
description: The Nexmo CLI is something we all use daily, so it is pretty
  essential, and we're investing the time to re-write it. I thought I'd share
  the process we're using to work on our next CLI application, in case you are
  interested or have a project like this yourself someday.
thumbnail: /content/blog/building-your-next-cli-dr/Blog_Next-CLI_1200x600.png
author: laka
published: true
published_at: 2020-06-05T13:30:58.000Z
updated_at: 2021-05-04T12:19:47.906Z
category: tutorial
tags:
  - cli
  - nodejs
comments: true
redirect: ""
canonical: ""
---
If you're not familiar with CLIs, let's have a short refresher. CLI stands for Command-Line Interface and is a tool that uses a text-based interface, usually accessible inside a Terminal-like application or a shell-like environment.

Regular readers will know that [we already have a CLI](https://github.com/nexmo/nexmo-cli), which we use as an alternative to the [Dashboard](http://developer.nexmo.com/ed?c=blog_text&ct=2020-06-05-building-your-next-cli-dr). It allows you to manage your [Vonage account](http://developer.nexmo.com/ed?c=blog_text&ct=2020-06-05-building-your-next-cli-dr) and use Vonage products from the command line. We've had this tool for about 4 years, and is written in [Node.js](https://nodejs.org/). It uses the [commander.js](https://github.com/tj/commander.js/) framework and has grown quite a bit as we added functionality over time.

Because the tool has become quite large, we've hit the limitations of the framework we are using. Commander has a specific way to handle alias commands and a hard limit on the number of aliases a command can have. For example, `nexmo app:list`, `nexmo apps:list`, `nexmo apps` and `nexmo al`, all list your Vonage applications. But to achieve that with Commander, we had to duplicate some code. We created two commands, each with an alias, that both need to be maintained. It has increased the barrier for people to contribute. It also increases the chance someone (mostly me) forgets to update the help menu for both before a release.

Commander is great for building smaller CLIs, but as the CLI has grown in scope and features, it couldn't cope with some of our requirements. When we updated our [Applications API](https://developer.nexmo.com/api/application.v2) to support multiple capabilities on the same Application, we thought people shouldn't have to remember 9 flags for a command. So we improved the developer experience for the CLI, by adding an interactive prompt that guides people through the Application creation process. Because `Commander` doesn't support an interactive mode, we also pulled in [Inquirer.js](https://github.com/SBoudrias/Inquirer.js) as a dependency.

You're probably seeing where I'm going with this. The workarounds we've been using to make up for the framework limitations have made it harder to maintain and update our CLI. The CLI is something we all use daily, so it is pretty essential, and we're investing the time to re-write it. I thought I'd share the process we're using to work on our next CLI application, in case you are interested or have a project like this yourself someday.

## Retrospective

Before we jumped straight into a new code project, we took the time to make sure we had a clear structure. We kicked off the process with a retrospective for the current CLI. We listed a few things about the current CLI: "<em>things we are doing well</em>", "<em>things we should do better</em>", and "<em>things we should stop doing</em>". Here are a few examples of things we've come up with for all those columns.

Things we are doing well:

* Our CLI is a first-class product, on a par with our [Server SDKs](https://developer.nexmo.com/tools).
* The CLI offers more than one way to do some things (like the Application listing I mentioned earlier).

Things we should do better:

* Interactive mode on most commands.
* Formatters for CSV, JSON, and standard output.
* Command autocomplete support.
* Support plugins.
* Reduce our dependencies.

Things we should stop doing:

* Stop flogging that old codebase. 😅

You can see we had a lot more things listed under the 'should do better' category. That retrospective was really helpful for identifying a list of requirements.

## Requirements Gathering

Next, we assembled a list of use cases we wanted to have for the CLI. We came up with them based on the current use cases supported by the CLI. And the feature requests we wanted to implement. Some of them would have been too costly with the existing framework (i.e., plugin support). We split those into user-facing requirements like "<em>Users must be able to list their applications.</em>". And non-user-facing requirements like "<em>Multiple output formats (ASCII tables, CSV, JSON) will be offered.</em>".

As you can imagine, we ended up having a long list of use cases. While we hope to implement all of them, we felt that to do so in one go would be counterproductive and take a long time. So we've broken them down into core features and things we should build plugins for. To make them even more manageable, we've assigned target versions for all of them. For example, most of the authentication use cases are going to be implemented in V1, with a few moving to V2. "<em>Sending an SMS</em>" is going to be one of the first plugins we implement.

## Command Examples

After we had broken down the requirements into manageable releases, we put together a set of standards for the CLI. We're using examples to make sure that we build a very consistent developer experience in our new tool. Here's the list of standards we landed on:

* Command naming should be about the user’s action, not our API names. i.e. `nexmo number format --number=012345678 --country=GB` rather than `nexmo insight basic --format --number=12345678 --country=GB`.
* Command names are a singular noun. i.e. `nexmo app` or `nexmo number`.
* The second part of the command should be an active verb. i.e `nexmo app create` or `nexmo number list`.
* Flags are preferred over positional arguments. i. e. `nexmo app update --name MyBetterNamedApp`.
* Flags can have shorthand versions. i.e. `nexmo app update -n MyBetterNamedApp`.
* Universal flags should include `--help`, `--silent`, `--verbose`, `--debug`, `--format`, `--non-interactive` and `--color`.
* Paginated commands will use `--limit` and `--offset`, no matter the underlying pagination mechanism of our various APIs.

## What's Next?

Building a new CLI starts with reflecting on the old one if you have one, gathering requirements, and figuring out which ones are the most important for your user experience. With a better understanding of what we wanted from the next iteration of the CLI, we've started identifying CLI building frameworks and comparing them against our requirements. I'll cover this process in more detail in the next blog post. 

Until then, we're working on improving our CLI, and you can track our progress at <https://github.com/nexmo/nexmo-cli>. If you have any suggestions or issues, please feel free to raise them in GitHub or in our [community slack](https://developer.nexmo.com/community/slack).