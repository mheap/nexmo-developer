---
title: "Surviving Hacktoberfest: A Guide for Maintainers"
description: Hacktoberfest can be quite the experience for maintainers! We asked
  our most experienced open source project maintainer for her best tips to help
  you out.
thumbnail: /content/blog/surviving-hacktoberfest-a-guide-for-maintainers/Blog_Survival-Guide_Hacktoberfest_1200x600.png
author: lornajane
published: true
published_at: 2020-10-13T13:28:53.000Z
updated_at: 2021-05-10T21:17:41.610Z
category: tutorial
tags:
  - hacktoberfest
  - opensource
comments: true
redirect: ""
canonical: ""
---
Happy Hacktoberfest to one and all! Contributors, I hope you are having a wonderful time learning new skills and discovering projects where you can make a difference. Maintainers, today's post is just for you. Hopefully, the rules changes mean a better quality of pull requests for your projects, but it can still be a lot to handle. I'm a long-time maintainer, and today I'd like to share some tips that I hope will help you through.

Vonage is thrilled to be a Hacktoberfest 2020 partner. We’re [no strangers to open source](https://youtu.be/zYJpYMCy6PA), with our libraries, code snippets, and demos all on GitHub. To fully immerse yourself in the festivities, be sure to check out our [Hacktoberfest page](https://nexmo.dev/2GZcyHc) for details on all that we have planned!

## Let's Talk Priorities

Open source project maintainers are mostly doing this work in their "spare" time, and it's a lot. It's not just for Hacktober, and a lot of the work can be rather unseen. This Hacktoberfest, especially with global events around us, it's important to consider your priorities and to keep sight of them!

I'd suggest that you, your project, and then its contributors, in that order, is a good order of priorities. A project is nothing without maintainers, and many are teams of one. The aims and goal of the project is an important priority; there's no pressure to expand the scope or pivot the project because a pull request arrived to do that. The joy of open source is that people can use their own forks as the basis of a new project if they don't like the way you run things! And finally the contributors; Hacktoberfest has a lot of new contributors, but we want to raise them to be contributors, not spoilt children. So if they need to read the project guidelines before contributing, then say so rather than doing a lot of re-work yourself.

## Handling Notification Fatigue

Hacktoberfest is now opt-in, but if you are "in", then it's easy to feel overwhelmed, especially on a high profile or already-busy project. Key to coping is to manage your notifications. And no, an email rule to just file or delete everything with your project name in it is not the answer!

![Add a filter to file all incoming mail with the word GitHub in](/content/blog/surviving-hacktoberfest-a-guide-for-maintainers/gmail-github-filter.png "Add a filter to file all incoming mail with the word GitHub in")

Take some time with your GitHub notifications setup to make sure you are being notified when you want to be, and not being notified with too much that isn't relevant. You can also route different notifications for different orgs to different email addresses, which can be very useful.

### Configure and Route Emails

GitHub has excellent help documentation, so I won't repeat their content here, but I'll direct you to the places I find the most useful!\
First, you can link multiple email addresses to one GitHub account, which is useful if you do some work projects with your GitHub account, or use a different email address for a particular open source project. Take a look at the [documentation for verifying additional email addresses](https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/verifying-your-email-address) on GitHub.

Next, get the right notifications going to the right email address. It's under "custom routing" in the notifications configuration, and of course, there is [excellent documentation on routing emails on GitHub](https://docs.github.com/en/free-pro-team@latest/github/managing-subscriptions-and-notifications-on-github/configuring-notifications#choosing-where-your-organizations-email-notifications-are-sent).

### Watch and Unwatch

The ability to "Watch" a repo is very valuable. If there's a project you want to get all the notifications for, click the "Watch" button at the top and choose "Watching". This is useful if you need to keep track of activity in a particular repo.

![screenshot showing the GitHub watch button and options: not watching, releases only, not watching, ignoring](/content/blog/surviving-hacktoberfest-a-guide-for-maintainers/github-watch-settings.png)

Perhaps more valuable is the ability to "unwatch" a project! I find that because I do some of the GitHub maintenance at work, I have access to many repositories, and by default, if you have access, you are subscribed to the notifications! This can be pretty noisy as you can imagine, so the same "Watch" button gives us some other options - the default is "Not Watching", so you'll get notifications on your own issues/PRs or if you're mentioned. You can also set it to "Ignoring" if you're getting involved when you don't want to be.

### Subscribe and Unsubscribe

On a per-repo level, you can also get notifications without having to comment on the discussion to make yourself "participating". Look for the button on the right-hand side labelled "Subscribe" under "Notifications". Again, there's an opposite option too! Suppose you've chimed in on something that you're no longer interested in getting notifications for. In that case, you can "Unsubscribe" from just one issue or pull request without having to unsubscribe from a whole repository.

## Move Quickly

If a pull request isn't useful or doesn't meet the project goals, don't be afraid to reject it. The [Hacktoberfest FAQ](https://hacktoberfest.digitalocean.com/faq) is your friend here. Always be friendly - but quick responses are valuable if you have the availability to keep up with things every few days. If a pull request could be made acceptable, for example, because it makes the build fail but can be corrected, offer some feedback to your new contributor explaining what would make the pull request ready to merge. If it's a change you don't want (emoji to decorate your `README` seems a popular contribution), then say so and close it.

Open source isn't always a welcoming place, and we operate in public, so bystanders get a good impression of our projects by the way we interact with people. Take the time to thank people for their input! Even if the pull request isn't worth the time it took you to read it, a simple "This doesn't seem useful to the project, why not check the issue list for ideas?" is much more welcoming than closing with no other communication or explanation.

## Thank you

On that note of thanking contributors, I'd like to close by thanking you, the maintainer. It's a common misconception that open source projects are maintained by some amazing, distant, heroic figure. In fact, those of us who give our time and energy in this way are real people with real lives.

Thank you for all that you do, open source changes the world, and in your own way, you're making that happen.