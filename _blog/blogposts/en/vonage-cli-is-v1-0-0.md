---
title: Vonage CLI is v1.0.0
description: Today, our Vonage CLI (Command Line Interface) is in v1.0.0. See
  new features and find out what happens to the Nexmo CLI.
thumbnail: /content/blog/vonage-cli-is-v1-0-0/dev_sdk-updates_1000x420.png
author: kellyjandrews
published: true
published_at: 2021-09-21T14:16:46.129Z
updated_at: 2021-09-21T06:50:42.941Z
category: release
tags:
  - cli
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
Today marks a very proud moment for everyone here. Our Vonage CLI (Command Line Interface) is now v1.0.0. I honestly couldn't be happier with how things have gone so far, and I know they will only get better from here. 

## What's In v1?

### Applications
You can now manage your applications from the command line. The Vonage CLI will allow you to create, update, link numbers to, and even delete applications. 

```shell
vonage apps --help
vonage apps:create
```
You will also be able to manage application users, in-app conversations, and conversation members.

### Numbers
At the core of Vonage is the telephone - it's how I first learned of them 17 years ago. The Vonage CLI will let you buy or cancel phone numbers, search our inventory, and view yours. 

```shell
vonage numbers --help
vonage numbers:search US
```

### Number Insights

Vonage's Number Insight API delivers real-time intelligence about a phone number's validity, reachability, and roaming status. You can now have these insights on the command line - in basic, standard and advanced. 

```shell
vonage numberinsight --help
```

### JWT and Friends
And lastly, the Vonage CLI can create a JWT in your terminal for testing and development. You can also check your account balance. 

```shell
vonage jwt --help
vonage balance --help
```

## Getting Started

The latest core is on npm and you can install it with:

```
npm install -g @vonage/cli
```

Once you have that installed, you will need to go to your [dashboard](https://dashboard.nexmo.com/) to grab your API key and secret, and set your config with the following:

```shell
vonage config:set --apiKey=XXXXXX --apiSecret=XXXXXX
```

Now you are set to start exploring using `--help, -h` on any command. 

## What happens to the Nexmo CLI?
The Nexmo CLI will move into maintenance mode and receive bug fixes for the next year—until September 21, 2022. At that time, it will officially deprecate and will no longer be supported. 

## Final Request
I only want the best tools here, but I can't do it without you. Your feedback and support are fantastic, and with all of us working together, we can make the future of our CLI something special. 

Feel free to drop me a line [@kellyjandrews](https://twitter.com/kellyjandrews), send me an [issue](https://github.com/Vonage/vonage-cli/issues), or email us at devrel@vonage.com.
