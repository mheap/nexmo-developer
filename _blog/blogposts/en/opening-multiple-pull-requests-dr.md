---
title: Opening Multiple Pull Requests
description: Avoid pull request mistakes by setting your local repo up for
  success. Win Hacktoberfest with this one local repo setup trick.
thumbnail: /content/blog/opening-multiple-pull-requests-dr/Blog_Multiple-Pull-Requests_1200x600.png
author: lornajane
published: true
published_at: 2020-10-06T13:27:51.000Z
updated_at: 2021-05-10T21:42:59.032Z
category: tutorial
tags:
  - github
  - hacktoberfest
comments: true
redirect: ""
canonical: ""
---
'Tis the season of many pull requests, so today I thought I'd share a tip for avoiding common pull request mistakes that arise from having an out of date master branch.  
Becoming a repeat contributor of a project is one of the best things that can happen to anyone taking part in Hacktoberfest - but there are some things to look out for when you're making a pull request that isn't the first on a freshly forked repo. Today I'll share my tips for making sure that every pull request is as good as the first one!

Vonage is thrilled to be a Hacktoberfest 2020 partner. We’re [no strangers to open source](https://youtu.be/zYJpYMCy6PA), with our libraries, code snippets, and demos all on GitHub. To fully immerse yourself in the festivities, be sure to check out our [Hacktoberfest page](https://nexmo.dev/2GZcyHc) for details on all that we have planned!

## The Finish Is in the Preparation

To do more than a fly-by, one-off contribution, there's one small addition to your usual workflow that can make a very big difference. When you get set up for contributing to a new repo, try this:

1. Fork the repo to your own account
2. Clone that repo to your computer
3. **Now add the original repo as an "upstream" remote**

That magical third step, before you start making changes or creating a branch or even setting up the project to work locally, will give you the link you need to collaborate with a project more than once.

## Sync Before Branching

With this upstream remote in place, it is easier to keep your local main or master branch in sync with the one on the upstream project.

> Remember that you should never commit to your local `master` or `main` branch directly. It should always follow the state of the main project, so that you can branch from it and not include any additional changes by mistake!

When you come to make the second contribution, update your local main or master branch before creating the branch you will be working on.

1. `git checkout main`
2. `git pull upstream main`
3. `git push`

That's it! Check the GitHub URLs for the project and your own fork - and you will see that your main branch is up to date with the project one.

Now you can go ahead and make another change ... and another ... and another. Happy Hacktoberfest!

