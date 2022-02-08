---
title: Vonage CLI Now In Beta
description: The Vonage CLI is now in beta - and here is how you can help out!
thumbnail: /content/blog/vonage-cli-now-in-beta/social_sdk-updates_1200x627.png
author: kellyjandrews
published: true
published_at: 2021-08-24T09:27:25.992Z
updated_at: 2021-08-20T12:59:30.361Z
category: release
tags:
  - CLI
  - oclif
  - Lerna
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Throughout a career, specific projects naturally stand out. The [Vonage CLI](https://github.com/Vonage/vonage-cli) is one of those projects for me, and I can now tell you that the CLI (Command Line Interface) is in beta! The future potential of the CLI and the power of a new plugin architecture have me excited to bring you the news!

## How It's Built

When initially planning the new CLI architecture, there were two essential requirements: plugins and modularizing our packages better.  

We chose [oclif](https://oclif.io/), a CLI framework written by the team at Heroku and used for their own internal project, including the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli). Ultimately, the decision came down to its ease of use, and the plugin architecture built into the framework. Both of which satisfied our requirements. 

The plugin architecture will help us to build, deliver, and support additional use cases and functionality that would have been otherwise impossible in our current CLI.

Along with being able to create and install plugins, the processes for quickly versioning and deploying them are equally critical. These reasons are why I chose [Lerna](https://lerna.js.org/) to support our multi-package repository. Having the ability to link local packages together made versioning and deploying plugins so much easier. 

The real power I found was in deployments. The Lerna CLI steps you through the process of versioning packages and offers the option of only releasing new or keeping the same versions of any updated software. In all, I fell in love with Lerna and enjoy this methodology. 

## How to Help

The beta is currently available for testing and can be installed using [`npm` ](https://www.npmjs.com/):

```shell
npm install -g @vonage/cli@beta
vonage --help
```
Once installed, you can get around using the `--help` flag on any command to learn more about the arguments and flags available. The first thing you will want to do is get your authentication set up. You can do with the following:

```shell
vonage config:set --apiKey=XXXXXX --apiSecret=XXXXXX
```
We also have two plugins in beta - In-App Conversations and  Users. Once you have the CLI installed, you can also add these:

```shell
vonage plugins:install @vonage/cli-plugin-conversations@beta
vonage plugins:install @vonage/cli-plugin-users@beta
```
Both users and conversations will expect you to have an application created:

```shell
vonage apps:create
```

## Feedback 

I'm working on getting this to v1.0 as quickly as I can, and I won't get it entirely right without your help as well. Install it, break things, and send me some issues on [the Vonage CLI Github repo](https://github.com/Vonage/vonage-cli/issues), ask questions in our [Slack community](https://developer.vonage.com/community/slack) in the `#vonage-cli` channel, or email us at `devrel@vonage.com`. 