---
title: Send SMS with GitHub Actions
description: Make sure your boss knows you're working by sending them automated
  text messages each time you check in code with GitHub Actions and Nexmo.
thumbnail: /content/blog/send-sms-github-actions-dr/Send-SMS-with-GitHub-Actions.png
author: cr0wst
published: true
published_at: 2019-02-08T19:51:08.000Z
updated_at: 2021-05-12T02:58:15.168Z
category: tutorial
tags:
  - sms-api
comments: true
redirect: ""
canonical: ""
---
Bosses come in all shapes and sizes. Some are hands-off, letting you work to the best of your abilities. Others, take a more direct approach and measure your accomplishments solely through the code that you produce. After all, if you're not writing code then why are we paying you?

Want to show your boss just how hard you're working? Absolutely! With the power of Nexmo and GitHub Actions, you can make sure that an excellent annual review and a sizable pay raise are in order.

## Prerequisites

<sign-up number></sign-up>

At the time of writing, GitHub Actions is currently in public beta. If you aren't a member of the beta, you will need to [apply for the beta](https://github.com/features/actions/signup/).

## What is GitHub Actions?

[GitHub Actions](https://developer.github.com/actions/) is a new tool from GitHub in which individual actions are combined to make a workflow that performs on different [trigger event types](https://developer.github.com/v3/activity/events/types/).

Each action is a Docker container containing a single entry point. The action lives inside of a `Dockerfile` with `LABEL` instructions providing information about the action.

For example, let's say you wanted to print out the name of the user (referred to as the GitHub Actor) to the console. You would create a repository that contains a `Dockerfile` with the following contents:

```dockerfile
FROM alpine:3.8

LABEL "com.github.actions.name"="Print GitHub Actor"
LABEL "com.github.actions.description"="Print the GITHUB_ACTOR environment variable to the console."
LABEL "com.github.actions.icon"="user"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/cr0wst/display-github-actor-action"
LABEL "homepage"="https://smcrow.net"
LABEL "maintainer"="Steve Crow <steve.crow@nexmo.com>"

ENTRYPOINT ["sh", "-c", "echo $GITHUB_ACTOR"]
```

This entire action runs the command `echo $GITHUB_ACTOR` where `$GITHUB_ACTOR` is an environment variable that GitHub provides to the container containing the user who triggered the action.

> For more information on Docker see this [Docker Overview](https://docs.docker.com/engine/docker-overview/).

The advantage of GitHub Actions comes in creating reusable actions that others can use in their workflows.

## Creating Your First Workflow

For this guide you will be creating a new repository with a workflow that sends your boss a text message every time a push is received.

### Create a Repository

First, start by creating a new repository:

![Creating a new repository on GitHub](/content/blog/send-sms-with-github-actions/create-new-repo.png "Creating a new repository on GitHub")

### Create a New Workflow

After you create your repository, you will need to navigate to the actions tab where you will see a button to create a new workflow:

![Create your first workflow on GitHub](/content/blog/send-sms-with-github-actions/create-first-workflow.png "Create your first workflow on GitHub")

Workflows can be created in either the graphical user interface (GUI) or by creating a `workflow` file.

### Link the Action Trigger to an Action

Drag the blue connector down to create your first action.

![Drag the connector to create a new action](/content/blog/send-sms-with-github-actions/create-action.gif "Drag the connector to create a new action")

The action that you will be bringing in is the [Nexmo SMS Action](https://github.com/nexmo-community/nexmo-sms-action). This action uses the [Nexmo CLI](https://github.com/Nexmo/nexmo-cli) to send text messages.

In the "Find or enter an action..." box put `nexmo-community/nexmo-sms-action@master` and click the use button.

![Enter the Nexmo Send SMS Action](/content/blog/send-sms-with-github-actions/choose-nexmo-action.png "Enter the Nexmo Send SMS Action")

This action requires three secret variables to be defined:

* `NEXMO_API_KEY` containing your Nexmo API Key.
* `NEXMO_API_SECRET` containing your Nexmo API Secret.
* `NEXMO_NUMBER` containing the number from which to send the message.

I recommend storing your boss' number in another secret variable.

Scroll down and enter your secret variables. I will be using the `BOSS_NUMBER` environment variable to store the number that will be receiving the SMS. 

For testing purposes, and probably production purposes, I wouldn't recommend using your boss's *actual* number. Try it with your phone number first. The phone number must be in international format without any spaces or special characters separating the numbers. For example, 15551239876.

![Define your secrets](/content/blog/send-sms-with-github-actions/define-secrets.gif "Define your secrets")

The command works by taking an argument in the form of `RECIPIENT_NUMBER The contents of the message.` You can use variables like `$BOSS_NUMBER` and `$GITHUB_ACTOR` in the arguments, which resolve upon the execution of the action.

Now, enter the following in the `args` box:

```text
$BOSS_NUMBER Hey boss! Just letting you know that I, $GITHUB_ACTOR, just pushed some code.
```

Now you can hit the done button and save your action with the "start commit" button in the upper-right corner:

![Save your action](/content/blog/send-sms-with-github-actions/save-changes.png "Save your action")

Saving the action is a `push` in and of itself. If you look in the actions tab, you can see the status of your action.

![See the status of the action in progress](/content/blog/send-sms-with-github-actions/workflow-in-progress.png "See the status of the action in progress")

You should receive a text message upon saving your action and on any additional pushes to the repository.

![Text message which states that you are working.](/content/blog/send-sms-with-github-actions/hey-boss-sms.png "Text message which states that you are working.")

## Conclusion

Soon enough your boss will start to realize the true value you bring to the company. Your work will be filling up their text message inbox and sending them into a state of "my direct reports are amazing" euphoria.

![You being praised by all of your bosses.](/content/blog/send-sms-with-github-actions/happy-boss.png "You being praised by all of your bosses.")

Check out the [hey-boss-im-working](https://github.com/cr0wst/hey-boss-im-working/) repository for a full example of this workflow. You can also find it as part of our [Nexmo Extend Catalog](https://developer.nexmo.com/extend/).