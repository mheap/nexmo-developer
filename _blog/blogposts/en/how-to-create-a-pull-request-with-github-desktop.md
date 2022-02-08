---
title: How To Create a Pull Request With GitHub Desktop
description: A tutorial published during the event of Hacktoberfest 2020 showing
  how to create a pull request with GitHub Desktop.
thumbnail: /content/blog/how-to-create-a-pull-request-with-github-desktop/Blog_GitHub-Desktop_Pull-Requests_1200x600.png
author: greg-holmes
published: true
published_at: 2020-10-01T13:27:20.000Z
updated_at: 2021-04-19T10:26:47.410Z
category: tutorial
tags:
  - github
  - git
  - hacktoberfest
comments: true
redirect: ""
canonical: ""
---
In this tutorial, we will learn how to review code changes in GitHub Desktop, commit these changes and then create a pull request on GitHub. [Git](https://git-scm.com/) is a distributed version control system that allows developers to keep track of all changes to files within their projects. [GitHub](https://www.github.com) is a remote hosting platform that enables developers to store their projects externally. [GitHub Desktop](https://desktop.github.com) is a native application for both Windows and macOS to allow developers to manage their repositories.

If you don't know what Git is, please check out the [Introduction to Git tutorial](https://www.nexmo.com/blog/2020/09/29/an-introduction-to-git-dr).

## Install GitHub Desktop

[GitHub Desktop](https://desktop.github.com/) is available on [Windows](https://central.github.com/deployments/desktop/desktop/latest/win32) and [macOS](https://central.github.com/deployments/desktop/desktop/latest/darwin). To download the version for your operating system, click one of the previous links and follow the instructions.

## Review Your Branch and Files

Firstly, carry out the following:

* authorize the application to access your GitHub account and repositories
* clone your repository to your local machine
* create a new branch
* make changes to your new branch

You're now ready to review your changes in GitHub Desktop. If you have the repository and branch chosen in your GitHub repository, you should see a screen similar to what's shown below. Below is an example I have when I created some changes to the `README.md` file of the [Vonage PHP SDK](https://github.com/vonage/vonage-php-sdk-core). At the time of writing this tutorial, Vonage is going through a rebrand, changing the Nexmo and OpenTok branding to Vonage branding. In this `README.md` file, there were still references to Nexmo, so I suggested the changes shown in the image below:

![Compare Changes in Github Desktop](/content/blog/how-to-create-a-pull-request-with-github-desktop/compare-changes-in-github-desktop.png)

## Creating a Pull Request

You can see the new changes on the GitHub Desktop application. On the left-hand side, it will show the files that have been added, removed, or altered. Tick the files you wish committed to the repository.

At the bottom left of the screen, you'll see two text boxes and a button labelled "Commit to <branch name>" Where `<branch_name>` is your branch name.

Add a commit message into the first text box. This commit message should be a very brief description of what the commit as a whole was. The second text box will allow you to be a little more descriptive on what your changes are doing. Add a description to the second text box.

An example of this is below with my suggested changes during the rebrand to Vonage:

![Writing a commit message and description](/content/blog/how-to-create-a-pull-request-with-github-desktop/write-commit-message-and-description.png)



Once you've typed your message and description, click the "Commit to <branch name>" button.

You'll then see an option appear similar to the image below where it's asking if you wish to push your commits to the origin remote. This request is where your changes are to the remote server, which will be visible by anyone with access to that repository.

![Pushing changes to remote Github repository](/content/blog/how-to-create-a-pull-request-with-github-desktop/push-changes.png)



Now, it's time to create a pull request for your changes! Once you've pushed your changes, you'll have another option to "Create a Pull Request from your current branch" as shown in the image below. If you're ready to do this, click the "Create Pull Request" button.

![Creating a Pull Request with Github Desktop](/content/blog/how-to-create-a-pull-request-with-github-desktop/create-pull-request.png)

You're then taken to a web browser to proceed with creating this pull request.

The image below shows an example of what you may expect to see in the browser. What you see may slightly differ for you depending on where you're creating the pull request. Here at Vonage, we have a specific process you're required to fill certain information out or acknowledge that you've done a particular process for the pull request to be accepted.

These requirements include:

* providing a general summary of the changes,
* describing these changes,
* why are the changes required?
* Have you added any new tests
* and have your changes broken the existing tests?

Make sure you've followed the required input/processes for that repository. Otherwise, you may risk a delay in getting your changes approved. It's better to have as much information as possible for the reviewer, than none at all.

![Image showing reviewing your code changes before submitting a pull request](/content/blog/how-to-create-a-pull-request-with-github-desktop/review-pull-request-before-submitting.png)



Once you've submitted your pull request, you will see a page that shows you the message, description and, if you scroll down, the files changed.

![Image showing the summary of the submitted Pull Request](/content/blog/how-to-create-a-pull-request-with-github-desktop/review-submitted-pull-request.png)

Some repositories have processes that run automatically as soon as a pull request is created. Make sure you check that these all pass as well (you may need to wait a few minutes after creation for the checks to finish). If these checks don't pass, make sure you revisit your changes and rectify the issue to ensure a quick release of your changes.

![Image showing all checks have passed for this Pull Request](/content/blog/how-to-create-a-pull-request-with-github-desktop/check-any-build-tests-pass.png)



## Conclusion

If you have followed this tutorial from start to finish, you have now:

* installed GitHub Desktop on your machine,
* connected it to your GitHub account,
* cloned a repository to your local machine,
* created a new branch,
* made changes to files within this branch,
* committed these changes,
* and finally created a pull request on the remote repository.

## Where Next?

Now that [Hacktoberfest](https://hacktoberfest.digitalocean.com/) has started, there’s no better time to put your Git learnings into practice! We are excited to be a [Hacktoberfest partner](https://www.nexmo.com/blog/2020/09/25/vonage-joins-hacktoberfest-2020) this year, so you might want to check out some of the [Vonage projects](https://www.nexmo.com/blog/2020/09/25/vonage-joins-hacktoberfest-2020) while you work towards your PR goal. Happy hacking!

Don't forget, if you have any questions, advice or ideas you'd like to share with the community, then please feel free to jump on our [Community Slack workspace](https://developer.nexmo.com/community/slack).

Vonage is thrilled to be a Hacktoberfest 2020 partner. We’re [no strangers to open source](https://youtu.be/zYJpYMCy6PA), with our libraries, code snippets, and demos all on GitHub. To fully immerse yourself in the festivities, be sure to check out our [Hacktoberfest page](https://nexmo.dev/2GZcyHc) for details on all that we have planned!