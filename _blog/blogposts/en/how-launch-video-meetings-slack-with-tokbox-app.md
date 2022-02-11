---
title: How to Launch Video Meetings in Slack with Vonage
description: The TokBox app is now available in the Slack Directory. Create a
  custom live video experience for end users without ever having to leave your
  slack channel.
thumbnail: /content/blog/how-launch-video-meetings-slack-with-tokbox-app/Blog_Launch-Video-Meetings_1200x600.png
author: manik
published: true
published_at: 2019-02-01T18:21:58.000Z
updated_at: 2021-05-21T06:20:04.862Z
category: tutorial
tags:
  - video-api
  - slack
comments: true
redirect: ""
canonical: ""
---
Slack is a popular workplace collaboration tool that has an estimated [10+ million daily active users.](https://slackhq.com/slack-has-10-million-daily-active-users) 

With so many people using Slack, including those within our own developer community, bringing our customizable live video experience with the Vonage-Slack integration app was a natural progression. Elevating the developer experience is at the forefront of everything we do, from our [developer center](https://tokbox.com/developer/) to our [Vonage Video API platform.](https://tokbox.com/platform) 

The Vonage-Slack integration offers an easy way for you to launch a customized live video experience on Slack for end users, without ever having to leave their workspace.

![Vonage Slack Integration](/content/blog/how-to-launch-video-meetings-in-slack-with-vonage/image2-1.png "Vonage Slack Integration")

While the Vonage Video app offers a default live video meeting web experience, it is a simple starting point.

You can easily implement your own branded and full-featured video conferencing application using the Vonage Video SDKs. With one command, our new slack integration provides users with a seamless way to launch a video session.

## Configuring Your Vonage Video App on Slack

To get started, you will need to [sign up for a Vonage account](https://tokbox.com/account/user/signup). (Need help getting started? Try our fast track, [here](https://tokbox.com/developer/get-started-options/).) Once this is done, you can configure TokBox and create meetings with a few simple commands. 

When you use this command: `/tokbox`, it enables you to configure the app, while also allowing your workspace users to generate unique links for live video meetings that are Vonage-hosted. 

Here are a few more commands that you need to know:

<pre class="lang:default decode:true ">/tokbox config  <apikey> <secret></pre>

Set the OpenTok Project API key and secret. If the workspace already has the app configured, it will be overwritten with new credentials.

<pre class="lang:default decode:true ">/tokbox config</pre>

Display the current Project API key. The response is visible only for the user who types the command.

<pre class="lang:default decode:true ">/tokbox</pre>

Create a new meeting. The meeting link will be posted in the channel where the user types the command.

<pre class="lang:default decode:true ">/tokbox remove</pre>

Remove the current Video Project API Key and secret.

![Remove the current Video Project API Key and secret.](/content/blog/how-to-launch-video-meetings-in-slack-with-vonage/image2.png "Remove the current Video Project API Key and secret.")

And now you're ready to elevate collaboration with customized live video meetings, all without ever leaving your Slack workspace.

**Already use Vonage Video?** [Click here to add Slack](https://nexmo.slack.com/oauth?client_id=2321281313.377902837510&redirect_uri=https%3A%2F%2Ftokbox-meet.herokuapp.com%2Fauth%2Fredirect&state=&scope=commands&team=&install_redirect=&single_channel=0). 

**Ready to use Vonage Video?** [Click here to visit our developer center](https://tokbox.com/developer/) and receive your free API key.