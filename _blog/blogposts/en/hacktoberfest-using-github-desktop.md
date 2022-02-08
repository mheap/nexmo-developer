---
title: "Hacktoberfest: Using GitHub Desktop"
description: Learn with this tutorial how to use GitHub for Desktop, a graphical
  interface for the Git actions traditionally available via the command line.
thumbnail: /content/blog/hacktoberfest-using-github-desktop/Blog_GitHub-Desktop_1200x600.png
author: garann-means
published: true
published_at: 2020-10-08T13:20:03.000Z
updated_at: 2021-05-10T21:29:12.604Z
category: tutorial
tags:
  - git
  - github
  - hacktoberfest
comments: true
redirect: ""
canonical: ""
---
It must have been a revelation when the first directories of open source projects offering free-to-use tools and seeking contributions were created. Now it's such an institution in the world of technology that we barely pause to explain what GitHub is. That might be a problem if this is your first Hacktoberfest because you're new to open source or coding in general.

GitHub is a host for code being version-controlled using Git. It makes it easier for developers to share code and work on projects together by providing a publicly-available home for a repository. There are lots of other hosts for Git repositories, and for those using other version control systems, but GitHub distinguished itself early on by emphasizing usability. Not too long after GitHub the website appeared, they released the GitHub Desktop application, a graphical interface for the Git actions traditionally available via the command line.

If you don't already have a lot of Git knowledge, you might find it easier to contribute during Hacktoberfest using GitHub Desktop. You'll gain familiarity with the concepts in the process of using it on a real project, and may decide to become a Git superuser later on!

## Cloning a Repo

You'll probably contribute to existing projects by first downloading a copy of the project repository: "cloning the repo". However, you shouldn't think of this like downloading an episode of a tv show. 

Git is a distributed version control system. That means that though you went to GitHub to find the project and clone it, it "lives" everywhere it's been cloned. All the different copies stay in synch by notifying GitHub of their own changes, then requesting updates from GitHub. There are complex tools in Git for merging these changes together so you can update your local copy and work on what everyone else is seeing. For a beginner, though, the best tool to use is small and frequent commits.

With GitHub Desktop, a nice shortcut for cloning a repo is to use the link on GitHub.com. If you have the correct permissions, you'll be able to open a "Code" menu above a project on the site and select an "Open with GitHub Desktop" option, which will pop you into the application with the menu to clone a repo open and populated.

![Cloning a repo from the GitHub site](/content/blog/hacktoberfest-using-github-desktop/giphy.gif "Cloning a repo from the GitHub site")

Within the app itself, you'll find a repositories drop-down in the top left corner. If you expand it, you'll see an "Add" button. Clicking that also gives you the option to clone repositories from GitHub.

## Creating a Fork

A fork of a repository is another type of copy of the repository. It's controlled by you, instead of by the origin repository's parent organization. You might want a fork to build on a project or take it in a different direction, or simply because you're outside the organization that ordinarily works on it. 

You can fork a repository from the GitHub website. The button is near the top right when you're viewing a repo. Once you've forked it, you have a copy under your username that you can open in GitHub Desktop just like any other repo you have rights to, using the repositories drop-down.

## Creating a Branch

At the top of the GitHub application, you'll see which branch you're currently working in. When you first open a repository, you'll probably be on the project's main branch. If you want to look at a certain feature still being worked on, you'll often need to switch to a special branch containing that work. You can get an idea of which branches are for what by looking at the project's pull requests. A pull request is a branch off of an existing branch that's asking to be merged back into the branch it came from.

To create a new branch for your work, first figure out which branch is most appropriate as a jumping-off point. You can switch branches using the drop-down next to the current branch at the top of the application window. From the "Repository" top menu, choose "Pull" to get the latest code on that branch. Ideally, you'd do this before adding your own code, or you may get merge conflicts.

Once you're up to date, create a new branch by going to the branches drop-down again and clicking the "New Branch" button. This will give you a window where you can enter a name for your new branch. Try to follow the project's branch naming conventions but, if in doubt, give it a name that summarizes the main change you'll make there, like `fix-password-resetting`.

## Commits

Within your repository and branch in GitHub Desktop, you'll have two tabs: "Changes" and "History". Changes will show you all the files that differ between your local repository and the most recent commit. If you see too many irrelevant changes–or changes in files you don't want to accidentally publish–you can add a `.gitignore` file listing all the files and paths you don't want Git to track. An existing project probably has one already.

Where possible, it's helpful to make commits that do just one thing, for example `Add contact button event handler`. Testing can help confirm this, as tests won't pass at every commit if half the work is in one commit and half in another. Once you've got your changes saved and tested, select all the relevant files from the list on the left of the screen, add a commit message, and click the "Commit to..." button below.

![Making a commit in GitHub Desktop](/content/blog/hacktoberfest-using-github-desktop/giphy-1.gif)

## Making Pull Requests

On a project with more than one contributor, it's never a bad idea to make changes via pull request. It's possible to make changes, commit them, and push them directly, but aside from emergency fixes, that pattern is less popular. In very large projects, it's often banned altogether.

Once you have a series of commits that add up to your change saved on a dedicated branch, you can publish the branch and make a pull request. This is very straightforward in GitHub Desktop. In the top "Branch" menu, you'll find an option to "Create Pull Request". That will perform the process for you, including publishing your branch if it's new.

Making your first pull request is a big step. You can check out [our post on the entire PR process](https://www.nexmo.com/blog/2020/10/01/how-to-create-a-pull-request-with-github-desktop) for more detail.

## Advanced Git Actions

GitHub Desktop isn't a particularly fancy tool, but it can help with more complex scenarios than what we've covered here. However, it's probably best not to go looking to create merge conflicts just to learn how to resolve them. 

The basics above should get you started. Once you need to do something more complex, poke around the rest of the UI and you'll find another tier of more advanced tasks the app can perform. 

## What Next?

Vonage is a [Hacktoberfest partner](https://www.nexmo.com/blog/2020/09/25/vonage-joins-hacktoberfest-2020) for 2020, and we'd love to welcome you to get comfortable with GitHub Desktop by contributing to our repos. We're happy to provide guidance in the [Vonage Community Slack](https://developer.nexmo.com/community/slack) to help you take the next step. To fully immerse yourself in the festivities, be sure to check out our [Hacktoberfest page](https://nexmo.dev/2GZcyHc) for details on all that we have planned!