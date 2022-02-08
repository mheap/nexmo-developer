---
title: Version Control GUIs
description: A brief introduction into various Git GUIs (including GitHub
  Desktop, GitKraken, and Sourcetree), for those who may be intimidated by the
  command line.
thumbnail: /content/blog/version-control-guis/Blog_Git_GUIs_1200x600.png
author: garann-means
published: true
published_at: 2020-10-02T07:25:52.000Z
updated_at: 2021-05-10T22:02:27.225Z
category: tutorial
tags:
  - git
  - opensource
comments: true
redirect: ""
canonical: ""
---

A lot of contributing to open source changes depending on the angle you approached programming from. Some people find a command line interface the easiest and most direct way of getting programming tasks like managing version control accomplished. For others, the time to move a cursor across a desktop is a good trade-off for the time saved not having to look up Git syntax. Tutorials are often biased toward the command line, but that's because the command line can be very consistently explained. 

The right tool for the job is the one you feel comfortable using. If you want to take part in events like [Hacktoberfest](https://hacktoberfest.digitalocean.com/), a little thing like the command line shouldn't stop you. Especially when there are lots of graphical version control clients you can use instead!

Vonage is thrilled to be a Hacktoberfest 2020 partner. We’re [no strangers to open source](https://youtu.be/zYJpYMCy6PA), with our libraries, code snippets, and demos all on GitHub. To fully immerse yourself in the festivities, be sure to check out our [Hacktoberfest page](https://nexmo.dev/2GZcyHc) for details on all that we have planned!

## GitHub Desktop

If you're already using GitHub, the [GitHub Desktop](https://desktop.github.com/) app is your default choice for a version control GUI. An advantage of choosing this tool is the integration with GitHub. You'll see the option to clone repositories with GitHub Desktop on the site, for example.

GitHub Desktop very much encourages you to do one thing at a time. It feels a little more like a web application than a desktop app in that way. The simplicity can be nice if you mostly want a tool to ease tasks like selecting files for a commit and creating pull requests.

## GitKraken

Although open source maintainers have historically used the same tools as everyone else, [GitKraken](https://www.gitkraken.com/) might be a way to make life easier if you're spending _a lot_ of time dealing with version control. It includes a text editor, for example, so you have one less reason to switch applications. There is a free version, but the app isn't completely functional unless you upgrade to Pro. 

Personally, my strategy is just to hope fervently I don't need to do a rebase, but GitKraken provides a very attractive rebasing UI that almost makes the process look straightforward. The default repository view is also useful for understanding where bits branch off of each other. In general, the application feels less like a GUI version of a command line and more like a version control dashboard.

## Sourcetree

Like GitKraken, [Sourcetree](https://www.sourcetreeapp.com/) will let you connect to GitHub, GitLab, and Azure DevOps. But unlike GitKraken, one of the first things you might notice with Sourcetree is a bias toward Bitbucket. However, you can use any host you want. 

Sourcetree's setup is a bit awkward, and it's not entirely obvious at first that you need double-click a repository to get to the actual UI. Once you do, though, it's a nice middle ground between GitHub Desktop and GitKraken. 

Concepts like stashing and submodules are surfaced at the same level as branches. If you want a gentler way of messing around with less common Git features, it's a good alternative to learning on the command line.

## Others

There are many, many free and open source version control GUIs. There are also a few established paid products. You're most likely to find yourself using one of these as part of a team, but if the few options above don't meet your needs it might be worth seeing what else is out there.